#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_qbt.sh)
# File Name: cg_qbt.sh
# Author: cgking
# Created Time : 2021.5.28
# Description:qbittonrrent脚本
# System Required: Debian/Ubuntu
# Version: final
#=============================================================
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor
#/home/qbt/cg_qbt.sh "%N" "%F" "%C" "%Z" "%I" "%L"
torrent_name=$1 # %N：Torrent名称=mide-007-C
content_dir=$2 # %F：内容路径=/home/btzz/mide-007-C
files_num=$3 # %C
torrent_size=$4 #%Z
file_hash=$5 #%I
file_category=$6 #%L：分类=btzz

qb_version="4.3.5.10"
qb_username="cgking"
qb_password="340622"
qb_web_url="$(hostname -I | awk '{print $1}'):8070"
rclone_remote="upsa"

################## 检查qbt安装情况 ##################
check_qbt() {
    if [ -z "$(command -v qbittorrent-nox)" ]; then
    clear
    #apt-get remove qbittorrent-nox -y
    #获取最新版本号，并下载安装
    # qbtver=$(curl -s "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    wget -qN https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-$qb_version/qbittorrent-nox_x86_64-linux-musl_static.zip
    unzip -o qbittorrent*.zip && rm -f qbittorrent*.zip
    mv -f qbittorrent-nox /usr/bin/
    chmod +x /usr/bin/qbittorrent-nox
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
程序名称：qBittorrent-Enhanced-Edition
版本名称：4.3.5.10
程序目录：/usr/bin/qbittorrent-nox
服务地址：/etc/systemd/system/qbt.service
-----------------------------------------------------------------------------
EOF
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
  if [ -z "${file_category}" ]; then
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
  elif [ "${file_category}" == "chs" ]; then
    rclone_dest="{1hzETacfMuAIBAsHqKIys-98glIMRb-iv}"
  elif [ "${file_category}" == "fc2" ]; then
    rclone_dest="{1yIDI4ZMWpTiFecLrJwLb6hgJwfjWG18N}"
  elif [ "${file_category}" == "suren" ]; then
    rclone_dest="{1yIDI4ZMWpTiFecLrJwLb6hgJwfjWG18N}"
  elif [ "${file_category}" == "pohuaiban" ]; then
    rclone_dest="{1S-b-47Pe54j6wh6ph5t6eY5ZjZqnacqw}"
  else
    rclone_dest="{0AAa0DHcTPGi9Uk9PVA}"
  fi
  cat >> /home/qbt/qb.log << EOF
-----------------------------------------------------------------------------
种子名称：${torrent_name}
内容路径：${content_dir}
文件数量：${files_num}
文件大小：${torrent_size} Bytes
文件哈希: ${file_hash}
分类名称：${file_category}
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] $torrent_name 分类=$file_category 开始上传
-----------------------------------------------------------------------------
EOF
  fclone move "$content_dir" "$rclone_remote":"$rclone_dest" --use-mmap --stats=10s --stats-one-line -vvP --min-size 100M --log-file=/home/qbt/bt_upload.log
  RCLONE_EXIT_CODE=$?
  if [ ${RCLONE_EXIT_CODE} -eq 0 ]; then
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Upload done: ${torrent_name} -> ${rclone_remote}:${rclone_dest}" >> /home/qbt/qb.log
  else
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Upload failed: ${torrent_name}" >> /home/qbt/qb.log
    exit 1
  fi
}

################## rclone上传模块 ##################
qb_del() {
  cookie=$(curl -i --header "Referer: ${qb_web_url}" --data "username=${qb_username}&password=${qb_password}" "${qb_web_url}/api/v2/auth/login" | grep -P -o 'SID=\S{32}')
  if [ -n "${cookie}" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 登录成功！cookie:${cookie}" >> /home/qbt/qb.log
    curl "${qb_web_url}/api/v2/torrents/delete?hashes=${file_hash}&deleteFiles=true" --cookie "$cookie"
    rm -f "$content_dir"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] 删除成功！种子名称:${torrent_name}" >> /home/qbt/qb.log
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] 登录失败！" >> /home/qbt/qb.log
    exit 1
  fi
}

################## 主执行模块 ##################
check_rclone
check_qbt
if [ ! -d /home/qbt ]
then
	mkdir -p /home/qbt
fi
if [ -z "$content_dir" ]; then
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] 无种子信息，脚本停止运行" >> /home/qbt/qb.log
  exit 1 #异常退出
else
  rclone_upload
  qb_del
fi