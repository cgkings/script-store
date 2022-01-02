#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_1key_dd)
# File Name: cg_1key_dd.sh
# Author: cgkings
# Created Time : 2022.1.1
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

################## 调试日志 ##################
#set -x    ##分步执行
#exec &> /tmp/log.txt   ##脚本执行的过程和结果导入/tmp/log.txt文件中
################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

echo "[p#1 输入命令]" |base64 |tr -d "\n"


source <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "Passwd123."  -port "22" -cmd "[p#3 首次开机执行命令bash64编码]"