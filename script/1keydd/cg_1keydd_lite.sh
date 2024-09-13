#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_1key_dd)
# File Name: cg_1key_dd.sh
# Author: cgkings
# Created Time : 2022.1.1
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#该脚本安装基础软件、基础系统环境、开发环境(python/node/docker)、自用软件(rclone/fclone/ohmyzsh/ohmytmux/caddy)、系统优化(禁用swap/bbr)
#=============================================================

################## 调试日志 ##################
#set -x    ##分步执行
#exec &> /tmp/log.txt   ##脚本执行的过程和结果导入/tmp/log.txt文件中

################## 前置变量 ##################
curr_date=$(date "+%Y-%m-%d %H:%M:%S")

################## 基础软件安装 ##################
#echo -e "${curr_date} 静默升级系统软件源"
sys_update=$(apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1)
sys_upgrade=$(apt upgrade -y 2> /dev/null | grep upgraded)
echo -e "${curr_date} $sys_update\n$sys_upgrade" | tee -a /root/install_log.txt
#echo -e "${curr_date} 静默检查并安装常用软件1"
apt install -y sudo git make curl wget tree nano tmux htop net-tools parted nethogs ntp manpages-zh screenfetch file virt-what iperf3 jq expect iotop 2> /dev/null
#echo -e "${curr_date} 静默检查并安装常用软件2"
apt install -y ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar pv ffmpeg build-essential ncdu zsh fonts-powerline fuse fonts-noto-cjk-extra wondershaper vnstat 2> /dev/null
echo -e "${curr_date} 基础常用:sudo git make curl wget tree nano tmux parted ntp manpages-zh screenfetch file virt-what jq expect \n系统监控:htop iotop net-tools vnstat nethogs iperf3\n解压缩:tar zip unzip gzip bzip2 unar


net-tools parted nethogs ntpdate manpages-zh screenfetch file virt-what iperf3 jq expect ca-certificates dmidecode findutils dpkg pv locale ffmpeg build-essential ncdu  已安装" | tee -a /root/install_log.txt
#echo -e "${curr_date} 静默检查并安装youtubedl"
if [ -z "$(command -v youtube-dl)" ]; then
  sudo curl -sL https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
  sudo chmod a+rx /usr/local/bin/youtube-dl
  echo -e "${curr_date} youtube-dl 已安装" | tee -a /root/install_log.txt
fi

################## 基础系统环境 ##################
#设置中国时区
if timedatectl | grep -q Asia/Shanghai; then
  echo > /dev/null
else
  timedatectl set-timezone 'Asia/Shanghai'
  timedatectl set-ntp true
  echo -e "${curr_date} 设置时区为Asia/Shanghai,done!" | tee -a /root/install_log.txt
fi
#设置en_US.UTF-8
if [[ $LANG == "en_US.UTF-8" ]]; then
  echo > /dev/null
else
  chattr -i /etc/locale.gen #解除文件修改限制
  cat > '/etc/locale.gen' << EOF
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
  locale-gen
  update-locale
  chattr -i /etc/default/locale
  cat > '/etc/default/locale' << EOF
LANGUAGE="en_US.UTF-8"
LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
EOF
  export LANGUAGE="en_US.UTF-8"
  export LANG="en_US.UTF-8"
  export LC_ALL="en_US.UTF-8"
  echo -e "${curr_date} 设置语言为英文，done!" | tee -a /root/install_log.txt
fi
#设置256颜色
if [ -z "$(grep -s "export TERM=xterm-256color" ~/.bashrc)" ]; then
  cat >> ~/.bashrc << EOF

if [ "$TERM" != "xterm-256color" ]; then
export TERM=xterm-256color
fi
EOF
  # shellcheck source=/dev/null
  source /root/.bashrc
  echo -e "${curr_date} 设置256色成功" | tee -a /root/install_log.txt
fi
#设置系统别名
if grep -q "alias c='clear'" /root/.bashrc; then
  echo > /dev/null
else
  cat >> /root/.bashrc << EOF

alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias la='ls -lAh'
alias lsa='ls -lah'
alias md='mkdir -p'
alias rd='rmdir'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias untar='tar -zxvf'
alias wget='wget -c'
alias tmuxl='tmux ls'
alias tmuxa='tmux a -t'
alias tmuxn='tmux new -s'
alias c='clear'
alias yd="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --write-auto-sub --sub-lang zh-Hans --embed-sub -i --exec 'fclone move {} cgking:{1849n4MVDof3ei8UYW3j430N1QPG_J2de} -vP'"
alias nano="nano -m"
EOF
  echo -e "${curr_date} 设置alias别名,done!" | tee -a /root/install_log.txt
fi

################## 基础开发环境 ##################
#安装python环境
apt install -y python python3 python3-pip python3-distutils #build-essential libncurses5-dev libpcap-dev libffi-dev
if [ -z "$(command -v virtualenv)" ]; then
  pip3 install -U pip > /dev/null
  hash -d pip3
  pip3 install -U wheel requests scrapy Pillow baidu-api cloudscraper fire setuptools virtualenv > /dev/null
  echo -e "${curr_date} pythonh环境已安装" | tee -a /root/install_log.txt
fi
#安装node环境
if [ -z "$(command -v node)" ]; then
  if [ -e /usr/local/lib/nodejs ]; then
    rm -rf /usr/local/lib/nodejs
  fi
  apt install -y nodejs npm
  echo -e "${curr_date} nodejs&npm已安装,nodejs路径:/usr/local/lib/nodejs" | tee -a /root/install_log.txt
fi
if [ -z "$(command -v yarn)" ]; then
  npm install -g yarn
  echo -e "${curr_date} yarn&n已安装" | tee -a /root/install_log.txt
fi
#预装docker
bash <(curl -sL https://get.docker.com)
#预装docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

################## 安装装逼神器 ohmyzsh & ohmytmux ##################
#安装oh my zsh
cd /root && bash <(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended
sed -i '/^ZSH_THEME=/c\ZSH_THEME="jtriley"' ~/.zshrc #设置主题
git clone https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions /root/.oh-my-zsh/plugins/zsh-completions
#[ -z "$(grep "autoload -U compinit && compinit" ~/.zshrc)" ] && echo "autoload -U compinit && compinit" >> ~/.zshrc
[ -z "$(grep "plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)" ~/.zshrc)" ] && sed -i '/^plugins=/c\plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' ~/.zshrc
#自动更新
echo "zstyle ':omz:update' mode auto" >> ~/.zshrc
# source /root/.bashrc
[ -z "$(grep "source /root/.bashrc" ~/.zshrc)" ] && echo -e "\nsource /root/.bashrc" >> /root/.zshrc
#不显示开机提示语
touch ~/.hushlogin
echo -e "${curr_date} 安装oh my zsh,done!" | tee -a /root/install_log.txt
#安装oh my tmux
cd /root && git clone https://github.com/gpakosz/.tmux.git
ln -sf .tmux/.tmux.conf .
cp .tmux/.tmux.conf.local .
echo -e "${curr_date} 安装oh my tmux，done!" | tee -a /root/install_log.txt
sudo chsh -s "$(which zsh)"

################## 安装caddy ##################
if [ -z "$(command -v caddy)" ]; then
  echo -e "${curr_date} [DEBUG] caddy2 不存在.正在为您安装，请稍后..."
  sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https 2> /dev/null
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
  sudo apt update 2> /dev/null
  sudo apt install -y caddy 2> /dev/null
  systemctl enable caddy
  echo -e "${curr_date} [INFO] caddy2 安装完成!" | tee -a /root/install_log.txt
fi

################## 安装rclone ##################
#检查fclone安装状态，没装就安装
if [ -z "$(command -v fclone)" ]; then
  if [[ $(uname -m 2> /dev/null) = x86_64 ]]; then
    wget -qN https://github.com/cgkings/script-store/raw/master/tools/fclone && mv -f fclone /usr/bin/ > /dev/null && chmod +x /usr/bin/fclone
  elif [[ $(uname -m 2> /dev/null) = aarch64 ]]; then
    wget -qN https://github.com/cgkings/script-store/raw/master/tools/fclone_arm64/fclone && mv -f fclone /usr/bin/ > /dev/null && chmod +x /usr/bin/fclone
  fi
  echo -e "${curr_date} fclone已安装" | tee -a /root/install_log.txt
fi
#检查rclone安装状态，没装就安装
if [ -z "$(command -v rclone)" ]; then
  bash <(curl -sL https://rclone.org/install.sh) > /dev/null
  echo -e "${curr_date} rclone已安装" | tee -a /root/install_log.txt
fi
#检查rclone的conf文件是否存在
if [ ! -f /root/.config/rclone/rclone.conf ]; then
    mkdir -p /root/.config/rclone
    touch /root/.config/rclone/rclone.conf
    echo -e "${curr_date} 已新建rclone.conf空文件，需要请自行配置" | tee -a /root/install_log.txt
fi
###file-max设置，解决too many open files问题###
if grep -q "65535" /etc/security/limits.conf; then
  echo > /dev/null
else
  echo -e "\nfs.file-max = 6553500" >> /etc/sysctl.conf
  sysctl -p
  cat >> /etc/security/limits.conf << EOF

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
  echo -e "\nsession required pam_limits.so" >> /etc/pam.d/common-session
  echo -e "${curr_date} file_max 修改成功" | tee -a /root/install_log.txt
fi

################## 系统优化swap & bbr ##################
#禁用swap
echo 'vm.swappiness=0' >> /etc/sysctl.conf
#检查bbr是否已启用
if lsmod | grep -q bbr; then
  echo
else
  echo net.core.default_qdisc=fq >> /etc/sysctl.conf
  echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
  sysctl -p
  echo -e "${curr_date} BBR加速已启用" | tee -a /root/install_log.txt
fi

################## 重启 ##################
reboot -f