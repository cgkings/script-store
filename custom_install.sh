#!/bin/bash
rm -rf custom_gd.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/custom_gd.sh
echo "输入配置gclone的名称"
read -p "gclone config Name:" gclone
sed -i "s/goog/$gclone/g" custom_gd.sh
chmod +x custom_gd.sh
echo "请输入 ./custom_gd.sh 使用脚本"
