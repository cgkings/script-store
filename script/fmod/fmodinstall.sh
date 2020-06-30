#!/bin/bash
rm -rf fmod.sh
wget https://raw.githubusercontent.com/cgkings/gclone-assistant/master/script/fmod/fmod.sh
echo "【fmod一键转存脚本自用】系统配置"
read -p "输入配置fmod的名称:" fmodid
sed -i "s/gc/$fmodid/g" fmod.sh
read -p "请输入需要转存到的固定地址ID:" tdid
sed -i "s/myid/$tdid/g" fmod.sh
chmod +x fmod.sh
echo "请输入 ./fmod.sh 使用脚本"