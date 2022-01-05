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
    sudo apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1
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

################## 输入反代域名 ##################
input_domin() {
  reverse_domin=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "输入$rever_domin_name反代域名" --nocancel '注：请填写要反代本地端口的域名,esc推出脚本' 10 68 3>&1 1>&2 2>&3)
  if [ -z "$reverse_domin" ]; then
    myexit 0
  fi
}

################## 配置caddy2 ##################
caddy_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_emby。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "cg_caddy2 主菜单" --menu --nocancel "注：本脚本适配caddy2，ESC退出" 14 55 6 \
    "Preset_reverse" "      ==>预置反代设置" \
    "Custom_reverse" "      ==>自定义反代" \
    "Custom_webset" "      ==>自定义网站发布" \
    "Uninstall_caddy2" "      ==>卸载caddy2" \
    "Exit" "      ==>退 出 脚本" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Preset_reverse)
      whiptail --clear --ok-button "安装完成请手动重启生效" --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "预置反代设置" --checklist --separate-output --nocancel "请按空格及方向键来选择需要设置的反代，ESC退出脚本" 14 61 6 \
        "back_menu" " == 返回上级菜单" off \
        "rever_prober" " == [8008 ] 反代本地哪吒探针" off \
        "rever_xui" " == [54321] 反代本地x-ui " on \
        "rever_rsshub" " == [1200 ] 反代本地Rsshub" off \
        "rever_emby" " == [8096 ] 反代本地emby&jellyfin" on \
        "rever_qbt" " == [8070 ] 反代本地qbittorrent" on 2> results
      while read -r choice; do
        case $choice in
          back_menu)
            caddy_menu
            break
            ;;
          rever_prober)
            rever_domin_name="探针"
            input_domin
            cat >> /etc/caddy/Caddyfile << EOF

${reverse_domin} {
	reverse_proxy localhost:8008
}
EOF
            ;;
          rever_xui)
            rever_domin_name="xui"
            input_domin
            cat >> /etc/caddy/Caddyfile << EOF

${reverse_domin} {
	reverse_proxy localhost:54321
}
EOF
            ;;
          rever_rsshub)
            rever_domin_name="rsshub"
            input_domin
            cat >> /etc/caddy/Caddyfile << EOF

${reverse_domin} {
	reverse_proxy localhost:1200
}
EOF
            ;;
          rever_emby)
            rever_domin_name="emby"
            input_domin
            cat >> /etc/caddy/Caddyfile << EOF

${reverse_domin} {
	reverse_proxy localhost:8096
}
EOF
            ;;
          rever_qbt)
            rever_domin_name="qbittorrent"
            input_domin
            cat >> /etc/caddy/Caddyfile << EOF

${reverse_domin} {
	reverse_proxy localhost:8070
}
EOF
            ;;
          *)
            myexit 0
            ;;
        esac
      done < results
      rm results
      systemctl restart caddy
      ;;
    Custom_reverse)
      exit
      ;;
    Custom_webset)
      exit
      ;;
    Uninstall_caddy2)
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
