#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_mount.sh)
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
  mount_path=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "本地挂载路径输入" --nocancel "注：默认值：/mnt/gd,如路径不含“/”,则挂载路径视为：/mnt/你的输入,ESC退出" 10 68 /mnt/gd 3>&1 1>&2 2>&3)
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
  mount_del
  echo -e "$curr_date [Info] 开始临时挂载..."
  echo -e "$curr_date [Info] 挂载命令：fclone mount ${my_remote}: ${mount_path} --drive-root-folder-id ${td_id} ${mount_tag} &"
  fclone mount $my_remote: $mount_path --drive-root-folder-id ${td_id} $mount_tag &
  sleep 5s
  echo -e "$curr_date [Info] 临时挂载[done]"
  echo -e "$curr_date [Info] 如挂载性能不好，请反馈作者"
  df -h
}

################## 创建开机挂载服务 ##################
mount_server_creat() {
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
  if (whiptail --title "挂载参数选择" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --yesno "默认挂载参数如下，是否使用默认值？ /
--umask 000                              *权限设置
--allow-other                            *允许多用户使用
--allow-non-empty                        *多盘同地址挂载
--daemon-timeout=10m                     *内核响应超时
--dir-cache-time 24h                     *缓存强制刷新时间
--poll-interval 1h                       *轮询gd盘变动间隔
--cache-dir=/home/cache                  *缓存目录
--vfs-cache-mode writes                  *vfs模式
--use-mmap                               *内存占用优化
--buffer-size 512M                       *内存缓冲区
--vfs-read-chunk-size 128M               *最小缓存块
--vfs-read-chunk-size-limit 1G           *缓存块倍增极限值
--log-level INFO --log-file=/mnt/rclone.log" 20 65); then
    echo "You chose Yes. Exit status was $?."
  else
    echo "You chose No. Exit status was $?."
  fi
}

################## 脚本参数帮助 ##################
mount_help() {
  cat << EOF
用法(Usage):
  bash <(curl -sL git.io/cg_mount.sh) [flags1] [flags2] [flags3] [flags4]
  注意：无参数则进入主菜单,使用命令参数直接创建挂载，参数不够4个进入帮助!

[flags1]可用参数(Available flags)：
  L  临时创建挂载
  S  服务创建挂载
  d  删除挂载
  h  命令帮助
  
[flags2]可用参数(Available flags)：
  flags2 为需要创建挂载的remote名称，可查阅~/.config/rclone/rclone.conf

[flags3]可用参数(Available flags)：
  flags3 为挂载盘或文件夹ID（网盘ID）

[flags4]可用参数(Available flags)：
  flags4 为挂载路径（本地路径）
  
例如：bash <(curl -sL git.io/cg_mount.sh) L remote 0AAa0DHcTPGi9Uk9PVA /mnt/gd
EOF
}

################## 开  始  菜  单 ##################
mount_menu() {
  clear
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "一键挂载 菜单模式" --menu --nocancel "注：h参数查看参数模式帮助，ESC退出脚本" 14 55 6 \
    "1" "临时挂载" \
    "2" "服务挂载" \
    "3" "删除挂载" \
    "4" "退出" 3>&1 1>&2 2>&3)
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
    4 | *)
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
  if [[ "${release}" = "centos" ]]; then
          yum install fuse -y > /dev/null
  elif [[ "${release}" = "debian" || "${release}" = "ubuntu" ]]; then
          apt-get install fuse -y > /dev/null
  fi
  echo
  echo -e "$curr_date fuse安装完成." >> /root/install_log.txt
  echo
fi
#挂载参数,缓存目录默认在/home/cache
mount_tag="--umask 000 --allow-other --allow-non-empty --daemon-timeout=10m --dir-cache-time 24h --poll-interval 1h --cache-dir=/home/cache --vfs-cache-mode full --use-mmap --buffer-size 512M --vfs-read-ahead 8G --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 1G --log-level INFO --log-file=/mnt/rclone.log"
#mount_tag="--umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --poll-interval 1h --vfs-cache-mode full --use-mmap --buffer-size 256M --cache-dir=/home/cache --vfs-read-ahead 50G --vfs-cache-max-size $cache_size --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G --log-level INFO --log-file=/mnt/rclone.log"
if [ -z "$1" ]; then
  mount_menu
else
  my_remote="$2"
  td_id="$3"
  mount_path="$4"
  case "$1" in
    L | l)
      echo
      if [ -z "$4" ]; then
        mount_help
      else
        dir_check
        mount_creat
      fi
      ;;
    S | s)
      echo
      if [ -z "$4" ]; then
        mount_help
      else
        dir_check
        mount_server_creat
      fi
      ;;
    D | d)
      echo
      dir_choose
      mount_del
      ;;
    H | h)
      echo
      mount_help
      ;;
    *)
      echo
      mount_help
      ;;
  esac
fi
