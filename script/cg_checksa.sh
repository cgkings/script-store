#!/bin/bash

# ★★★sa检查-已完成★★★

echo "▂▃▄▅▆▇█▓▒░ sa|执行检测 ░▒▓█▇▆▅▄▃▂"
read -rp "请输入sa保存地址:" safolder
read -rp "请输入用于sa检测的fclone账号名,即remote:" fclone_name1
#read -rp "请输入用于sa检测的团队盘id,为了检测速度,请尽量选择文件较少的团队盘,但不能选择空盘:" fsa_id
stty erase '^H'
cat << EOF
remote:$fclone_name1
sa保存目录:$safolder
sa检测目标文件夹id:$fsa_id
检测NG.文件目录:$safolder/invalid"
EOF
mkdir -p "$safolder"/invalid
sa1_sum=$(ls -l "$safolder" | grep "^-" | wc -l)
echo -e "█║▌║▌║待检测sa $sa1_sum 个，开始检测║▌║▌║█\n"
do_sumnum=0
for sa_path in $(find $safolder -type f -name "*.json")
do
  n=1
  do_sumnum=$((do_sumnum+1))
  do_per=`awk 'BEGIN{printf "%.1f%%\n",('$do_sumnum'/'$sa1_sum')*100}'`
  echo -e "正在检测$sa_path ，第$do_sumnum个,共计$sa1_sum，完成进度$do_per"
  rclone lsd "$fclone_name1": --drive-root-folder-id "1KkgnRObLcw8v_IAZd0XwRBSUdcrXnHXC" --drive-service-account-file="$sa_path"
  if [ $? -eq 0 ]; then
    echo &> /dev/null
  else
    echo -e "$sa_path检测NG,即将移至$safolder/invalid"
    mv -f $sa_path $safolder/invalid
  fi
done
xsa_sum=$(ls -l $safolder/invalid | grep "^-" | wc -l)
sa_sum=$(ls -l $safolder | grep "^-" | wc -l)
if [ x$xsa_sum = x0 ]; then
    echo -e "█║▌║▌║恭喜你!你的sa[$sa_sum],全部检测ok║▌║▌║█"
elif [ x$sa_sum = x0 ]; then
    echo -e "█║▌║▌║非常遗憾,你的sa[$sa_sum],全部检测NG.║▌║▌║█\n"
else
    echo -e "█║▌║▌║检测NG sa $xsa_sum 个║▌║▌║█\n"
fi
echo -e "done!!!"