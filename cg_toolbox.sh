#!/bin/bash
#=============================================================
# https://github.com/cgkings/cg_shellbot
# bash <(curl -sL git.io/cg_toolbox)
# File Name: cg_toolbox.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:vps装机一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

# set -e #异常则退出整个脚本，避免错误累加
# set -x #脚本调试，逐行执行并输出执行的脚本命令行
#expand_aliases on #shell中开启alias扩展

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 系统初始化设置【颜色、时区、语言、file-max】 ##################
initialization() {
  #TERM=ansi whiptail --title "初始化中(initializing) cg_toolbox by 王大锤" --infobox "初始化中...(initializing)
#请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)
#初始化包括安装常用软件、设置中国时区、自动创建虚拟内存（已有则不改变）" 8 100
  sleep 0.5s
  echo 10
  check_sys
  sleep 0.5s
  echo 20
  #echo -e "${curr_date} [INFO] 静默升级系统软件源"
  apt-get update --fix-missing > /dev/null
  sleep 0.5s
  echo 50
  #echo -e "${curr_date} [INFO] 静默升级已安装系统软件"
  #apt upgrade -y > /dev/null
  #echo -e "${curr_date} [INFO] 静默检查并安装常用软件"
  check_command sudo git make wget tree vim nano tmux htop parted nethogs screen ntpdate manpages-zh screenfetch file jq expect ca-certificates findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full pv locale ffmpeg build-essential ncdu
  sleep 0.5s
  echo 70
  check_youtubedl
  sleep 0.5s
  echo 80
  check_rclone
  ###设置时区###
  sleep 0.5s
  echo 90
  if timedatectl | grep -q Asia/Shanghai; then
    echo > /dev/null
  else
    timedatectl set-timezone 'Asia/Shanghai'
    timedatectl set-ntp true
    #  [ -n "$(find /etc -name 'localtime')" ] && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    #  echo "Asia/Shanghai" > /etc/timezone
    echo -e "${curr_date} [INFO] 设置时区为Asia/Shanghai成功" >> /root/install_log.txt
  fi
  sleep 1s
  echo 95
  echo 100
}

################## 语言设置 ##################[done]
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
    echo -e "${curr_date} [INFO] 设置语言为中文" >> /root/install_log.txt
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
    echo -e "${curr_date} [INFO] 设置语言为英文" >> /root/install_log.txt
  fi
}

################## 批量别名 ##################
my_alias() {
  check_youtubedl
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
alias toolbox='bash <(curl -sL git.io/cg_toolbox)'
alias swap='bash <(curl -sL git.io/cg_swap)'
alias a2='bash <(curl -sL git.io/aria2.sh)'
alias am='bash <(curl -sL git.io/cg_auto_mount)'
alias av='AV_Data_Capture'
alias yd="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --write-auto-sub --sub-lang zh-Hans --embed-sub -i --exec 'fclone move {} cgking:{1849n4MVDof3ei8UYW3j430N1QPG_J2de} -vP'"
alias nano="nano -m"
EOF
  source /root/.bashrc
}

################## 安装装逼神器 oh my zsh & on my tmux ##################待完善
install_beautify() {
  ####设置颜色###
  echo -e "${curr_date} [INFO] 设置系统256色"
  if [ "$(tput colors)" != 256 ]; then
    cat >> ~/.bashrc << EOF

if [ "$TERM" != "xterm-256color" ]; then
  export TERM=xterm-256color
fi
EOF
    source /root/.bashrc
    echo -e "${curr_date} [INFO] 设置256色成功" >> /root/install_log.txt
  fi
  echo -e "${curr_date} [INFO] 已完成"
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
  echo -e "${curr_date} [INFO] 装逼神器之oh my zsh 已安装" >> /root/install_log.txt
  #安装oh my tmux
  cd /root && git clone https://github.com/gpakosz/.tmux.git
  ln -sf .tmux/.tmux.conf .
  cp .tmux/.tmux.conf.local .
  echo -e "${curr_date} [INFO] 装逼神器之oh my tmux 已安装" >> /root/install_log.txt
  sudo chsh -s "$(which zsh)"
  echo "${red}${on_white}${bold}${curr_date} [INFO]即将reset生效 ${normal}"
  reset
}

################## buyvm挂载256G硬盘 ##################
buyvm_disk() {
  disk=$(fdisk -l|grep 256|sed -n '$p'|awk '{print $1}') #获取256G磁盘名
  mount_status=$(df -h | grep "$disk")                                     #挂载状态
  if [ -z "$disk" ]; then
    echo -e "未找到256G磁盘，请到控制台先加卷后再运行本脚本"
    exit
  else
    if [ -z "$mount_status" ]; then
      #使用fdisk创建分区
      fdisk "$disk" << EOF
n
p
1
 
 
wq
EOF
      partprobe                                            #不重启重新读取分区信息
      #格式化ext4分区
      mkfs -t ext4 "$disk" << EOF
y
EOF
      mkdir -p 755 /home                                   #确保/home目录存在
      mount "$disk" /home                                 #将256G硬盘挂载到系统/home文件夹
      echo "${disk} /home ext4 defaults 1 2" >> /etc/fstab #第五列是dump备份设置:1，允许备份；0，忽略备份;第六列是fsck磁盘检查顺序设置:0，永不检查；/根目录分区永远为1。其它分区从2开始，数字相同，同时检查。
    else
      echo -e "256G磁盘已挂载，无须重复操作"
    fi
  fi
  mount_status_update=$(df -h | grep "$disk")
  if [ -z "$mount_status_update" ]; then
    echo -e "${curr_date} [ERROR] buyvm 256G硬盘尚未挂载到/home" >> /root/install_log.txt
  else
    echo -e "${curr_date} [INFO] buyvm 256G硬盘成功挂载到/home" >> /root/install_log.txt
    df -Th
  fi
}

################## LNMP一键脚本 ##################
install_LNMP() {
  tmux new -s lnmp -d
  tmux send -t "lnmp" "wget http://soft.vpser.net/lnmp/lnmp1.7.tar.gz -cO lnmp1.7.tar.gz && tar zxf lnmp1.7.tar.gz && cd lnmp1.7 && LNMP_Auto="y" DBSelect="2" DB_Root_Password="lnmp.org" InstallInnodb="y" PHPSelect="10" SelectMalloc="1" ./install.sh lnmp" Enter
  cat >> /root/install_log.txt << EOF

${curr_date} [INFO] 您使用了lnmp一键包！
安装：mysql5.5(数据库root密码：lnmp.org) & php7.4 
1、Nginx + MySQL + PHP 的默认安装目录如下：
   Nginx 目录: /usr/local/nginx/
   MySQL 目录 : /usr/local/mysql/
   MySQL 数据库所在目录：/usr/local/mysql/var/
   PHP 目录 : /usr/local/php/
   默认网站目录 : /home/wwwroot/default/
   Nginx 日志目录：/home/wwwlogs/
2、LNMP 默认的配置文件目录如下：
   Nginx 主配置(默认虚拟主机)文件：/usr/local/nginx/conf/nginx.conf
   添加的虚拟主机配置文件：/usr/local/nginx/conf/vhost/域名.conf
   MySQL 配置文件：/etc/my.cnf
   PHP 配置文件：/usr/local/php/etc/php.ini
   php-fpm 配置文件：/usr/local/php/etc/php-fpm.conf
3、一般维护站点需要用到的命令如下：
  重启 nginx/mysql/php：lnmp nginx/mysql/php restart
  重启所有：lnmp restart
  添加站点：lnmp vhost add
  添加数据库：lnmp database add
  查看帮助：lnmp
EOF
}

################## 效率检测 ##################
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

################## 主    菜    单 ##################
main_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "Cg_toolbox 主菜单" --menu --nocancel "注：本脚本所有操作日志路径：/root/install_log.txt" 18 80 10 \
    "Install_standard" "系统设置(buyvm挂载/虚拟内存/语言设置/开发环境)" \
    "Install_extend" "扩展安装(fq/离线下载三件套/网络工具/emby/挂载)" \
    "Benchmark" "效能测试" \
    "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    ## 基础标准安装
    Install_standard)
      whiptail --clear --ok-button "安装完成后自动重启" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "基础安装模式" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装的软件。" 22 53 15 \
        "Back" "返回上级菜单" off \
        "languge_cn" "设置系统语言（中文）" off \
        "languge_us" "设置系统语言（英文）" on \
        "swap" "设置虚拟内存（2倍物理内存）" on \
        "buyvm_disk" "buyvm挂载256G硬盘" off \
        "develop1" "安装python开发环境" on \
        "develop2" "安装nodejs开发环境" on \
        "develop3" "安装go开发环境" off \
        "my_alias" "自定义别名(alias命令查看)" on \
        "lnmp" "LNMP 一键脚本" off \
        "baota" "宝塔面板一键脚本" off \
        "zsh" "安装oh my zsh &tmux" on 2> results
      while read -r choice; do
        case $choice in
          Back)
            main_menu
            break
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
          zsh)
            install_beautify
            ;;
          buyvm_disk)
            buyvm_disk
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
          my_alias)
            my_alias
            echo -e "${curr_date} [INFO] 您设置了my_alias别名！" >> /root/install_log.txt
            ;;
          offline)
            clear
            bash <(curl -sL git.io/cg_dl)
            ;;
          avdc)
            clear
            bash <(curl -sL git.io/cg_avdc)
            echo "说明：即将为您安装AV_Data_Capture-CLI-4.3.2
              这个小脚本不带参数则帮您安装AVDC
              带参数，就tmux开一个后台窗口刮削指定目录，如bash <(curl -sL git.io/cg_avdc) /home/gd，也可用本脚本的一键别名，将bash <(curl -sL git.io/cg_avdc) /home/gd设置别名为avdc，你只要输入avdc，它就开始后台刮削了"
            echo -e "${curr_date} [INFO] 您已安装AVDC！" >> /root/install_log.txt
            ;;
          gd_bot)
            bash <(curl -sL git.io/cg_gdbot)
            ;;
          lnmp)
            clear
            install_LNMP
            ;;
          baota)
            clear
            bash <(curl -sL git.io/cg_baota)
            echo -e "${curr_date} [INFO] 您安装了宝塔面板！" >> /root/install_log.txt
            ;;
          *)
            myexit 0
            ;;
        esac
      done < results
      rm results
      ;;
    Install_extend)
      extend_menu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "扩展安装模式" --menu --nocancel "注：本脚本所有操作日志路径：/root/install_log.txt" 22 65 14 \
        "Back" "返回上级菜单(Back to main menu)" \
        "my_alias" "自定义别名[可通过alias命令查看]" \
        "bbr" "BBR一键加速[转自HJM]" \
        "v2ray" "一键搭建V2ray[转自233boy]" \
        "offline" "离线下载3件套[aria2/rsshub/flexget]" \
        "auto_mount" "自动网盘挂载脚本[支持命令参数模式]" \
        "emby" "EMBY一键安装搭建脚本" \
        "avdc" "安装配置AVDC刮削工具[转自yoshiko2]" \
        "cg_sort" "网盘文件整理" \
        "gd_bot" "搭建gd转存bot[未完成]" \
        "lnmp" "LNMP 一键脚本" \
        "baota" "宝塔面板一键脚本[转自-laowangblog.com]" 3>&1 1>&2 2>&3)
      case $extend_menu in
        Back)
          main_menu
          return 0
          ;;
        my_alias)
          my_alias
          echo -e "${curr_date} [INFO] 您设置了my_alias别名！" >> /root/install_log.txt
          ;;
        bbr)
          clear
          bash <(curl -sL git.io/cg_bbr)
          echo -e "${curr_date} [INFO] 您设置了BBR加速！" >> /root/install_log.txt
          ;;
        v2ray)
          clear
          bash <(curl -sL git.io/cg_v2ray)
          echo -e "${curr_date} [INFO] 您搭建了v2ray！" >> /root/install_log.txt
          ;;
        offline)
          clear
          bash <(curl -sL git.io/cg_dl)
          install_aria2
          install_rsshub
          run_rsshub
          install_flexget
          config_flexget
          ;;
        auto_mount)
          clear
          bash <(curl -sL git.io/cg_mount.sh)
          echo -e "${curr_date} [INFO] 您设置了自动网盘挂载！" >> /root/install_log.txt
          ;;
        emby)
          clear
          bash <(curl -sL git.io/cg_emby)
          echo -e "${curr_date} [INFO] 您安装搭建了EMBY！" >> /root/install_log.txt
          ;;
        avdc)
          clear
          bash <(curl -sL git.io/cg_avdc)
          echo "说明：即将为您安装AV_Data_Capture-CLI-4.3.2
            这个小脚本不带参数则帮您安装AVDC
            带参数，就tmux开一个后台窗口刮削指定目录，如bash <(curl -sL git.io/cg_avdc) /home/gd，也可用本脚本的一键别名，将bash <(curl -sL git.io/cg_avdc) /home/gd设置别名为avdc，你只要输入avdc，它就开始后台刮削了"
          echo -e "${curr_date} [INFO] 您已安装AVDC！" >> /root/install_log.txt
          ;;
        cg_sort)
          clear
          bash <(curl -sL git.io/cg_sort.sh)
          ;;
        gd_bot)
          bash <(curl -sL git.io/cg_gdbot)
          ;;
        lnmp)
          clear
          install_LNMP
          ;;
        baota)
          clear
          bash <(curl -sL git.io/cg_baota)
          echo -e "${curr_date} [INFO] 您安装了宝塔面板！" >> /root/install_log.txt
          ;;
        *)
          myexit 0
          ;;
      esac
      ;;
    Benchmark)
      Benchmark_menu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "测试模式" --menu --nocancel "注：本脚本所有操作日志路径：/root/install_log.txt" 22 65 10 \
        "Back" "返回上级菜单(Back to main menu)" \
        "1" "设备基础配置" \
        "2" "硬盘I/O测试" \
        "3" "网络测试" 3>&1 1>&2 2>&3)
      case $Benchmark_menu in
        Back)
          main_menu
          return 0
          ;;
        1)
          VPS_INFO
          main_menu
          ;;
        2)
          io_test
          main_menu
          ;;
        3)
          curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
          ;;
        *)
          exit 0
          ;;
      esac
      ;;
    Exit)
      myexit 0
      ;;
  esac
}

################## 执  行  命  令 ##################
initialization | whiptail --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --gauge "初始化(initializing),过程可能需要几分钟，请稍后.........." 6 60 0
main_menu