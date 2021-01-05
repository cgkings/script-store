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
  apt-get -y install git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq tar git-core
  echo -e "常用软件安装列表：git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq tar git-core" >>install_logo.txt
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
install_environment() {
  #安装基础开发环境
  apt-get update --fix-missing -y && apt upgrade -y
  apt-get -y install build-essential libncurses5-dev libpcap-dev libffi-dev #yum groupinstall "Development Tools"
  echo -e "基础开发环境build-essential&libncurses5-dev&libpcap-dev&libffi-dev已安装" >>install_logo.txt
  #安装python环境
  apt-get -y install python python3 python3-pip python3-distutils
  python3 -m pip install --upgrade pip
  pip install --upgrade setuptools
  pip install requests scrapy Pillow baidu-api pysocks cloudscraper fire pipenv delegator.py python-telegram-bot
  echo -e "python已安装,pip已升级，依赖安装列表：requests scrapy Pillow baidu-api pysocks cloudscraper fire pipenv delegator.py python-telegram-bot" >>install_logo.txt
  #安装nodejs环境
  apt-get -y install nodejs npm
  npm install -g yarn n --force
  npm install npm@latest -g #更新npm
  #n stable  #更新node
  yarn set version latest
  echo -e "nodejs&npm已安装,yarn&n已安装" >>install_logo.txt
  #安装go环境
  wget -q https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -O /root/go.tar.gz
  tar -zxf /root/go.tar.gz -C /home && rm -f /root/go.tar.gz
  cat >>/etc/profile <<EOF
export PATH=$PATH:/home/go/bin
export GOROOT=/home/go
export GOPATH=/home/go/gopath
EOF
  echo -e "go1.15.6环境已安装,go库路径：/home/go/gopath" >>install_logo.txt
  apt autoremove -y
  echo -e "python/nodejs/go环境已安装，建议重启生效"
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
  source ~/.zshrc
  chsh -s zsh
  touch ~/.hushlogin #不显示开机提示语
  echo -e "装逼神器之oh my zsh 已安装" >>install_logo.txt
  #安装oh my tmux
  cd /root && git clone https://github.com/gpakosz/.tmux.git
  ln -s -f .tmux/.tmux.conf
  cp .tmux/.tmux.conf.local .
  echo -e "装逼神器之oh my tmux 已安装" >>install_logo.txt
}

################## 安装rclone/fclone ##################[未完成]
install_rclone() {
  check_rclone
  read -p "即将为你解压sa文件夹及rclone conf文件，请输入解压密码：" zip_password
  wget -qN https:// -O /root/sa1.zip && unzip -qo /root/sa1.zip -d /root -P $zip_password && rm -f /root/sa1.zip  
  wget -qN https:// -O /root/sa2.zip && unzip -qo /root/sa2.zip -d /root -P $zip_password && rm -f /root/sa2.zip  
  wget -qN https:// -O /root/rclone_conf.zip && unzip -qo /root/rclone_conf.zip -d /root/.config/rclone -P $zip_password && rm -f /root/rclone_conf.zip  
  echo -e "rclone&fclone已安装,sa及conf文件已下载解压" >>install_logo.txt
}

################## buyvm挂载硬盘 ##################
buyvm_disk() {
  
}

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
