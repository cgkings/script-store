#!/bin/bash
#=============================================================
# https://github.com/cgkings/cg_shellbot
# File Name: cg_toolbox.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行
#expand_aliases on #shell中开启alias扩展

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 尾行添加 ##################




################## 前置变量 ##################



################## 执  行  命  令 ##################
check_sys
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