#!/bin/bash
:step1
echo "输入分享链接"
read -p "请输入:" link
link=${link#*id=};
link=${link#*folders/}
echo $link
link=${link#*d/}
link=${link%?usp*}
shareid=$link
j=$(gclone lsd goog:{$shareid} --dump bodies -vv 2>&1 |  grep '^{"shareid"' | grep $shareid)
rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
#copylink=`gclone mkdir goog:{myid}/$rootName`
gclone mkdir goog:{myid}/$rootName
:step2
#copylink=`gclone copy goog:{$link} goog:{myid}/$rootName --drive-server-side-across-configs -vvP --min-size 10M --transfers=10`
gclone copy goog:{$link} goog:{myid}/$rootName --drive-server-side-across-configs -vvP --min-size 10M --transfers=10
set /a n+=1
if %n%==2 goto:step3
goto:step2
:step3
#copylink=`gclone dedupe newest goog:{myid}/$rootName --drive-server-side-across-configs -v`
gclone dedupe newest goog:{myid}/$rootName --drive-server-side-across-configs -v
goto:step1
