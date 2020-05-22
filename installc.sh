#!/bin/bash
rm -rf gdb.sh
wget https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/gdb.sh
echo 本脚本将执行：复制一份，备份四份，共计五份相同档案
read -p "请输入配置gclone的名称后按回车键:" gclone
sed -i "s/goog/$gclone/g" gdb.sh
read -p "请输入备份路径1的地址ID后按回车键:" id1
sed -i "s/Backupid1/$id1/g" gdb.sh
read -p "请输入备份路径2的地址ID后按回车键:" id2
sed -i "s/Backupid2/$id2/g" gdb.sh
read -p "请输入备份路径3的地址ID后按回车键:" id3
sed -i "s/Backupid3/$id3/g" gdb.sh
read -p "请输入备份路径4的地址ID后按回车键:" id4
sed -i "s/Backupid4/$id4/g" gdb.sh
chmod +x gdb.sh
mkdir -p ~/AutoRclone/LOG/
echo "请输入 ./gdb.sh 使用脚本"
