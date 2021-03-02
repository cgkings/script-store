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
source <(curl -sL git.io/cg_script_option)
setcolor
check_sys
check_rclone
# shellcheck disable=SC2034
c_id="1Xmtx8ueVSZNxGQxAZiE0bl2QnNof4eXo"
fc2_id="1gzA5P1R7WY6hlZITcRSfqJgshtgizWzh"
suren_id="1vQczVyalU5lOk5-czf6LEE7gnjpYNHoG"
uncensored_id="12x-LqDnmlAyqg1wEOdFLCQ20ddbopgD2"
censored_id="1vd5gc-j8p2BdJ0cf0-7RcAGY8Z7tAdfG"

######################提取单文件##########################
singlefile() {
  #提取单文件到当前目录
  rclone lsf $my_remote: --files-only --format "p" -R --drive-root-folder-id $from_id | xargs -t -n1 -I {} rclone move $my_remote:/{} $my_remote: --drive-server-side-across-configs --check-first --stats=1s --stats-one-line -vP --delete-empty-src-dirs --ignore-errors --drive-root-folder-id $from_id
  #按hash查重
  rclone dedupe $my_remote: --dedupe-mode largest --by-hash -vv --drive-use-trash=false --ignore-errors --drive-root-folder-id $from_id
  #删除空文件夹
  fclone rmdirs $my_remote:{"$from_id"} --fast-list --drive-use-trash=false -vv --checkers=8 --transfers=16 --drive-pacer-min-sleep=5ms --drive-pacer-burst=1000 --ignore-errors
  exit
}

######################移动中字文件##########################
c_move() {
  #移动-C视频文件
  fclone move "$my_remote":{$from_id} "$my_remote":{$c_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '*-c.{mp4,mkv,avi,rmvb,rm,mpg,wmv,mpeg,flv,ts}' --ignore-case --delete-empty-src-dirs --ignore-errors --check-first
}

######################移动FC2文件##########################
fc2_move() {
  #移动FC2[done]
  fclone move "$my_remote":{$from_id} "$my_remote":{$fc2_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '{FC2}*.*' --ignore-case --delete-empty-src-dirs --ignore-errors --check-first
  #FC2查重
  rclone dedupe "$my_remote": --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $fc2_id
}

######################移动素人文件##########################
suren_move() {
  #移动素人
  fclone move "$my_remote":{$from_id} "$my_remote":{$suren_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '{ARA,CUTE,DCV,EZD,EVA,G-area,GANA,getchu,HMDN,himemix,HOI,ION,JAC,JKZ,KNB,LUXU,MAAN,MIUM,Mywife,NAMA,NTK,ORETD,ORE,PER,S-cute,SCP,SWEET,SIRO,SCUTE,SQB,SIMM,URF,326EVA,200GANA,328HMDN,390JAC,336KNB,259LUXU,300MAAN,300MIUM,332NAMA,300NTK,230OREX,326SCP}*.*' --ignore-case --delete-empty-src-dirs --ignore-errors --check-first
  #素人查重
  rclone dedupe "$my_remote": --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $suren_id
}

######################移动无码文件##########################
uncensored_move() {
  #移动uncensored[done]
  fclone move "$my_remote":{$from_id} "$my_remote":{$uncensored_id} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include '{[0-9][0-9][0-9][0-9]*-[0-9],[0-9][0-9][0-9][0-9]*_[0-9],n[0-9][0-9][0-9][0-9]*,BT,CT,EMP,CCDV,CWP,CWPBD,DSAM,DRC,DRG,GACHI,heydouga,JAV,LAF,LAFBD,HEYZO,KTG,KP,KG,LLDV,MCDV,MKD,MKBD,MMDV,NIP,PB,PT,QE,RED,RHJ,S2M,SKY,SKYHD,SMD,SSDV,SSKP,TRG,TS,xxx-av,YKB}*.*' --ignore-case --delete-empty-src-dirs --ignore-errors --check-first
  #uncensored查重
  rclone dedupe "$my_remote": --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $uncensored_id
}

######################移动有码文件##########################
censored_move() {
  #移动censored[done]
  suma=0
  for forder_num in {A..Z}; do
    suma=$((suma + 1))
    echo -e "即将开始整理从A到Z的视频文件，当前进度 $suma / 26"
    fclone move "$my_remote":{$from_id} "$my_remote":{$censored_id}/"$forder_num" --drive-server-side-across-configs -vv --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include "[$forder_num]*.*" --ignore-case --delete-empty-src-dirs --ignore-errors --check-first
    rclone dedupe "$my_remote":/"$forder_num" --dedupe-mode largest --by-hash -vv --drive-use-trash=false --drive-root-folder-id $censored_id
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
  S  提取单文件到当前要整理的文件夹根目录下；
  Z  step1:提取单文件到当前要整理的文件夹根目录下；
     step2:移动中文字幕到c_forder参数文件夹下；
     step3:按照FC2,素人，有码，无码分别移至相应参数设置下；
  C  自定义模式：可自行修改脚本，添加自己需要的功能模块；  
EOF
}

######################脚本命令帮助##########################
get_id() {
  #输入整理文件夹ID
  read -r -p "请输入要整理的文件夹id==>>" from_id
  #选择要操作的remote
  remote_choose
}

######################命令执行##########################
if [ -z $1 ]; then
  sort_help
else
  case "$1" in
    #提取单文件
    S | s)
      echo
      get_id
      singlefile
      ;;
    #中字离线下载整理
    Z | z)
      echo
      get_id
      singlefile
      c_move
      fc2_move
      suren_move
      uncensored_move
      censored_move
      ;;
    C | c)
      echo
      get_id
      fc2_move
      suren_move
      uncensored_move
      censored_move
      ;;
    *)
      echo
      sort_help
      ;;
  esac
fi