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
check_sys
check_command tar zip unzip gzip bzip2 unar p7zip-full
file_dir="$1"
taget_dir="$2"
shift
ex_flags="$@"
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 万能解压 ##################
if [ -z ${file_dir} ]; then
  cat << EOF
用法(Usage):ex [flag1] [flag2] [flag3] 
——————————————————————————————————————
可用参数(Available flags)：
flag1:需要解压的压缩包路径
flag2:要解压到的路径，留空默认当前路径
flag3:其他参数，按各压缩程序格式，自行填写，如7z的"-p"+<密码>，unar的-P+空格+<密码>,flag2为空不可用
注：无参数进入本命令帮助"
—————————————————————————————————————————————————————————
EOF
elif [ -f ${file_dir} ]; then
  if [ -z ${taget_dir} ]; then
    case $file_dir in
      *.tar)       tar xvf ${file_dir}    ;;
      *.tbz2)      tar xvf ${file_dir}    ;;
      *.tgz)       tar xvf ${file_dir}    ;;
      *.tar.bz2)   tar xvf ${file_dir}    ;;
      *.tar.gz)    tar xvf ${file_dir}    ;;
      *.tar.xz)    tar xvf ${file_dir}    ;;
      *.tar.Z)     tar xvf ${file_dir}    ;;
      *.bz2)       bzip2 -d ${file_dir}   ;;
      *.rar)       unar -f ${file_dir}       ;;
      *.gz)        unar -f ${file_dir}       ;;
      *.zip)       unar -f ${file_dir}      ;;
      *.Z)         unar -f ${file_dir} ;;
      *.xz)        unar -f ${file_dir}      ;;
      *.lzo)       unar -f ${file_dir}    ;;
      *.7z)        7z x ${file_dir}       ;;
      *)           echo "该文件压缩格式本脚本暂不支持" ;;
    esac
  else
    case $file_dir in
      *.tar)       tar -zxf ${file_dir} -C ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.tbz2)      tar -zxf ${file_dir} -C ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.tgz)       tar -zxf ${file_dir} -C ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.tar.bz2)   tar -zxf ${file_dir} -C ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.tar.gz)    tar -zxf ${file_dir} -C ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.tar.xz)    tar -zxf ${file_dir} -C ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.tar.Z)     tar -zxf ${file_dir} -C ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.bz2)       unar ${file_dir} -f -o ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.rar)       unar ${file_dir} -f -o ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.gz)        unar ${file_dir} -f -o ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.zip)       unar ${file_dir} -f -o ${taget_dir} && rm -f ${file_dir} && du -sh ${taget_dir}    ;;
      *.Z)         uncompress ${file_dir}  ;;
      *.xz)        xz -d ${file_dir}       ;;
      *.lzo)       lzo -dv ${file_dir}     ;;
      *.7z)        7z x ${file_dir} -o${taget_dir}  ;;
      *)           echo "该文件压缩格式本脚本暂不支持";;
    esac
  fi
else
  echo "${file_dir} 并非有效文件"
fi