#!/bin/bash
read -p """输入分享链接
     请输入 =>:""" link
# 检查接受到的分享链接规范性，并转化出分享文件ID
if [ -z "$link" ] ;then
    echo "不允许输入为空"
    exit
else :
link=${link#*id=};link=${link#*folders/};link=${link#*d/};link=${link%?usp*}
flist=$(gclone size goog:{"$link"})
    if [[ $flist == *"Error 404"* ]] ;then
    echo "链接无效，检查是否有权限" && exit
    else ：
    echo "你输入的分享链接ID为： $link,即将开始转存别着急"
    fi
fi
# 进行选项操作，默认1急速转存
option(){
echo -e "\n\n 确认输入你的选择：
              1 .极速版:立即向固定地址ID转存(默认选项，回车即可)；
              2 .自定义:向自定义目录ID转存；
              3 .自动备份：固定地址所在TD向备份盘进行全盘备份；"
read -p "请说出你的决定（默认回车极速）：" list2
if -o [[ -z $list2 ] [$list2 = 1 ]] ; then
    id=$link
    j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
    echo "将转存入该文件夹："$rootName
         "==<<极速转存即将开始，可ctrl+c中途中断>>=="
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
    #echo "gclone check goog:{$link} "goog:{myid}/$rootName" --size-only --one-way --no-traverse"
    gclone check goog:{$link} "goog:{myid}/$rootName" --size-only --one-way --no-traverse --min-size 10M
else
    case [$list2 = 2]  
    read -p "请输入分类文件夹ID后按回车键:" folderid
    id=$folderid
    j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) folderName=$(echo $j | grep -Po '(?<="name":")[^"]*')
    echo "文件将拷贝入分类目录："$folderName/$rootName
    echo 【开始拷贝】......
    #echo "gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M"
    gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【查缺补漏】......
    #echo "gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M"
    gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【去重检查】......
    #echo "gclone dedupe newest "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP"
    gclone dedupe newest "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP
    echo 【比对检查】......
    #echo "gclone check goog:{$link} "goog:{$folderid}/$rootName" --size-only --one-way --no-traverse"
    gclone check goog:{$link} "goog:{$folderid}/$rootName" --size-only --one-way --no-traverse --min-size 10M
        esac
    case [$list2 = 3]
    echo "全盘备份，有可能时间漫长敬请等待，建议tmux或screen后台进行"
    echo 【开始备份】......
    #echo "gclone copy goog:{tdid} goog:{bakid} --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M"
    gclone sync goog:{tdid} goog:{bakid} --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【查缺补漏】......
    #echo "gclone sync goog:{tdid} goog:{bakid} --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M"
    gclone sync goog:{tdid} goog:{bakid} --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【去重检查】......
    #echo "gclone dedupe newest goog:{bakid} --drive-server-side-across-configs -vvP"
    gclone dedupe newest goog:{bakid} --drive-server-side-across-configs -vvP
    echo 【比对检查】......
    #echo "gclone check goog:{tdid} goog:{bakid} --size-only --one-way --no-traverse"
    gclone check goog:{tdid} goog:{bakid} --size-only --one-way --no-traverse --min-size 10M
        esac
fi
