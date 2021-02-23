#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
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
source <(wget -qO- https://git.io/cg_script_option)
setcolor

################## 选择挂载目录ID ##################[done]
td_id_choose() {
  read -r -p "请输入需要挂载网盘或文件夹ID:" td_id
}

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
  read -p "请输入需要挂载目录的路径（回车默认/mnt,非绝对路径：含/创建该路径，不含为/mnt/输入文件夹名）:" mount_path
  mount_path=${mount_path:-/mnt}
  dir_check
  echo -e "您的挂载目录为 ${mount_path}"
}

################## 删除服务 ##################
mount_del() {
  check_command fuse
  if [ -z "$mount_path" ]; then
    read -r -p "请输入需要删除的挂载目录路径:" mount_path
  fi
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

################## 挂载参数选择 ##################
tag_choose() {
  cat << EOF
1、256G硬盘或以上[回车默认值]
2、小硬盘，2G内存以上
3、小硬盘，512M-1G内存
注：如参数不合适，可自行修改脚本内挂载参数行，已备注
EOF
  read -r -n1 -p "请选择挂载参数:(回车默认1)" tag_choose_result
  tag_choose_result=${tag_choose_result:-1}
  case $tag_choose_result in
    1)
      echo
      mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
      ;;
    2)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
      ;;
    3)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
      ;;
    *)
      echo
      echo "输入错误，请重新输入"
      mount_menu
      ;;
  esac
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
Wants = network-online.target
After = network-online.target

[Service]
Type = notify
KillMode = none
Restart = on-failure
RestartSec = 5
User = root
ExecStart = fclone mount ${my_remote}: ${mount_path} --drive-root-folder-id ${td_id} ${mount_tag}
ExecStop = fusermount -qzu ${mount_path}

[Install]
WantedBy = multi-user.target
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
    echo -e "$curr_date [Info] 创建服务 ${red}reclone-${mount_path_name}.service${normal}.并已添加开机挂载.\n您可以通过 ${red}systemctl [start|stop|status]${normal} 进行挂载服务管理。"
    sleep 2s
  else
    echo
    echo -e "$curr_date [警告] 未知错误."
  fi
  df -h
}

################## 脚本参数帮助 ##################
mount_help() {
  cat << EOF
用法(Usage):
  bash <(curl -sL https://git.io/cg_auto_mount) [flags1] [flags2] [flags3] [flags4]
  注意：无参数则进入主菜单,参数少于3个显示help，即1,2,3为脚本参数执行方式必备!

[flags1]可用参数(Available flags)：
  bash <(curl -sL https://git.io/cg_auto_mount) l1,2,3  临时创建挂载(1,2,3代表挂载方案)
  bash <(curl -sL https://git.io/cg_auto_mount) s1,2,3  服务创建挂载(1,2,3代表挂载方案)
  bash <(curl -sL https://git.io/cg_auto_mount) d       删除挂载
  bash <(curl -sL https://git.io/cg_auto_mount) h       命令帮助
  
[flags2]可用参数(Available flags)：
  flags2 为需要创建挂载的remote名称，可查阅~/.config/rclone/rclone.conf

[flags3]可用参数(Available flags)：
  flags3 为挂载盘或文件夹ID

[flags4]可用参数(Available flags)：
  flags4 为挂载路径
  
例如：bash <(curl -sL https://git.io/cg_auto_mount) l1 remote 0AAa0DHcTPGi9Uk9PVA /mnt/gd
EOF
}

################## 开  始  菜  单 ##################

mount_menu() {
  clear
  cat << EOF
———————————————————————————————————————
{green}mount一键脚本 by cgkings${normal}
${green}1、临时挂载${normal}"
${green}2、服务挂载${normal}
${green}3、删除挂载${normal}
${green}4、退出${normal}"
———————————————————————————————————————
EOF
  read -n1 -p "请输入数字 [1-4]:" num
  case "$num" in
    1)
      echo
      remote_choose
      td_id_choose
      dir_choose
      tag_choose
      mount_creat
      exit
      ;;
    2)
      echo
      remote_choose
      td_id_choose
      dir_choose
      tag_choose
      mount_server_creat
      exit
      ;;
    3)
      echo
      mount_del
      exit
      ;;
    4)
      exit
      ;;
    *)
      echo
      echo "输入错误，请重新输入"
      mount_menu
      ;;
  esac
}

################## 执  行  命  令 ##################
check_root
check_vz
check_rclone
if [ -z $1 ]; then
  mount_menu
else
  my_remote=$2
  td_id=$3
  mount_path=$4 
  case "$1" in
    L1 | l1)
      echo
      mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
      dir_check
      mount_creat
      ;;
    L2 | l2)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
      dir_check
      mount_creat
      ;;
    L3 | l3)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
      dir_check
      mount_creat
      ;;
    S1 | s1)
      echo
      mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
      dir_check
      mount_server_creat
      ;;
    S2 | s2)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
      dir_check
      mount_server_creat
      ;;
    S3 | s3)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
      dir_check
      mount_server_creat
      ;;
    D | d)
      echo
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