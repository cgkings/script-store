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
setcolor
check_root
check_vz

################## 系统初始化设置【颜色、时区、语言、file-max】 ##################
initialization() {
  #安装常用软件
  apt-get update --fix-missing -y && apt upgrade -y
  apt-get -y install git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq tar
  echo -e "常用软件安装列表：git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq" >>install_logo.txt
  #设置颜色
  cat >>/root/.bashrc <<EOF
if [ "$TERM" == "xterm" ]; then
  export TERM=xterm-256color
fi
EOF
  source ~/.bashrc
  if [ $(tput colors) == 256 ]; then
    echo -e "设置256色成功" >>install_logo.txt
  else
    echo -e "设置256色失败" >>install_logo.txt
  fi
  #设置时区
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" >/etc/timezone
  echo -e "设置时区为Asia/Shanghai成功" >>install_logo.txt
  ntpdate cn.ntp.org.cn #同步时间
  #设置语言
  apt-get install -y locales
  echo "LANG=en_US.UTF-8" >/etc/default/locale
  cat >/etc/locale.gen <<EOF
  en_US.UTF-8 UTF-8
  zh_CN.UTF-8 UTF-8
EOF
  locale-gen
  echo -e "设置语言为en_US.UTF-8成功" >>install_logo.txt
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
    echo -e "file_max 修改成功" >>install_logo.txt
  else
    echo -e "file_max 修改失败" >>install_logo.txt
  fi
}

################## 安装开发各种环境 ##################
Common_environment(){
  #安装基础开发环境
  apt-get update --fix-missing -y && apt upgrade -y
  apt-get -y install build-essential libncurses5-dev libpcap-dev libffi-dev #yum groupinstall "Development Tools"
  echo -e "基础开发环境build-essential&libncurses5-dev&libpcap-dev&libffi-dev已安装" >>install_logo.txt
  #安装python环境
  apt-get -y install python python3 python3-pip python3-distutils
  python3 -m pip install --upgrade pip
  pip install --upgrade setuptools
  pip install requests scrapy Pillow baidu-api pysocks cloudscraper fire pipenv delegator.py python-telegram-bot
  #安装nodejs环境
  apt-get -y install nodejs npm
  npm install -g yarn
  yarn set version latest
  #安装go环境
  wget -q https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -O /root/go.tar.gz
  tar -zxf /root/go.tar.gz -C /home
  echo "export PATH=$PATH:/home/go/bin" >> /etc/profile
  source /etc/profile
  go version





  apt autoremove -y
}


#安装zsh
echo 第六步：安装oh my zsh（装逼神器）
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sed -i '/^ZSH_THEME=/c\ZSH_THEME="jtriley"' ~/.zshrc && source ~/.zshrc #设置主题
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
[ -z "$(grep "autoload -U compinit && compinit" ~/.zshrc)" ] && echo "autoload -U compinit && compinit" >>~/.zshrc
sed -i '/^plugins=/c\plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' ~/.zshrc
echo -e "alias c="clear"\nalias 6pan="/root/six-cli"" >>/root/.zshrc
source ~/.zshrc
chsh -s zsh
touch ~/.hushlogin #不显示提示语

screenfetch

#   -------------------------------
#   POWERLINE
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

##### PATCHED FONT INSTALLATION #####
# mv -v 'SomeFont for Powerline.otf' ~/.fonts/
# fc-cache -vf ~/.fonts/
# After installing patched font terminal emulator, GVim or whatever application powerline should work with must be configured to use the patched font. The correct font usually ends with for Powerline.

##### POWERLINE FONTS #####
# sudo git clone https://github.com/powerline/fonts.git --depth=1
# pusd ./fonts
# ./install.sh
# popd
# rm -rvf fonts
