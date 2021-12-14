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
#/home/qbt/cg_qbt.sh "%N" "%F" "%C" "%Z" "%I" "%L"
torrent_name=$1 # %N：Torrent名称=mide-007-C
content_dir=$2 # %F：内容路径=/home/btzz/mide-007-C
#files_num=$3 # %C
#torrent_size=$4 #%Z
file_hash=$5 #%I
file_category=$6 #%L：分类
qb_username="admin"
qb_password="adminadmin"
qb_web_url="http://$(hostname -I | awk '{print $1}'):8070"
rclone_remote="upsa"

################## 检查qbt安装情况 ##################
check_qbt() {
  if [ -z "$(command -v qbittorrent-nox)" ]; then
    clear
    apt-get remove qbittorrent-nox -y && rm -f /usr/bin/qbittorrent-nox
    if [[ $(uname -m 2> /dev/null) = x86_64 ]]; then
      wget -qO /usr/bin/qbittorrent-nox https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox && chmod +x /usr/bin/qbittorrent-nox
    elif [[ $(uname -m 2> /dev/null) = aarch64 ]]; then
      wget -qO /usr/bin/qbittorrent-nox https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/aarch64-qbittorrent-nox && chmod +x /usr/bin/qbittorrent-nox
    fi
    #备份配置文件：cd /home && tar -cvf qbt_bat.tar qbt
    #还原qbt配置：
    wget -qN https://github.com/cgkings/script-store/raw/master/config/qbt_bat.tar && rm -rf /home/qbt && tar -xvf qbt_bat.tar -C /home && rm -f qbt_bat.tar && chmod -R 755 /home/qbt
    #建立qbt服务
    cat > '/etc/systemd/system/qbt.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --webui-port=8070 --profile=/home/qbt -d
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload && systemctl enable qbt.service && systemctl restart qbt.service
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done！
-----------------------------------------------------------------------------
程序名称：qBittorrent
版本名称：4.3.6
程序目录：/usr/bin/qbittorrent-nox
服务地址：/etc/systemd/system/qbt.service
-----------------------------------------------------------------------------
EOF
  fi
}

Uninstall_qbt() {
  systemctl stop qbt && rm -f /etc/systemd/system/qbt.service && rm -f /usr/bin/qbittorrent-nox
}

check_mktorrent() {
  if [ -z "$(command -v mktorrent)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到mktorrent包.正在安装..."
    sleep 1s
    git clone https://github.com/Rudde/mktorrent.git && cd mktorrent && make && make install
    echo -e "${curr_date} [INFO] mktorrent 安装完成!" >> /root/install_log.txt
    echo
  fi
}

################## qbt删除种子 ##################
qb_del() {
  cookie=$(curl -si --header "Referer: ${qb_web_url}" --data "username=${qb_username}&password=${qb_password}" "${qb_web_url}/api/v2/auth/login" | grep -P -o 'SID=\S{32}')
  if [ -n "${cookie}" ]; then
    curl -s "${qb_web_url}/api/v2/torrents/delete?hashes=${file_hash}&deleteFiles=true" --cookie "$cookie"
    cat >> /home/qbt/qb.log << EOF
$(date '+%Y-%m-%d %H:%M:%S') [INFO] ✔ login  done ${cookie}
$(date '+%Y-%m-%d %H:%M:%S') [INFO] ✔ delete done ${content_dir}
EOF
  else
    cat >> /home/qbt/qb_fail.log << EOF
--------------------------------------------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [ERROR] ❌ 登录删除失败！:
分类名称：${file_category}
种子名称：${torrent_name}
文件哈希: ${file_hash}
cookie : ${cookie}
--------------------------------------------------------------------------------------------------------------
EOF
    exit 1
  fi
}

# ################## 检查上传类型：文件or目录 ##################
# check_content_dir() {
#   if [ -f "${content_dir}" ]; then
#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 类型：文件" >> ${log_dir}/qb.log
#     type="file"
#   elif [ -d "${content_dir}" ]; then
#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] 类型：目录" >> ${log_dir}/qb.log
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
分类名称：${file_category}
种子名称：${torrent_name}
文件哈希: ${file_hash}
--------------------------------------------------------------------------------------------------------------
EOF
  fi
}

################## 主执行模块 ##################
check_rclone
check_mktorrent
check_qbt
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
  elif [ "${file_category}" == "00pt-for-down" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
    rclone_upload
  elif [ "${file_category}" == "00pt-for-up" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
  fi
fi
#获取特定种子的分享率命令：curl -s "http://205.185.127.160:8070/api/v2/torrents/properties?hash=d24f98e3b90560629456424fa63833126396ff3a" --cookie "SID=h31J/C2MEOOzu0b3hd/URtmKi7AwIJcI" | jq .share_ratio
#逐一查看未分类中的已完成种子的分享率 curl -s "http://51.158.153.55:8070/api/v2/torrents/info?filter=completed&category=" --cookie "SID=1Np3WU0feLDOcCtQWBp9cRAqFiQ2vBrj"|jq ".[0]|.ratio"

#fclone move /home/qbt/qBittorrent/downloads/chs/OKSN-339 upsa:{1hzETacfMuAIBAsHqKIys-98glIMRb-iv} --use-mmap --stats=10s --stats-one-line -vP --transfers=1 --min-size 100M --log-file=/home/qbt/bt_upload.log