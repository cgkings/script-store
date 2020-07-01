#!/bin/bash
rm -rf fmod.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/script/fmod/fmod.sh
echo "【fmod一键转存脚本自用】脚本配置"
read -p "输入配置fmod的名称:" fmodid
sed -i "s/goog/$fmodid/g" fmod.sh
read -p "请输入1#中转盘ID（默认）:" tdid1
sed -i "s/myid1/$tdid1/g" fmod.sh
read -p "请输入2#ADV盘ID:" tdid2
sed -i "s/myid2/$tdid2/g" fmod.sh
read -p "请输入3#MDV盘ID:" tdid3
sed -i "s/myid3/$tdid3/g" fmod.sh
read -p "请输入4#BOOK盘ID:" tdid4
sed -i "s/myid4/$tdid4/g" fmod.sh
echo "如需增减目标地址，可自行修改fmodinstall.sh和fmod.sh"
mkdir -p ~/gclone_log/
chmod +x fmod.sh
echo "请输入 ./fmod.sh 使用脚本"