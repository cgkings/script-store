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
apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1
apt install -y curl sudo git make wget tree vim nano tmux htop net-tools parted nethogs screen ntpdate manpages-zh screenfetch file virt-what iperf3 jq expect 2> /dev/null
apt install -y ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv ffmpeg build-essential ncdu zsh fonts-powerline fuse 2> /dev/null

network_ip=$(curl -sL ifconfig.me)
network_hostname=$(hostnamectl | grep hostname | awk '{print $3}')
network_card=$(ifconfig | grep -B 1 "$(curl -sL ifconfig.me)" | head -n 1 | awk -F: '{print $1}')
#network_netmask=$(ifconfig | grep "$(curl -sL ifconfig.me)" | awk '{print $4}')
network_gateway=$(ip route list | grep default | awk '{print $3}')
#network_ipv6ip=$(ip -6 a|grep -m 1 global|awk '{print $2}')
network_ipv6ip="2602:ffc8:5:a::15c:2786/112"
#network_ipv6gateway=$(ip -6 route list | grep -m 1 default | awk '{print $3}')
network_ipv6gateway="2602:ffc8:5:a::1"
network_ipv6ipkuai="2602:ffc8:5:a::/64"
#ipv6_dns1="2001:4860:4860::8888"
#ipv6_dns2="2001:4860:4860::8844"

################## 前置变量设置 ##################
install_pve() {
  if [ ! -f "/etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg" ]; then
    cat > /etc/hosts << EOF
127.0.0.1       localhost.localdomain localhost
$network_ip   $network_hostname.proxmox.com $network_hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
    echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
    wget -q https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
    apt update 2> /dev/null | grep packages | cut -d '.' -f 1 && apt full-upgrade -y 2> /dev/null | grep upgraded
    apt install -y pve-kernel-5.15
    systemctl reboot
  fi
  if [ -z "$(command -v postfix)" ]; then
    apt install -y proxmox-ve postfix open-iscsi 2> /dev/null
    apt remove linux-image-amd64 'linux-image-5.10*' -y
    update-grub
    apt remove os-prober -y
  fi
  if [ -z "$(command -v ndppd)" ]; then
    cat >> /etc/default/grub << EOF
GRUB_CMDLINE_LINUX_DEFAULT="quiet net.ifnames=0 biosdevname=0"
EOF
    update-grub
    cat > /etc/network/interfaces << EOF
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

iface $network_card inet manual

auto vmbr0
iface vmbr0 inet static
	address $network_ip/24
	gateway $network_gateway
	bridge-ports $network_card
	bridge-stp off
	bridge-fd 0

iface vmbr0 inet6 static
        address $network_ipv6ip
        gateway $network_ipv6gateway

auto vmbr1
iface vmbr1 inet static
        address 192.168.0.1
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up iptables -t nat -A POSTROUTING -s '192.168.0.0/24' -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '192.168.0.0/24' -o vmbr0 -j MASQUERADE
EOF
    systemctl restart networking
    echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf && sysctl -p
    apt -y install ndppd
    cat > /etc/ndppd.conf << EOF
proxy vmbr0 {
  rule $network_ipv6ipkuai {
    static
  }
}
EOF
    systemctl restart ndppd.service
    systemctl enable ndppd.service
    apt -y install radvd
    cat > /etc/radvd.conf << EOF
interface vmbr0 {
  AdvSendAdvert on;
  MinRtrAdvInterval 3;
  MaxRtrAdvInterval 10;
  prefix $network_ipv6ipkuai {
    AdvOnLink on;
    AdvAutonomous on;
    AdvRouterAddr on;
  };
};
EOF
    systemctl restart radvd.service
    systemctl enable radvd.service
  fi
  #iptables -t nat -A PREROUTING -p tcp -m tcp --dport 16823 -j DNAT --to-destination 192.168.0.4:22
}

install_pve

# Proxmox VE 无法关闭虚拟机的解决方法
# ls -l /run/lock/qemu-server
# rm -f /run/lock/qemu-server/lock-100.conf
# qm unlock 101
# qm stop 101
# qm status 101
