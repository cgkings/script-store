#!/bin/bash
echo -e "GD懒人一键转存脚本${Red_font_prefix}[ v1.0 ${Font_color_suffix} by \033[1;35mcgkings & oneking\033[0m]"
read -p """输入分享链接
     请输入 =>:""" link
# 检查接受到的分享链接规范性，并转化出分享文件ID
if [ -z "$link" ] ;then
    echo "不允许输入为空"
    exit
else
link=${link#*id=};
link=${link#*folders/};
link=${link#*d/};
link=${link%?usp*}
id=$link
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
check_results=`gclone size cgkings:{"$link"} 2>&1`
    if [[ $check_results =~ "Error 404" ]]
    then
    echo "链接无效，检查是否有权限" && exit
    else
    echo "分享链接的基本信息如下："
	echo "分享目录名："$rootName""
	echo "分享目录下文件数和总大小："$check_results""
    fi
fi
echo -e "\n"
    echo '==<<极速转存即将开始，可ctrl+c中途中断>>=='
    echo -e
    echo "将转存入该文件夹："$rootName"
    echo 【开始拷贝】......
    #echo "gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M"
    gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【查缺补漏】......
    #echo "gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M"
    gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【去重检查】......
    #echo "gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP"
    gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP
    echo 【比对检查】......
    #echo "gclone check goog:{$link} "goog:{myid}/$rootName" --size-only --one-way --no-traverse --min-size 10M"
    gclone check goog:{$link} "goog:{myid}/$rootName" --size-only --one-way --no-traverse --min-size 10M
    #./gd.sh
