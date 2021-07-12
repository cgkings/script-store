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
fclone sync frreq:{0AOoUhVD6ULIfUk9PVA} frreq:{0AM2AXmxuonynUk9PVA} --drive-server-side-across-configs --stats=1s --stats-one-line -vvP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
check_run

#gd间备份personal 1 to personal bak
echo -e "$curr_date [gd to gd]:personal 1 to personal bak" | tee -a /root/gdbak_log.txt
fclone sync frreq:{0AM2AXmxuonynUk9PVA} frreq:{0AL1vRw5scrxmUk9PVA} --drive-server-side-across-configs --stats=1s --stats-one-line -vvP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --drive-use-trash=false --check-first
check_run

#gd to od
echo -e "$curr_date [gd to od]:personal 1 to personal bak" | tee -a /root/gdbak_log.txt
fclone sync frreq:{0AOoUhVD6ULIfUk9PVA} [p#3 od_remote]:[p#4 od目录] --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=8 -vP --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --onedrive-chunk-size 187.5M --check-first
check_run

fclone sync frreq:{1qitlvImjpef9NMQ1vV8Z2Qf0vLQc-3jL} odjav: --fast-list --drive-use-trash=false --stats=5s --stats-one-line -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run

#gd to china od
echo -e "$curr_date [gd to china od]:personal to wod 影视" | tee -a /root/gdbak_log.txt
rclone sync frreq:"/1 影视" wod:/影视 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run

echo -e "$curr_date [gd to china od]:personal to wod 剧集" | tee -a /root/gdbak_log.txt
rclone sync frreq:"/2 剧集" wod:/剧集 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run

echo -e "$curr_date [gd to china od]:personal to wod 动漫" | tee -a /root/gdbak_log.txt
rclone sync frreq:"/3 动漫" wod:/动漫 --drive-root-folder-id "0AOoUhVD6ULIfUk9PVA" --fast-list --drive-use-trash=false --stats=5s --stats-one-line --transfers=4 -vvP --cache-chunk-size 128M --bwlimit 120M --max-size 100G --ignore-existing --ignore-checksum --ignore-size --ignore-errors --check-first
check_run