#!/bin/bash
rm -rf gdX.sh
wget https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/gdx.sh
echo "TD分享链接一键转存脚本 4 in 1版系统配置"
read -p "请输入配置gclone的名称后按回车键:" gclone
sed -i "s/goog/$gclone/g" gdx.sh
read -p "请输入需要转存到的固定地址ID后按回车键:" id
sed -i "s/myid/$id/g" gdx.sh
read -p "请输入备份路径1的地址ID后按回车键:" id1
sed -i "s/Backupid1/$id1/g" gdx.sh
read -p "请输入备份路径2的地址ID后按回车键:" id2
sed -i "s/Backupid2/$id2/g" gdx.sh
read -p "请输入备份路径3的地址ID后按回车键:" id3
sed -i "s/Backupid3/$id3/g" gdx.sh
read -p "请输入备份路径4的地址ID后按回车键:" id4
sed -i "s/Backupid4/$id4/g" gdx.sh
mkdir -p ~/AutoRclone/LOG/
chmod +x gdx.sh
echo "请输入 ./gdx.sh 使用脚本"
