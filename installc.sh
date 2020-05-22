#!/bin/bash
rm -rf gdc.sh
wget https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/gdc.sh
echo 本脚本将执行：复制一份，备份四份，共计五份相同档案
read -p "请输入配置gclone的名称后按回车键:" gclone
sed -i "s/goog/$gclone/g" gdc.sh
read -p "请输入备份路径1的地址ID后按回车键:" id1
sed -i "s/Backupid1/$id1/g" gdc.sh
read -p "请输入备份路径2的地址ID后按回车键:" id2
sed -i "s/Backupid2/$id2/g" gdc.sh
read -p "请输入备份路径3的地址ID后按回车键:" id3
sed -i "s/Backupid3/$id3/g" gdc.sh
read -p "请输入备份路径4的地址ID后按回车键:" id4
sed -i "s/Backupid4/$id4/g" gdc.sh
mkdir -p ~/AutoRclone/LOG/
chmod +x gdc.sh
echo "请输入 ./gdc.sh 使用脚本"
