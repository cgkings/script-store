#!/bin/bash
echo -e "\n"
echo -e "TD分享链接一键转存脚本 4 in 1版 ${Red_font_prefix}[v1.0 ${Font_color_suffix} by \033[1;35mcgkings&oneking\033[0m]"
read -p """输入分享链接
     请输入 =>:""" link
# 检查接受到的分享链接规范性，并读取分享文件夹ID和文件夹名
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
check_results=`gclone size goog:{"$link"} 2>&1`
    if [[ $check_results =~ "Error 404" ]]
    then
    echo "链接无效，检查是否有权限" && exit
    else
    echo "分享链接的基本信息如下："
	  echo "分享目录名："$rootName""
	  echo "分享目录下文件数和总大小："$check_results""
	  echo -e "\n"
    echo "请输入1~4选择转存模式,直接回车或5秒钟未输入自动选择“急速转存模式”"
    fi
fi
# 进行选项操作，默认1急速转存

run_gd_fast() {
echo -e "\n"
echo '==<<极速转存即将开始，可ctrl+c中途中断>>=='
id=myid
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) myidName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "文件将转存到以下目录：$myidName/$rootName"
echo '转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'.txt'
echo '查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check.txt'
echo '去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe.txt'
echo 【开始转存】......
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'.txt'
echo 【查缺补漏】......
gclone copy goog:{$link} "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check.txt'
echo 【去重检查】......
gclone dedupe newest "goog:{myid}/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe.txt'
#./gd.sh
}

run_gd_customiz() {
read -p "请输入分类文件夹ID后按回车键:" folderid
echo '==<<分类转存即将开始，可ctrl+c中途中断>>=='
id=$folderid
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) folderName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "文件将转存入分类目录："$folderName/$rootName
echo '转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'.txt'
echo '查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check.txt'
echo '去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe.txt'
echo 【开始转存】......
gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'.txt'
echo 【查缺补漏】......
gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check.txt'
echo 【去重检查】......
gclone dedupe newest "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe.txt'
#./gd.sh
}

run_gd_bak() {
read -p "请输入分类文件夹ID后按回车键:" folderid
echo '==<<分类转存"&"备份模式即将开始（转存一份、备份一份），可ctrl+c中途中断>>=='
id=$folderid
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) folderName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "文件将转存入分类目录："$folderName/$rootName
echo '转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'.txt'
echo '查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check.txt'
echo '去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe.txt'
echo 【开始转存】......
gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'.txt'
echo 【查缺补漏】......
gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check.txt'
echo 【去重检查】......
gclone dedupe newest "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe.txt'

if [[ ! -d "gclone lsd goog:{Backupid1}" ]]; then
	gclone mkdir "goog:{Backupid1}/$folderName"
else
	echo "$folderName"
fi
id=$Backupid1
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) BackupfolderName1=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "备份将存入分类目录："$BackupfolderName1/$folderName/$rootName
echo '备份转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup1.txt'
echo '备份查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check_backup1.txt'
echo '备份去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe_backup1.txt'
echo 【备份开始建立】......
gclone copy goog:{$link} "goog:{Backupid1}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_backup1.txt'
echo 【备份查缺补漏】......
gclone copy goog:{$link} "goog:{Backupid1}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check_backup1.txt'
echo 【备份去重检查】......
gclone dedupe newest "goog:{Backupid1}/$folderName/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe_backup1.txt'
}
run_gd_bak4() {
read -p "请输入分类文件夹ID后按回车键:" folderid
echo "==<<分类转存"&"多备份模式即将开始（转存一份、备份四份、共五份），可ctrl+c中途中断>>=="
id=$folderid
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) folderName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "文件将转存入分类目录："$folderName/$rootName
echo '转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'.txt'
echo '查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check.txt'
echo '去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe.txt'
echo 【开始转存】......
gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'.txt'
echo 【查缺补漏】......
gclone copy goog:{$link} "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check.txt'
echo 【去重检查】......
gclone dedupe newest "goog:{$folderid}/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe.txt'

if [[ ! -d "gclone lsd goog:{Backupid1}" ]]; then
  gclone mkdir "goog:{Backupid1}/$folderName"
else
  echo "$folderName"
fi
id=$Backupid1
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) BackupfolderName1=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "备份一将存入分类目录："$BackupfolderName1/$folderName/$rootName
echo '备份一转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup1.txt'
echo '备份一查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check_backup1.txt'
echo '备份一去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe_backup1.txt'
echo 【备份一开始建立】......
gclone copy goog:{$link} "goog:{Backupid1}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_backup1.txt'
echo 【备份一查缺补漏】......
gclone copy goog:{$link} "goog:{Backupid1}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check_backup1.txt'
echo 【备份一去重检查】......
gclone dedupe newest "goog:{Backupid1}/$folderName/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe_backup1.txt'

if [[ ! -d "gclone lsd goog:{Backupid2}" ]]; then
  gclone mkdir "goog:{Backupid2}/$folderName"
else
  echo "$folderName"
fi
id=$Backupid2
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) BackupfolderName2=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "备份二将存入分类目录："$BackupfolderName2/$folderName/$rootName
echo '备份二转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup2.txt'
echo '备份二查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check_backup2.txt'
echo '备份二去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe_backup2.txt'
echo 【备份二开始建立】......
gclone copy goog:{$link} "goog:{Backupid2}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_backup2.txt'
echo 【备份二查缺补漏】......
gclone copy goog:{$link} "goog:{Backupid2}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check_backup2.txt'
echo 【备份二去重检查】......
gclone dedupe newest "goog:{Backupid2}/$folderName/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe_backup2.txt'

if [[ ! -d "gclone lsd goog:{Backupid3}" ]]; then
  gclone mkdir "goog:{Backupid3}/$folderName"
else
  echo "$folderName"
fi
id=$Backupid3
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) BackupfolderName3=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "备份三将存入分类目录："$BackupfolderName3/$folderName/$rootName
echo '备份三转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup3.txt'
echo '备份三查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check_backup3.txt'
echo '备份三去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe_backup3.txt'
echo 【备份三开始建立】......
gclone copy goog:{$link} "goog:{Backupid3}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_backup3.txt'
echo 【备份三查缺补漏】......
gclone copy goog:{$link} "goog:{Backupid3}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check_backup3.txt'
echo 【备份三去重检查】......
gclone dedupe newest "goog:{Backupid3}/$folderName/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe_backup3.txt'

if [[ ! -d "gclone lsd goog:{Backupid4}" ]]; then
  gclone mkdir "goog:{Backupid4}/$folderName"
else
  echo "$folderName"
fi
id=$Backupid4
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) BackupfolderName4=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "备份四将存入分类目录："$BackupfolderName4/$folderName/$rootName
echo '备份四转存日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup4.txt'
echo '备份四查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check_backup4.txt'
echo '备份四去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe_backup4.txt'
echo 【备份四开始建立】......
gclone copy goog:{$link} "goog:{Backupid4}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_backup4.txt'
echo 【备份四查缺补漏】......
gclone copy goog:{$link} "goog:{Backupid4}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check_backup4.txt'
echo 【备份四去重检查】......
gclone dedupe newest "goog:{Backupid4}/$folderName/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe_backup4.txt'
}
echo && echo -e "
 ${Green_font_prefix} 1.${Font_color_suffix} 极速转存:讲转存入脚本配置时设置的固定文件夹
 ———————————————————————
 ${Green_font_prefix} 2.${Font_color_suffix} 分类转存:转存入输入的分类文件夹
 ———————————————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 分类转存&备份：转存入输入的分类文件夹并建立一个备份
 ———————————————————————
 ${Green_font_prefix} 4.${Font_color_suffix} 分类转存&多备份：转存入输入的分类文件夹并建立四个备份
 ———————————————————————"&& echo
read -t 5 -e -p "请输入数字 [1-4]:" num
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
4)
    run_gd_bak4
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
