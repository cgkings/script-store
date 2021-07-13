#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_gdbot)
# File Name: cg_gdbox.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

# set -e #异常则退出整个脚本，避免错误累加
# set -x #脚本调试，逐行执行并输出执行的脚本命令行
#expand_aliases on #shell中开启alias扩展

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 执  行  命  令 ##################
check_sys
check_command build-essential
check_nodejs
check_rclone
check_python
pip3 install -U pipenv delegator.py python-telegram-bot pysocks > /dev/null
git clone https://github.com/cgkings/cg_shellbot
cd ~/cg_shellbot || exit
npm install
tmux new -s gdbot -d
tmux send -t "gdbot" "cd ~/cg_shellbot && node server" Enter
sudo npm install -g forever
forever start ~/cg_shellbot/server.js