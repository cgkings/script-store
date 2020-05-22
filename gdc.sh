#!/bin/bash
read -p "请输入分享链接后按回车键:" link
link=${link#*id=};
link=${link#*folders/}
#echo $link
link=${link#*d/}
link=${link%?usp*}
id=$link
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) rootName=$(echo $j | grep -Po '(?<="name":")[^"]*')
read -p "请输入分类文件夹ID后按回车键:" folderid
id=$folderid
j=$(gclone lsd goog:{$id} --dump bodies -vv 2>&1 | grep '^{"id"' | grep $id) folderName=$(echo $j | grep -Po '(?<="name":")[^"]*')
echo "文件将拷贝入分类目录："$folderName/$rootName
echo '拷贝日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'.txt'
echo '查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check.txt'
echo '去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe.txt'
echo 【开始拷贝】......
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
echo '备份一拷贝日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup1.txt'
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
echo '备份二拷贝日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup2.txt'
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
echo '备份三拷贝日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup3.txt'
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
echo '备份四拷贝日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_backup4.txt'
echo '备份四查漏日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_check_backup4.txt'
echo '备份四去重日志文件将保存在：/root/AutoRclone/LOG/'"$rootName"'_dedupe_backup4.txt'
echo 【备份四开始建立】......
gclone copy goog:{$link} "goog:{Backupid4}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_backup4.txt'
echo 【备份四查缺补漏】......
gclone copy goog:{$link} "goog:{Backupid4}/$folderName/$rootName" --drive-server-side-across-configs -vvP --transfers=20 --min-size 100k --log-file=/root/AutoRclone/LOG/"$rootName"'_check_backup4.txt'
echo 【备份四去重检查】......
gclone dedupe newest "goog:{Backupid4}/$folderName/$rootName" --drive-server-side-across-configs -vvP --log-file=/root/AutoRclone/LOG/"$rootName"'_dedupe_backup4.txt'

#./gd.sh
