#!/bin/bash
#=============================================================
# https://github.com/cgkings/cg_shellbot
# File Name: autoex.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:万能解压脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

################## 前置变量 ##################
source <(wget -qO- https://git.io/cg_script_option)
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
setcolor
check_root
check_vz
archive_dir=$1


#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 执  行  命  令 ##################






















if [ -z $1 ]; then
  swap_menu
else
  case "$1" in
  A | a)
    echo
    auto_swap
    ;;
  M | m)
    echo
    add_swap
    ;;
  D | d)
    echo
    del_swap
    ;;
  H | h)
    echo
    swap_help
    ;;
  *)
    echo
    swap_help
    ;;
  esac
fi