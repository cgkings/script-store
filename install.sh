#!/bin/bash
rm -rf gd.sh
wget https://github.com/vitaminx/gclone-assistant/blob/master/gd.sh
echo "输入配置gclone的名称"
read -p "gclone config Name:" gclone
sed -i "s/goog/$gclone/g" gd.sh
echo "请输入需要转存到的固定地址"
read -p "固定地址ID:" id
sed -i "s/myid/$id/g" gd.sh
chmod +x gd.sh
echo "请输入 ./gd.sh 使用脚本"
