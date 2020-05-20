#!/bin/bash
copy(){
gclone copy goog:{$1} goog:$2 --drive-server-side-across-configs -v
}
folder(){
gclone lsd goog:$2|awk -v sz=$1 'NR==sz {print$5}'
}
option(){
name=`folder $list`
echo -e "\n\n确认请回车\n\n输入其他字符将在此 $name 下创建新文件夹并copy\n"
read -p "保存到 $name 这个文件夹？" list2
copy $link $name"/"$list2
}
read -p """输入分享链接
     请输入 ~>:""" link
if [ -z $link ] ;then
    echo "不允许输入为空"
    exit
else
    :
fi
link=${link#*id=};link=${link#*folders/};link=${link#*d/};link=${link%?usp*}

echo -e "为了操作快捷,简便,只支持选择一级目录\n二级目录需要手动创建"
gclone lsd goog:|awk '{print "     ",NR,"     ",$5}'
echo -e "\n\n输入回车或者其他字符将在此目录下创建新文件夹并copy\n\n创建目录用 / 分隔"
read -p "     选择文件夹，数字(1-99) ~>: " list
case $list in
    [1-9])
    option
    gclone check goog:{$link} goog:$name"/"$list2 --disable ListR
    ;;
    [1-9][0-9])
    option
    gclone check goog:{$link} goog:$name"/"$list2 --disable ListR
        ;;
        *)
        gclone copy goog:{$link} goog:$list --drive-server-side-across-configs -v
        gclone check goog:{$link} goog:$list --disable ListR
esac
