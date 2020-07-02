#!/bin/bash
# Author: cgking
# Created Time : 2020.7.1
# File Name: fmod.sh
# Description:
read -p "请输入分享链接==>" link
# 检查接受到的分享链接规范性，并转化出分享文件ID
if [ -z "$link" ] ; then
    echo "不允许输入为空" && exit
else
link=${link#*id=};
link=${link#*folders/};
link=${link#*d/};
link=${link%?usp*}
id=$link
j=$(fmod lsd goog:{$link} --checkers=256 --drive-pacer-min-sleep=1ms --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
    if [[ "$j" =~ "Error 404" ]] ; then
    echo "链接无效，检查是否有权限" && exit
    else
    echo "文件夹名称为："$rootName""
    fi
fi
echo -e " fmod自用版 ${Red_font_prefix} v1.0 ${Font_color_suffix} by \033[1;35mcgkings\033[0m
 ${Green_font_prefix} 1.${Font_color_suffix} 1#中转盘ID转存(默认5s自动)
 ${Green_font_prefix} 2.${Font_color_suffix} 2#ADV盘ID转存
 ${Green_font_prefix} 3.${Font_color_suffix} 3#MDV盘ID转存
 ${Green_font_prefix} 4.${Font_color_suffix} 4#BOOK盘ID转存
 ${Green_font_prefix} 5.${Font_color_suffix} 自定义ID转存"
read -t 5 -e -p " 请输入数字 [1-5]:" num
num=${num:-1}
case "$num" in
1)
    echo "你选择的是：1#中转盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid1
    ;;
2)
    echo "你选择的是：2#ADV盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid2
    ;;
3)
    echo "你选择的是：3#MDV盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid3
    ;;
4)
    echo "你选择的是：4#BOOK盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid4
    ;;
5)
    read -p "你选择的是：5 自定义ID转存
             请输入自定义转存ID:" myid5
    myid=$myid5
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
echo 【开始拷贝】......
fmod copy goog:{$link} goog:{$myid}/"$rootName" --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --check-first --min-size 10M --log-file=/root/gclone_log/"$rootName"'_copy1.txt'
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  拷贝完毕"
echo 【查缺补漏】......
fmod sync goog:{$link} goog:{$myid}/"$rootName" --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=256 --transfers=320 --drive-pacer-min-sleep=1ms --check-first --min-size 10M --drive-use-trash=false --log-file=/root/gclone_log/"$rootName"'_copy1.txt'
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  拷贝完毕"
echo 【去重检查】......
fmod dedupe newest goog:{$myid}/"$rootName" --fast-list --drive-use-trash=false --no-traverse --size-only -v --log-file=/root/gclone_log/"$rootName"'_dedupe.txt'
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  查重完毕"
echo 【比对检查】......
fmod check goog:{$link} goog:{$myid}/"$rootName" --fast-list --size-only --one-way --no-traverse --min-size 10M --checkers=256 --drive-pacer-min-sleep=1ms
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  检查完毕"
echo "请注意清空回收站，群组账号必须对团队盘有管理员权限"
echo "想要清空回收站，打个1，5s不选默认不清空"
read -t 5 -e -p " 请输入数字 [0 或 1]:" num
num=${num:-1}
case "$num" in
0)
    echo "日志文件存储路径/root/gclone_log/"$rootName"_(copy1/copy2/dedupe).txt"
    ;;
1)
    echo "==<<即将清空回收站，现在后悔可能还来得及>>=="
    fmod delete goog:{$myid} --fast-list --drive-trashed-only --drive-use-trash=false --drive-server-side-across-configs --checkers=256 --transfers=128 --drive-pacer-min-sleep=1ms --drive-pacer-burst=5000 --check-first --log-level INFO --log-file=/root/gclone_log/"$rootName"'_trash.txt'
    fmod rmdirs goog:{$myid} --fast-list --drive-trashed-only --drive-use-trash=false --drive-server-side-across-configs --checkers=256 --transfers=128 --drive-pacer-min-sleep=1ms --drive-pacer-burst=5000 --check-first --log-level INFO --log-file=/root/gclone_log/"$rootName"'_rmdirs.txt'
    echo "日志文件存储路径/root/gclone_log/"$rootName"_(copy1/copy2/dedupe/trash/rmdirs).txt"
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
./fmod.sh
