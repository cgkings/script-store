#!/bin/bash
rm -rf gda.sh
wget https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/gda.sh
#echo "输入配置gclone的名称"
read -p "请输入配置gclone的名称后按回车键:" gclone
sed -i "s/goog/$gclone/g" gda.sh
chmod +x gda.sh
mkdir -p -m a=rwx AutoRclone/LOG
echo "请输入 ./gda.sh 开始转存"
