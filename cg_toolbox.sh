#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_toolbox)
# File Name: cg_toolbox.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

################## 调试日志 ##################
#set -x    ##分步执行
#exec &> /tmp/log.txt   ##脚本执行的过程和结果导入/tmp/log.txt文件中
################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 系统初始化设置【常用工具、时区】 ##################
initialization() {
  check_sys
  echo 10
  #echo -e "${info_message} 静默升级系统软件源"
  apt-get update --fix-missing > /dev/null
  echo 30
  #echo -e "${info_message} 静默检查并安装常用软件1"
  check_command sudo git make wget tree vim nano tmux htop net-tools parted nethogs screen ntpdate manpages-zh screenfetch file virt-what iperf3
  apt install -y fonts-noto-cjk-extra
  echo 50
  #echo -e "${info_message} 静默检查并安装常用软件2"
  check_command jq expect ca-certificates dmidecode findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv locale ffmpeg build-essential ncdu
  echo 70
  #echo -e "${info_message} 静默检查并安装youtubedl"
  check_youtubedl
  echo 90
  setlanguage_us
  #设置中国时区
  if timedatectl | grep -q Asia/Shanghai; then
    echo > /dev/null
  else
    timedatectl set-timezone 'Asia/Shanghai'
    timedatectl set-ntp true
    #  [ -n "$(find /etc -name 'localtime')" ] && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    #  echo "Asia/Shanghai" > /etc/timezone
    echo -e "${info_message} 设置时区为Asia/Shanghai,done!" | tee -a /root/install_log.txt
  fi
  echo 100
}

################## 语言设置 ##################
setlanguage_cn() {
  if [[ $LANG == "zh_CN.UTF-8" ]]; then
    echo > /dev/null
  else
    chattr -i /etc/locale.gen #解除文件修改限制
    cat > '/etc/locale.gen' << EOF
zh_CN.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
    locale-gen
    update-locale
    chattr -i /etc/default/locale
    cat > '/etc/default/locale' << EOF
LANGUAGE="zh_CN.UTF-8"
LANG="zh_CN.UTF-8"
LC_ALL="zh_CN.UTF-8"
EOF
    #apt-get install manpages-zh -y
    export LANGUAGE="zh_CN.UTF-8"
    export LANG="zh_CN.UTF-8"
    export LC_ALL="zh_CN.UTF-8"
    echo -e "${info_message} 设置语言为中文，done!" | tee -a /root/install_log.txt
  fi
}

setlanguage_us() {
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
    echo -e "${info_message} 设置语言为英文，done!" | tee -a /root/install_log.txt
  fi
}

################## 批量别名 ##################
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
alias av='AV_Data_Capture'
alias toolbox='bash <(curl -sL git.io/cg_toolbox)'
alias cgmount='bash <(curl -sL git.io/cg_mount.sh)'
alias cgemby='bash <(curl -sL git.io/cg_emby)'
alias cgqbt='bash <(curl -sL git.io/cg_qbt.sh)'
alias yd="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --write-auto-sub --sub-lang zh-Hans --embed-sub -i --exec 'fclone move {} cgking:{1849n4MVDof3ei8UYW3j430N1QPG_J2de} -vP'"
alias nano="nano -m"
EOF
    echo -e "${info_message} 设置alias别名，done!！" | tee -a /root/install_log.txt
  fi
}

################## 安装装逼神器 oh my zsh & on my tmux ##################待完善
check_beautify() {
  ####设置颜色###
  if [ -z "$(grep -s "export TERM=xterm-256color" ~/.bashrc)" ]; then
    cat >> ~/.bashrc << EOF

if [ "$TERM" != "xterm-256color" ]; then
  export TERM=xterm-256color
fi
EOF
    source /root/.bashrc
    echo -e "${info_message} 设置256色成功" | tee -a /root/install_log.txt
  fi
  #安装oh my zsh
  check_command zsh fonts-powerline
  #调用oh my zsh安装脚本
  cd /root && bash <(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended
  sed -i '/^ZSH_THEME=/c\ZSH_THEME="jtriley"' ~/.zshrc #设置主题
  git clone https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions /root/.oh-my-zsh/plugins/zsh-completions
  [ -z "$(grep "autoload -U compinit && compinit" ~/.zshrc)" ] && echo "autoload -U compinit && compinit" >> ~/.zshrc
  [ -z "$(grep "plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)" ~/.zshrc)" ] && sed -i '/^plugins=/c\plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' ~/.zshrc
  sed -i 's/\# DISABLE_UPDATE_PROMPT="true"/DISABLE_UPDATE_PROMPT="true"/g' /root/.zshrc
  [ -z "$(grep "source /root/.bashrc" ~/.zshrc)" ] && echo -e "\nsource /root/.bashrc" >> /root/.zshrc
  touch ~/.hushlogin #不显示开机提示语
  echo -e "${info_message} 安装oh my zsh,done!" | tee -a /root/install_log.txt
  #安装oh my tmux
  cd /root && git clone https://github.com/gpakosz/.tmux.git
  ln -sf .tmux/.tmux.conf .
  cp .tmux/.tmux.conf.local .
  echo -e "${info_message} 安装oh my tmux，done!" | tee -a /root/install_log.txt
  sudo chsh -s "$(which zsh)"
}

################## buyvm挂载外挂硬盘 ##################
mount_disk() {
  disk_value=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "外挂硬盘名称" --nocancel '注：默认值/dev/sda，可自行fdisk -l查看名称' 10 68 /dev/sda 3>&1 1>&2 2>&3)
  disk_status=$(fdisk -l | grep "$disk_value")
  mount_status=$(df -h | grep "$disk_value")
  if [ -z "$disk_status" ]; then
    echo -e "${error_message} 未找到外挂磁盘名称，请到控制台先加卷后再运行本脚本" | tee -a /root/install_log.txt
    exit
  else
    if [ -z "$mount_status" ]; then
      #使用fdisk创建分区
      fdisk "$disk_value" << EOF
n
p
1
 
 
wq
EOF
      partprobe                                            #不重启重新读取分区信息
      #格式化ext4分区
      mkfs -t ext4 "$disk_value" << EOF
y
EOF
      mkdir -p 755 /home                                   #确保/home目录存在
      mount "$disk_value" /home                                 #将256G硬盘挂载到系统/home文件夹
      echo "${disk_value} /home ext4 defaults 1 2" >> /etc/fstab #第五列是dump备份设置:1，允许备份；0，忽略备份;第六列是fsck磁盘检查顺序设置:0，永不检查；/根目录分区永远为1。其它分区从2开始，数字相同，同时检查。
    else
      echo -e "${info_message} $disk_value 磁盘已挂载，无须重复操作" | tee -a /root/install_log.txt
    fi
  fi
  mount_status_update=$(df -h | grep "$disk_value")
  if [ -z "$mount_status_update" ]; then
    echo -e "${error_message} $disk_value 硬盘尚未挂载到/home" | tee -a /root/install_log.txt
  else
    echo -e "${info_message} $disk_value 硬盘成功挂载到/home" | tee -a /root/install_log.txt
    df -Th
  fi
}

check_bbr() {
  #检查是否系统自带bbr已安装
  if [[ $(uname -r | awk -F'.' '{print $1}') == "4" ]] && [[ $(uname -r | awk -F'.' '{print $2}') -ge 9 ]] || [[ $(uname -r | awk -F'.' '{print $1}') == "5" ]]; then
    #检查bbr是否已启用
    if lsmod | grep -q bbr ;then
      echo
    else
      echo net.core.default_qdisc=fq >> /etc/sysctl.conf
      echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
      sysctl -p
      echo -e "${info_message} BBR加速已启用！" | tee -a /root/install_log.txt
    fi
  else
    echo -e "${info_message} debian9以上版本自带bbr,您的系统内核未包含bbr，！" | tee -a /root/install_log.txt
  fi
}

################## 效率检测 ##################
VPS_INFO() {
  clear
  whiptail --backtitle "Hi,欢迎使用。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "机器配置信息" --msgbox "
CPU 型号: $(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
CPU 核心: $(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
CPU 频率: $(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//') MHz
硬盘容量: $(($(df -mt simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs -t swap --total 2> /dev/null | grep total | awk '{ print $2 }') / 1024)) GB
内存容量: $(free -m | awk '/Mem/ {print $2}') MB
虚拟内存: $(free -m | awk '/Swap/ {print $2}') MB
开机时长: $( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime)
系统负载: $( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
系统    : $(lsb_release -a | awk -F':' '/Description/ {print $2}')
架构    : $(uname -m)
内核    : $(uname -r)
虚拟架构: $(virt-what)
本地地址：$(hostname -I | awk '{print $1}')" 20 65
}

io_test() {
  whiptail --backtitle "Hi,欢迎使用。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "硬盘I/O测试" --msgbox "
硬盘I/O (第一次测试) :$( (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//')
硬盘I/O (第二次测试) :$( (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//')
硬盘I/O (第三次测试) :$( (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//')" 20 65
}

################## 主    菜    单 ##################
start_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "Cg_toolbox 主菜单" --menu --nocancel "CPU 型号: $(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')\n硬盘容量: $(($(df -mt simfs -t ext2 -t ext3 -t ext4 -t btrfs -t xfs -t vfat -t ntfs -t swap --total 2> /dev/null | grep total | awk '{ print $2 }') / 1024)) GB   内存容量: $(free -m | awk '/Mem/ {print $2}') MB   虚拟内存: $(free -m | awk '/Swap/ {print $2}') MB\n拥塞算法: $(awk '{print $1}' /proc/sys/net/ipv4/tcp_congestion_control)     队列算法: $(awk '{print $1}' /proc/sys/net/core/default_qdisc)\n注：本脚本所有操作日志路径：/root/install_log.txt" 17 60 5 \
    "Install_standard" "=>>  基 础 安 装" \
    "Install_extend" "=>>  扩 展 安 装" \
    "Benchmark" "=>>  效 能 测 试" \
    "Onekey_dd" "=>>  重 装 系 统" \
    "Exit" "=>>  退 出 脚 本" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Install_standard)
      whiptail --clear --ok-button "安装完成请手动重启生效" --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "系统设置模式" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装的软件，ESC退出脚本" 18 57 11 \
        "back" " == 返回上级菜单" off \
        "mountdisk" " == 挂载外挂硬盘" off \
        "languge_cn" " == 设置系统语言（中文）" off \
        "languge_us" " == 设置系统语言（英文）" off \
        "swap" " == 设置虚拟内存（2倍物理内存）" off \
        "develop1" " == 安装python开发环境" on \
        "develop2" " == 安装nodejs开发环境" on \
        "develop3" " == 安装go开发环境" off \
        "myalias" " == 自定义别名(alias命令查看)" on \
        "zsh" " == 安装oh my zsh &tmux" on \
        "bbr" " == 检查安装并启用bbr" on 2> results
      while read -r choice; do
        case $choice in
          back)
            start_menu
            break
            ;;
          mountdisk)
            mount_disk
            ;;
          languge_cn)
            setlanguage_cn
            ;;
          languge_us)
            setlanguage_us
            ;;
          swap)
            bash <(curl -sL git.io/cg_swap) a
            ;;
          develop1)
            check_python
            ;;
          develop2)
            check_nodejs
            ;;
          develop3)
            check_go
            ;;
          myalias)
            set_alias
            ;;
          zsh)
            check_beautify
            ;;
          bbr)
            check_bbr
            ;;
          *)
            myexit 0
            ;;
        esac
      done < results
      rm results
      reboot
      ;;
    Install_extend)
      extend_menu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "扩展安装模式" --menu --nocancel "注：本脚本所有操作日志路径：/root/install_log.txt" 18 55 10 \
        "Back_menu" " ==>> 返回上级菜单" \
        "Install_x-ui" " ==>> 搭建x-ui" \
        "Install_prober" " ==>> 搭建哪吒探针" \
        "Install_qbt" " ==>> 搭建qbittorrent" \
        "Auto_swap" " ==>> swap工具" \
        "Auto_mount" " ==>> 挂载工具" \
        "Install_emby" " ==>> 安装EMBY" \
        "Install_jellyfin" " ==>> 安装jellyfin" \
        "Auto_sort" " ==>> gd网盘整理" \
        "Auto_caddy2" " ==>> 安装配置caddy2" \
        "Exit" " ==>> 退出" 3>&1 1>&2 2>&3)
      case $extend_menu in
        Back_menu)
          start_menu
          return 0
          ;;
        Install_x-ui)
          bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
          start_menu
          ;;
        Install_prober)
          bash <(curl -Lso- https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh)
          start_menu
          ;;
        Install_qbt)
          bash <(curl -sL git.io/cg_qbt)
          start_menu
          ;;
        Auto_swap)
          bash <(curl -sL git.io/cg_swap)
          start_menu
          ;;
        Auto_mount)
          bash <(curl -sL git.io/cg_mount)
          start_menu
          ;;
        Install_emby)
          bash <(curl -sL git.io/cg_emby)
          start_menu
          ;;
        Install_jellyfin)
          bash <(curl -sL git.io/cg_jellyfin)
          start_menu
          ;;
        Auto_sort)
          bash <(curl -sL git.io/cg_sort)
          start_menu
          ;;
        Auto_caddy2)
          bash <(curl -sL git.io/cg_caddy2)
          start_menu
          ;;
        Exit | *)
          myexit 0
          ;;
      esac
      ;;
    Benchmark)
      Benchmark_menu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "测试模式" --menu --nocancel "注：本脚本所有操作日志路径：/root/install_log.txt" 18 53 8 \
        "Back" "返回上级菜单" \
        "1" "  设备基础配置(快速)" \
        "2" "  yabs性能测试" \
        "3" "  bench测试" \
        "4" "  流媒体解锁测试" \
        "5" "  三网网速测试" \
        "6" "  回程测试" \
        "7" "  退出" 3>&1 1>&2 2>&3)
      case $Benchmark_menu in
        Back)
          start_menu
          return 0
          ;;
        1)
          VPS_INFO
          start_menu
          ;;
        2)
          bash <(curl -L -s yabs.sh)
          start_menu
          ;;
        3)
          bash <(curl -sL bench.sh)
          start_menu
          ;;
        4)
          bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
          start_menu
          ;;
        5)
          bash <(curl -Lso- http://yun.789888.xyz/speedtest.sh)
          start_menu
          ;;
        6)
          bash <(curl -Lso- git.io/besttrace)
          start_menu
          ;;
        7 | *)
          myexit 0
          ;;
      esac
      ;;
    Onekey_dd)
      dd_passwd=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "设置debian11密码" --nocancel '注：回车继续，ESC表示root密码为空' 10 68 123456789 3>&1 1>&2 2>&3)
      bash <(wget --no-check-certificate -qO- 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh') -d 11 -v 64 -a -firmware -p "$dd_passwd"
      ;;
    Exit | *)
      myexit 0
      ;;
  esac
}

################## 执  行  命  令 ##################
initialization | whiptail --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --gauge "初始化(initializing),过程可能需要几分钟，请稍后.........." 6 60 0
check_rclone
start_menu
