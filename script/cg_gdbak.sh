#!/bin/bash
#=============================================================
# https://github.com/cgkings/cg_shellbot
# File Name: autoex.sh
# Author: cgkings
# Created Time : 2020.1.7
# Description:万能解压脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
check_sys
check_rclone

check_run(){
    EXIT_CODE=$?
    if [ ${EXIT_CODE} -eq 0 ]; then
    echo -e "该项备份完成" | tee -a /root/gdbak_log.txt
    else
    echo -e "该项备份完成" | tee -a /root/gdbak_log.txt
    fi
}

#gd间备份personal to personal 1
echo -e "$curr_date [gd to gd]:personal to personal 1" | tee -a /root/gdbak_log.txt
fclone sync frreq:{} frreq:{} --drive-server-side-across-configs --stats=1s --stats-one-line -vvP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
check_run

#gd间备份personal to personal 1
echo -e "$curr_date [gd to gd]:personal to personal 1" | tee -a /root/gdbak_log.txt
fclone sync frreq:{} frreq:{} --drive-server-side-across-configs --stats=1s --stats-one-line -vvP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
check_run

#gd to od
rclone sync [p#1 gd_remote]:"[p#2 from_id]" [p#3 od_remote]:[p#4 od目录] --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=8 -vP --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --onedrive-chunk-size 187.5M --check-first


#gd to china od
rclone sync [p#1 gd_remote]:"[p#2 from_id]" [p#3 od_remote]:[p#4 od目录] --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=8 -vP --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --onedrive-chunk-size 187.5M --check-first