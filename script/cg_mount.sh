#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_mount)
# File Name: automount
# Author: cgkings
# Created Time : 2020.12.25
# Description:挂载一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 选择挂载路径 ##################[done]
dir_check() {
  if [[ ${mount_path} =~ "/" ]]; then
    if [ ! -d "$mount_path" ]; then
      echo -e "$curr_date [警告] ${mount_path} 不存在，正在创建..."
      mkdir -p 755 "$mount_path"
      sleep 1s
      echo -e "$curr_date [Info] ${mount_path}创建完成！"
    fi
  else
    mount_path="/mnt/$mount_path"
    if [ ! -d "$mount_path" ]; then
      echo -e "$curr_date [警告] ${mount_path} 不存在，正在创建..."
      mkdir -p 755 "$mount_path"
      sleep 1s
      echo -e "$curr_date [Info] /mnt/$mount_path创建完成！"
    fi
  fi
  mount_path_name=$(echo "$mount_path" | sed 's/[/]//g' | sed 's/ //g')
}

dir_choose() {
  mount_path=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "本地挂载路径输入" --nocancel '注：默认值：/mnt/gd,如路径不含“/”,则挂载路径视为：/mnt/你的输入,ESC退出脚本' 10 68 /mnt/gd 3>&1 1>&2 2>&3)
  if [ -z "$mount_path" ]; then
    myexit 0
  else
    dir_check
  fi
}

################## 删除服务 ##################
mount_del() {
  if [ -z "$mount_path_name" ]; then
    mount_path_name=$(echo "$mount_path" | sed 's/[/]//g' | sed 's/ //g')
  fi
  echo -e "$curr_date [Info] 正在执行fusermount -qzu /mnt/gd..."
  fusermount -qzu /mnt/gd
  echo -e "$curr_date [Info] fusermount -qzu /mnt/gd [done]"
  echo -e "$curr_date [Info] 正在检查服务是否存在..."
  if [ -f /lib/systemd/system/rclone-mntgd.service ]; then
    echo -e "$curr_date [Info] 找到服务 rclone-mntgd.service 正在删除，请稍等..."
    systemctl stop rclone-mntgd.service
    systemctl disable rclone-mntgd.service
    rm /lib/systemd/system/rclone-mntgd.service
    sleep 2s
    echo -e "$curr_date [Info] 删除服务[done]"
  else
    echo -e "$curr_date [Debug] 你没创建过服务!"
  fi
  echo -e "$curr_date [Info] 删除挂载[done]"
}

################## 临  时  挂  载 ##################
mount_creat() {
  choose_mount_tag
  mount_del
  echo -e "$curr_date [Info] 开始临时挂载到/mnt/gd..."
  echo -e "$curr_date [Info] 挂载命令：fclone mount ${my_remote}: /mnt/gd --drive-root-folder-id ${td_id} ${mount_tag} &"
  fclone mount $my_remote: /mnt/gd --drive-root-folder-id ${td_id} $mount_tag &
  sleep 5s
  echo -e "$curr_date [Info] 临时挂载[done]"
  df -h
}

################## 创建开机挂载服务 ##################
mount_server_creat() {
  choose_mount_tag
  mount_del
  echo -e "$curr_date [Info] 正在创建服务 rclone-mntgd.service 请稍等..."
  cat > /lib/systemd/system/rclone-mntgd.service << EOF
[Unit]
Description = rclone-mntgd
AssertPathIsDirectory = /mnt/gd
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
KillMode=none
User=root
ExecStart=fclone mount ${my_remote}: /mnt/gd --drive-root-folder-id ${td_id} ${mount_tag}
ExecStop=fusermount -qzu /mnt/gd
Restart=on-abort
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
  sleep 2s
  echo -e "$curr_date [Info] 服务创建成功。"
  sleep 2s
  echo -e "$curr_date [Info] 启动服务..."
  systemctl start rclone-mntgd.service
  sleep 1s
  echo -e "$curr_date [Info] 添加开机启动..."
  systemctl enable rclone-mntgd.service
  if [[ $? ]]; then
    echo -e "$curr_date [Info] 创建服务 rclone-mntgd.service.并已添加开机挂载.\n您可以通过 systemctl [start|stop|status] 进行挂载服务管理。"
    sleep 2s
  else
    echo
    echo -e "$curr_date [警告] 未知错误."
  fi
  df -h
}

################## 选择挂载参数 ##################
choose_mount_tag() {
  choose_mount_tag_status=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "选择挂载参数" --menu --nocancel "注：默认缓存目录为/home/cache，ESC退出脚本" 12 80 3 \
    "1" "扫库参数[单文件内存缓冲 16M,缓存块 1M,缓存步进32M ]" \
    "2" "观看参数[单文件内存缓冲512M,缓存块32M,缓存步进128M,硬盘缓冲辅助512M]" \
    "3" "退出脚本" 3>&1 1>&2 2>&3)
  case $choose_mount_tag_status in
    1)
      mount_tag="--use-mmap --umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-chunk-size 1M"
      ;;
    2)
      mount_tag="--use-mmap --umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --cache-dir=/home/cache --vfs-cache-mode full --buffer-size 256M --vfs-read-ahead 512M --vfs-read-chunk-size 32M --vfs-read-chunk-size-limit 128M --vfs-cache-max-size 20G"
      ;;
    3 | *)
      myexit 0
      ;;
  esac
}

################## 开  始  菜  单 ##################
mount_menu() {
  clear
  if [ -f /lib/systemd/system/rclone-mntgd.service ]; then
    if systemctl | grep "rclone"; then
      curr_mount_status="已挂载，挂载盘ID为 $(ps -eo cmd|grep "fclone mount"|grep -v grep|awk '{print $6}')"
    else
      systemctl daemon-reload && systemctl restart rclone-mntgd.service
      sleep 2s
      curr_mount_status="已挂载，挂载盘ID为 $(ps -eo cmd|grep "fclone mount"|grep -v grep|awk '{print $6}')"
    fi
  else
    curr_mount_status="未挂载"
  fi
  curr_mount_tag=$(ps -eo cmd|grep "fclone mount"|grep -v grep|awk '{for (i=7;i<=NF;i++)printf("%s ", $i);print ""}')
  if [ -n "$curr_mount_tag" ]; then
    mount_server_name=$(systemctl|grep "rclone"|awk '{print $1}')
    if echo "$curr_mount_tag"|grep "vfs-read-chunk-size"; then
      curr_mount_tag_status="扫库参数"
    elif echo "$curr_mount_tag"|grep "buffer-size"; then
      curr_mount_tag_status="观看参数"
    fi
  fi
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "一键挂载 菜单模式" --menu --nocancel "挂载状态：$curr_mount_status\n挂载参数：$curr_mount_tag_status\n注：ESC退出脚本" 16 55 6 \
    "start_mount" "   开始挂载" \
    "delete_mount" "   删除挂载" \
    "switch_mount" "   切换挂载" \
    "switch_tag" "   切换参数" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    start_mount)
      echo
      remote_choose
      td_id_choose
      mount_server_creat
      ;;
    delete_mount)
      echo
      mount_del
      ;;
    switch_mount)
      echo
      mount_del
      remote_choose
      td_id_choose
      mount_server_creat
      ;;
    switch_tag)
      echo
      if [ -z "${curr_mount_tag_status}" ]; then
        TERM=ansi whiptail --title "警告" --infobox "还没挂载，切换个锤子的挂载参数" 8 68
        mount_menu
      elif [ "${curr_mount_tag_status}" == "扫库参数" ]; then
        systemctl stop "$mount_server_name"
        sed -i 's/--vfs-read-chunk-size 1M --vfs-read-chunk-size-limit 32M/--buffer-size 256M --vfs-read-ahead 500M --vfs-read-chunk-size 16M --vfs-read-chunk-size-limit 2G --vfs-cache-max-size 20G/g' /lib/systemd/system/"$mount_server_name"
        systemctl daemon-reload && systemctl restart "$mount_server_name"
      elif [ "${curr_mount_tag_status}" == "观看参数" ]; then
        systemctl stop "$mount_server_name"
        sed -i 's/--buffer-size 256M --vfs-read-ahead 500M --vfs-read-chunk-size 16M --vfs-read-chunk-size-limit 2G --vfs-cache-max-size 20G/--vfs-read-chunk-size 1M --vfs-read-chunk-size-limit 32M/g' /lib/systemd/system/"$mount_server_name"
        systemctl daemon-reload && systemctl restart "$mount_server_name"
      fi
      ;;
    *)
      myexit 0
      ;;
  esac
}

################## 执  行  命  令 ##################
check_sys
check_rclone
if [ ! -f /etc/fuse.conf ]; then
  echo -e "$curr_date 未找到fuse包.正在安装..."
  sleep 1s
  sudo apt-get install fuse -y > /dev/null
  echo -e "$curr_date fuse安装完成." >> /root/install_log.txt
  echo
fi
mount_menu