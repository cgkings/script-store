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
#bash /root/qb_auto.sh  "%N" "%F" "%R" "%D" "%C" "%Z" "%I" "%L"
""
torrent_name=$1 # %N：Torrent名称=mide-007-C
content_dir=$2 # %F：内容路径=/home/btzz/mide-007-C
root_dir=$3 # %R：根目录=/home/btzz/mide-007-C
save_dir=$4 # %D：保存路径=/home/btzz/
files_num=$5 # %C
torrent_size=$6 #%Z
file_hash=$7 #%I
file_category=$8 #%L：分类=btzz

qb_version="4.3.5.10"
qb_username="hostloc"
qb_password="hostloc.com"
qb_web_url="http://localhost:8080"
leeching_mode="true"
log_dir="/root/qbauto"
rclone_dest="gdrive"
rclone_parallel="32"
auto_del_flag="rclone"

################## 检查qbt安装情况 ##################
check_qbt() {
    if [ -z "$(command -v qbittorrent-nox)" ]; then
    clear
    apt-get remove qbittorrent-nox -y
    #获取最新版本号，并下载安装
    # qbtver=$(curl -s "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    wget -qN https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-$qb_version/qbittorrent-nox_x86_64-linux-musl_static.zip
    unzip -o qbittorrent*.zip && rm -f qbittorrent*.zip
    mv -f qbittorrent-nox /usr/bin/
    chmod +x /usr/bin/qbittorrent-nox
    #备份配置文件：cd /home && tar -cvf qbt_bat20210528.tar qbt
    #还原qbt配置：
    wget && rm -rf /home/qbt && tar -xvf qbt_bat20210528.tar -C /home && rm -f qbt_bat20210528.tar && chmod 755 /home/qbt
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
    clear
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
rclone_move() {
  if [ ${type} == "file" ]; then
    rclone_copy_cmd=$(rclone -v copy --transfers ${rclone_parallel} --log-file ${log_dir}/qbauto_copy.log "${content_dir}" ${rclone_dest}:qbauto/)
  elif [ ${type} == "dir" ]; then
    rclone_copy_cmd=$(rclone -v copy --transfers ${rclone_parallel} --log-file ${log_dir}/qbauto_copy.log "${content_dir}"/ ${rclone_dest}:qbauto/"${torrent_name}")
  fi
}

################## 主执行模块 ##################
check_qbt
if [ -z "$content_dir" ]; then
  echo
else
  rclone_move
  qb_login
  qb_add_auto_del_tags
  qb_del
  echo "种子名称：${torrent_name}" >> ${log_dir}/qb.log
  echo "内容路径：${content_dir}" >> ${log_dir}/qb.log
  echo "根目录：${root_dir}" >> ${log_dir}/qb.log
  echo "保存路径：${save_dir}" >> ${log_dir}/qb.log
  echo "文件数：${files_num}" >> ${log_dir}/qb.log
  echo "文件大小：${torrent_size}Bytes" >> ${log_dir}/qb.log
  echo "HASH:${file_hash}" >> ${log_dir}/qb.log
  echo "Cookie:${cookie}" >> ${log_dir}/qb.log
  echo -e "-------------------------------------------------------------\n" >> ${log_dir}/qb.log
fi
