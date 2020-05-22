#!/bin/bash
rm -rf gdb.sh
wget https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/gdb.sh
#echo "输入配置gclone的名称"
echo 本脚本将执行：复制一份，备份两份，共计三份相同档案
read -p "请输入配置gclone的名称后按回车键:" gclone
sed -i "s/goog/$gclone/g" gdb.sh
read -p "请输入备份路径1的地址ID后按回车键:" id1
sed -i "s/Backupid1/$id1/g" gdb.sh
read -p "请输入备份路径2的地址ID后按回车键:" id2
sed -i "s/Backupid2/$id2/g" gdb.sh
mkdir -p ~/AutoRclone/LOG/
chmod +x gdb.sh
echo "请输入 ./gdb.sh 使用脚本"
