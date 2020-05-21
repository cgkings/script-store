#!/bin/bash
echo "输入分享链接"
read -p "请输入:" link
link=${link#*id=};
link=${link#*folders/}
#echo $link
link=${link#*d/}
link=${link%?usp*}
id=$link
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "请输入分类文件夹ID"
read -p "分类文件夹ID:" folderid
id=$folderid
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) folderName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "文件将转存入："$folderName/$rootName
echo 【开始拷贝】......
#echo gclone copy goog:{$link} goog:"{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file="/root/AutoRclone/LOG/$rootName".txt
gclone copy goog:{$link} goog:"{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file="/root/AutoRclone/LOG/$rootName".txt
echo 【查缺补漏】......
#echo gclone copy goog:{$link} goog:"{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file="/root/AutoRclone/LOG/$rootName".txt
gclone copy goog:{$link} goog:"{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file="/root/AutoRclone/LOG/$rootName".txt
echo 【去重检查】......
#echo gclone dedupe newest goog:"{$folderid}/$rootName" --drive-server-side-across-configs -vvP --log-file="/root/AutoRclone/LOG/$rootName".txt
gclone dedupe newest goog:"{$folderid}/$rootName" --drive-server-side-across-configs -vvP --log-file="/root/AutoRclone/LOG/$rootName".txt
#./gd.sh
