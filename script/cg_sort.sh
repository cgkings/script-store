#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_sort.sh)
# File Name: cg_sort.sh
# Author: cgking
# Created Time : 2021.2.25
# Description:自动整理脚本
# System Required: Debian/Ubuntu
# Version: final
#=============================================================
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
# shellcheck source=/dev/null
moveto_id="0ADlZqPuTIX3sUk9PVA"

################## 选择remote ##################[done]
remote_choose() {
  #选择remote
  rclone listremotes | grep -Eo "[0-9A-Za-z-]+" | awk '{ print FNR " " $0}' > ~/.config/rclone/remote_list.txt
  remote_list="$(cat ~/.config/rclone/remote_list.txt)"
  remote_choose_num=$(whiptail --clear --ok-button "上下键选择,回车键确定" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "remote选择" --menu --nocancel "注：上下键回车选择,ESC退出脚本！" 18 62 10 "${remote_list[@]}" 3>&1 1>&2 2>&3)
  if [ -z "$remote_choose_num" ]; then
    rm -f ~/.config/rclone/remote_list.txt
    myexit 0
  else
    my_remote=$(awk '{print $2}' /root/.config/rclone/remote_list.txt | sed -n "$remote_choose_num"p)
    rm -f ~/.config/rclone/remote_list.txt
  fi
}
######################输入整理文件夹id##########################
get_id() {
  #输入整理文件夹ID
  from_id=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "输入需要整理的文件夹ID" --nocancel "注：回车确认,ESC退出" 10 68 3>&1 1>&2 2>&3)
  if [ -z "$from_id" ]; then
    myexit 0
  fi
  #选择要操作的remote
  remote_choose
}

######################提取单文件##########################
singlefile() {
  #提取单文件到当前目录
  rclone lsf "$my_remote": --files-only --format "p" -R --drive-root-folder-id "$from_id" | xargs -t -n1 -I {} rclone move "$my_remote":/{} "$my_remote": --drive-server-side-across-configs --check-first --stats=1s --stats-one-line -vP --delete-empty-src-dirs --ignore-errors --drive-root-folder-id "$from_id"
  #按hash查重
  rclone dedupe "$my_remote": --dedupe-mode largest --by-hash -vv --drive-use-trash=false --ignore-errors --drive-root-folder-id "$from_id"
  #删除空文件夹
  fclone rmdirs "$my_remote:{$from_id}" --fast-list --drive-use-trash=false -vv --checkers=8 --transfers=16 --drive-pacer-min-sleep=5ms --drive-pacer-burst=1000 --ignore-errors
  exit
}

######################移动有码文件##########################
file_move() {
  suma=0
  for forder_num in {A..Z}; do
    suma=$((suma + 1))
    echo -e "即将开始整理从A到Z的视频文件，当前进度 $suma / 26"
    fclone move "$my_remote:{$from_id}" "$my_remote:{$moveto_id}/$forder_num" --drive-server-side-across-configs -vv --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include "[$forder_num]*.*" --ignore-case --delete-empty-src-dirs --ignore-errors --check-first
    rclone dedupe "$my_remote:/$forder_num" --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $moveto_id
  done
}

######################脚本命令帮助##########################
sort_help() {
  cat << EOF
用法(Usage):
  bash <(curl -sL git.io/cg_sort.sh) [flags 1]
  注：无参数则进入帮助信息，
      条件整理，需要根目录下为单文件，否则需要修改脚本内，条件移动--include "*/"

可用参数(Available flags)：  
EOF
}

######################命令执行##########################
get_id
singlefile
file_move