#!/bin/bash
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
# 进行选项操作，默认1急速转存
run_gd_fast() {
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
}
run_gd_customiz() {
    read -p "请输入分类文件夹ID后按回车键:" folderid
    echo '==<<分类转存即将开始，可ctrl+c中途中断>>=='
    id=$folderid
    j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) folderName=$(echo $j | grep -Po '(?<="name":")[^"]*')
    echo "文件将转存入分类目录："$folderName/$rootName
    echo 【开始转存】......
    gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【查缺补漏】......
    gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 10M
    echo 【去重检查】......
    gclone dedupe newest "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP
}
run_gd_bak() {
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
}
echo && echo -e " gclone懒人一键转存脚本"
 ${Green_font_prefix} 1.${Font_color_suffix} 极速转存:预设固定目录ID定向转存(5秒不选默认运行)
 ———————————————————————
 ${Green_font_prefix} 2.${Font_color_suffix} 分类转存:向自定义目录ID转存
 ———————————————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 自动备份：TD to TD全盘备份
 ———————————————————————" && echo
read -t 5 -e -p " 请输入数字 [0-3]:" num
num=${num:-1}
case "$num" in
1)
    run_gd_fast
    ;;
2)
    run_gd_customiz
    ;;
3)
    run_gd_bak
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
