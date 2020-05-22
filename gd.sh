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
echo "转存入该文件夹："$rootName
echo 【开始拷贝】......
#echo gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
echo 【查缺补漏】......
#echo gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
echo 【去重检查】......
#echo gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP
gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP
echo 【比对检查】......
#echo gclone check goog:{$link} "goog:{myid}/$rootName" --size-only --one-way --no-traverse
gclone check goog:{$link} "goog:{myid}/$rootName" --size-only --one-way --no-traverse --min-size 10M
#./gd.sh
