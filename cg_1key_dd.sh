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
#=============================================================

################## 调试日志 ##################
#set -x    ##分步执行
#exec &> /tmp/log.txt   ##脚本执行的过程和结果导入/tmp/log.txt文件中
################## 前置变量 ##################
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
ip_addr=$(hostname -I | awk '{print $1}')

################## 待调用-装逼神器 ##################
check_beautify() {
  ####设置颜色###
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
  #安装oh my zsh
  cd /root && bash <(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended
  sed -i '/^ZSH_THEME=/c\ZSH_THEME="jtriley"' ~/.zshrc #设置主题
  git clone https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions /root/.oh-my-zsh/plugins/zsh-completions
  [ -z "$(grep "autoload -U compinit && compinit" ~/.zshrc)" ] && echo "autoload -U compinit && compinit" >> ~/.zshrc
  [ -z "$(grep "plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)" ~/.zshrc)" ] && sed -i '/^plugins=/c\plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' ~/.zshrc
  #自动更新
  sed -i '/mode[[:space:]]auto/d' ~/.zshrc
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
}

################## 待调用-批量别名 ##################
set_alias() {
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
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
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
    echo -e "${curr_date} 设置alias别名，done!" | tee -a /root/install_log.txt
  fi
}

################## 待调用-开启bbr ##################
check_bbr() {
    #检查bbr是否已启用
    if lsmod | grep -q bbr; then
      echo
  else
      echo net.core.default_qdisc=fq >> /etc/sysctl.conf
      echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
      sysctl -p
      echo -e "${curr_date} BBR加速已启用" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装rclone ##################
check_rclone() {
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
}

################## 待调用-安装python环境 ##################
check_python() {
  check_command python python3 python3-pip python3-distutils #build-essential libncurses5-dev libpcap-dev libffi-dev
  if [ -z "$(command -v virtualenv)" ]; then
    pip3 install -U pip > /dev/null
    hash -d pip3
    pip3 install -U wheel requests scrapy Pillow baidu-api cloudscraper fire setuptools virtualenv > /dev/null
    echo -e "${info_message} pythonh环境已安装" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装go环境 ##################
check_go() {
  if [ -z "$(command -v go)" ]; then
    echo -e "${debug_message} ${yellow}${jiacu}go${normal} 不存在.正在为您安装，请稍后..."
    if [ -e /home/go ]; then
      rm -rf /home/go
    fi
    wget -qN https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -O /root/go.tar.gz
    tar -zxf /root/go.tar.gz -C /home && rm -f /root/go.tar.gz
    [ -z "$(grep "export GOROOT=/home/go" /root/.bashrc)" ] && cat >> /root/.bashrc << EOF

export PATH=$PATH:/home/go/bin
export GOROOT=/home/go
export GOPATH=/home/go/gopath
EOF
    echo -e "${info_message} go1.15.6环境已安装,go库路径：/home/go/gopath" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装nodejs环境 ##################
check_nodejs() {
  if [ -z "$(command -v node)" ]; then
    if [ -e /usr/local/lib/nodejs ]; then
      rm -rf /usr/local/lib/nodejs
    fi
    apt-get install -y nodejs npm
    echo -e "${info_message} nodejs&npm已安装,nodejs路径：/usr/local/lib/nodejs" | tee -a /root/install_log.txt
  fi
  if [ -z "$(command -v yarn)" ]; then
    npm install -g yarn
    echo -e "${info_message} yarn&n已安装" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装emby ##################
check_emby() {
  emby_version="4.6.7.0"
  if [ ! -f "/usr/lib/systemd/system/emby-server.service" ]; then
    if [[ $(uname -m 2> /dev/null) = x86_64 ]]; then
      wget -qN https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-deb_"${emby_version}"_amd64.deb
      dpkg -i emby-server-deb_"${emby_version}"_amd64.deb > /dev/null
      sleep 1s
      rm -f emby-server-deb_"${emby_version}"_amd64.deb
    elif [[ $(uname -m 2> /dev/null) = aarch64 ]]; then
      wget -qN https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-deb_"${emby_version}"_arm64.deb
      dpkg -i emby-server-deb_"${emby_version}"_arm64.deb > /dev/null
      sleep 1s
      rm -f emby-server-deb_"${emby_version}"_arm64.deb
    fi
    echo -e "${curr_date} [INFO] 恭喜您emby $emby_version 安装成功，请访问:http://${ip_addr}:8096 进一步配置" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装jellyfin ##################
check_jellyfin() {
  if [ -z "$(command -v jellyfin)" ]; then
    echo -e "${curr_date} [INFO] jellyfin 不存在.正在为您安装，请稍等..."
    apt-get install -y apt-transport-https > /dev/null
    wget -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo apt-key add -
    echo "deb [arch=$( dpkg --print-architecture)] https://repo.jellyfin.org/$(  awk -F'=' '/^ID=/{ print $NF }' /etc/os-release) $(  awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release) main"  | sudo tee /etc/apt/sources.list.d/jellyfin.list
    apt-get update > /dev/null
    apt-get install -y jellyfin > /dev/null
    sleep 1s
    echo -e "${curr_date} [INFO] jellyfin 安装成功，请访问：http://${ip_addr}:8096 进一步配置" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装pt套装 ##################
check_pt() {
  #安装qbt最新版
  bash <(curl -sL git.io/cg_qbt)
  #安装mktorrent
  git clone https://github.com/Rudde/mktorrent.git && cd mktorrent && make && make install
}

################## 初始安装 ##################
initialization() {
  #echo -e "${curr_date} 静默升级系统软件源"
  sys_update=$(apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1)
  sys_upgrade=$(apt upgrade -y 2> /dev/null | grep upgraded)
  echo -e "${curr_date} $sys_update\n$sys_upgrade" | tee -a /root/install_log.txt
  #echo -e "${curr_date} 静默检查并安装常用软件"
  apt install sudo git make wget tree vim nano tmux htop net-tools parted nethogs screen ntpdate manpages-zh screenfetch file virt-what iperf3 jq expect ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv locale ffmpeg build-essential ncdu zsh fonts-powerline fuse -y --upgrade 2> /dev/null
  echo -e "${curr_date} sudo git make wget tree vim nano tmux htop net-tools parted nethogs screen ntpdate manpages-zh screenfetch file virt-what iperf3 jq expect ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv locale ffmpeg build-essential ncdu 已安装" | tee -a /root/install_log.txt
  #echo -e "${curr_date} 静默检查并安装youtubedl"
  if [ -z "$(command -v youtube-dl)" ]; then
    sudo curl -sL https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
    sudo chmod a+rx /usr/local/bin/youtube-dl
    echo -e "${curr_date} youtube-dl 已安装" | tee -a /root/install_log.txt
  fi
  apt install -y fonts-noto-cjk-extra
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
  #预装py/go/node
  check_python
  check_go
  check_nodejs
  #预装docker
  bash <(curl -sL https://get.docker.com)
  #预装docker-compose
  curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  #预装rclone
  check_rclone
  #预装X-UI
  bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
  #别名设置
  set_alias
  #预装ohmyzsh和ohmytmux
  check_beautify
  #bbr
  check_bbr
}

################## 命令帮助 ##################
dd_help() {
    cat << EOF
用法(Usage):
  bash <(curl -sL git.io/cg_1key_dd) [flags]

可用参数(Available flags):
  --basic    基础版DD[预装常用软件&py/go/node开发环境&docker]
  --emby     基础版+emby
  --jellyfin 基础版+jellyfin
  --pt       基础版+qbt+mktorrent
  --package  基础版+emby+pt套装
  --help     命令帮助
注:无参数则进入主菜单
例如:bash <(curl -sL git.io/cg_1key_dd) --help
EOF
}

################## 主菜单 ##################
dd_input() {
  dd_passwd=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "设置debian11密码" --nocancel '注:回车继续，不可esc' 10 68 Passwd123. 3>&1 1>&2 2>&3)
  dd_port=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "设置debian11 ssh端口" --nocancel '注:回车继续，不可esc' 10 68 22 3>&1 1>&2 2>&3)
}

dd_menu() {
  dd_mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "一键DD debian11 带预装脚本" --menu --nocancel "注:本脚本所有操作日志路径/root/install_log.txt\n基础版DD预装:常用软件、bbr、x-ui、rclone、py/go/node开发环境、docker" 16 78 7 \
        "Pure_dd" " ==>> 纯净版DD[仅预装curl wget]" \
        "Basic_dd" " ==>> 基础版DD" \
        "Emby_dd" " ==>> 基础版+emby" \
        "Jellyfin_dd" " ==>> 基础版+jellyfin" \
        "Pt_dd" " ==>> 基础版+qbt+mktorrent" \
        "Preload_package" " ==>> 基础版+emby+pt套装" \
        "Exit" " ==>> 退出" 3>&1 1>&2 2>&3)
  case $dd_mainmenu in
        Pure_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl wget" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Basic_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --basic && reboot" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Emby_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --emby && reboot" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Jellyfin_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --jellyfin && reboot" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Pt_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --pt && reboot" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Preload_package)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --package && reboot" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Exit | *)
          exit 0
          ;;
  esac
}

################## 主运行程序 ##################
if [ -z "$1" ]; then
  dd_menu
else
  case "$1" in
    --basic)
      initialization
      ;;
    --emby)
      initialization
      check_emby
      ;;
    --jellyfin)
      initialization
      check_jellyfin
      ;;
    --pt)
      initialization
      check_pt
      ;;
    --package)
      initialization
      check_emby
      check_pt
      ;;
    --help | *)
      dd_help
      ;;
  esac
fi
