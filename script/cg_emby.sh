#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_emby)
# File Name: cg_emby.sh
# Author: cgkings
# Created Time : 2021.3.4
# Description:swap一键脚本
# System Required: Debian/Ubuntu
# 感谢wuhuai2020、moerats、github众多作者，我只是整合代码
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor
ip_addr=$(curl -s ifconfig.me)

################## 前置变量 ##################
check_emby(){
        check_dir_file "/usr/lib/systemd/system/emby-server.service"
        [ "$?" -ne 0 ] && echo -e "${curr_date} ${RED}未检测到Emby程序.请重新运行脚本安装Emby.${END}" && exit 1
        return 0
}

check_emby_local_version(){
        if [[ "${release}" == "centos" ]];then
                emby_local_version=$(rpm -q emby-server | grep -Eo "[0-9.]+\.[0-9]+")
        elif [[ "${release}" == "debian" ]] || [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "armdebian" ]];then
                emby_local_version=$(dpkg -l emby-server | grep -Eo "[0-9.]+\.[0-9]+")
        else
                echo -e "${RED}获取emby版本失败.暂时不支持您的操作系统.${END}"
        fi
}

#安装Emby
#

setup_emby(){
        emby_version=$(curl -s https://github.com/MediaBrowser/Emby.Releases/releases/ | grep -Eo "tag/[0-9.]+\">([0-9.]+.*)" | grep -v "beta"|grep -Eo "[0-9.]+"|head -n1)
        centos_packet_file="emby-server-rpm_${emby_version}_x86_64.rpm"
        debian_packet_file="emby-server-deb_${emby_version}_amd64.deb"
	armdebian64_packet_file="emby-server-deb_${emby_version}_arm64.deb"
        url="https://github.com/MediaBrowser/Emby.Releases/releases/download"
        debian_url="${url}/${emby_version}/${debian_packet_file}"
        armdebian64_url="${url}/${emby_version}/${armdebian64_packet_file}"
        centos_url="${url}/${emby_version}/${centos_packet_file}"

        check_emby_local_version

        if [ -n "${emby_local_version}" ]; then

                if [ "${emby_local_version}" = "${emby_version}" ];then
                        sleep 1s
                        echo
                        echo -e "${curr_date} 本系统已安装最新版，无需操作。"
                        return 0
                else
                        sleep 1s
                        echo -e "${curr_date} 已安装版本为：${RED}${emby_local_version}${END}.最新版本为：${RED}${emby_version}${END}.正在为您更新..."
                        echo
                fi
        fi
        echo -e "${curr_date} 您的系统是 ${RED}${release}${END}。正在为您准备安装包,请稍等..."
        if [[ "${release}" = "debian" ]];then
                if [[ "${sys}" = "x86_64" ]];then
                        wget -c "${debian_url}" && dpkg -i "${debian_packet_file}"
                        sleep 1s
                        rm -f "${debian_packet_file}"
                fi
	elif [[ "${release}" = "armdebian" ]];then
		if [[ "${sys}" = "aarch64" ]];then
			
                        wget -c "${armdebian64_url}" && dpkg -i "${armdebian64_packet_file}"
		fi
        elif [[ "${release}" = "ubuntu" ]];then
                if [[ "${sys}" = "x86_64" ]];then
                        wget -c "${debian_url}" && dpkg -i "${debian_packet_file}"
                        sleep 1s
                        rm -f "${debian_packet_file}"
                fi
        elif [[ "${release}" = "centos" ]];then
                if [[ "${sys}" = "x86_64" ]];then
                        yum install -y "${centos_url}"
                        sleep 1s
                        rm -f "${centos_packet_file}"
                fi
        fi
        echo -e "Emby安装成功.您可以访问 ${RED}http://${ip_addr}:8096/${END} 进一步配置Emby."

}

################## 前置变量 ##################
setup_emby
