#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_swap)
# File Name: cg_swap.sh
# Author: cgkings
# Created Time : 2020.12.16
# Description:swap一键脚本
# System Required: Debian/Ubuntu
# 感谢github众多作者，我只是整合代码
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor







################## 运行命令 ##################
clear
while :; do
  echo
  echo "........... V2Ray 一键安装脚本 & 管理脚本 by 233v2.com .........."
  echo
  echo "帮助说明: https://233v2.com/post/1/"
  echo
  echo "搭建教程: https://233v2.com/post/2/"
  echo
  echo " 1. 安装"
  echo
  echo " 2. 卸载"
  echo
  if [[ $local_install ]]; then
    echo -e "$yellow 温馨提示.. 本地安装已启用 ..$none"
    echo
  fi
  read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" choose
  case $choose in
    1)
      install
      break
      ;;
    2)
      uninstall
      break
      ;;
    *)
      error
      ;;
  esac
done
SAVE TO CACHER
