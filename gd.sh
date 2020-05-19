#!/bin/bash
echo "输入分享链接"
read -p "请输入:" link
link=${link#*id=};
link=${link#*folders/}
echo $link
link=${link#*d/}
link=${link%?usp*}
#copylink=`gclone copy goog:{$link} goog:{myid} --drive-server-side-across-configs -vvP --min-size 10M --transfers=10`
gclone mkdir goog:{myid}/$link
gclone copy goog:{$link} goog:{myid}/$link --drive-server-side-across-configs -vvP --min-size 10M --transfers=10
