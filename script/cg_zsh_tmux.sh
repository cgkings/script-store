#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_1key_dd)
# File Name: cg_zsh_tmux.sh
# Author: cgkings
# Created Time : 2022.1.1
# Description:zsh
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
echo -e "${curr_date} $sys_update" | tee -a /root/install_log.txt
#echo -e "${curr_date} 静默检查并安装常用软件1"
apt install -y sudo git wget nano tmux chrony jq tar zip unzip gzip unar ncdu zsh vnstat bc 2> /dev/null
#echo -e "${curr_date} 静默检查并安装常用软件2"
echo -e "${curr_date} sudo git wget nano tmux chrony jq tar zip unzip gzip unar ncdu zsh vnstat bc 已安装" | tee -a /root/install_log.txt

################## 基础系统环境 ##################
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

alias wget='wget -c'
alias tmuxl='tmux ls'
alias tmuxa='tmux a -t'
alias tmuxn='tmux new -s'
alias c='clear'
alias nano="nano -m"
EOF
  echo -e "${curr_date} 设置alias别名,done!" | tee -a /root/install_log.txt
fi

################## 基础开发环境 ##################
#预装docker
bash <(curl -sL https://get.docker.com)

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
sudo chsh -s /usr/bin/zsh

################## bbr ###################
wget https://github.com/Zxilly/bbr-v3-pkg/releases/download/2024-03-07-190234/linux-headers-6.4.0-bbrv3_6.4.0-g7542cc7c41c0-1_amd64.deb && wget https://github.com/Zxilly/bbr-v3-pkg/releases/download/2024-03-07-190234/linux-image-6.4.0-bbrv3_6.4.0-g7542cc7c41c0-1_amd64.deb && dpkg -i linux-headers-6.4.0-bbrv3_6.4.0-g7542cc7c41c0-1_amd64.deb && dpkg -i linux-image-6.4.0-bbrv3_6.4.0-g7542cc7c41c0-1_amd64.deb
# 使用单个 sed 命令删除不需要的行
sed -i '/net\.ipv4\.tcp_no_metrics_save\|net\.ipv4\.tcp_ecn\|net\.ipv4\.tcp_frto\|net\.ipv4\.tcp_mtu_probing\|net\.ipv4\.tcp_rfc1337\|net\.ipv4\.tcp_sack\|net\.ipv4\.tcp_fack\|net\.ipv4\.tcp_window_scaling\|net\.ipv4\.tcp_adv_win_scale\|net\.ipv4\.tcp_moderate_rcvbuf\|net\.ipv4\.tcp_rmem\|net\.ipv4\.tcp_wmem\|net\.core\.rmem_max\|net\.core\.wmem_max\|net\.ipv4\.udp_rmem_min\|net\.ipv4\.udp_wmem_min\|net\.core\.default_qdisc\|net\.ipv4\.tcp_congestion_control/d' /etc/sysctl.conf

# 追加新的配置
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 16384 33554432
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

# 重新加载配置
sysctl -p && sysctl --system
################## 重启 ##################
reboot -f