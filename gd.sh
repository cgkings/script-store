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
echo "将文件存入配置目录下文件夹："$rootName
echo '将日志文件保存在目录：/root/AutoRclone/LOG/'"$rootName"'.txt'
echo 【开始拷贝】......
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k
echo 【查缺补漏】......
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k
gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP
#./gd.sh
