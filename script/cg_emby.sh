#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_emby)
# File Name: cg_emby.sh
# Author: cgkings
# Created Time : 2021.3.4
# Description:swap一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
ip_addr=$(hostname -I | awk '{print $1}')
emby_version="4.6.4.0"
emby_local_version=$(dpkg -l emby-server | grep -Eo "[0-9.]+\.[0-9]+")
emby_local_version=${emby_local_version:-"未安装"}

################## 检查挂载状态 ##################
check_mount() {
  mount_status=$(pgrep -f "mount"|wc -l)
  if [ "$mount_status" -gt 0 ];then
    mount_info="存在"
  else
    mount_info="不存在"
  fi
}

################## 安装emby ##################
check_emby() {
  #判断emby本地安装状态
  if [ -f /usr/lib/systemd/system/emby-server.service ]; then
    if [ "$emby_local_version" = "$emby_version" ]; then
      echo -e "${curr_date} [INFO] 本机原emby版本为 $emby_local_version,无须重复安装"
    else
      echo -e "${curr_date} [INFO] 本机原emby版本为 $emby_local_version，建议安装为 $emby_version"
    fi
  else
    #如未安装，则进行安装
    echo -e "${curr_date} [INFO] emby $emby_version 不存在.正在为您安装，请稍等..."
    wget -vN https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-deb_"${emby_version}"_amd64.deb
    dpkg -i emby-server-deb_"${emby_version}"_amd64.deb
    sleep 1s
    rm -f emby-server-deb_"${emby_version}"_amd64.deb
    whiptail --title "EMBY安装成功提示！！！" --msgbox "恭喜您EMBY $emby_version 安装成功，请您访问：http://${ip_addr}:8096 进一步配置Emby, 感谢使用~~~" 10 60
  fi
}

##################破解emby####################
crack_emby() {
  systemctl stop emby-server
  #修改emby服务,fail自动重启
  if grep -s "Restart=on-failure" /usr/lib/systemd/system/emby-server.service; then
    echo -e "${curr_date} [INFO] emby服务已设置fail自动重启,无需重复设置."
  else
    sed -i '/[Service]/a\Restart=on-failure\nRestartSec=2\nStartLimitInterval=0' /usr/lib/systemd/system/emby-server.service
    echo -e "${curr_date} [INFO] emby服务已设置fail自动重启."
  fi
  if [ "$emby_local_version" = "$emby_version" ]; then
    #破解emby
    rm -rf /opt/emby-server/system/System.Net.Http.dll /opt/emby-server/system/dashboard-ui/embypremiere/embypremiere.js /opt/emby-server/system/Emby.Web.dll
    wget -q https://github.com/cgkings/script-store/raw/master/config/emby/System.Net.Http.dll -O /opt/emby-server/system/System.Net.Http.dll --no-check-certificate
    wget -q https://raw.githubusercontent.com/cgkings/script-store/master/config/emby/464crack/embypremiere.js -O /opt/emby-server/system/dashboard-ui/embypremiere/embypremiere.js --no-check-certificate
    wget -q https://github.com/cgkings/script-store/raw/master/config/emby/464crack/Emby.Web.dll -O /opt/emby-server/system/Emby.Web.dll --no-check-certificate
    sleep 3s
    systemctl daemon-reload && systemctl restart emby-server
    whiptail --title "EMBY破解成功提示！！！" --msgbox "恭喜您EMBY $emby_version 破解成功，请您访问：http://${ip_addr}:8096 输入任意值密钥解锁会员, 感谢使用~~~" 10 60
  else
    echo -e "${curr_date} [ERROR] 您的emby版本为 $emby_local_version，本脚本破解功能仅支持 $emby_version"
    exit 0
  fi
}

################## 备份emby ##################
bak_emby() {
  check_emby
  remote_choose
  td_id_choose
  systemctl stop emby-server #结束 emby 进程
  #rm -rf /var/lib/emby/cache/* #清空cache
  cd /var/lib && tar -cvf emby_bak_"$(date "+%Y-%m-%d")".tar emby #打包/var/lib/emby
  fclone move emby_bak_"$(date "+%Y-%m-%d")".tar "$my_remote": --drive-root-folder-id "${td_id}" -vP #上传gd
  systemctl start emby-server
  echo -e "${curr_date} [INFO] emby备份完毕."
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
      echo -e "${curr_date} [INFO] emby还原完毕."
  fi
}

################## 卸载emby ##################
check_caddy() {
  if [ -z "$(command -v caddy)" ]; then
    echo -e "${debug_message} ${yellow}${jiacu}caddy${normal} 不存在.正在为您安装，请稍后..." | tee -a /root/install_log.txt
    echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
    | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list
    sudo apt update
    sudo apt install caddy
  fi
}






################## 卸载emby ##################
del_emby() {
  systemctl stop emby-server #结束 emby 进程
  dpkg --purge emby-server
}

################## 主菜单 ##################
cg_emby_main_menu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_emby。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "cg_emby 主菜单" --menu --nocancel "本机emby版本号:$emby_local_version\n挂载进程:$mount_info\n注：本脚本适配emby$emby_version，ESC退出" 19 50 7 \
    "Install" "==>安 装 emby" \
    "Crack" "==>破 解 emby" \
    "Bak" "==>备 份 emby" \
    "Revert" "==>还 原 emby" \
    "Uninstall" "==>卸 载 emby" \
    "Automation" "自用无人值守" \
    "Exit" "退 出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Install)
      check_emby
      cg_emby_main_menu
      ;;
    Crack)
      crack_emby
      cg_emby_main_menu
      ;;
    Bak)
      bak_emby
      cg_emby_main_menu
      ;;
    Revert)
      revert_emby
      cg_emby_main_menu
      ;;
    Uninstall)
      del_emby
      cg_emby_main_menu
      ;;
    Automation)
      whiptail --clear --ok-button "回车开始执行" --backtitle "Hi,欢迎使用cg_toolbox。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "无人值守模式" --checklist --separate-output --nocancel "请按空格及方向键来多选，ESC退出" 20 54 13 \
        "Back" "返回上级菜单(Back to main menu)" off \
        "mount" "挂载gd" off \
        "swap" "自动设置2倍物理内存的虚拟内存" off \
        "install" "安装emby" off \
        "revert" "还原emby" off 2> results
      while read choice; do
        case $choice in
          Back)
            cg_emby_main_menu
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

################## 执行命令 ##################
check_sys
check_rclone
check_mount
cg_emby_main_menu