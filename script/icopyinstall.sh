#!/bin/bash
# 进行选项操作，默认1急速转存
run_icopy_install() {
bash <(wget -qO- https://git.io/gclone.sh)
git clone https://github.com/fxxkrlab/iCopy.git && cd iCopy
python3 -m venv .
../bin/activate
pip3 install -r requirements.txt -y
cp settings.py.example settings.py
read -p "请输入BOT TOKEN" tokenid
sed -i "s/"填写bot Api Token"/$tokenid/g" settings.py
read -p "请输入个人TG的ID" myid
sed -i "s/"填写个人TG ID"/$myid/g" settings.py
read -p "请输入gclone配置名" gcloneid
sed -i "s/"填写gclone配置名"/$gcloneid/g" settings.py
read -p "请输入固定地址ID" folderid
sed -i "s/"预定的Dst Folder ID"/$folderid/g" settings.py
read -p "请输入sa文件夹，结尾不要加\" safolder
sed -i "s/"填入Service_Account_Path路径末端不需要的斜杠"/$safolder/g" settings.py
}
run_icopy_update() {
cd /root/iCopy
git pull
}
run_icopy_uninstall() {
cd /root/iCopy
pip3 uninstall -r requirements.txt -y
rm -rf /root/iCopy
}
run_icopy_reinstall() {
cd /root/iCopy
pip3 uninstall -r requirements.txt -y
rm -rf /root/iCopy
bash <(wget -qO- https://git.io/gclone.sh)
git clone https://github.com/fxxkrlab/iCopy.git && cd iCopy
python3 -m venv .
../bin/activate
pip3 install -r requirements.txt -y
cp settings.py.example settings.py
read -p "请输入BOT TOKEN" tokenid
sed -i "s/"填写bot Api Token"/$tokenid/g" settings.py
read -p "请输入个人TG的ID" myid
sed -i "s/"填写个人TG ID"/$myid/g" settings.py
read -p "请输入gclone配置名" gcloneid
sed -i "s/"填写gclone配置名"/$gcloneid/g" settings.py
read -p "请输入固定地址ID" folderid
sed -i "s/"预定的Dst Folder ID"/$folderid/g" settings.py
read -p "请输入sa文件夹，结尾不要加\" safolder
sed -i "s/"填入Service_Account_Path路径末端不需要的斜杠"/$safolder/g" settings.py
}
echo && echo -e " icopy一键安装脚本 ${Red_font_prefix}[v1.0 ${Font_color_suffix} by \033[1;35mcgkings\033[0m
 
 ${Green_font_prefix} 1.${Font_color_suffix} 首次安装
 ———————————————————————
 ${Green_font_prefix} 2.${Font_color_suffix} 更新安装
 ———————————————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 卸载
  ———————————————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 故障重新安装
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-4]:" num
num=${num:-1}
case "$num" in
1)
    run_icopy_install
    ;;
2)
    run_icopy_update
    ;;
3)
    run_icopy_uninstall
    ;;
4)
    run_icopy_reinstall
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
