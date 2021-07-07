#!/bin/bash
#=============================================================
# https://github.com/cgkings/cg_shellbot
# bash <(curl -sL git.io/cg_toolbox)
# File Name: cg_toolbox.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

########################### 调试日志 #########################
#set -x    ##分步执行
#exec &> /tmp/log.txt   ##脚本执行的过程和结果导入/tmp/log.txt文件中
########################### 前置变量 #########################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

########################### 调试日志 #########################
