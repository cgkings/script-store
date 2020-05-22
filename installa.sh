#!/bin/bash
rm -rf gda.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/gda.sh
echo "输入配置gclone的名称"
read -p "gclone config Name:" gclone
sed -i "s/goog/$gclone/g" gda.sh
chmod +x gda.sh
echo "请输入 ./gda.sh 开始转存"
