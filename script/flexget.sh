#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# File Name: flexget一键脚本
# Author: cgkings
# Created Time : 2020.12.25
# Description:flexget
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

################## 安装flexget ##################

pip3 install --ignore-installed flexget
mkdir -p ~/.config/flexget
wget -qN https://raw.githubusercontent.com/cgkings/script-store/master/config/config.yml -O ~/.config/flexget/config.yml

################## 搭建RSSHUB ##################

