#!/bin/bash

#fonts color
Green="\033[32m" 
Red="\033[31m" 
Font="\033[0m"

#notification information
Info="${Red}[Info]${Font}"
OK="${Red}[OK]${Font}"
Error="${Red}[Error]${Font}"

#folder
yh_tz="https://www.moerats.com/usr/down/YX_TZ/yh_tz.zip"
x_tz="https://www.moerats.com/usr/down/YX_TZ/x_tz.zip"

source /etc/os-release &>/dev/null

domain_check()
{
MyLink=$MyLink
read -p "请输入你的域名或IP: " MyLink
}

# 系统检测、支持 Debian 和 Ubuntu系统
check_system(){
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 6 ]];then
        echo -e "${OK} ${Green} 当前系统为 Debian ${VERSION_ID} ${Font} "
    elif [[ "${ID}" == "ubuntu" && `echo "${VERSION_ID}" | cut -d '.' -f1` -ge 12 ]];then
        echo -e "${OK} ${Green} 当前系统为 Ubuntu ${VERSION_ID} ${Font} "
    else
        echo -e "${Error} ${Red} 当前系统为不在支持的系统列表内，安装中断 ${Font} "
        exit 1
    fi
}
# 判定是否为root用户
is_root(){
    if [ `id -u` == 0 ]
        then echo -e "${OK} ${Green} 当前用户是root用户，进入安装流程 ${Font} "
        sleep 1
    else
        echo -e "${Error} ${Red} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}" 
        exit 1
    fi
}
debian_update(){
apt-get -y update && apt-get -y upgrade
apt-get -y install unzip
}

install_nginx_php(){
wget --no-check-certificate https://raw.github.com/Xeoncross/lowendscript/master/setup-debian.sh && chmod +x setup-debian.sh && ./setup-debian.sh dotdeb && ./setup-debian.sh nginx && ./setup-debian.sh php
}

yh_install(){
./setup-debian.sh site ${MyLink} && cd /var/www/${MyLink}/public && wget -N --no-check-certificate ${yh_tz} && unzip yh_tz.zip
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${Green}雅黑探针 安装成功 进入http://${MyLink}/tz.php查看 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${Red}雅黑探针 安装失败 ${Font}"
        exit 1
    fi
}
x_install(){
./setup-debian.sh site ${MyLink} && cd /var/www/${MyLink}/public && wget -N --no-check-certificate ${x_tz} && unzip x_tz.zip
    if [[ $? -eq 0 ]];then
        echo -e "${OK} ${Green}X-Prober探针 安装成功 进入http://${MyLink}/tz.php查看 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${Red}X-Prober探针 安装失败 ${Font}"
        exit 1
    fi
}

standard_yh(){
    debian_update
    domain_check
    install_nginx_php
    yh_install
}

standard_x(){
    debian_update
    domain_check
    install_nginx_php
    x_install
}

main(){
         echo "################################################"
         echo "#    探针一键脚本 for Ubuntu/Debian系统        #"
         echo "################################################"
         check_system
         is_root
	sleep 2
	echo -e "${Red}请输入对应的数字进行安装：${Font}"
	echo -e "1、安装雅黑探针"
	echo -e "2、安装X-Prober探针"
	read -p "Please input a number: " number
	case ${number} in
		1)
            standard_yh
	         ;;
		2)
            standard_x
	         ;;
		*)
			echo -e "${Error} ${RedBG} 请输入正确的数字 ${Font}"
			exit 1
			;;
	esac
   
}

main