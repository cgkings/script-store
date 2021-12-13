#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_caddy2)
# File Name: cg_caddy2.sh
# Author: cgkings
# Created Time : 2021.3.4
# Description:caddy2一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
curr_date=$(date "+%Y-%m-%d %H:%M:%S")

################## 初始化检查安装caddy2 ##################
check_caddy() {
  sleep 0.5s
  echo 20
  if [ -z "$(command -v caddy)" ]; then
    echo -e "${curr_date} [DEBUG] caddy2 不存在.正在为您安装，请稍后..."
    sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https > /dev/null
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt-get install -y caddy > /dev/null
    systemctl enable caddy.service
    echo -e "${curr_date} [INFO] caddy2 安装完成!" | tee -a /root/install_log.txt
  fi
  sleep 0.5s
  echo 40
  sleep 0.5s
  echo 60
  sleep 0.5s
  echo 80
  sleep 0.5s
  echo 100
}

################## 配置caddy2 ##################
caddy_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_emby。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "cg_caddy2 主菜单" --menu --nocancel "注：本脚本适配caddy2，ESC退出" 18 55 7 \
    "Preset_reverse" "      ==>预置反代设置" \
    "Custom_reverse" "      ==>自定义反代" \
    "Custom_webset" "      ==>自定义网站发布" \
    "Uninstall_caddy" "      ==>卸载caddy" \
    "Exit" "      ==>退 出 脚本" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Preset_reverse)
      exit
      ;;
    Custom_reverse)
      exit
      ;;
    Custom_webset)
      exit
      ;;
    Uninstall_caddy)
      exit
      ;;
    Exit | *)
      myexit 0
      ;;
  esac
}

################## 执行命令 ##################
check_caddy | whiptail --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --gauge "caddy2初始化(initializing),可能需要几分钟，请稍后..." 6 60 0
caddy_menu