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
network_ip=$(curl -sL ifconfig.me)
network_hostname=$(hostnamectl | grep hostname | awk '{print $3}')
network_card=$(ifconfig | grep -B 1 "$(curl -sL ifconfig.me)"|head -n 1|awk -F: '{print $1}')
network_netmask=$(ifconfig | grep "$(curl -sL ifconfig.me)"|awk '{print $4}')

################## 前置变量设置 ##################
install_pve() {
  if [ -z "$(command -v postfix)" ]; then
    apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1
    apt install -y curl sudo git make wget tree vim nano tmux htop net-tools parted nethogs screen ntpdate manpages-zh screenfetch file virt-what iperf3 jq expect 2> /dev/null
    apt install -y ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv ffmpeg build-essential ncdu zsh fonts-powerline fuse 2> /dev/null
    cat > /etc/hosts << EOF
127.0.0.1       localhost.localdomain localhost
$network_ip   $network_hostname.proxmox.com $network_hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
    echo "deb [arch=amd64] http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
    wget -q https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg && chmod +r /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
    apt update 2> /dev/null | grep packages | cut -d '.' -f 1 && apt full-upgrade -y 2> /dev/null | grep upgraded
    apt install -y proxmox-ve postfix open-iscsi 2> /dev/null
    systemctl reboot
  fi
  if [ -z "$(command -v os-prober)" ]; then
    apt remove linux-image-amd64 'linux-image-5.10*' -y
    update-grub
    apt remove os-prober -y
    cat > /etc/network/interfaces << EOF
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto $network_card
iface $network_card inet manual

auto vmbr0
iface vmbr0 inet static
    address  $(curl -sL ifconfig.me)
    netmask  $network_netmask
    gateway  $(ip route list | grep default | awk '{print $3}')
    broadcast  广播地址
    bridge-ports $network_card
    bridge-stp off
    bridge-fd 0

EOF
    systemctl restart networking
  fi
}

install_pve

# Proxmox VE 无法关闭虚拟机的解决方法
# ls -l /run/lock/qemu-server
# rm -f /run/lock/qemu-server/lock-100.conf
# qm unlock 101
# qm stop 101
# qm status 101
