#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_mount)
# File Name: automount
# Author: cgkings
# Created Time : 2020.12.25
# Description:挂载一键脚本
# System Required: Debian/Ubuntu
# 感谢wuhuai2020、moerats、github众多作者，我只是整合代码
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
  echo -e "$curr_date [Info] 正在执行fusermount -qzu "${mount_path}"..."
  fusermount -qzu "${mount_path}"
  echo -e "$curr_date [Info] fusermount -qzu "${mount_path}"[done]"
  echo -e "$curr_date [Info] 正在检查服务是否存在..."
  if [ -f /lib/systemd/system/rclone-${mount_path_name}.service ]; then
    echo -e "$curr_date [Info] 找到服务 ${red}rclone-${mount_path_name}.service${normal} 正在删除，请稍等..."
    systemctl stop rclone-${mount_path_name}.service
    systemctl disable rclone-${mount_path_name}.service
    rm /lib/systemd/system/rclone-${mount_path_name}.service
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
  echo -e "$curr_date [Info] 开始临时挂载..."
  echo -e "$curr_date [Info] 挂载命令：fclone mount ${my_remote}: ${mount_path} --drive-root-folder-id ${td_id} ${mount_tag} &"
  fclone mount $my_remote: $mount_path --drive-root-folder-id ${td_id} $mount_tag &
  sleep 5s
  echo -e "$curr_date [Info] 临时挂载[done]"
  df -h
}

################## 创建开机挂载服务 ##################
mount_server_creat() {
  choose_mount_tag
  mount_del
  echo -e "$curr_date [Info] 正在创建服务 ${red}rclone-${mount_path_name}.service${normal} 请稍等..."
  cat > /lib/systemd/system/rclone-${mount_path_name}.service << EOF
[Unit]
Description = rclone-${mount_path_name}
AssertPathIsDirectory = ${mount_path}
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
KillMode=none
User=root
ExecStart=fclone mount ${my_remote}: ${mount_path} --drive-root-folder-id ${td_id} ${mount_tag}
ExecStop=fusermount -qzu ${mount_path}
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
  sleep 2s
  echo -e "$curr_date [Info] 服务创建成功。"
  sleep 2s
  echo -e "$curr_date [Info] 启动服务..."
  systemctl start rclone-"$mount_path_name".service
  sleep 1s
  echo -e "$curr_date [Info] 添加开机启动..."
  systemctl enable rclone-"$mount_path_name".service
  if [[ $? ]]; then
    echo -e "$curr_date [Info] 创建服务 ${red}rclone-${mount_path_name}.service${normal}.并已添加开机挂载.\n您可以通过 ${red}systemctl [start|stop|status]${normal} 进行挂载服务管理。"
    sleep 2s
  else
    echo
    echo -e "$curr_date [警告] 未知错误."
  fi
  df -h
}

################## 选择挂载参数 ##################
choose_mount_tag() {
  choose_mount_tag_status=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "选择挂载参数" --menu --nocancel "注：默认缓存目录为/home/cache，ESC退出脚本" 12 60 3 \
    "1" "扫库参数 *内存缓冲 16M，硬盘缓存块1M" \
    "2" "观看参数 *内存缓冲128M，硬盘缓存块128M，预读2G" \
    "3" "退出脚本" 3>&1 1>&2 2>&3)
  case $choose_mount_tag_status in
    1)
      echo
      mount_tag="--umask 000 --allow-other --allow-non-empty --dir-cache-time 1000h --poll-interval 10s --cache-dir=/home/cache --vfs-cache-mode full --use-mmap --vfs-read-chunk-size 1M --no-modtime --log-level INFO --log-file=/mnt/rclone.log"
      ;;
    2)
      echo
      mount_tag="--umask 000 --allow-other --allow-non-empty --dir-cache-time 1000h --poll-interval 10s --cache-dir=/home/cache --vfs-cache-mode full --use-mmap --buffer-size 128M --vfs-read-ahead 2G --no-modtime --log-level INFO --log-file=/mnt/rclone.log"
      #mount_tag="--umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --poll-interval 1h --vfs-cache-mode full --use-mmap --buffer-size 256M --cache-dir=/home/cache --vfs-read-ahead 50G --vfs-cache-max-size $cache_size --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G --log-level INFO --log-file=/mnt/rclone.log"
      ;;
    3 | *)
      myexit 0
      ;;
  esac
}

################## 自 定 义 挂 载 列 表 ##################
my_mountlist() {
   if [ -d /home/mountlist.json ]; then
   TERM=ansi whiptail --title "异常退出" --infobox "未检测到/home/mountlist.json配置文件，无法实现切换！" 8 68
   echo 
   myexit 1
   fi
   mountlistmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "切换挂载模式" --menu --nocancel "注：ESC退出脚本" 15 45 6 \
    "1" "kws_jav_uncensor" \
    "2" "kws_jav_censor" \
    "3" "kws_cav_uncensor" 3>&1 1>&2 2>&3)
}

################## 开  始  菜  单 ##################
mount_menu() {
  clear
  if systemctl | grep "rclone"; then
    curr_mount_status="服务挂载模式"
  elif ps -eo cmd|grep "fclone mount"|grep -v grep; then
    curr_mount_status="临时挂载模式"
  else
    curr_mount_status="未挂载"
  fi
  curr_mount_tag=$(ps -eo cmd|grep "fclone mount"|grep -v grep|awk '{for (i=7;i<=NF;i++)printf("%s ", $i);print ""}')
  if [ -n "$curr_mount_tag" ]; then
    if echo "$curr_mount_tag"|grep "vfs-read-chunk-size"; then
      curr_mount_tag_status="扫库参数"
    elif echo "$curr_mount_tag"|grep "buffer-size"; then
      curr_mount_tag_status="观看参数"
    fi
  fi
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "一键挂载 菜单模式" --menu --nocancel "注：ESC退出脚本\n挂载状态：$curr_mount_status\n挂载参数：$curr_mount_tag_status" 15 45 6 \
    "1" "临时挂载" \
    "2" "服务挂载" \
    "3" "删除挂载" \
    "4" "切换挂载" \
    "5" "切换参数" \
    "6" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    1)
      echo
      remote_choose
      td_id_choose
      dir_choose
      mount_creat
      ;;
    2)
      echo
      remote_choose
      td_id_choose
      dir_choose
      mount_server_creat
      ;;
    3)
      echo
      dir_choose
      mount_del
      ;;
    4)
      echo
      my_mountlist
      ;;
    5)
      echo
      my_mountlist
      ;;
    6 | *)
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