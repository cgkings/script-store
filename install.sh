#!/bin/bash
rm -rf gd.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/gd.sh
echo "【gclone懒人一键转存脚本】系统配置"
echo "输入配置gclone的名称"
read -p "gclone config Name:" gclone
sed -i "s/goog/$gclone/g" gd.sh
echo "请输入需要转存到的固定地址"
read -p "固定地址ID:" mid
sed -i "s/myid/$mid/g" gd.sh
chmod +x gd.sh
echo "请输入 ./gd.sh 使用脚本"
