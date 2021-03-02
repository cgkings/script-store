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
  check_sys
  clear
  TERM=ansi whiptail --title "初始化中(initializing) cg_toolbox by 王大锤" --infobox "初始化中...(initializing)
请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)
初始化包括安装常用软件、设置中国时区、自动创建虚拟内存（已有则不改变）" 8 100
  echo -e "${curr_date} [INFO] 静默升级系统软件源"
  apt-get update --fix-missing -y > /dev/null
  echo -e "${curr_date} [INFO] 静默升级已安装系统软件"
  apt upgrade -y > /dev/null
  echo -e "${curr_date} [INFO] 静默检查并安装常用软件"
  check_command sudo git make wget tree vim nano tmux htop parted nethogs screen ntpdate manpages-zh screenfetch file jq expect ca-certificates findutils dpkg tar zip unzip gzip bzip2 unar p7zip-full locale ffmpeg
  ###设置时区###
  echo -e "${curr_date} [INFO] 静默检查设置中国时区"
  if [ "$(cat /etc/timezone)" != "Asia/Shanghai" ]; then
    [ -z "$(find /etc -name 'localtime')" ] && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    echo -e "${curr_date} [INFO] 设置时区为Asia/Shanghai成功" >> /root/install_log.txt
  fi
  ###自动设置虚拟内存###
  [[ $(free -m | awk '/Swap:/{print $2}') == 0 ]] && bash <(curl -sL git.io/cg_swap) a
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
  echo "${red}${on_white}${bold}${curr_date} [INFO]重新登录shell工具生效 ${normal}"
}

################## buyvm挂载256G硬盘 ##################
buyvm_disk() {
  disk=$(fdisk -l | grep 256 | awk '{print $2}' | tr -d : | sed -n '1p') #获取256G磁盘名
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
      mkfs -t ext4 "$disk"1                                #格式化ext4分区
      mkdir -p 755 /home                                   #确保/home目录存在
      mount "$disk"1 /home                                 #将256G硬盘挂载到系统/home文件夹
      echo "${disk}1 /home ext4 defaults 1 2" >> /etc/fstab #第五列是dump备份设置:1，允许备份；0，忽略备份;第六列是fsck磁盘检查顺序设置:0，永不检查；/根目录分区永远为1。其它分区从2开始，数字相同，同时检查。
    else
      echo -e "256G磁盘已挂载，无须重复操作"
    fi
  fi
  mount_status_update=$(df -h | grep "$disk")
  if [ -z "$mount_status_update" ]; then
    echo -e "${curr_date} [ERROR] buyvm 256G硬盘尚未挂载到/home" >> /root/install_log.txt
  else
    echo -e "${curr_date} [INFO] buyvm 256G硬盘成功挂载到/home" >> /root/install_log.txt
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

################## 批量别名 ##################
my_alias(){
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
alias yd="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --write-auto-sub --sub-lang zh-Hans --embed-sub -i --exec 'fclone move {} cgking:{1aPplg-6egJie2tIJHakDdee39g3pJEUm} -vP'"
alias ydl="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --write-auto-sub --sub-lang zh-Hans --embed-sub -i --exec 'fclone move {} cgking:{1aPplg-6egJie2tIJHakDdee39g3pJEUm} -vP' --yes-playlist -f -k ListURL"
EOF
source /root/.bashrc
}

################## menu_go_on ##################
menu_go_on() {
  echo -e "安装日志路径：/root/install_log.txt"
  echo -e "${black}${on_white}${bold}                               我们的生活充满阳  光                               ${normal}"
  echo -e "${red}是否还要继续?${normal}"
  read -r -n1 -p "Y继续执行，其它任意键退出脚本[Y/n]" res
  echo
  case "$res" in
    Y | y)
      main_menu
      ;;
    N | n)
      exit 1
      ;;
    *)
      echo "输入错误"
      exit 1
      ;;
  esac
}

################## 主    菜    单 ##################
main_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "VPS ToolBox Menu 注：本脚本所有操作日志路径：/root/install_log.txt" --menu --nocancel "Welcome to VPS Toolbox main menu,Please Choose an option 欢迎使用VPSTOOLBOX,请选择一个选项" 20 80 10 \
  "Install_standard" "系统设置(buyvm挂载/虚拟内存/语言设置/开发环境)" \
  "Install_extend" "扩展安装(fq/离线下载三件套/网络工具/emby/挂载)" \
  "Benchmark" "效能测试"\
  "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    ## 基础标准安装
    Install_standard)
    whiptail --clear --ok-button "下一步" --backtitle "Hi,请按空格以及方向键来选择,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "Install_standard" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装/更新的软件。" 18 65 10 \
"Back" "返回上级菜单(Back to main menu)" off \
"languge" "设置系统语言" on \
"swap" "设置虚拟内存" off \
"zsh" "安装oh my zsh &tmux" off \
"buyvm" "buyvm挂载256G硬盘" off \
"kfhj" "安装python/nodejs/go开发环境" off 2>results
    while read choice
    do
      case $choice in
        Back) 
        main_menu
        break
        ;;
        languge)
        setlanguage
        ;;
        swap)
        bash <(curl -sL git.io/cg_swap)
        ;;
        zsh)
        install_beautify
        ;;
        buyvm)
        buyvm_disk
        ;;
        kfhj)
        check_python
        check_nodejs
        check_go
        ;;
        *)
        ;;
      esac
    done < results
    rm results
    exit 0
    ;;
    Install_extend)
    whiptail --clear --ok-button "下一步" --backtitle "Hi,请按空格以及方向键来选择,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "Install_extend" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装的软件。" 18 65 10 \
"Back" "返回上级菜单(Back to main menu)" off \
"alias" "自定义别名[可通过alias命令查看]" on \
"bbr" "BBR一键加速[转自HJM]" on \
"v2ray" "一键搭建V2ray[转自233boy]" off \
"offline" "离线下载3件套[aria2/rsshub/flexget]" off \
"auto_mount" "自动网盘挂载脚本[支持命令参数模式]" off \
"emby" "EMBY一键安装搭建脚本[转自wuhuai2020]" off \
"avdc" "安装配置AVDC刮削工具[转自yoshiko2]" off \
"cg_sort" "网盘文件整理" off \
"gd_bot" "搭建gd转存bot[未完成]" off \
"lnmp" "LNMP 一键脚本" off \
"baota" "宝塔面板一键脚本[转自-laowangblog.com]" off 2>results
    while read choice
    do
      case $choice in
        Back) 
        main_menu
        break
        ;;
        alias)
        my_alias
        echo -e "${curr_date} [INFO] 您设置了my_alias别名！" >> /root/install_log.txt
        ;;
        bbr)
        bash <(curl -sL git.io/cg_bbr)
        echo -e "${curr_date} [INFO] 您设置了BBR加速！" >> /root/install_log.txt
        ;;
        v2ray)
        bash <(curl -sL git.io/cg_v2ray)
        echo -e "${curr_date} [INFO] 您搭建了v2ray！" >> /root/install_log.txt
        ;;
        offline)
        bash <(curl -sL git.io/cg_dl)
        install_aria2
        install_rsshub
        run_rsshub
        install_flexget
        config_flexget
        ;;
        auto_mount)
        bash <(curl -sL git.io/cg_auto_mount)
        echo -e "${curr_date} [INFO] 您设置了自动网盘挂载！" >> /root/install_log.txt
        ;;
        emby)
        bash <(curl -sL git.io/11plus.sh)
        echo -e "${curr_date} [INFO] 您安装搭建了EMBY！" >> /root/install_log.txt
        ;;
        avdc)
        bash <(curl -sL git.io/cg_avdc)
        echo "说明：即将为您安装AV_Data_Capture-CLI-4.3.2
            这个小脚本不带参数则帮您安装AVDC
            带参数，就tmux开一个后台窗口刮削指定目录，如bash <(curl -sL git.io/cg_avdc) /home/gd，也可用本脚本的一键别名，将bash <(curl -sL git.io/cg_avdc) /home/gd设置别名为avdc，你只要输入avdc，它就开始后台刮削了"
        echo -e "${curr_date} [INFO] 您已安装AVDC！" >> /root/install_log.txt
        ;;
        cg_sort)
        bash <(curl -sL git.io/cg_sort.sh)
        ;;
        gd_bot)
        bash <(curl -sL git.io/cg_gdbot)
        ;;
        lnmp)
        install_LNMP
        ;;
        baota)
        bash <(curl -sL git.io/cg_baota)
        echo -e "${curr_date} [INFO] 您安装了宝塔面板！" >> /root/install_log.txt
        ;;
        *)
        ;;
      esac
    done < results
    rm results
    exit 0
    ;;
    Benchmark)
    clear
    if (whiptail --title "测试模式" --yes-button "快速测试" --no-button "完整测试" --yesno "效能测试方式(fast or full)?" 8 68); then
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
        else
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s full
    fi
    exit 0
    ;;
    Exit)
    whiptail --title "Bash Exited" --msgbox "Goodbye" 8 68
    exit 0
    ;;
  esac
}

################## 执  行  命  令 ##################
initialization
check_rclone
main_menu