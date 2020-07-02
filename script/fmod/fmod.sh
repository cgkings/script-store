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
check_results=`fmod size goog:{"$link"} --checkers=256 --drive-pacer-min-sleep=1ms 2>&1`
    if [[ $check_results =~ "Error 404" ]] ; 
    then
    echo "链接无效，检查是否有权限" && exit
    else
    echo -e "分享链接的基本信息如下:\n"$check_results""
    echo -e "folder name："$rootName"" 
    fi
fi
echo -e " fmod自用版 [ v1.0 by \e[1;34m cgkings \e[0m ]
[0]. 中转盘ID转存
[1]. ADV盘ID转存
[2]. MDV盘ID转存
[3]. BOOK盘ID转存
[4]. 自定义ID转存"
read -t 10 -n1 -p " 请输入数字 [0-4]: (10s默认选0)" num
num=${num:-0}
case "$num" in
0)
    echo "你选择的是：1#中转盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid1
    ;;
1)
    echo "你选择的是：2#ADV盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid2
    ;;
2)
    echo "你选择的是：3#MDV盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid3
    ;;
3)
    echo "你选择的是：4#BOOK盘ID，如选错可ctrl+c中断该转存任务"
    echo "==<<极速转存即将开始>>=="
    myid=myid4
    ;;
4)
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
fmod check goog:{$link} goog:{$myid}/"$rootName" --fast-list --size-only --one-way --no-traverse --min-size 10M --checkers=320 --drive-pacer-min-sleep=1ms
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  检查完毕"
echo "请注意清空回收站，群组账号必须对团队盘有管理员权限"
read -t 10 -n1 -p "是否要清空回收站 [Y/N]? 10s不选默认N" answer
answer=${answer:-N}
case "$answer" in
Y | y)
    echo -e "/n ==<<即将清空回收站，现在后悔可能还来得及>>=="
    fmod delete goog:{$myid} --fast-list --drive-trashed-only --drive-use-trash=false --drive-server-side-across-configs --checkers=256 --transfers=128 --drive-pacer-min-sleep=1ms --drive-pacer-burst=5000 --check-first --log-level INFO --log-file=/root/gclone_log/"$rootName"'_trash.txt'
    fmod rmdirs goog:{$myid} --fast-list --drive-trashed-only --drive-use-trash=false --drive-server-side-across-configs --checkers=256 --transfers=128 --drive-pacer-min-sleep=1ms --drive-pacer-burst=5000 --check-first --log-level INFO --log-file=/root/gclone_log/"$rootName"'_rmdirs.txt'
    echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  回收站清空完毕"
    echo "日志文件存储路径/root/gclone_log/"$rootName"_(copy1/copy2/dedupe/trash/rmdirs).txt"
    ;;
N | n)
    echo "日志文件存储路径/root/gclone_log/"$rootName"_(copy1/copy2/dedupe).txt"
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
./fmod.sh
