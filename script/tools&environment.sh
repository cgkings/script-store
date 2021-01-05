#!/bin/bash
#=============================================================
# https://github.com/cgkings/cg_shellbot
# File Name: vps_onekey.sh
# Author: cgking
# Created Time : 2020.12.7
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

################## 前置变量 ##################
source <(wget -qO- https://git.io/cg_script_option)
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
setcolor
check_root
check_vz
set -e #异常则退出整个脚本，避免错误累加
set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 系统初始化设置【颜色、时区、语言、file-max】 ##################
initialization() {
  #安装常用软件
  apt-get update --fix-missing -y &>/dev/null && apt upgrade -y &>/dev/null
  apt-get -y install git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq tar git-core expect e4fsprogs &>/dev/null
  echo -e "${curr_date} [info] 常用软件安装列表：git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq tar git-core expect e4fsprogs" >>install_logo.txt
  #设置颜色
  cat >>/root/.bashrc <<EOF
if [ "$TERM" == "xterm" ]; then
  export TERM=xterm-256color
fi
EOF
  source ~/.bashrc
  if [ $(tput colors) == 256 ]; then
    echo -e "${curr_date} [info] 设置256色成功" >>install_logo.txt
  else
    echo -e "${curr_date} [error] 设置256色失败" >>install_logo.txt
  fi
  #设置时区
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" >/etc/timezone
  echo -e "${curr_date} [info] 设置时区为Asia/Shanghai成功" >>install_logo.txt
  ntpdate cn.ntp.org.cn #同步时间
  #设置语言
  apt-get install -y locales
  echo "LANG=en_US.UTF-8" >/etc/default/locale
  cat >/etc/locale.gen <<EOF
  en_US.UTF-8 UTF-8
  zh_CN.UTF-8 UTF-8
EOF
  locale-gen
  echo -e "${curr_date} [info] 设置语言为en_US.UTF-8成功" >>install_logo.txt
  #file-max设置，解决too many open files问题
  cat >>/etc/sysctl.conf <<EOF
fs.file-max = 6553500
EOF
  sysctl -p
  cat >>/etc/security/limits.conf <<EOF
* soft memlock unlimited
* hard memlock unlimited
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535

root soft memlock unlimited
root hard memlock unlimited
root soft nofile 65535
root hard nofile 65535
root soft nproc 65535
root hard nproc 65535
EOF
  cat >>/etc/pam.d/common-session <<EOF
session required pam_limits.so
EOF
  if [ $(ulimit -n) == 65535 ]; then
    echo -e "${curr_date} [info] file_max 修改成功" >>install_logo.txt
  else
    echo -e "${curr_date} [error] file_max 修改失败" >>install_logo.txt
  fi
}

################## 安装各种开发环境 ##################
install_environment() {
  #安装基础开发环境
  apt-get update --fix-missing -y &>/dev/null && apt upgrade -y &>/dev/null
  apt-get -y install build-essential libncurses5-dev libpcap-dev libffi-dev &>/dev/null #yum groupinstall "Development Tools"
  echo -e "${curr_date} [info] 基础开发环境build-essential&libncurses5-dev&libpcap-dev&libffi-dev已安装" >>install_logo.txt
  #安装python环境
  apt-get -y install python python3 python3-pip python3-distutils &>/dev/null
  python3 -m pip install --upgrade pip &>/dev/null
  pip install --upgrade setuptools &>/dev/null
  pip install requests scrapy Pillow baidu-api pysocks cloudscraper fire pipenv delegator.py python-telegram-bot &>/dev/null
  echo -e "${curr_date} [info] python已安装,pip已升级，依赖安装列表：requests scrapy Pillow baidu-api pysocks cloudscraper fire pipenv delegator.py python-telegram-bot" >>install_logo.txt
  #安装nodejs环境
  apt-get -y install nodejs npm &>/dev/null
  npm install -g yarn n --force &>/dev/null
  npm install npm@latest -g &>/dev/null #更新npm
  #n stable  #更新node
  yarn set version latest &>/dev/null
  echo -e "${curr_date} [info] nodejs&npm已安装,yarn&n已安装" >>install_logo.txt
  #安装go环境
  wget -qN https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -O /root/go.tar.gz
  tar -zxf /root/go.tar.gz -C /home && rm -f /root/go.tar.gz
  cat >>/etc/profile <<EOF
export PATH=$PATH:/home/go/bin
export GOROOT=/home/go
export GOPATH=/home/go/gopath
EOF
  echo -e "${curr_date} [info] go1.15.6环境已安装,go库路径：/home/go/gopath" >>install_logo.txt
  apt autoremove -y &>/dev/null
}

################## 安装装逼神器 oh my zsh & on my tmux ##################
install_beautify() {
  #安装oh my zsh
  chsh -s /usr/bin/zsh
  cd /root && bash <(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended
  sed -i '/^ZSH_THEME=/c\ZSH_THEME="jtriley"' ~/.zshrc #设置主题
  git clone https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions /root/.oh-my-zsh/plugins/zsh-completions
  [ -z "$(grep "autoload -U compinit && compinit" ~/.zshrc)" ] && echo "autoload -U compinit && compinit" >>~/.zshrc
  sed -i '/^plugins=/c\plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' ~/.zshrc
  echo -e "alias c="clear"\nalias 6pan="/root/six-cli"" >>/root/.zshrc
  source ~/.zshrc &>/dev/null
  chsh -s zsh
  touch ~/.hushlogin #不显示开机提示语
  echo -e "${curr_date} [info] 装逼神器之oh my zsh 已安装" >>install_logo.txt
  #安装oh my tmux
  cd /root && git clone https://github.com/gpakosz/.tmux.git
  ln -s -f .tmux/.tmux.conf &>/dev/null
  cp .tmux/.tmux.conf.local . &>/dev/null
  echo -e "${curr_date} [info] 装逼神器之oh my tmux 已安装" >>install_logo.txt
}

################## 安装rclone/fclone ##################[未完成]
install_rclone() {
  check_rclone
  read -p "即将为你解压sa文件夹及rclone conf文件，请输入解压密码：" zip_password
  wget -qN https:// -O /root/sa1.zip && unzip -qo /root/sa1.zip -d /root -P $zip_password && rm -f /root/sa1.zip
  wget -qN https:// -O /root/sa2.zip && unzip -qo /root/sa2.zip -d /root -P $zip_password && rm -f /root/sa2.zip
  wget -qN https:// -O /root/rclone_conf.zip && unzip -qo /root/rclone_conf.zip -d /root/.config/rclone -P $zip_password && rm -f /root/rclone_conf.zip
  echo -e "${curr_date} [info] rclone&fclone已安装,sa及conf文件已下载解压" >>install_logo.txt
}

################## buyvm挂载256G硬盘 ##################
buyvm_disk() {
  disk=$(fdisk -l | grep 256 | awk '{print $2}' | tr -d : | sed -n '1p') #获取256G磁盘名
  mount_status=$(df -h | grep $disk)                                     #挂载状态
  if [ -z $disk ]; then
    echo -e "未找到256G磁盘，请到控制台先加卷后再运行本脚本"
    exit
  else
    if [ -n $mount_status ]; then
      echo -e "256G磁盘已挂载，无须重复操作"
      exit
    else
      #使用fdisk创建分区
      fdisk $disk <<EOF
n
p
1
 
 
wq
EOF
      #expet用法示例
      #expect -c "
      #spawn fdisk $disk
      #expect { "Command" { send \"n\r\" ; exp_continue } "Select" { send \"p\r\" ; exp_continue } "Partition" { send \"1\r\" ; #exp_continue } "First" { send \"\r\" ; exp_continue } "Last" { send \"\r\" ; exp_continue } }
      #expect  "Command" { send \"w\r\"}
      #expect eof "
      mkfs -t ext4 "$disk"1                                #格式化ext4分区
      mkdir -p /home                                       #确保/home目录存在
      mount "$disk"1 /home                                 #将256G硬盘挂载到系统/home文件夹
      echo "${disk}1 /home ext4 defaults 1 2" >>/etc/fstab #第五列是dump备份设置:1，允许备份；0，忽略备份;第六列是fsck磁盘检查顺序设置:0，永不检查；/根目录分区永远为1。其它分区从2开始，数字相同，同时检查。
    fi
  fi
  mount_status=$(df -h | grep $disk)
  if [ -n $mount_status ]; then
    echo -e "${curr_date} [info] buyvm 256G硬盘成功挂载到/home" >>install_logo.txt
  else
    echo -e "${curr_date} [error] buyvm 256G硬盘成功挂载到/home" >>install_logo.txt
  fi
}

################## 自动设置虚拟内存 ##################
swap() {
  bash <(curl -sL https://git.io/cg_swap)
}

################## rclone自动挂载 ##################
rclone_mount() {
  bash <(curl -sL https://git.io/cg_auto_mount)
}

################## menu_go_on ##################
menu_go_on() {
  echo
  echo -e "${red}是否继续执行脚本?${normal}"
  read -n1 -p "Y继续执行，N退出脚本[Y/n]" res
  echo
  case "$res" in
  Y | y) ;;
    main_menu
  N | n)
    exit 1
    ;;
  *)
    echo "输入错误"
    menu_go_on
    ;;
  esac
}

################## 主    菜    单 ##################
main_menu() {
  clear
  echo -e "${green}#################################################${normal}"
  echo -e "${green}#                                               #${normal}"
  echo -e "${green}#       VPS一键脚本 for Ubuntu/Debian系统        #${normal}"
  echo -e "${green}#                               by cgkings      #${normal}"
  echo -e "${green}#                                               #${normal}"
  echo -e "${green}#################################################${normal}"
  echo -e "${green}——————————————————系 统 相 关—————— ——————————————${normal}"
  echo -e "${green}A1、系统初始化设置[颜色/时区/语言/maxfile/常用工具]${normal}"                      #已完成
  echo -e "${green}A2、安装各种开发环境[python/nodejs/go]${normal}"                                  #已完成
  echo -e "${green}A3、设置虚拟内存[支持命令参数模式]${normal}"                                       #已完成
  echo -e "${green}A4、安装装逼神器 oh my zsh & on my tmux${normal}"                                #已完成
  echo -e "${green}A5、buyvm挂载256G硬盘${normal}"                                                  #已完成
  echo -e "${green}——————————————————离 线 转 存————————————————————${normal}"
  echo -e "${green}B1、安装rclone/fclone/6pan-cli/aria2cli/youtube-dl[包括sa/conf备份还原]${normal}" #已完成
  echo -e "${green}B2、安装配置aria2一键增强[转自P3TERX]${normal}"                                   #已完成
  echo -e "${green}B3、安装qBittorrent/Deluge/Transmission[转自aniverse]${normal}"                  #已完成
  echo -e "${green}B4、安装配置rsshub/flexget自动添加种子${normal}"                                  #未完成
  echo -e "${green}B5、搭建shellbot，TG控制vps下载、转存[包含一键gd转存，具备限时定量定向分盘序列功能]${normal}"
  echo -e "${green}——————————————————网 络 相 关————————————————————${normal}"
  echo -e "${green}C1、BBR一键加速[转自-忘记抄的谁的了]${normal}"                                    #已完成
  echo -e "${green}C2、一键搭建V2ray[转自233boy]${normal}"                                          #已完成
  echo -e "${green}C3、LNMP 一键脚本[转自-忘记抄的谁的了]${normal}"                                  #已完成
  echo -e "${green}C4、宝塔面板一键脚本[转自-忘记抄的谁的了]${normal}"                                #已完成
  echo -e "${green}——————————————————EMBY  相 关————————————————————${normal}"
  echo -e "${green}D1、自动网盘挂载脚本[支持命令参数模式]${normal}"                                   #已完成
  echo -e "${green}D2、安装配置AVDC刮削工具[转自yoshiko2]${normal}"                                  #未完成
  echo -e "${green}D3、EMBY一键安装搭建脚本[转自wuhuai2020 & why]${normal}"                          #未完成
  echo -e "${green}—————————————————————————————————————————————————${normal}"
  read -n1 -p "请输入数字 [1-4]:" num
  case "$num" in
  1)
    echo
    remote_chose
    dir_chose
    tag_chose
    mount_creat
    exit
    ;;
  2)
    echo
    remote_chose
    dir_chose
    tag_chose
    mount_server_creat
    exit
    ;;
  3)
    echo
    mount_del
    exit
    ;;
  4)
    exit
    ;;
  *)
    echo
    echo "输入错误，请重新输入"
    mount_menu
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



screenfetch

#   -------------------------------
#   POWERLINE字体安装
#   -------------------------------
# printf '\n      >>> Installing powerline....\n'
# sudo rm -v PowerlineSymbols*
# sudo rm -v 10-powerline-symbols*
# wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
# wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
# mkdir -p ~/.fonts/
# mv -v PowerlineSymbols.otf ~/.fonts/
# fc-cache -vf ~/.fonts/ #Clean fonts cache
# mkdir -pv .config/fontconfig/conf.d #if directory doesn't exists
# mv -v 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/

##### 修补字体安装 #####
# mv -v 'SomeFont for Powerline.otf' ~/.fonts/
# fc-cache -vf ~/.fonts/
# After installing patched font terminal emulator, GVim or whatever application powerline should work with must be configured to use the patched font. The correct font usually ends with for Powerline.

##### 电力线字体 #####
# sudo git clone https://github.com/powerline/fonts.git --depth=1
# pusd ./fonts
# ./install.sh
# popd
# rm -rvf fonts
