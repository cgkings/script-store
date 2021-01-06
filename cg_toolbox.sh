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
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 系统初始化设置【颜色、时区、语言、file-max】 ##################
initialization() {
  #安装常用软件
  apt-get update --fix-missing -y && apt upgrade -y
  apt-get -y install git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq tar expect ca-certificates findutils gzip dpkg
  echo -e "${curr_date} [info] 常用软件安装列表：git make curl wget tree vim nano tmux unzip htop zsh parted nethogs screen sudo ntpdate manpages-zh screenfetch fonts-powerline file zip jq tar expect ca-certificates findutils gzip dpkg" >> /root/install_log.txt
  #设置颜色
  cat >> /root/.bashrc << EOF
if [ "$TERM" == "xterm" ]; then
  export TERM=xterm-256color
fi
EOF
  source ~/.bashrc
  if [ $(tput colors) == 256 ]; then
    echo -e "${curr_date} [info] 设置256色成功" >> /root/install_log.txt
  else
    echo -e "${curr_date} [error] 设置256色失败" >> /root/install_log.txt
  fi
  #设置时区
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
  echo -e "${curr_date} [info] 设置时区为Asia/Shanghai成功" >> /root/install_log.txt
  ntpdate cn.ntp.org.cn #同步时间
  #设置语言
  apt-get install -y locales
  echo "LANG=en_US.UTF-8" > /etc/default/locale
  cat > /etc/locale.gen << EOF
  en_US.UTF-8 UTF-8
  zh_CN.UTF-8 UTF-8
EOF
  locale-gen
  echo -e "${curr_date} [info] 设置语言为en_US.UTF-8成功" >> /root/install_log.txt
  #file-max设置，解决too many open files问题
  cat >> /etc/sysctl.conf << EOF
fs.file-max = 6553500
EOF
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
  cat >> /etc/pam.d/common-session << EOF
session required pam_limits.so
EOF
  if [ $(ulimit -n) == 65535 ]; then
    echo -e "${curr_date} [info] file_max 修改成功" >> /root/install_log.txt
  else
    echo -e "${curr_date} [error] file_max 修改失败" >> /root/install_log.txt
  fi
}

################## 安装各种开发环境 ##################
install_environment() {
  #安装基础开发环境
  apt-get update --fix-missing -y && apt upgrade -y
  apt-get -y install build-essential libncurses5-dev libpcap-dev libffi-dev  #yum groupinstall "Development Tools"
  echo -e "${curr_date} [info] 基础开发环境build-essential&libncurses5-dev&libpcap-dev&libffi-dev已安装" >> /root/install_log.txt
  #安装python环境
  apt-get -y install python python3 python3-pip python3-distutils 
  pip3 install --upgrade pip
  pip3 install --upgrade setuptools
  pip install requests scrapy Pillow baidu-api pysocks cloudscraper fire pipenv delegator.py python-telegram-bot
  echo -e "${curr_date} [info] python已安装,pip已升级，依赖安装列表：requests scrapy Pillow baidu-api pysocks cloudscraper fire pipenv delegator.py python-telegram-bot" >> /root/install_log.txt
  #安装nodejs环境
  apt-get -y install nodejs npm
  npm i --save module-alias
  npm install -g yarn n dotenv https-proxy-agent --force
  npm install npm@latest -g #更新npm
  n stable  #更新node
  yarn set version latest
  echo -e "${curr_date} [info] nodejs&npm已安装,yarn&n已安装" >> /root/install_log.txt
  #安装go环境
  wget -qN https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -O /root/go.tar.gz && tar -zxf /root/go.tar.gz -C /home && rm -f /root/go.tar.gz
  cat >> /etc/profile << EOF
export PATH=$PATH:/home/go/bin
export GOROOT=/home/go
export GOPATH=/home/go/gopath
EOF
  echo -e "${curr_date} [info] go1.15.6环境已安装,go库路径：/home/go/gopath" >> /root/install_log.txt
  apt autoremove -y
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
  [ -z "$(grep "autoload -U compinit && compinit" ~/.zshrc)" ] && echo "autoload -U compinit && compinit" >> ~/.zshrc
  sed -i '/^plugins=/c\plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' ~/.zshrc
  echo -e "alias c="clear"\nalias 6pan="/root/six-cli"" >> /root/.zshrc
  source ~/.zshrc
  chsh -s zsh
  touch ~/.hushlogin #不显示开机提示语
  echo -e "${curr_date} [info] 装逼神器之oh my zsh 已安装" >> /root/install_log.txt
  #安装oh my tmux
  cd /root && git clone https://github.com/gpakosz/.tmux.git
  ln -s -f .tmux/.tmux.conf
  cp .tmux/.tmux.conf.local .
  echo -e "${curr_date} [info] 装逼神器之oh my tmux 已安装" >> /root/install_log.txt
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
      fdisk $disk << EOF
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
      partprobe                                            #不重启重新读取分区信息
      mkfs -t ext4 "$disk"1                                #格式化ext4分区
      mkdir -p /home                                       #确保/home目录存在
      mount "$disk"1 /home                                 #将256G硬盘挂载到系统/home文件夹
      echo "${disk}1 /home ext4 defaults 1 2" >> /etc/fstab #第五列是dump备份设置:1，允许备份；0，忽略备份;第六列是fsck磁盘检查顺序设置:0，永不检查；/根目录分区永远为1。其它分区从2开始，数字相同，同时检查。
    fi
  fi
  mount_status=$(df -h | grep $disk)
  if [ -n $mount_status ]; then
    echo -e "${curr_date} [info] buyvm 256G硬盘成功挂载到/home" >> /root/install_log.txt
  else
    echo -e "${curr_date} [error] buyvm 256G硬盘成功挂载到/home" >> /root/install_log.txt
  fi
}

################## 安装rclone/fclone ##################[未完成]
install_rclone() {
  check_rclone
  read -p "即将为你解压sa文件夹及rclone conf文件，请输入解压密码：" zip_password
  wget -qN https:// -O /root/sa1.zip && unzip -qo /root/sa1.zip -d /root -P $zip_password && rm -f /root/sa1.zip
  wget -qN https:// -O /root/sa2.zip && unzip -qo /root/sa2.zip -d /root -P $zip_password && rm -f /root/sa2.zip
  wget -qN https:// -O /root/rclone_conf.zip && unzip -qo /root/rclone_conf.zip -d /root/.config/rclone -P $zip_password && rm -f /root/rclone_conf.zip
  echo -e "${curr_date} [info] rclone&fclone已安装,sa及conf文件已下载解压" >> /root/install_log.txt
  wget -qN https://github.com/cgkings/script-store/raw/master/tools/six-cli_v0.0.7-alpha_linux_amd64.tar.gz -O /root/six-cli.tar.gz && tar -zxf /root/six-cli.tar.gz -C /bin && chmod 777 /bin/six-cli && rm -f /root/six-cli.tar.gz
  echo -e "${curr_date} [info] 6盘six-cli已安装！" >> /root/install_log.txt
  wget -qN https://raw.githubusercontent.com/cgkings/script-store/master/tools/aria2cli.py -O /bin/aria2cli.py && chmod 777 /bin/aria2cli.py
  echo -e "${curr_date} [info] aria2cli.py已安装！" >> /root/install_log.txt
  wget -qN https://yt-dl.org/downloads/latest/youtube-dl -O /bin/youtube-dl && chmod a+rx /bin/youtube-dl
  echo -e "${curr_date} [info] youtube-dl已安装！" >> /root/install_log.txt
}

################## 安装配置aria2自动下载上传 ##################
install_aria2() {
  cd /root
  bash <(curl -sL git.io/aria2.sh) << EOF
1 
EOF
  #修改默认本地下载路径为/home/download
  mkdir -p /home/download
  bash <(curl -sL git.io/aria2.sh) << EOF
7 
3 
/home/download 
EOF
  #修改完成后执行的脚本为自动上传
  sed -i 's/clean.sh/upload.sh/g' /root/.aria2c/aria2.conf
  #修改自动上传的工具，由rclone改为fclone
  sed -i 's/rclone move/fclone move/g' /root/.aria2c/upload.sh
  #输入自动上传的fclone remote
  read -p "请输入自动上传的fclone remote:" fclone_remote
  fclone backend lsdrives $fclone_remote: | awk '{ print FNR " " $0}' > ~/.config/rclone/"$fclone_remote"_drivelist.txt
  drive_id=$(sed -n '/'$fclone_remote'/,/\[/p' ~/.config/rclone/rclone.conf | awk '/team_drive/{print $3}' | sed -n '1p')
  if [ -z $drive_id ]; then
    echo -e "$curr_date ${red}[error]您的remote或remote下的team_drive id为空${normal}"
    return
  fi
  #清空~/.config/rclone/rclone.conf内的相应root id
  rootid=$(sed -n '/'$fclone_remote'/,/\[/p' ~/.config/rclone/rclone.conf | grep 'root_folder_id' | sed -n '1p')
  sed -i "s/$rootid/root_folder_id = /g" ~/.config/rclone/rclone.conf
  #获取drive_name
  drive_name=$(cat ~/.config/rclone/"$fclone_remote"_drivelist.txt | awk '/'$drive_id'/{print $3}')
  #设置自动上传的fclone remote
  sed -i 's/drive-name=.*$/drive-name='$fclone_remote'/g' /root/.aria2c/script.conf
  #设置自动上传网盘目录
  sed -i 's/#drive-dir=.*$/drive-dir=\/Download/g' /root/.aria2c/script.conf
  echo -e "$curr_date ${red}[Info]您选择的remote为：${fclone_remote}，自动上传目录为：${drive_name}/Download"
  service aria2 restart
  aria2_install_status=$(/root/.aria2c/upload.sh | sed -n '4p')
  if [[ "$aria2_install_status" == "success" ]]; then
    echo -e "${curr_date} [info] aria2自动上传已安装配置成功！
    本地下载目录为：/home/download
    remote为：${fclone_remote}，自动上传目录为：${drive_name}/Download" >> /root/install_log.txt
  else
    echo -e "${curr_date} [error] aria2自动上传安装配置失败！" >> /root/install_log.txt
  fi
}

################## menu_go_on ##################
menu_go_on() {
  echo -e "安装日志路径：/root/install_log.txt"
  echo -e " ${black}${on_white}${bold}                           menu_go_on                               ${normal} "
  echo -e "${red}是否继续执行脚本?${normal}"
  read -n1 -p "Y继续执行，其它任意键退出脚本[Y/n]" res
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
  clear
  cat << EOF
${on_black}${white}                ${bold}VPS一键脚本 for Ubuntu/Debian系统    by cgkings 王大锤              ${normal}
${blue}${bold}————————————————————————————————系 统 相 关—————————————————————————————————————${normal}
${green}${bold}A1、${normal}系统初始化设置[颜色/时区/语言/maxfile/常用工具]
${green}${bold}A2、${normal}安装各种开发环境[python/nodejs/go]
${green}${bold}A3、${normal}设置虚拟内存[支持命令参数模式]
${green}${bold}A4、${normal}安装装逼神器 oh my zsh & on my tmux
${green}${bold}A5、${normal}buyvm挂载256G硬盘
${blue}${bold}————————————————————————————————离 线 转 存—————————————————————————————————————${normal}
${green}${bold}B1、${normal}安装rclone/fclone/6pan-cli/aria2cli/youtube-dl[包括sa/conf备份还原]
${green}${bold}B2、${normal}安装配置aria2一键增强[转自P3TERX]
${green}${bold}B3、${normal}安装配置rsshub/flexget自动添加种子
${green}${bold}B4、${normal}搭建shellbot，TG控制vps下载、转存[包含一键gd转存，具备限时定量定向分盘序列功能] #未完成
${blue}${bold}————————————————————————————————网 络 相 关—————————————————————————————————————${normal}
${green}${bold}C1、${normal}BBR一键加速[转自-忘记抄的谁的了]
${green}${bold}C2、${normal}一键搭建V2ray[转自233boy]
${green}${bold}C3、${normal}宝塔面板一键脚本[转自-laowangblog.com]
${blue}${bold}————————————————————————————————EMBY  相 关—————————————————————————————————————${normal}
${green}${bold}D1、${normal}自动网盘挂载脚本[支持命令参数模式]
${green}${bold}D2、${normal}安装配置AVDC刮削工具[转自yoshiko2]
${green}${bold}D3、${normal}EMBY一键安装搭建脚本[转自wuhuai2020 & why]
${blue}${bold}————————————————————————————————————————————————————————————————————————————————${normal}
${green}${bold}al、${normal}新机安装[A1-A4,B1-B4,D2]
${green}${bold}qq、${normal}退出脚本
${blue}${bold}————————————————————————————————————————————————————————————————————————————————${normal}
EOF
  read -n2 -p "${green}${bold}请输入选择 [A1-D3]:${normal}" num
  case "$num" in
    A1 | a1)
      echo
      initialization
      menu_go_on
      ;;
    A2 | a2)
      echo
      install_environment
      menu_go_on
      ;;
    A3 | a3)
      echo
      bash <(curl -sL git.io/cg_swap) a
      echo -e "${curr_date} [info] 您设置了虚拟内存！" >> /root/install_log.txt
      menu_go_on
      ;;
    A4 | a4)
      echo
      install_beautify
      menu_go_on
      ;;
    A5 | a5)
      echo
      buyvm_disk
      menu_go_on
      ;;
    B1 | b1)
      echo
      install_rclone
      menu_go_on
      ;;
    B2 | b2)
      echo
      install_aria2
      menu_go_on
      ;;
    B3 | b3)
      echo
      bash <(curl -sL git.io/cg_flexget)
      echo -e "${curr_date} [info] 您安装配置了RSSHUB和flexget！" >> /root/install_log.txt
      menu_go_on
      ;;
    B4 | b4)
      echo
      menu_go_on
      ;;
    C1 | c1)
      echo
      bash <(curl -sL git.io/cg_bbr)
      echo -e "${curr_date} [info] 您设置了BBR加速！" >> /root/install_log.txt
      menu_go_on
      ;;
    C2 | c2)
      echo
      bash <(curl -sL git.io/cg_v2ray)
      echo -e "${curr_date} [info] 您搭建了v2ray！" >> /root/install_log.txt
      menu_go_on
      ;;
    C3 | c3)
      echo
      bash <(curl -sL git.io/cg_baota)
      echo -e "${curr_date} [info] 您安装了宝塔面板！" >> /root/install_log.txt
      menu_go_on
      ;;
    D1 | d1)
      echo
      bash <(curl -sL git.io/cg_auto_mount)
      echo -e "${curr_date} [info] 您设置了自动网盘挂载！" >> /root/install_log.txt
      menu_go_on
      ;;
    D2 | d2)
      echo
      bash <(curl -sL git.io/cg_avdc)
      echo "说明：即将为您安装AV_Data_Capture-CLI-4.3.2
            这个小脚本不带参数则帮您安装AVDC
            带参数，就tmux开一个后台窗口刮削指定目录，如bash <(curl -sL git.io/cg_avdc) /home/gd，也可用本脚本的一键别名，将bash <(curl -sL git.io/cg_avdc) /home/gd设置别名为avdc，你只要输入avdc，它就开始后台刮削了"
      echo -e "${curr_date} [info] 您已安装AVDC！" >> /root/install_log.txt
      menu_go_on
      ;;
    D3 | d3)
      echo
      bash <(curl -sL https://git.io/11plus.sh)
      echo -e "${curr_date} [info] 您安装搭建了EMBY！" >> /root/install_log.txt
      menu_go_on
      ;;
    AL | al)
      echo
      initialization
      install_environment
      bash <(curl -sL git.io/cg_swap) a
      echo -e "${curr_date} [info] 您设置了虚拟内存！" >> /root/install_log.txt
      install_beautify
      install_rclone
      install_aria2
      bash <(curl -sL git.io/cg_flexget) 20
      echo -e "${curr_date} [info] 您安装配置了RSSHUB和flexget！" >> /root/install_log.txt
      bash <(curl -sL git.io/cg_avdc)
      echo "说明：即将为您安装AV_Data_Capture-CLI-4.3.2
            这个小脚本不带参数则帮您安装AVDC
            带参数，就tmux开一个后台窗口刮削指定目录，如bash <(curl -sL git.io/cg_avdc) /home/gd，也可用本脚本的一键别名，将bash <(curl -sL git.io/cg_avdc) /home/gd设置别名为avdc，你只要输入avdc，它就开始后台刮削了"
      echo -e "${curr_date} [info] 您已安装AVDC！" >> /root/install_log.txt
      menu_go_on
      ;;
    QQ | qq)
      echo
      menu_go_on
      ;;
    *)
      echo
      echo "输入错误，请重新输入"
      main_menu
      ;;
  esac
}

################## 执  行  命  令 ##################
main_menu

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