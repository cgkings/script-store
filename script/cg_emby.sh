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
  emby_version=${emby_version:-"4.5.4.0"}
  #获取本地emby版本号
  if [[ "${release}" == "centos" ]]; then
    emby_local_version=$(rpm -q emby-server | grep -Eo "[0-9.]+\.[0-9]+")
  elif [[ "${release}" == "debian" ]] || [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "armdebian" ]]; then
    emby_local_version=$(dpkg -l emby-server | grep -Eo "[0-9.]+\.[0-9]+")
  fi
}

check_emby() {
  check_emby_version
  #判断emby本地安装状态
  if [ -f /usr/lib/systemd/system/emby-server.service ]; then
      echo -e "${curr_date} ${green}[INFO]${normal} 您的系统已安装emby $emby_local_version,关于版本升级，请在网页操作。"
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
    #安装常用插件
    echo -e "${curr_date} ${green}[INFO]${normal} 安装emby常用插件（Subscene射手字幕/JAV_scraper/Auto Organize/douban/Reports）."
    #wget -N -O kernel-
    #chown 998.998 /var/lib/emby/plugins/Emby.Subtitle.Subscene.dll  修改用户和用户组
    #chown 998.998 /var/lib/emby/plugins/JavScraper.dll
    #
    #修改emby服务,fail自动重启
    if grep -q "Restart=always" /usr/lib/systemd/system/emby-server.service; then
      echo
    else
      echo -e "${curr_date} ${green}[INFO]${normal} 修改emby服务设置fail自动重启."
      systemctl stop emby-server #结束 emby 进程
      sed -i '/[Service]/a\Restart=always\nRestartSec=2\nStartLimitInterval=0' /usr/lib/systemd/system/emby-server.service
      #破解emby
      rm -f /opt/emby-server/system/System.Net.Http.dll
      wget https://github.com/cgkings/script-store/raw/master/config/System.Net.Http.dll -O /opt/emby-server/system/System.Net.Http.dll #(注意替换掉命令中的 emby 所在目录)下载破解程序集替换原有程序
      sleep 3s
      systemctl daemon-reload && systemctl start emby-server
      whiptail --title "EMBY安装成功提示！！！" --msgbox "恭喜您EMBY安装成功，请您访问：http://${ip_addr}:8096 进一步配置Emby, 感谢使用~~~" 10 60
    fi
  fi
}

################## 备份emby ##################
bak_emby() {
  check_emby
  remote_choose
  td_id_choose
  systemctl stop emby-server #结束 emby 进程
  rm -rf /var/lib/emby/cache/* #清空cache
  cd /var/lib && tar -cvf emby_bak_"$(date "+%Y-%m-%d")".tar emby #打包/var/lib/emby
  fclone move emby_bak_"$(date "+%Y-%m-%d")".tar "$my_remote": --drive-root-folder-id "${td_id}" -vP #上传gd
  systemctl start emby-server
}

################## 还原emby ##################
revert_emby() {
    check_emby
    remote_choose
    td_id_choose
    fclone lsf "$my_remote": --drive-root-folder-id "${td_id}" --include 'emby_bak*' --files-only -F "pt" | sed 's/ /_/g;s/\;/    /g' > ~/.config/rclone/bak_list.txt
    bak_list=($(cat ~/.config/rclone/bak_list.txt))
    bak_name=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "备份文件选择" --menu --nocancel "注：上下键回车选择,ESC退出脚本！" 18 62 10 \
    "${bak_list[@]}" 3>&1 1>&2 2>&3)
    if [ -z "$bak_name" ]; then
      rm -f ~/.config/rclone/bak_list.txt
      myexit 0
    else
      systemctl stop emby-server #结束 emby 进程
      fclone copy "$my_remote":"$bak_name" /root --drive-root-folder-id "${td_id}" -vP
      rm -rf /var/lib/emby
      tar -xvf "$bak_name" -C /var/lib && rm -f "$bak_name"
      systemctl start emby-server
      rm -rf ~/.config/rclone/bak_list.txt
    fi
}

################## 卸载emby ##################
del_emby() {
  systemctl stop emby-server #结束 emby 进程
  dpkg -r --purge emby-server
}

################## 主菜单 ##################
main_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_emby。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "cg_emby 主菜单" --menu --nocancel "注：本脚本的emby安装和卸载、备份和还原需要配套使用，ESC退出" 18 80 10 \
    "install" "安装emby[已破解]" \
    "bak" "备份emby" \
    "revert" "还原emby" \
    "Uninstall" "卸载emby"
    "Install_Unattended" "无人值守(重装多选)" \
    "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    install)
      check_emby
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
    Install_Unattended)
      whiptail --clear --ok-button "回车开始执行" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "无人值守模式" --checklist --separate-output --nocancel "请按空格及方向键来多选，ESC退出" 20 54 13 \
        "Back" "返回上级菜单(Back to main menu)" off \
        "mount" "挂载gd" off \
        "swap" "自动设置2倍物理内存的虚拟内存" off \
        "install" "安装emby" off \
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
