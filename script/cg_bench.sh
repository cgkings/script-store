#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_bench)
# File Name: cg_bench.sh
# Author: cgkings
# Created Time : 2020.12.16
# Description:vps效能测试脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor
#机器所在地IP
ip_addr=$(hostname -I | awk '{print $1}')
#SSH登录所在地IP
OwnerIP=$(who am i | awk '{print $NF}' | sed -e 's/[()]//g')
check_command virt-what

################## 显示机器配置信息 ##################
VPS_INFO() {
  clear
  whiptail --backtitle "Hi,欢迎使用。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "机器配置信息" --msgbox "
CPU 型号: $(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
CPU 核心: $(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
CPU 频率: $(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//') MHz
硬盘容量: $(($(df -mt simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs -t swap --total 2>/dev/null|grep total|awk '{ print $2 }') / 1024)) GB
内存容量: $(free -m | awk '/Mem/ {print $2}') MB
虚拟内存: $(free -m | awk '/Swap/ {print $2}') MB
开机时长: $( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime)
系统负载: $( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
系统    : $(lsb_release -a | awk -F':' '/Description/ {print $2}')
架构    : $(uname -m)
内核    : $(uname -r)
虚拟架构: $(virt-what)
本地地址：$(hostname -I | awk '{print $1}')" 20 65
  clear
}

io_test(){
  whiptail --backtitle "Hi,欢迎使用。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "硬盘I/O测试" --msgbox "
硬盘I/O (第一次测试) :$( (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//')
硬盘I/O (第二次测试) :$( (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//')
硬盘I/O (第三次测试) :$( (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//')" 20 65
}

net_speed() {
  wget -qN https://github.com/cgkings/script-store/raw/master/tools/besttrace4linux.zip && unar besttrace4linux.zip -o /home && rm -f besttrace4linux.zip
  chmod +x /home/besttrace4linux/*
  /home/besttrace4linux/besttrace 120.237.4.195

  besttrace 119.6.6.6
}