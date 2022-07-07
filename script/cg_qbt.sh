#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_qbt)
# File Name: cg_qbt.sh
# Author: cgking
# Created Time : 2022.7.7
# Description:qbittonrrent脚本
# System Required: Debian/Ubuntu
# Version: final
#=============================================================

#set -e #异常则退出整个脚本,避免错误累加
#set -x #脚本调试,逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
#/home/qbt/cg_qbt.sh "%N" "%F" "%C" "%Z" "%I" "%L"
torrent_name=$1 # %N: Torrent名称=mide-007-C
content_dir=$(echo "$2" | sed "s/downloads/home\/qbt\/downloads/g") # %F: 内容路径=/home/btzz/mide-007-C
#files_num=$3 # %C
#torrent_size=$4 #%Z
file_hash=$5 #%I
file_category=$6 #%L: 分类
qpt_username="admin"
qpt_password="adminadmin"
ip_addr=$(hostname -I | awk '{print $1}')
qb_web_url="http://$ip_addr:8070"
rclone_remote="upsa"

################## 检查安装qbt ##################
check_qbt() {
  if [ -z "$(command -v qbittorrent-nox)" ] && [ -z "$(docker ps -a | grep qbittorrent)" ]; then
    clear
    echo -e "${curr_date} [DEBUG] 未找到qbittorrent.正在安装..."
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
    #备份配置文件: cd /home && zip -qr qbt_bat.zip qbt
    #还原qbt配置:
    docker stop qbittorrent
    wget -qN https://github.com/cgkings/script-store/raw/master/config/qbt_bat.zip && rm -rf /home/qbt && unzip -q qbt_bat.zip -d /home && rm -f qbt_bat.zip
    wget -qN https://github.com/cgkings/script-store/raw/master/script/cg_qbt.sh -O /home/qbt/cg_qbt.sh && chmod 755 /home/qbt/cg_qbt.sh
    docker start qbittorrent
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
${curr_date} [INFO] install done!
-----------------------------------------------------------------------------
容器名称: qbittorrent
网页地址: ${qb_web_url}
默认用户: admin
默认密码: adminadmin
下载目录: /home/qbt/downloads
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt | sed '/.*downloads.*/q'
  fi
}

################## 检查安装mktorrent ##################
check_mktorrent() {
  if [ -z "$(command -v mktorrent)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到mktorrent包.正在安装..."
    sleep 1s
    git clone https://github.com/Rudde/mktorrent.git && cd mktorrent && make && make install
    echo -e "${curr_date} [INFO] mktorrent 安装完成!" | tee -a /root/install_log.txt
    echo
  fi
}

################## 检查安装autoremove-torrents ##################
check_amt() {
  if [ -z "$(command -v autoremove-torrents)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到autoremove-torrents.正在安装..."
    sleep 1s
    pip install autoremove-torrents && mkdir -p /home/amt
    cat > /home/amt/config.yml << EOF
# 任务模板: YAML语法,不能使用tab,要用空格来缩进,每个层级要用两个空格缩进,否则必定报错！
# Part 1: 任务块名称,左侧不能有空格
my_task:
# Part 2: BT客户端登录信息,可以管理其他机的客户端
  client: qbittorrent
  host: http://127.0.0.1:8070
  username: admin
  password: adminadmin
# Part 3: 策略块（删除种子的条件）
  strategies:
    # Part I: 策略名称
    strategy1:
      # Part II: 筛选过滤器,过滤器定义了删除条件应用的范围,多个过滤器是且的关系,顺序执行过滤
      excluded_status:
        - Downloading
      excluded_trackers:
        - tracker.totheglory.im
      # Part III: 删除条件,多个删除条件之间是或的关系,顺序应用删除条件
      last_activity: 900
      free_space:
        min: 100
        path: /home/qbt/downloads
        action: remove-inactive-seeds
    strategy2:
      status: Downloading
      remove: last_activity > 900 or download_speed < 50
      #delete_data: true
    # 一个任务块可以包括多个策略块...
# Part 4: 是否在删除种子的同时也删除数据。如果此字段未指定,则默认值为false
  delete_data: true
# 该模板策略块1为:对于非下载状态且非TTG的种子,删除900秒未活动的种子,或硬盘小于100G时,尽量删除不活跃种子
EOF
    echo -e "${curr_date} [INFO] autoremove-torrents 安装完成!" | tee -a /root/install_log.txt
    # crontab -l | {
    #                cat
    #                     echo "*/15 * * * * /usr/bin/autoremove-torrents --conf=/home/amt/config.yml"
    # }                                            | crontab -
  fi
}

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

################## 主执行模块 ##################
check_mktorrent
check_amt
check_qbt
if [ -z "${file_hash}" ]; then
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] 无种子信息,脚本停止运行" >> /home/qbt/qb.log
  exit 0
else
  if [ -z "${file_category}" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
    rclone_upload
    qb_del
  elif [ "${file_category}" == "98t-c" ]; then
    rclone_dest="{1hzETacfMuAIBAsHqKIys-98glIMRb-iv}"
    rclone_upload
    qb_del
  elif [ "${file_category}" == "1.pt-down" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
    rclone_upload
  elif [ "${file_category}" == "2.pt-up" ] || [ "${file_category}" == "3.pt-mt" ] || [ "${file_category}" == "4.pt-ttg" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
  fi
fi
#获取特定种子的分享率命令: curl -s "http://205.185.127.160:8070/api/v2/torrents/properties?hash=d24f98e3b90560629456424fa63833126396ff3a" --cookie "SID=h31J/C2MEOOzu0b3hd/URtmKi7AwIJcI" | jq .share_ratio
#逐一查看未分类中的已完成种子的分享率 curl -s "http://51.158.153.55:8070/api/v2/torrents/info?filter=completed&category=" --cookie "SID=1Np3WU0feLDOcCtQWBp9cRAqFiQ2vBrj"|jq ".[0]|.ratio"