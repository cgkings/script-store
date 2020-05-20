#!/bin/bash
rm -rf gd.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/custom_gd.sh
echo "输入配置gclone的名称"
read -p "gclone config Name:" gclone
sed -i "s/goog/$gclone/g" gd.sh
chmod +x gd.sh
echo "请输入 ./gd.sh 使用脚本"
