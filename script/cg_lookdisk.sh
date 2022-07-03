#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_lookdisk)
# File Name: cg_lookdisk.sh
# Author: cgkings
# Created Time : 2022.7.4
# Description:磁盘空间监控脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
disk_warn_line="90%"
disk_name="/dev/sda1"
disk_curr=$(df -h | grep $disk_name | awk '{print $5}')
curr_date=$(date "+%Y-%m-%d %H:%M:%S")

################## 监控命令 ##################
diffnum=$(echo "${disk_curr%%%}-${disk_warn_line%%%}" | bc -l)
if [ $diffnum -gt 0 ]; then
  echo "[Warning]已超过$disk_warn_line,现在占用$disk_curr"
else
  echo "[Info] 未超过限值($disk_warn_line),现在占用$disk_curr"
fi