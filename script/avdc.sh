#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# File Name: automount
# Author: cgkings
# Created Time : 2020.12.25
# Description:挂载一键脚本
# System Required: Debian/Ubuntu
# 感谢wuhuai2020、moerats、github众多作者，我只是整合代码
# Version: 1.0
#=============================================================

################## 前置变量设置 ##################
source <(wget -qO- https://git.io/cg_script_option)
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
setcolor
check_root
check_vz
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

