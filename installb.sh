#!/bin/bash
rm -rf gdb.sh
wget https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/gdb.sh
#echo "输入配置gclone的名称"
read -p "请输入配置gclone的名称后按回车键:" gclone
sed -i "s/goog/$gclone/g" gdb.sh
#echo "请输入需要转存到的固定地址"
read -p "请输入需要转存到的固定地址ID后按回车键:" id
sed -i "s/myid/$id/g" gdb.sh
read -p "请输入备份路径1的地址ID后按回车键:" id1
sed -i "s/Backupid1/$id1/g" gdb.sh
read -p "请输入备份路径2的地址ID后按回车键:" id2
sed -i "s/Backupid2/$id2/g" gdb.sh
chmod +x gdb.sh
echo "请输入 ./gdb.sh 使用脚本"
