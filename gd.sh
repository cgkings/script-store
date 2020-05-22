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
echo '日志文件保存在：/root/gclone_log/'"$rootName"'.log'
echo 【开始拷贝】......
#echo gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M --log-file=/root/gclone_log/'"$rootName"'.log'
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M --log-file=/root/gclone_log/'"$rootName"'.log'
echo 【查缺补漏】......
#echo gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M --log-file=/root/gclone_log/'"$rootName"'.log'
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M --log-file=/root/gclone_log/'"$rootName"'.log'
echo 【去重检查】......
#echo gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/gclone_log/'"$rootName"'.log'
gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/gclone_log/'"$rootName"'.log'
echo 【比对检查】......
#./gd.sh
