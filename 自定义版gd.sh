#!/bin/bash
echo "输入分享链接"
read -p "请输入:" link
link=${link#*id=};
link=${link#*folders/}
echo $link
link=${link#*d/}
link=${link%?usp*}
echo -e "1   选择目录"
echo -e "2   创建目录"
read -p " 选择保存   >: " list
#copylink=`gclone copy goog:{$link} goog:$dyj --drive-server-side-across-configs -v`
case $list in
	1)
	gclone lsd goog:|awk '{print NR,$5}'
	read -p "选择" option
	dyj=`gclone lsd goog:|awk -v sz=$option 'NR==sz {print$5}'`
	while true
	do
	    clear
	    echo -e "输入n浏览下一级目录\n输入y将保存到 $dyj 文件夹\n输入其他字符将在 $dyj 下创建文件夹"
    	read -p "保存到 $dyj 这个文件夹？" suer
        case $suer in
            n)
            gclone lsd goog:$dyj | awk '{print NR,$5}'
            read -p "选择" option
            dyj2=`gclone lsd goog:$dyj|awk -v sz=$option 'NR==sz {print$5}'`
            dyj=$dyj"/"$dyj2
            ;;
            y)
            gclone copy goog:{$link} goog:$dyj --drive-server-side-across-configs -v
            break
            ;;
            *)
            gclone copy goog:{$link} goog:$dyj"/"$suer --drive-server-side-across-configs -v
            break
            ;;
        esac
    done
	;;
	2)
	read -p "创建目录:" mkdir
	gclone copy goog:{$link} goog:$mkdir --drive-server-side-across-configs -v
esac
