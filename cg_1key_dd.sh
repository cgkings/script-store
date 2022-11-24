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
    cat >> /etc/sysctl.conf << EOF
#vm.swappiness=0
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max = 8400000
net.core.rmem_default = 4200000
net.core.wmem_max = 8400000
net.core.wmem_default = 4200000
net.ipv4.tcp_wmem = 4096 4200000 8400000
net.ipv4.tcp_rmem = 4096 4200000 8400000
EOF
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
    echo -e "\nfs.file-max = 6553500" >> /etc/sysctl.conf && sysctl -p
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
  apt install -y python python3 python3-pip python3-distutils #build-essential libncurses5-dev libpcap-dev libffi-dev
  if [ -z "$(command -v virtualenv)" ]; then
    pip3 install -U pip > /dev/null
    hash -d pip3
    pip3 install -U wheel requests scrapy Pillow baidu-api cloudscraper fire setuptools virtualenv > /dev/null
    echo -e "${curr_date} pythonh环境已安装" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装nodejs环境 ##################
check_nodejs() {
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
}

################## 待调用-安装php7.4环境 ##################
check_php7.4() {
  if [ -z "$(command -v php7.4)" ]; then
    sudo apt install -y gnupg2 lsb-release ca-certificates apt-transport-https software-properties-common
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
    wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -
    sudo apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1
    sudo apt install -y php7.4-cgi php7.4-fpm php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-fileinfo php7.4-iconv php7.4-zip php7.4-mysql php7.4-exif php7.4-common php7.4-cli php7.4-sqlite3 sqlite3
    sudo systemctl start php7.4-fpm.service && sudo systemctl enable php7.4-fpm.service
  fi
}

################## 待调用-安装caddy环境 ##################
check_caddy() {
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
}

################## 待调用-安装emby ##################
check_emby() {
  emby_version="4.7.6.0"
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
    apt install -y apt-transport-https > /dev/null
    wget -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo apt-key add -
    echo "deb [arch=$( dpkg --print-architecture)] https://repo.jellyfin.org/$(  awk -F'=' '/^ID=/{ print $NF }' /etc/os-release) $(  awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release) main"  | sudo tee /etc/apt/sources.list.d/jellyfin.list
    sudo apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1
    apt install -y jellyfin > /dev/null
    sleep 1s
    echo -e "${curr_date} [INFO] jellyfin 安装成功，请访问：http://${ip_addr}:8096 进一步配置" | tee -a /root/install_log.txt
  fi
}

################## 待调用-安装pt套装 ##################
check_pt() {
  #安装qbt最新版
  if [ -z "$(command -v qbittorrent-nox)" ]; then
    clear
    apt remove qbittorrent-nox -y && rm -f /usr/bin/qbittorrent-nox
    if [[ $(uname -m 2> /dev/null) = x86_64 ]]; then
      wget -qO /usr/bin/qbittorrent-nox https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox && chmod +x /usr/bin/qbittorrent-nox
    elif [[ $(uname -m 2> /dev/null) = aarch64 ]]; then
      wget -qO /usr/bin/qbittorrent-nox https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/aarch64-qbittorrent-nox && chmod +x /usr/bin/qbittorrent-nox
    fi
    #备份配置文件：cd /home && tar -cvf qbt_bat.tar qbt
    #还原qbt配置：
    wget -qN https://github.com/cgkings/script-store/raw/master/config/qbt_bat.tar && rm -rf /home/qbt && tar -xvf qbt_bat.tar -C /home && rm -f qbt_bat.tar && chmod -R 755 /home/qbt
    #建立qbt服务
    cat > '/etc/systemd/system/qbt.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --webui-port=8070 --profile=/home/qbt -d
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload && systemctl enable qbt.service && systemctl restart qbt.service
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done！
-----------------------------------------------------------------------------
程序名称：qBittorrent
版本名称：4.3.9
程序目录：/usr/bin/qbittorrent-nox
服务地址：/etc/systemd/system/qbt.service
-----------------------------------------------------------------------------
EOF
  fi
  #安装mktorrent
  git clone https://github.com/Rudde/mktorrent.git && cd mktorrent && make && make install
  #安装tr
  #   if [ -z "$(command -v transmission-daemon)" ]; then
  #     echo -e "${curr_date} [DEBUG] 未找到transmission-daemon包.正在安装..."
  #     apt install -y transmission-daemon
  #     mkdir -p /home/downloads
  #     chmod 777 /home/downloads
  #     #下载settings.json
  #     service transmission-daemon stop
  #     rm -f /var/lib/transmission-daemon/info/settings.json && wget -qO /var/lib/transmission-daemon/info/settings.json https://raw.githubusercontent.com/cgkings/script-store/master/config/transmission/settings.json && chmod +x /var/lib/transmission-daemon/info/settings.json
  #     service transmission-daemon start
  #     bash <(curl -sL https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh) << EOF
  # 1
  # EOF
  #     cat >> /root/install_log.txt << EOF
  # -----------------------------------------------------------------------------
  # $(date '+%Y-%m-%d %H:%M:%S') [INFO] install done！
  # -----------------------------------------------------------------------------
  # 程序名称：transmission-daemon
  # 版本名称：3.0
  # 程序目录：/var/lib/transmission-daemon
  # 下载目录：/home/downloads
  # 服务地址：/lib/systemd/system/transmission-daemon.service
  # -----------------------------------------------------------------------------
  # EOF
  #   fi
}

################## 搭建aria2 ##################
install_aria2() {
  cd /root || exit
  bash <(curl -sL git.io/aria2.sh) << EOF
1 
EOF
  #修改默认本地下载路径为/home/download
  [ ! -e /home/download ] && mkdir -p 755 /home/download
  [ -z "$(grep "/home/download" /root/.aria2c/aria2.conf)" ] && sed -i 's/dir=.*$/dir=\/home\/download/g' /root/.aria2c/aria2.conf
  #修改完成后执行的脚本为自动上传
  [ -z "$(grep "upload.sh" /root/.aria2c/aria2.conf)" ] && sed -i 's/clean.sh/upload.sh/g' /root/.aria2c/aria2.conf
  #修改自动上传的工具，由rclone改为fclone
  [ -z "$(grep "fclone move" /root/.aria2c/upload.sh)" ] && sed -i 's/rclone move/fclone move/g' /root/.aria2c/upload.sh
  #选择fclone remote
  remote_choose
  #设置自动上传的fclone remote
  [ -z "$(grep "$my_remote" /root/.aria2c/script.conf)" ] && sed -i 's/drive-name=.*$/drive-name='$my_remote'/g' /root/.aria2c/script.conf
  #通知remote选择结果及自动上传目录
  echo -e "$curr_date [INFO] 您选择的remote为：${my_remote}，自动上传目录为：/Download，如有需要，请bash <(curl -sL git.io/aria2.sh)自行修改" | tee -a /root/install_log.txt
  service aria2 restart
  #检查是否安装成功
  aria2_install_status=$(/root/.aria2c/upload.sh | sed -n '4p')
  if [ "$aria2_install_status" = success ]; then
    echo -e "${curr_date} [INFO] aria2自动上传已安装配置成功！本地下载目录为：/home/download,remote为：${my_remote}，自动上传目录为：/Download" | tee -a /root/install_log.txt
  else
    echo -e "${curr_date} [ERROR] aria2自动上传安装配置失败！" | tee -a /root/install_log.txt
  fi
  bash <(curl -sL git.io/aria2.sh) << EOF
6 
EOF
  docker run -d \
    --name ariang \
    --restart unless-stopped \
    --log-opt max-size=1m \
    -p 6880:6880 \
    p3terx/ariang
  cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done！
-----------------------------------------------------------------------------
程序名称：aria2
aria2地址：http://${ip_addr}:6800
ariang地址：http://${ip_addr}:6880
-----------------------------------------------------------------------------
EOF
}

################## 搭建RSSHUB ##################
install_rsshub() {
  [ -e /home/RSSHub ] && rm -rf /home/RSSHub
  mkdir -p 755 /home/RSSHub && git clone https://github.com/cgkings/RSSHub /home/RSSHub
  sleep 5s
  cd /home/RSSHub || exit
  npm cache clean --force
  npm install --production
  tmux new -s rsshub -d
  tmux send -t "rsshub" "cd /home/RSSHub && npm start" Enter
  echo -e "rsshub已完成部署动作，可网页访问你的ip:1200，看下效果吧！"
}

################## 初始安装 ##################
initialization() {
  #echo -e "${curr_date} 静默升级系统软件源"
  sys_update=$(apt update --fix-missing 2> /dev/null | grep packages | cut -d '.' -f 1)
  #sys_upgrade=$(apt upgrade -y 2> /dev/null | grep upgraded)
  echo -e "${curr_date} $sys_update" | tee -a /root/install_log.txt
  #echo -e "${curr_date} 静默检查并安装常用软件"
  apt install -y sudo git make wget tree vim nano tmux htop net-tools parted nethogs screen ntpdate manpages-zh screenfetch file virt-what iperf3 jq expect 2> /dev/null
  apt install -y ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv ffmpeg build-essential ncdu zsh fonts-powerline fuse 2> /dev/null
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
    echo -e "${curr_date} 设置语言为英文，done!" | tee -a /root/install_log.txt
  fi
  #预装py/go/node/php
  check_python
  check_nodejs
  #预装docker
  bash <(curl -sL https://get.docker.com)
  #预装docker-compose
  curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  #预装rclone
  check_rclone
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
          wget -q https://github.com/cgkings/script-store/raw/master/script/1keydd/cg_1keydd_lite.sh
          cmd_bash64=$(base64 /root/cg_1keydd_lite.sh | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Emby_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --emby" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Jellyfin_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --jellyfin" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Pt_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --pt" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Preload_package)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --package" | base64 | tr -d "\n")
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
    --lite)
      initialization
      reboot
      ;;
    --basic)
      initialization
      #预装建站环境php/sql/redis/caddy2
      sudo apt install -y redis-server
      check_php7.4
      check_caddy
      #禁用swap
      echo 'vm.swappiness=0' >> /etc/sysctl.conf
      #预装X-UI
      bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
      reboot
      ;;
    --emby)
      initialization
      check_emby
      reboot
      ;;
    --jellyfin)
      initialization
      check_jellyfin
      reboot
      ;;
    --pt)
      initialization
      check_pt
      reboot
      ;;
    --package)
      initialization
      check_emby
      check_pt
      reboot
      ;;
    --help | *)
      dd_help
      ;;
  esac
fi
