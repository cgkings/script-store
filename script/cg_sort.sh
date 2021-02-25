#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# File Name: cg_sort.sh
# Author: cgking
# Created Time : 2020.7.8
# Description:自动整理脚本
# System Required: Debian/Ubuntu
# Version: final
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
# shellcheck disable=SC2034
#c_id="1Xmtx8ueVSZNxGQxAZiE0bl2QnNof4eXo"
fc2_id="1gzA5P1R7WY6hlZITcRSfqJgshtgizWzh"
suren_id="1vQczVyalU5lOk5-czf6LEE7gnjpYNHoG"
uncensored_id="12x-LqDnmlAyqg1wEOdFLCQ20ddbopgD2"
censored_id="1vd5gc-j8p2BdJ0cf0-7RcAGY8Z7tAdfG"

######################命令执行##########################
read -r -p "请输入要整理的文件夹id==>>" from_id
#选择要操作的remote
remote_choose
#移动-C视频文件
#fclone move "$my_remote":{$from_id} "$my_remote":{$c_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '**-c.{mp4,mkv,avi,rmvb,rm,mpg,wmv,mpeg,flv,ts}' --ignore-case --check-first --delete-empty-src-dirs
#移动FC2[done]
fclone move "$my_remote":{$from_id} "$my_remote":{$fc2_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '{FC2}*.*' --ignore-case --check-first --delete-empty-src-dir
#FC2查重
rclone dedupe "$my_remote": --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $fc2_id
#移动素人
fclone move "$my_remote":{$from_id} "$my_remote":{$suren_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '{ARA,CUTE,DCV,EZD,EVA,G-area,GANA,getchu,HMDN,himemix,HOI,ION,JAC,JKZ,KNB,LUXU,MAAN,MIUM,Mywife,NAMA,NTK,ORETD,ORE,PER,S-cute,SCP,SWEET,SIRO,SCUTE,SQB,SIMM,URF,326EVA,200GANA,328HMDN,390JAC,336KNB,259LUXU,300MAAN,300MIUM,332NAMA,300NTK,230OREX,326SCP}*.*' --ignore-case --check-first --delete-empty-src-dirs
#素人查重
rclone dedupe "$my_remote": --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $suren_id
#移动uncensored[done]
fclone move "$my_remote":{$from_id} "$my_remote":{$uncensored_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '{[0-9][0-9][0-9][0-9]*-[0-9],[0-9][0-9][0-9][0-9]*_[0-9],n[0-9][0-9][0-9][0-9]*,BT,CT,EMP,CCDV,CWP,CWPBD,DSAM,DRC,DRG,GACHI,heydouga,JAV,LAF,LAFBD,HEYZO,KTG,KP,KG,LLDV,MCDV,MKD,MKBD,MMDV,NIP,PB,PT,QE,RED,RHJ,S2M,SKY,SKYHD,SMD,SSDV,SSKP,TRG,TS,xxx-av,YKB}*.*' --ignore-case --check-first --delete-empty-src-dirs
#uncensored查重
rclone dedupe "$my_remote": --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $uncensored_id
#移动censored[done]
suma=0
for forder_num in {A..Z}; do
  suma=$((suma+1))
  echo -e "即将开始整理从A到Z的视频文件，当前进度 $suma / 26"
  fclone move "$my_remote":{$from_id} "$my_remote":{$censored_id}/"$forder_num" --drive-server-side-across-configs -vv --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include "[$forder_num]*.*" --ignore-case --check-first --delete-empty-src-dirs --ignore-errors
  rclone dedupe "$my_remote":/"$forder_num" --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $censored_id
done