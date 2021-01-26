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
source <(wget -qO- https://git.io/cg_script_option)
setcolor



################## 获取显示参数 ##################
get_information(){
  #有脚本配置文件就读取配置文件，没有就使用作者自己设置值
  if [ ! -f /root/cg_sort_config.ini ]; then
    remote="cgking"
    singleto_id=""
    uncensored_id=""
    amateur_id=""
    censored_id=""
  else
    source /root/cg_sort_config.ini
  fi
  #检查配置参数中的remote是否有效，无效就需要设置
  if [ -z "$(grep "$remote" /root/.config/rclone/rclone.conf)" ]; then
    echo -e "${curr_date} [INFO] 预设remote检测失败，请重新设置" | tee -a /root/sort_log.txt
    chenge_sort_flags
  fi
  read -r -p "请输入要整理的文件夹id==>>" sort_from_id
  
}

chenge_sort_flags(){

  cat > /root/cg_sort_config.ini << EOF

remote=""
singleto_id=""
uncensored_id=""
amateur_id=""
censored_id=""
EOF

}












source /root/fclone_shell_bot/myfc_config.ini
clear
read -p "请输入目标链接==>" link1
link1=${link1#*id=};link1=${link1#*folders/};link1=${link1#*d/};link1=${link1%?usp*}
input_info=`fclone lsjson "$fclone_name1":{$link1} --fast-list --files-only --no-mimetype --no-modtime --max-depth 6`
input_ids=$(echo "$input_info" | cut  -d '"' -f 20 | sed -n '1!P;N;$q;D')
echo "$input_ids"
for input_id in $input_ids
do
   input_name=$(echo "$input_info" | grep '"'$input_id'"' | cut  -d '"' -f 8)
   echo "$input_name"
   output_names=$(cut -d ":" -f 1 /root/fclone_shell_bot/av_num.txt)
   if [[ $input_names =~ "*$output_names*" ]]; then
   output_id=$(awk 'BEGIN{FS=":"}/^'$output_names'/{print $2}' /root/fclone_shell_bot/av_num.txt)
   fclone copy "$fclone_name1":{$input_id} "$fclone_name1":{$output_id} --drive-server-side-across-configs --fast-list --no-traverse --size-only --stats=1s --stats-one-line -P --drive-pacer-min-sleep=1ms --ignore-checksum --ignore-existing --buffer-size=50M --use-mmap --checkers=8 --transfers=8 --check-first --log-level=ERROR --log-file=/root/fclone_shell_bot/log/fsingle.log
   else
   echo "无可整理的文件"
   fi
done
exit

################## 执 行 命 令 ##################
#该脚本不允许并行调用，如发现进程中，有本脚本，再运行将自动退出
if pidof -o %PPID -x "$0"; then
  exit 1
fi
check_rclone




  


cat << EOF
${on_black}${white}                ${bold}JAV自动整理脚本    by cgkings 王大锤              ${normal}
${blue}${bold}————————————————————————————————使 用 说 明—————————————————————————————————————${normal}
${green}${bold}[STEP1] ${normal}获取信息
   1.获取要整理的sort_from_id；
   2.告知预设参数(remote，单文件提取目的地id及路径，无码、素人、有码整理至id及路径),询问是否需要更改，回车或超时五秒自动不更改;
${green}${bold}[STEP2] ${normal}提取单文件视频
${green}${bold}[STEP3] ${normal}筛选移动无码番号视频
${green}${bold}[STEP4] ${normal}筛选移动素人番号视频
${green}${bold}[STEP5] ${normal}筛选移动有码番号视频，并按A-Z文件夹归类
注：本脚本所有操作日志路径：/root/install_log.txt
${blue}${bold}————————————————————————————————————————————————————————————————————————————————${normal}
EOF




suma=0
for forder_num in {A..Z}; do
  suma=$((suma+1))
  echo -e "即将开始整理从A到E的视频文件，当前进度 $suma / 26"
  fclone move wdc:"{$sort_from_id}" wdc:"{1vd5gc-j8p2BdJ0cf0-7RcAGY8Z7tAdfG}/"$forder_num" --drive-server-side-across-configs -v --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --drive-pacer-burst=1000 --include "[$forder_num]*.{mp4,mkv,avi,rmvb,rm,mpg,mpeg,flv,ts}" --ignore-case --check-first --delete-empty-src-dirs --ignore-errors --disable DirMove
done