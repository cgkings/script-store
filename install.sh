#!/bin/bash
rm -rf gd.sh
wget https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/gd.sh
#echo "输入配置gclone的名称"
read -p "请输入配置gclone的名称后按回车键:" gclone
sed -i "s/goog/$gclone/g" gd.sh
#echo "请输入需要转存到的固定地址"
read -p "请输入需要转存到的固定地址ID后按回车键:" id
sed -i "s/myid/$id/g" gd.sh
mkdir -p ~/AutoRclone/LOG/
chmod +x gd.sh
echo "请输入 ./gd.sh 使用脚本"
