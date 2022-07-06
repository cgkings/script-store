#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_qbt)
# File Name: cg_qbt.sh
# Author: cgking
# Created Time : 2021.6.21
# Description:qbittonrrent脚本
# System Required: Debian/Ubuntu
# Version: final
#=============================================================

################## 前置变量设置 ##################
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
#/home/qbt/cg_qbt.sh "%N" "%F" "%C" "%Z" "%I" "%L"
torrent_name=$1 # %N: Torrent名称=mide-007-C
content_dir=$2 # %F: 内容路径=/home/btzz/mide-007-C
#files_num=$3 # %C
#torrent_size=$4 #%Z
file_hash=$5 #%I
file_category=$6 #%L: 分类
qpt_username="admin"
qpt_password="adminadmin"
aria2_rpc_secret="abc12345678"
ip_addr=$(hostname -I | awk '{print $1}')
qb_web_url="http://$ip_addr:8070"
tr_web_url="http://$ip_addr:9070"
rclone_remote="upsa"

################## 检查安装qbt ##################
check_qbt() {
  if [ -z "$(command -v qbittorrent-nox)" ] && [ -z "$(docker ps -a | grep qbittorrent)" ]; then
    clear
    docker run -d \
      --name=qbittorrent \
      -e PUID=$UID \
      -e PGID=$GID \
      -e TZ=Asia/Shanghai \
      -e WEBUI_PORT=8070 \
      -p 8070:8070 \
      -p 51414:51414 \
      -p 51414:51414/udp \
      -v /home/qbt/config:/config \
      -v /home/qbt/downloads:/downloads \
      --restart unless-stopped \
      lscr.io/linuxserver/qbittorrent:latest
    #备份配置文件: cd /home/qbt/config && zip -qr qbt_bat.zip qBittorrent
    #还原qbt配置:
    wget -qN https://github.com/cgkings/script-store/raw/master/config/qbt_bat.zip && rm -rf /home/qbt/config/qBittorrent && unzip -q qbt_bat.zip -d /home/qbt/config && rm -f qbt_bat.zip
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done!
-----------------------------------------------------------------------------
容器名称: qbittorrent
网页地址: ${qb_web_url}
默认用户: admin
默认密码: adminadmin
下载目录: /home/qbt/downloads
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt
  fi
}

################## 检查安装transmission ##################
check_tr() {
  if [ -z "$(command -v transmission-daemon)" ] && [ -z "$(docker ps -a | grep transmission)" ]; then
    docker run -d --name="transmission" \
      -p 51413:51413 \
      -p 51413:51413/udp \
      -p 9070:9070 \
      -e USERNAME=admin \
      -e PASSWORD=adminadmin \
      -v /data/downloads:/home/tr/downloads \
      -v /data/transmission:/home/tr/config \
      --restart=always \
      helloz/transmission
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done!
-----------------------------------------------------------------------------
容器名称: transmission
网页地址: ${tr_web_url}
默认用户: admin
默认密码: adminadmin
下载目录: /home/tr/downloads
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt
  fi
}

################## 检查安装aria2 ##################
check_aria2() {
  if [ -z "$(docker ps -a | grep aria2)" ]; then
    docker run -d \
      --name aria2-pro \
      --restart unless-stopped \
      --log-opt max-size=1m \
      --network host \
      -e PUID=$UID \
      -e PGID=$GID \
      -e RPC_SECRET=$aria2_rpc_secret \
      -e RPC_PORT=6800 \
      -e LISTEN_PORT=6888 \
      -v /root/aria2:/config \
      -v /home/dl:/downloads \
      -v /usr/bin/fclone:/usr/local/bin/rclone \
      -v /home/vps_sa/ajkins_sa:/home/vps_sa/ajkins_sa \
      -e SPECIAL_MODE=rclone \
      p3terx/aria2-pro
    cp ~/.config/rclone/rclone.conf ~/aria2
    [ -z "$(grep "$rclone_remote" ~/aria2/script.conf)" ] && sed -i 's/drive-name=.*$/drive-name='$rclone_remote'/g' ~/aria2/script.conf
    docker run -d \
      --name ariang \
      --restart unless-stopped \
      --log-opt max-size=1m \
      -p 6880:6880 \
      p3terx/ariang
    aria2_rpc_secret_bash64=$(echo $aria2_rpc_secret | base64 | tr -d "\n")
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done！
-----------------------------------------------------------------------------
容器名称: aria2-pro & ariang
网页地址: ${tr_web_url}
默认用户: admin
默认密码: adminadmin
下载目录: /home/tr/downloads
访问地址: http://$ip_addr:6880/#!/settings/rpc/set/http/$ip_addr/6800/jsonrpc/$aria2_rpc_secret_bash64
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt
  fi
}

################## 检查安装mktorrent ##################
check_mktorrent() {
  if [ -z "$(command -v mktorrent)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到mktorrent包.正在安装..."
    sleep 1s
    git clone https://github.com/Rudde/mktorrent.git && cd mktorrent && make && make install
    echo -e "${curr_date} [INFO] mktorrent 安装完成!" >> /root/install_log.txt
    echo
  fi
}

################## 卸载qbt ##################
Uninstall_qbt() {
  systemctl stop qbt && rm -f /etc/systemd/system/qbt.service && rm -f /usr/bin/qbittorrent-nox
}

################## 卸载transmission-daemon ##################
Uninstall_transmission-daemon() {
  systemctl disable transmission-daemon
  service transmission-daemon stop
  bash <(curl -sL https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh) << EOF
1
EOF
  sudo apt remove -y transmission-daemon
  sudo apt autoremove -y
  rm -f /lib/systemd/system/transmission-daemon.service
}
################## qbt删除种子 ##################
qb_del() {
  cookie=$(curl -si --header "Referer: ${qb_web_url}" --data "username=${qpt_username}&password=${qpt_password}" "${qb_web_url}/api/v2/auth/login" | grep -P -o 'SID=\S{32}')
  if [ -n "${cookie}" ]; then
    curl -s "${qb_web_url}/api/v2/torrents/delete?hashes=${file_hash}&deleteFiles=true" --cookie "$cookie"
    cat >> /home/qbt/qb.log << EOF
$(date '+%Y-%m-%d %H:%M:%S') [INFO] ✔ login  done ${cookie}
$(date '+%Y-%m-%d %H:%M:%S') [INFO] ✔ delete done ${content_dir}
EOF
  else
    cat >> /home/qbt/qb_fail.log << EOF
-----------------------------------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [ERROR] ❌ 登录删除失败！:
分类名称: ${file_category}
种子名称: ${torrent_name}
文件哈希: ${file_hash}
cookie : ${cookie}
-----------------------------------------------------------------------------------------------------
EOF
    exit 1
  fi
}

# ################## 检查上传类型: 文件or目录 ##################
# check_content_dir() {
#   if [ -f "${content_dir}" ]; then
#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 类型: 文件" >> ${log_dir}/qb.log
#     type="file"
#   elif [ -d "${content_dir}" ]; then
#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 类型: 目录" >> ${log_dir}/qb.log
#     type="dir"
#   else
#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 未知类型，取消上传" >> ${log_dir}/qb.log
#   fi
# }

################## rclone上传模块 ##################
rclone_upload() {
  fclone copy "$content_dir" "$rclone_remote":"$rclone_dest" --use-mmap --stats=10s --stats-one-line -vP --transfers=1 --min-size 100M --ignore-existing --log-file=/home/qbt/bt_upload.log
  RCLONE_EXIT_CODE=$?
  if [ ${RCLONE_EXIT_CODE} -eq 0 ]; then
    cat >> /home/qbt/qb.log << EOF
--------------------------------------------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] ✔ Upload done ${file_category}:${torrent_name} ==> ${rclone_remote}:${rclone_dest}
EOF
  else
    cat >> /home/qbt/qb_fail.log << EOF
--------------------------------------------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [ERROR] ❌ Upload failed:"$content_dir" "$rclone_remote":"$rclone_dest"
分类名称: ${file_category}
种子名称: ${torrent_name}
文件哈希: ${file_hash}
--------------------------------------------------------------------------------------------------------------
EOF
  fi
}

################## 主执行模块 ##################
check_rclone
check_qbt
# check_transmission
check_mktorrent
mkdir -p /home/qbt
if [ -z "$content_dir" ]; then
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] 无种子信息，脚本停止运行" >> /home/qbt/qb.log
  exit 0
else
  if [ -z "${file_category}" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
    rclone_upload
    qb_del
  elif [ "${file_category}" == "rss-chs" ]; then
    rclone_dest="{1hzETacfMuAIBAsHqKIys-98glIMRb-iv}"
    rclone_upload
    qb_del
  elif [ "${file_category}" == "rss-fc2" ]; then
    rclone_dest="{1yIDI4ZMWpTiFecLrJwLb6hgJwfjWG18N}"
    rclone_upload
    qb_del
  elif [ "${file_category}" == "rss-suren" ]; then
    rclone_dest="{1yIDI4ZMWpTiFecLrJwLb6hgJwfjWG18N}"
    rclone_upload
    qb_del
  elif [ "${file_category}" == "pohuaiban" ]; then
    rclone_dest="{1S-b-47Pe54j6wh6ph5t6eY5ZjZqnacqw}"
    rclone_upload
    qb_del
  elif [ "${file_category}" == "00PT_for_down" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
    rclone_upload
  elif [ "${file_category}" == "00PT_for_up" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
  elif [ "${file_category}" == "00seed_save" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
  fi
fi
#获取特定种子的分享率命令: curl -s "http://205.185.127.160:8070/api/v2/torrents/properties?hash=d24f98e3b90560629456424fa63833126396ff3a" --cookie "SID=h31J/C2MEOOzu0b3hd/URtmKi7AwIJcI" | jq .share_ratio
#逐一查看未分类中的已完成种子的分享率 curl -s "http://51.158.153.55:8070/api/v2/torrents/info?filter=completed&category=" --cookie "SID=1Np3WU0feLDOcCtQWBp9cRAqFiQ2vBrj"|jq ".[0]|.ratio"

#fclone move /home/qbt/qBittorrent/downloads/chs/OKSN-339 upsa:{1hzETacfMuAIBAsHqKIys-98glIMRb-iv} --use-mmap --stats=10s --stats-one-line -vP --transfers=1 --min-size 100M --log-file=/home/qbt/bt_upload.log
