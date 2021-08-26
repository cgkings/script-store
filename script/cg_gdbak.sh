#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_gdbak)
# File Name: cg_gdbak.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:gd备份
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

################## 调试日志 ##################
#set -x    ##分步执行
#exec &> /tmp/log.txt   ##脚本执行的过程和结果导入/tmp/log.txt文件中
################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
bak_gd_remote="gd-"$bak_gd_remote""
check_sys
check_rclone
: > /root/gdbak_log.log

check_run(){
    EXIT_CODE=$?
    if [ ${EXIT_CODE} -eq 0 ]; then
    echo -e "该项备份完成" | tee -a /root/gdbak_log.log
    else
    echo -e "该项备份完成" | tee -a /root/gdbak_log.log
    fi
}

#gd间备份personal to personal 1
echo -e "$curr_date [gd to gd]:personal to personal 1" | tee -a /root/gdbak_log.log
fclone sync "$bak_gd_remote":{0AOoUhVD6ULIfUk9PVA} "$bak_gd_remote":{0AM2AXmxuonynUk9PVA} --drive-server-side-across-configs --stats=1s --stats-one-line -P --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
check_run

#gd间备份personal 1 to personal bak
echo -e "$curr_date [gd to gd]:personal 1 to personal bak" | tee -a /root/gdbak_log.log
fclone sync "$bak_gd_remote":{0AM2AXmxuonynUk9PVA} "$bak_gd_remote":{0AL1vRw5scrxmUk9PVA} --drive-server-side-across-configs --stats=1s --stats-one-line -P --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
check_run

#gd to od
echo -e "$curr_date [gd to od]:personal to odjav bak" | tee -a /root/gdbak_log.log
fclone sync "$bak_gd_remote":{1qitlvImjpef9NMQ1vV8Z2Qf0vLQc-3jL} ode5-jav: --fast-list --drive-use-trash=false --stats=5s --stats-one-line -P --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run

#gd to china od
echo -e "$curr_date [gd to china od]:personal to wod 影视" | tee -a /root/gdbak_log.log
rclone sync "$bak_gd_remote":"/1 影视" wod:/影视 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -P --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run

echo -e "$curr_date [gd to china od]:personal to wod 剧集" | tee -a /root/gdbak_log.log
rclone sync "$bak_gd_remote":"/2 剧集" wod:/剧集 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -P --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run

echo -e "$curr_date [gd to china od]:personal to wod 动漫" | tee -a /root/gdbak_log.log
rclone sync "$bak_gd_remote":"/3 动漫" wod:/动漫 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -P --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run