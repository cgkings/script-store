#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_emby)
# File Name: cg_emby.sh
# Author: cgkings
# Created Time : 2021.3.4
# Description:swap一键脚本
# System Required: Debian/Ubuntu
# 感谢wuhuai2020、moerats、github众多作者，我只是整合代码
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor
ip_addr=$(hostname -I | awk '{print $1}')

################## 安装emby ##################
check_emby_version() {
  #获取官网最新正式版版本号(排除beta版)
  emby_version=$(curl -s https://github.com/MediaBrowser/Emby.Releases/releases/ | grep -Eo "tag/[0-9.]+\">([0-9.]+.*)" | grep -v "beta" | grep -Eo "[0-9.]+" | head -n1)
  #获取本地emby版本号
  if [[ "${release}" == "centos" ]]; then
    emby_local_version=$(rpm -q emby-server | grep -Eo "[0-9.]+\.[0-9]+")
  elif [[ "${release}" == "debian" ]] || [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "armdebian" ]]; then
    emby_local_version=$(dpkg -l emby-server | grep -Eo "[0-9.]+\.[0-9]+")
  fi
}

check_emby() {
  #判断emby本地安装状态
  if [ -f /usr/lib/systemd/system/emby-server.service ]; then
    #如已安装，获取本地安装的emby版本
    check_emby_local_version
    if [ "${emby_local_version}" = "${emby_version}" ]; then
      sleep 1s
      echo
      echo -e "${curr_date} ${green}[INFO]${normal} 您的系统已安装最新版emby。"
      return 0
    else
      sleep 1s
      echo -e "${curr_date} ${green}[INFO]${normal} 已安装版本为：${emby_local_version}.最新版本为:${emby_version}.请自便！"
      return 0
    fi
  else
    #如未安装，则进行安装
    echo -e "${curr_date} ${green}[INFO]${normal} 您的系统是 ${release}。正在为您准备安装包,请稍等..."
    if [[ "${release}" == "centos" ]]; then
      yum install https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-rpm_"${emby_version}"_x86_64.rpm
    elif [[ "${release}" == "debian" ]] || [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "armdebian" ]]; then
      wget -vN https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-deb_"${emby_version}"_amd64.deb
      dpkg -i emby-server-deb_"${emby_version}"_amd64.deb
      sleep 1s
      rm -f emby-server-deb_"${emby_version}"_amd64.deb
    fi
    echo -e "${curr_date} ${green}[INFO]${normal} Emby安装成功.您可以访问  http://${ip_addr}:8096 进一步配置Emby."
  fi
}

################## 破解emby ##################
pojie_emby() {
  sudo -i #切换为 root 用户
  systemctl stop emby-server #结束 emby 进程
  rm -f /opt/emby-server/system/System.Net.Http.dll
  wget https://github.com/cgkings/script-store/raw/master/config/System.Net.Http.dll -O /opt/emby-server/system/System.Net.Http.dll #(注意替换掉命令中的 emby 所在目录)下载破解程序集替换原有程序
  sleep 3s
  systemctl daemon-reload && systemctl start emby-server
}

################## 修改emby服务,fail自动重启 ##################
sys_emby() {
  sudo -i #切换为 root 用户
  systemctl stop emby-server #结束 emby 进程
  sed -i '/[Service]/a\Restart=always\nRestartSec=2\nStartLimitInterval=0' /usr/lib/systemd/system/emby-server.service
  systemctl daemon-reload && systemctl start emby-server
}

################## 备份emby ##################
bak_emby() {
  check_emby
  systemctl stop emby-server #结束 emby 进程
  rm -rf /var/lib/emby/cache/* #清空cache
  cd /var/lib && tar -cvf emby_bak.tar emby #打包/var/lib/emby
  rclone move 'emby_bak.tar' "$my_remote": -vP #上传gd
  systemctl start emby-server
}

################## 还原emby ##################
revert_emby() {
    systemctl stop emby-server #结束 emby 进程
    fclone copy wdc:emby_bak.tar /root -vP
    rm -rf /var/lib/emby
    tar -xvf emby_bak.tar -C /var/lib && rm -f emby_bak.tar
    systemctl start emby-server
}

################## 卸载emby ##################
del_emby() {
  systemctl stop emby-server #结束 emby 进程
  dpkg -r --purge emby-server
}

################## 主菜单 ##################
main_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_emby。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "cg_emby 主菜单" --menu --nocancel "注：本脚本的emby安装和卸载、备份和还原需要配套使用，ESC退出" 18 80 10 \
    "Install_standard" "基础安装(分项单选)" \
    "Install_Unattended" "无人值守(重装多选)" \
    "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Install_standard)
      standard_menu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_emby。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "单选模式" --menu --nocancel "注：本脚本的emby安装和卸载、备份和还原需要配套使用，ESC退出" 22 65 10 \
      "Back" "返回上级菜单(Back to main menu)" \
      "install" "安装emby" \
      "pojie" "破解emby" \
      "youhua" "优化emby（fail自动重启）" \
      "bak" "备份emby" \
      "revert" "还原emby" \
      "Uninstall" "卸载emby" 3>&1 1>&2 2>&3)
      case $standard_menu in
        Back)
        main_menu
        ;;
        install)
        check_emby
        ;;
        pojie)
        pojie_emby
        ;;
        youhua)
        sys_emby
        ;;
        bak)
        bak_emby
        ;;
        revert)
        revert_emby
        ;;
        Uninstall)
        del_emby
        ;;
        *)
        myexit 0
        ;;
      esac
    ;;
    Install_Unattended)
      whiptail --clear --ok-button "回车开始执行" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "无人值守模式" --checklist --separate-output --nocancel "请按空格及方向键来多选，ESC退出" 20 54 13 \
        "Back" "返回上级菜单(Back to main menu)" off \
        "mount" "挂载gd" off \
        "swap" "自动设置2倍物理内存的虚拟内存" off \
        "install" "安装emby" off \
        "pojie" "破解emby" off \
        "youhua" "优化emby（fail自动重启）" off \
        "revert" "还原emby" off 2> results
      while read choice; do
        case $choice in
          Back)
            main_menu
            break
            ;;
          mount)
            remote_choose
            td_id_choose
            dir_choose
            bash <(curl -sL git.io/cg_mount.sh) s $my_remote $td_id $mount_path
            ;;
          swap)
            bash <(curl -sL git.io/cg_swap) a
            ;;
          install)
            check_emby
            ;;
          pojie)
            pojie_emby
          ;;
          youhua)
            sys_emby
            ;;
          revert)
            revert_emby
            ;;
          *)
            myexit 0          
            ;;
        esac
      done < results
      rm results
      ;;
    Exit | *)
      myexit 0
      ;;
  esac
}

check_sys
check_release
check_rclone
main_menu
#/usr/lib/systemd/system/rclone-mntgd.service
#/usr/lib/systemd/system/emby-server.service