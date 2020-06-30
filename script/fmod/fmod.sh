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
j=$(fmod lsd goog:{$link} --checkers=128 --drive-pacer-min-sleep=1ms --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
    if [[ "$j" =~ "Error 404" ]] ; then
    echo "链接无效，检查是否有权限" && exit
    else
    echo "文件夹名称为："$rootName""
    fi
fi
echo "==<<极速转存即将开始，可ctrl+c中途中断>>=="
echo 【开始拷贝】......
fmod copy goog:{$link} goog:{myid}/"$rootName" --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms --check-first --min-size 10M --log-file=/root/gclone_log/"$rootName"'_copy1.txt'
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  拷贝完毕"
echo 【查缺补漏】......
fmod sync goog:{$link} goog:{myid}/"$rootName" --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms --check-first --min-size 10M --log-file=/root/gclone_log/"$rootName"'_copy1.txt'
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  拷贝完毕"
echo 【去重检查】......
fmod dedupe newest goog:{myid}/"$rootName" --drive-server-side-across-configs --checkers=128 --drive-pacer-min-sleep=1ms -q --log-file=/root/gclone_log/"$rootName"'_dedupe.txt'
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  查重完毕"
echo 【比对检查】......
fmod check goog:{$link} goog:{myid}/"$rootName" --size-only --one-way --no-traverse --min-size 10M --checkers=128 --drive-pacer-min-sleep=1ms
echo "|▉▉▉▉▉▉▉▉▉▉▉▉|100%  检查完毕"
echo "日志文件存储路径/root/gclone_log/"$rootName"_(copy1/copy2/dedupe).txt"
./fmod.sh