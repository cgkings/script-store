#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# File Name: cg_swap.sh
# Author: cgkings
# Created Time : 2020.12.16
# Description:swap一键脚本
# System Required: Debian/Ubuntu
# 感谢wuhuai2020、moerats、github众多作者，我只是整合代码
# Version: 1.0
#=============================================================

################## 前置变量 ##################
source <(wget -qO- https://git.io/cg_script_option)
check_root
check_vz
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行
totalmem=$(free -m | awk '/Mem:/{print $2}')
totalswap=$(free -m | awk '/Swap:/{print $2}')

################## 生 成swap ##################
make-swapfile() {
  echo -e "${green}正在为您创建"$swapsize"的swap分区...${normal}"
  #分配大小
  fallocate -l ${swapsize} /swapfile
  #设置适当的权限
  chmod 600 /swapfile
  #设置swap区
  mkswap /swapfile
  #启用swap区
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >>/etc/fstab
  echo -e "${green}swap创建成功，信息如下：${normal}"
  cat /proc/swaps
  cat /proc/meminfo | grep Swap
}

################## 自动添加swap ##################
auto_swap() {
  if [ -z "$1" ]; then
    if [ $totalmem -le 1024 ]; then
      swapsize="2048MB"
    elif [ $totalmem -gt 1024 ]; then
      swapsize="$(($totalmem * 2))MB"
    fi
  else
    swapsize="$1MB"
  fi
  if [ "$totalswap" == '0' ]; then
    make-swapfile
  else
    del_swap
    make-swapfile
  fi
}

################## 自定义添加swap ##################
add_swap() {
  echo -e "${green}请输入需要添加的swap，建议为物理内存的2倍大小\n默认为MB，您也可以输入数字+[KB、MB、GB]的方式！（例如：4GB、4096MB、4194304KB）！${normal}"
  read -p "请输入swap数值:" swapsize
  echo
  swapsize=$(echo ${swapsize} | tr '[a-z]' '[A-Z]')
  swapsize_unit=${swapsize:0-2:2}
  echo "${swapsize_unit}" | grep -qE '^[0-9]+$'
  if [ $? -eq 0 ]; then
    swapsize="${swapsize}MB"
  else
    if [ "${swapsize_unit}" != "GB" ] && [ "${swapsize_unit}" != "MB" ] && [ "${swapsize_unit}" != "KB" ]; then
      echo -e "${Red}Error:swap大小只能是数字+单位，并且单位只能是KB、MB、GB。请检查后重新输入!${normal}"
      add_swap
    fi
  fi
  #检查是否存在swapfile
  grep -q "swapfile" /etc/fstab
  #如果不存在将为其创建swap
  if [ $? -ne 0 ]; then
    make-swapfile
  else
    del_swap
    make-swapfile
  fi
}

################## 删 除 swap ##################
del_swap() {
  #检查是否存在swapfile
  grep -q "swapfile" /etc/fstab
  #如果存在就将其移除
  if [ $? -eq 0 ]; then
    echo -e "${green}swapfile已发现，正在删除SWAP空间...${normal}"
    sed -i '/swapfile/d' /etc/fstab
    echo "3" >/proc/sys/vm/drop_caches
    swapoff -a
    rm -f /swapfile
    echo -e "${green}swap 删除成功！${normal}"
  else
    echo -e "${Red}你没建过swap,删什么玩意，跟我闹呢，删除失败！${normal}"
    swap_menu
  fi
}

################## 脚本参数帮助 ##################
swap_help() {
  echo -e "用法(Usage):
  bash <(curl -sL https://git.io/cg_swap) [flags]

可用参数(Available flags)：
  bash <(curl -sL https://git.io/cg_swap) a  自动添加swap
  bash <(curl -sL https://git.io/cg_swap) m  手动添加swap
  bash <(curl -sL https://git.io/cg_swap) d  删除现有swap
  bash <(curl -sL https://git.io/cg_swap) h  命令帮助
  注：无参数则进入主菜单"
}

################## 开  始  菜  单 ##################
swap_menu() {
  clear
  printf "${green}"
  cat <<EOF
—————————————————————————————————————————————————————————
  当前SWAP：$totalswap MB"
  swap一键脚本 by cgkings
  1、全自动添加swap[默认值][内存*2，最小设置2G]
  2、自定义添加swap
  3、删除swap
  4、退出
  注：输入2、3、4外任意字符，默认选1.自动添加
  感谢wuhuai2020、moerats、github众多作者，我只是整合代码
—————————————————————————————————————————————————————————
EOF
  printf "${normal}"
  read -n1 -p "请输入数字 [1-4]:" num
  case "$num" in
  1)
    echo
    auto_swap
    ;;
  2)
    echo
    add_swap
    ;;
  3)
    echo
    del_swap
    ;;
  4)
    exit
    ;;
  *)
    echo
    auto_swap
    ;;
  esac
}

################## 执  行  命  令 ##################
if [ -z $1 ]; then
  swap_menu
else
  case "$1" in
  A | a)
    echo
    auto_swap
    ;;
  M | m)
    echo
    add_swap
    ;;
  D | d)
    echo
    del_swap
    ;;
  H | h)
    echo
    swap_help
    ;;
  *)
    echo
    swap_help
    ;;
  esac
fi
#swap调用参数调整
#modi(){
#echo "正在优化..."
#echo
#cat /proc/sys/vm/swappiness
#sudo sysctl vm.swappiness=10
#cat /proc/sys/vm/vfs_cache_pressure
#sudo sysctl vm.vfs_cache_pressure=50
#cp /etc/sysctl.conf /etc/sysctl.conf.bak
#echo >> /etc/sysctl.conf
#echo "vm.swappiness=10" >> /etc/sysctl.conf
#echo >> /etc/sysctl.conf
#echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
#echo "优化完成"
#swap_menu
#}