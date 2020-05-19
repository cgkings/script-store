#!/bin/bash
echo "输入分享链接"
read -p "请输入:" link
link=${link#*id=};
link=${link#*folders/}
echo $link
link=${link#*d/}
link=${link%?usp*}
id=$link
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo $rootName
echo gclone copy goog:{$link} goog:{myid}/$rootName --drive-server-side-across-configs -vvP --min-size 10M --transfers=10
gclone copy goog:{$link} goog:{myid}/$rootName --drive-server-side-across-configs -vvP --min-size 10M --transfers=10
echo gclone copy goog:{$link} goog:{myid}/$rootName --drive-server-side-across-configs -vvP --min-size 10M --transfers=10
gclone copy goog:{$link} goog:{myid}/$rootName --drive-server-side-across-configs -vvP --min-size 10M --transfers=10
echo gclone dedupe newest goog:{myid}/$rootName --drive-server-side-across-configs -v
gclone dedupe newest goog:{myid}/$rootName --drive-server-side-across-configs -v
