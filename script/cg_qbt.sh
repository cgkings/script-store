#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_qbt)
# File Name: cg_qbt.sh
# Author: cgking
# Created Time : 2022.7.7
# Description:qb自动上传脚本
# System Required: Debian/Ubuntu
# Version: final
#=============================================================

#set -e #异常则退出整个脚本,避免错误累加
#set -x #脚本调试,逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
#/config/cg_qbt.sh "%N" "%F" "%C" "%Z" "%I" "%L"
torrent_name=$1 # %N: Torrent名称=mide-007-C
#content_dir=$(echo "$2" | sed "s/downloads/home\/qbt\/downloads/g") # %F: 内容路径=/home/btzz/mide-007-C
content_dir=$2
#files_num=$3 # %C
#torrent_size=$4 #%Z
file_hash=$5 #%I
file_category=$6 #%L: 分类
qpt_username="admin"
qpt_password="adminadmin"
qb_web_url="http://$(curl -sL ifconfig.me):8070"
rclone_remote="upsa"

################## rclone上传模块 ##################
rclone_upload() {
  fclone copy "$content_dir" "$rclone_remote":"$rclone_dest" --use-mmap --stats=10s --stats-one-line -vP --transfers=1 --min-size 100M --ignore-existing --log-file=/config/bt_upload.log
  RCLONE_EXIT_CODE=$?
  if [ ${RCLONE_EXIT_CODE} -eq 0 ]; then
    cat >> /config/qb.log << EOF
--------------------------------------------------------------------------------------------------------------
${curr_date} [INFO] ✔ Upload done ${file_category}:${torrent_name} ==> ${rclone_remote}:${rclone_dest}
EOF
  else
    cat >> /config/qb_fail.log << EOF
--------------------------------------------------------------------------------------------------------------
${curr_date} [ERROR] ❌ Upload failed:"$content_dir" "$rclone_remote":"$rclone_dest"
分类名称: ${file_category}
种子名称: ${torrent_name}
文件哈希: ${file_hash}
--------------------------------------------------------------------------------------------------------------
EOF
  fi
}

################## qbt删除种子 ##################
qb_del() {
  cookie=$(curl -si --header "Referer: ${qb_web_url}" --data "username=${qpt_username}&password=${qpt_password}" "${qb_web_url}/api/v2/auth/login" | grep -Eo 'SID=\S{32}')
  if [ -n "${cookie}" ]; then
    curl -s "${qb_web_url}/api/v2/torrents/delete?hashes=${file_hash}&deleteFiles=true" --cookie "$cookie"
    cat >> /config/qb.log << EOF
${curr_date} [INFO] ✔ login  done ${cookie}
${curr_date} [INFO] ✔ delete done ${content_dir}
EOF
  else
    cat >> /config/qb_fail.log << EOF
-----------------------------------------------------------------------------------------------------
${curr_date} [ERROR] ❌ 登录删除失败！:
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
if [ -z "${file_hash}" ]; then
  echo -e "${curr_date} [ERROR] 无种子信息,脚本停止运行" >> /config/qb.log
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