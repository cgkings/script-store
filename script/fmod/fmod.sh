#!/bin/bash
read -p "请输入分享链接==》" link
# 检查接受到的分享链接规范性，并转化出分享文件ID
if [ -z "$link" ] ;then
    echo "不允许输入为空"
    exit
else
link=${link#*id=};
link=${link#*folders/};
link=${link#*d/};
link=${link%?usp*}
check_results=`fmod size gc:{"$link"} 2>&1`
    if [[ $check_results =~ "Error 404" ]]
    then
    echo "链接无效，检查是否有权限" && exit
    else
    echo "分享链接的基本信息如下："$check_results""
    echo "你输入的分享链接ID为： $link,即将开始转存"
    fi
fi
   id=$link
    j=$(fmod lsd gc:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
    echo "将转存入该文件夹："$rootName"
    ==<<极速转存即将开始，可ctrl+c中途中断>>=="
    echo 【开始拷贝】......
    fmod copy gc:{$link} "gc:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【查缺补漏】......
    fmod sync gc:{$link} "gc:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【去重检查】......
    fmod dedupe newest "gc:{myid}/$rootName" --drive-server-side-across-configs -vvP
    echo 【比对检查】......
    fmod check gc:{$link} "gc:{myid}/$rootName" --size-only --one-way --no-traverse --min-size 10M