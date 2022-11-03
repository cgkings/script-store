#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_pve)
# File Name: automount
# Author: cgkings
# Created Time : 2022.11.3
# Description:PVE一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 前置变量设置 ##################
install_pve() {
  apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1
  apt install -y curl sudo git make wget tree vim nano tmux htop net-tools parted nethogs screen ntpdate manpages-zh screenfetch file virt-what iperf3 jq expect 2> /dev/null
  apt install -y ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv ffmpeg build-essential ncdu zsh fonts-powerline fuse 2> /dev/null
  cat > /etc/hosts << EOF
127.0.0.1       localhost localhost.localdomain
$(curl -sL ifconfig.me)       $(hostnamectl | grep hostname | awk '{print $3}') $(hostnamectl | grep hostname | awk '{print $3}').proxmox.com

# The following lines are desirable for IPv6 capable hosts
::1     localhost localhost.localdomain
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
  echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
  wget -q https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
  apt update 2> /dev/null | grep packages | cut -d '.' -f 1 && apt full-upgrade -y 2> /dev/null | grep upgraded
  apt install -y proxmox-ve postfix open-iscsi 2> /dev/null
  systemctl reboot
}

install_pve