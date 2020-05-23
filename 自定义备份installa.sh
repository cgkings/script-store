#!/bin/bash
rm -rf gd.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/gdt.sh
echo "输入配置gclone的名称"
read -p "gclone config Name:" gclone
sed -i "s/goog/$gclone/g" gd.sh
echo "请输入需要转存到的固定地址"
read -p "固定地址ID:" mid
sed -i "s/myid/$mid/g" gd.sh
echo "请输入固定地址所在团队盘地址"
read -p "固定地址团队盘ID:" tid
sed -i "s/tdid/$tid/g" gd.sh
echo "请输入备份盘的全盘地址"
read -p "全盘地址ID:" bid
sed -i "s/bakid/$bid/g" gd.sh
chmod +x gd.sh
echo "请输入 ./gd.sh 使用脚本"
