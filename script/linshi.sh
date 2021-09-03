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

install() {
  if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
    echo
    echo " 大佬...你已经安装 V2Ray 啦...无需重新安装"
    echo
    echo -e " $yellow输入 ${cyan}v2ray${none} $yellow即可管理 V2Ray${none}"
    echo
    exit 1
  elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
    echo
    echo "  如果你需要继续安装.. 请先卸载旧版本"
    echo
    echo -e " $yellow输入 ${cyan}v2ray uninstall${none} $yellow即可卸载${none}"
    echo
    exit 1
  fi
  v2ray_config
  blocked_hosts
  shadowsocks_config
  install_info
  # [[ $caddy ]] && domain_check
  install_v2ray
  if [[ $caddy || $v2ray_port == "80" ]]; then
    if [[ $cmd == "yum" ]]; then
      [[ $(pgrep "httpd") ]] && systemctl stop httpd
      [[ $(command -v httpd) ]] && yum remove httpd -y
    else
      [[ $(pgrep "apache2") ]] && service apache2 stop
      [[ $(command -v apache2) ]] && apt-get remove apache2* -y
    fi
  fi
  [[ $caddy ]] && install_caddy

  ## bbr
  _load bbr.sh
  _try_enable_bbr

  get_ip
  config
  show_config_info
}

################## 卸载v2ray ##################
uninstall() {
  if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
    . $backup
    if [[ $mark ]]; then
      _load uninstall.sh
    else
      echo
      echo -e " $yellow输入 ${cyan}v2ray uninstall${none} $yellow即可卸载${none}"
      echo
    fi

  elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
    echo
    echo -e " $yellow输入 ${cyan}v2ray uninstall${none} $yellow即可卸载${none}"
    echo
  else
    echo -e "
		$red 大胸弟...你貌似毛有安装 V2Ray ....卸载个鸡鸡哦...$none

		备注...仅支持卸载使用我 (233v2.com) 提供的 V2Ray 一键安装脚本
		" && exit 1
  fi
}

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
