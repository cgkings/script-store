#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# File Name: 一键提取单文件
# Author: cgkings
# Created Time : 2021.2.23
# Description:flexget
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
check_root
check_vz
check_rclone

######################命令执行##########################
#提取当前ID单文件
read -r -p "请输入要提取单文件的文件夹id==>>" from_id
#选择要操作的remote
remote_choose
#提取单文件到当前目录
rclone lsf $my_remote: --files-only --format "p" -R --drive-root-folder-id $from_id | xargs -t -n1 -I {} rclone move $my_remote:/{} $my_remote: --drive-server-side-across-configs --check-first --stats=1s --stats-one-line -vP --delete-empty-src-dirs --ignore-errors --drive-root-folder-id $from_id
#按hash查重
rclone dedupe $my_remote: --dedupe-mode largest --by-hash -vv --drive-use-trash=false --ignore-errors --drive-root-folder-id $from_id
#删除空文件夹
fclone rmdirs $my_remote:{"$from_id"} --fast-list --drive-use-trash=false -vv --checkers=8 --transfers=16 --drive-pacer-min-sleep=5ms --drive-pacer-burst=1000 --ignore-errors
exit