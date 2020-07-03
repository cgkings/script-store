#!/bin/bash
rm -rf fmod.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/script/fmod/fmod.sh
echo "【fmod一键转存脚本自用】脚本配置"
read -p "输入配置fmod的名称:" fmodid
sed -i "s/goog/$fmodid/g" fmod.sh
read -p "请输入0#中转盘ID（默认）:" tdid0
sed -i "s/myid0/$tdid0/g" fmod.sh
read -p "请输入1#ADV盘ID:" tdid1
sed -i "s/myid1/$tdid1/g" fmod.sh
read -p "请输入2#MDV盘ID:" tdid2
sed -i "s/myid2/$tdid2/g" fmod.sh
read -p "请输入3#BOOK盘ID:" tdid3
sed -i "s/myid3/$tdid3/g" fmod.sh
echo "如需增减目标地址，可自行修改fmodinstall.sh和fmod.sh"
mkdir -p ~/gclone_log/
chmod +x fmod.sh
echo "请输入 ./fmod.sh 使用脚本"