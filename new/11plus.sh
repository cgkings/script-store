#!/bin/bash
RED='\E[1;31m'
RED_W='\E[41;37m'
END='\E[0m'
release=''
sys=''
ip_addr=''
emby_local_version=''


check_root(){
	if [[ $EUID -ne 0 ]]; then
 	       echo -e "${Red}本脚本必须root账号运行，请切换root用户后再执行本脚本!${END}"
	       exit 1
	fi
}

check_vz(){
	if [[ -d "/proc/vz" ]]; then
		 echo -e "${Red}对不起，您的VPS是openVZ架构，不能使用该脚本!${END}"
		 exit 1
        fi
}

#
#检查系统相关
#
check_release(){
        if [[ -f /etc/redhat-release ]]; then
               release='centos'
       elif cat /etc/issue | grep -q -E -i "debian"; then
               release='debian'
       elif cat /etc/issue | grep -q -E -i "armbian";then
	       release='armdebian'
       elif cat /etc/issue | grep -q -E -i "ubuntu"; then
               release='ubuntu'
       elif cat /etc/issue | grep -q -E -i "redhat|red hat|centos";then
               release='centos'
       elif cat /proc/version | grep -q -E -i "debian"; then
               release='debian'
       elif cat /proc/version | grep -q -E -i "ubuntu"; then
               release='ubuntu'
       elif cat /proc/version | grep -q -E -i "redhat|red hat|centos"; then
               release='centos'
       fi
        sys=$(uname -m)
}

check_command(){
        command -v $1 > /dev/null 2>&1

        if [[  $? != 0 ]];then
                echo -e "`curr_date` ${RED}$1${END} 不存在.正在为您安装，请稍后..."
                if [[ "${release}" = "centos" ]];then
                        yum install $1 -y
                elif [[ "${release}" = "debian" || "${release}" = "ubuntu" ||  "${release}" = "armdebian" ]];then
                        apt-get install $1 -y
                else
                        echo -e "`curr_date` ${RED}对不起！您的系统暂不支持该脚本，请联系作者做定制优化，谢谢！${END}"
                        exit 1
                fi
        fi

}
untar(){
        total_size=`du -sk $1 | awk '{print $1}'`
        echo
        pv -s $((${total_size} * 1020)) $1 | tar zxf - -C $2
}


check_dir_file(){
        if [ "${1:0-1:1}" = "/" ] && [ -d "$1" ];then
                return 0
        elif [ -f "$1" ];then
                return 0
        fi
        return 1
}

check_rclone(){
        check_dir_file "/usr/bin/rclone"
        [ "$?" -ne 0 ] && echo -e "`curr_date` ${RED}未检测到rclone程序.请重新运行脚本安装rclone.${END}" && exit 1
        check_dir_file "/root/.config/rclone/rclone.conf"
        [ "$?" -ne 0 ] && echo -e "`curr_date` ${RED}未检测到rclone配置文件.请重新运行脚本安装rclone.${END}" && exit 1
        return 0
}

check_emby(){
        check_dir_file "/usr/lib/systemd/system/emby-server.service"
        [ "$?" -ne 0 ] && echo -e "`curr_date` ${RED}未检测到Emby程序.请重新运行脚本安装Emby.${END}" && exit 1
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
red(){
        echo -e "${RED}${1}${END}"
}



curr_date(){
        curr_date=`date +[%Y-%m-%d"_"%H:%M:%S]`
        echo -e "`red $(date +[%Y-%m-%d_%H:%M:%S])`"
}
#
#安装rclone
#
setup_rclone(){

        if [[ ! -f /usr/bin/rclone ]];then
                echo -e "`curr_date` 正在下载rclone,请稍等..."
		if [ "${release}" != "armdebian" ];then
                	wget http://www.e-11.tk/rclone.tar.gz && tar zxvf rclone.tar.gz -C /usr/bin/

                	sleep 1s
                	rm -f rclone.tar.gz
		else
			wget http://www.e-11.tk/rclone && mv ./rclone /usr/bin/ && chmod 777 /usr/bin/rclone
		fi


                if [[ -f /usr/bin/rclone ]];then
                        sleep 1s
                        echo
                        echo -e "`curr_date` Rclone安装成功."
                else
                        echo -e "`curr_date` 安装失败.请重新运行脚本安装."
                        exit 1
                fi

        else
                echo
                echo -e "`curr_date` 本机已安装rclone.无须安装."
         fi



        if [[ ! -f /root/.config/rclone/rclone.conf ]];then
                echo
                echo -e "`curr_date` 正在下载rclone配置文件，请稍等..."
                sleep 1s
                wget http://www.e-11.tk/rclone.conf -P /root/.config/rclone/
                echo
                if [[ -f /root/.config/rclone/rclone.conf ]];then
                        sleep 1s
                        echo -e "`curr_date` 配置文件下载成功."
                else
                        echo -e "`curr_date` 下载配置文件失败,请重新运行脚本下载."
                        exit 1
                fi
        else
                echo
                echo -e "`curr_date`   本机已存在配置文件.\n\n\t\t\t如需使用新的配置文件,请先手动删除本机配置文件(`red "mv -f /root/.config/rclone/rclone.conf /root/.config/rclone/"`)后再运行脚本."
        fi
}

#
#安装Emby
#

setup_emby(){

        emby_version=`curl -s https://github.com/MediaBrowser/Emby.Releases/releases/ | grep -Eo "tag/[0-9.]+\">([0-9.]+.*)" | grep -v "beta"|grep -Eo "[0-9.]+"|head -n1`
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
                        echo -e "`curr_date` 本系统已安装最新版，无需操作。"
                        return 0
                else
                        sleep 1s
                        echo -e "`curr_date` 已安装版本为：${RED}${emby_local_version}${END}.最新版本为：${RED}${emby_version}${END}.正在为您更新..."
                        echo
                fi
        fi
        echo -e "`curr_date` 您的系统是 ${RED}${release}${END}。正在为您准备安装包,请稍等..."
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


#
#创建rclone服务
#
create_rclone_service(){

        check_rclone

        i=1

        list=()

        for item in $(sed -n "/\[.*\]/p" ~/.config/rclone/rclone.conf | grep -Eo "[0-9A-Za-z-]+")
        do
                list[i]=${item}
                i=$((i+1))
        done
        while [[ 0 ]]
        do
                while [[ 0 ]]
                do
                        echo
                        echo -e "   本地已配置网盘列表:"
                        echo
				echo -e "      `red +-------------------------+`"
                        for((j=1;j<=${#list[@]};j++))
                        do
				temp="${j}：${list[j]}"
				count=$((`echo "${temp}" | wc -m` -1))
				if [ "${count}" -le 6 ];then
					temp="${temp}\t\t\t"
				elif [ "${count}" -gt 6 ] && [ "$count" -le 14 ];then
					temp="${temp}\t\t"
				elif [ "${count}" -gt 14 ];then
					temp="${temp}\t"
				fi
                                echo -e "      ${RED}| ${temp}|${END}"
                                echo -e "      `red +-------------------------+`"
                        done


                        echo
                        read -n3 -p "   请选择需要挂载的网盘（输入数字即可）：" rclone_config_name
                        if [ ${rclone_config_name} -le ${#list[@]} ] && [ -n ${rclone_config_name} ];then
                                echo
                                echo -e "`curr_date` 您选择了：${RED}${list[rclone_config_name]}${END}"
                                break
                        fi
                        echo
                        echo "输入不正确，请重新输入。"
                        echo
                done
                echo
                read -p "请输入需要挂载目录的路径（如不是绝对路径则挂载到/mnt下）:" path
                if [[ "${path:0:1}" != "/" ]];then
                        path="/mnt/${path}"
                fi
                while [[ 0 ]]
                do
                        echo
                        echo -e "您选择了 ${RED}${list[rclone_config_name]}${END} 网盘，挂载路径为 ${RED}${path}${END}."
                        read -n1 -p "确认无误[Y/n]:" result
                        echo
                        case ${result} in
                                Y | y)
                                        echo
                                        break 2;;
                                n | N)
                                        continue 2;;
                                *)
                                        echo
                                        continue;;
                        esac
                done

        done


        fusermount -qzu "${path}"
        if [[ ! -d ${path} ]];then
                echo
                echo -e "`curr_date`  ${RED}${path}${END} 不存在，正在创建..."
                mkdir -p ${path}
                sleep 1s
                echo
                echo -e "`curr_date` 创建完成！"
        fi



        echo
        echo -e "`curr_date` 正在检查服务是否存在..."
        if [[ -f /lib/systemd/system/rclone-${list[rclone_config_name]}.service ]];then

                echo -e "`curr_date` 找到服务 \"${RED}rclone-${list[rclone_config_name]}.service${END}\"正在删除，请稍等..."
                systemctl stop rclone-${list[rclone_config_name]}.service &> /dev/null
                systemctl disable rclone-${list[rclone_config_name]}.service &> /dev/null
                rm /lib/systemd/system/rclone-${list[rclone_config_name]}.service &> /dev/null
                sleep 2s
                echo -e "`curr_date` 删除成功。"
        fi
        echo -e "`curr_date` 正在创建服务 \"${RED}rclone-${list[rclone_config_name]}.service${END}\"请稍等..."
        echo "[Unit]
        Description = rclone-sjhl

        [Service]
        User = root
        ExecStart = /usr/bin/rclone mount ${list[rclone_config_name]}: ${path} --transfers 10  --buffer-size 1G --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 2G  --allow-non-empty --allow-other --dir-cache-time 12h --umask 000
        Restart = on-abort

        [Install]
        WantedBy = multi-user.target" > /lib/systemd/system/rclone-${list[rclone_config_name]}.service
        sleep 2s
        echo -e "`curr_date` 服务创建成功。"
        if [ ! -f /etc/fuse.conf ]; then
                echo -e "`curr_date` 未找到fuse包.正在安装..."
                sleep 1s
                if [[ "${release}" = "centos" ]];then
                        yum install fuse -y
                elif [[ "${release}" = "debian" || "${release}" = "ubuntu" ]];then
                        apt-get install fuse -y
                fi
                echo
                echo -e "`curr_date` fuse安装完成."
                echo
        fi

        sleep 2s
        echo
        echo -e "`curr_date` 启动服务..."
        systemctl start rclone-${list[rclone_config_name]}.service &> /dev/null
        sleep 1s
        echo -e "`curr_date` 添加开机启动..."
        systemctl enable rclone-${list[rclone_config_name]}.service &> /dev/null
        if [[ $? ]];then
                echo
                echo -e "已为网盘 ${RED}${list[rclone_config_name]}${END} 创建服务 ${RED}reclone-${list[rclone_config_name]}.service${END}.并已添加开机挂载.\n您可以通过 ${RED}systemctl [start|stop|status]${END} 进行挂载服务管理。"
                echo
                echo
                sleep 2s
        else
                echo
                echo -e "`curr_date` 警告:未知错误."
        fi
}

#
#复制Emby配置文件
#
renew_emby(){
        if [ -d /var/lib/emby.bak ];then
                 echo -e "`curr_date` 找到已备份的emby配置文件，正在还原..."
                 mv -f /var/lib/emby.bak /var/lib/emby
                 systemctl start emby-server.service
                 echo
                 echo -e "`curr_date` 已还原Emby."
         else
                echo
                 echo -e "`curr_date` ${RED}未知错误.还原失败!${END}"
        fi
}
get_nfo_db_path(){
	echo
	echo -e "请输入削刮包安装路径，留空则默认为 `red /home/Emby`.\n如果是相对路径则是默认在 `red /home` 目录下创建输入的目录名称."
	read -p "请输入路径(例如:/mnt/xg)：" nfo_db_path
	if [ -d /home/Emby ];then
		temp_date=`date +%y%m%d%H%M%S`
		echo
		echo -e "找到 `red /home/Emby` 正备份为 `red /home/Emby_${temp_date}.bak`..."
		sleep 1s
		mv /home/Emby /home/Emby_${temp_date}.bak
	fi	
	if [ "${nfo_db_path}" == "" ];then
		nfo_db_path="/home/Emby"
	elif [ "${nfo_db_path:0:1}" != "/" ];then
                nfo_db_path="/home/${nfo_db_path}"
		echo -e "正在创建 `red ${nfo_db_path}` 链接到`red /home/Emby`"
		ln -s "${nfo_db_path}" /home/Emby
	else
		ln -s "${nfo_db_path}" /home/Emby
		echo -e "正在创建 `red ${nfo_db_path}` 链接到`red /home/Emby`"
	fi
}

copy_emby_config(){
        db_path="/mnt/video/EmbyDatabase/"
        nfo_db_file="Emby削刮库.tar.gz"
        opt_file="Emby-server数据库.tar.gz"
        var_config_file="Emby-VarLibEmby数据库.tar.gz"



        check_emby
	get_nfo_db_path
        if [ -f /usr/lib/systemd/system/emby-server.service ];then
                echo -e "`curr_date` 停用Emby服务..."
                systemctl stop emby-server.service
                sleep 2s
                echo
                echo -e "`curr_date` 已停用Emby服务"
        else
                sleep 2s
                echo
                echo -e "`curr_date` 未找到emby.请重新执行安装脚本安装."
                exit 1
        fi

        if [ -d /var/lib/emby ];then
                echo
                echo -e "`curr_date` 已找到emby配置文件，正在备份..."
                mv -f /var/lib/emby /var/lib/emby.bak
                sleep 2s
                echo -e "`curr_date` 已将 ${RED}/var/lib/emby${END} 备份到当前目录."
                echo
        elif  [ -d /var/lib/emby.bak ];then
                echo -e "`curr_date` 已备份，无需备份."
                sleep 2s
        fi
        echo -e "`curr_date` 正在安装削刮库到 ${RED}${nfo_db_path}${END} 需要很长时间,请耐心等待..."
        if [ ! -d "${nfo_db_path}" ];then
                mkdir ${nfo_db_path}
        fi
        if [  -d ${db_path} ];then
                if [ -f "${db_path}${nfo_db_file}" ];then
                        untar ${db_path}${nfo_db_file}  ${nfo_db_path}
                else
                        echo -e "`curr_date` 未能找到削刮包 ${RED}${db_path}${nfo_db_file}${END} 请确认无误后重新运行脚本."
                        echo
                        renew_emby
                        exit 1
                fi
                if [ "$?" -eq 0 ];then
                        echo -e "`curr_date` Emby削刮包安装完成."
                else
                        echo -e "`curr_date` 异常退出.请检查挂载并从新运行脚本."
                        exit 1
                fi
                echo

                sleep 2s
                echo -e "`curr_date` 正在安装emby配置文件.请稍等..."

                if [ -f ${db_path}${var_config_file} ];then
                        untar ${db_path}${var_config_file} /var/lib
                else
                        echo -e "`curr_date` 未能找到配置文件包 ${RED}${db_path}${var_config_file}${END} 请确认无误后重新运行脚本."
                        echo
                        renew_emby
                        exit 1

                fi

                if [ "$?" -eq 0 ];then
                        echo -e "`curr_date` Emby程序配置完成."
                else
                        echo -e "`curr_date` 异常退出.请检查挂载并从新运行脚本."
                        exit 1
                fi
                echo

        else
                echo -e "`curr_date` 未找到 ${RED}${db_path}${END},请检查是否正确挂载。确认无误后重新执行脚本."
                echo
                renew_emby
                exit 1

        fi

        echo -e "`curr_date` 启动emby服务..."
        systemctl start emby-server.service

        sleep 1s
        echo -e "`curr_date` 配置完成."
        echo
        echo -e "访问地址为:${RED}http://${ip_addr}:8096。账号：admin 密码为空${END}"
}


add_swap(){
	echo
	echo -e "${RED}请输入需要添加的swap，建议为物理内存的2倍大小\n默认为KB，您也可以输入数字+[KB、MB、GB]的方式！（例如：4GB、4096MB、4194304KB）${END}"
	read -p "请输入swap数值(MB):" size
	echo
	size=`echo ${size} | tr '[a-z]' '[A-Z]'`
        size_unit=${size:0-2:2}
        echo "${size_unit}" | grep -qE '^[0-9]+$'
        if [ $? -eq 0 ];then
               size="${size}MB"
        else
 	       if [ "${size_unit}" != "GB" ] && [ "${size_unit}" != "MB" ] && [ "${size_unit}" != "KB" ];then
		       echo -e "swap大小只能是数字+单位，并且单位只能是KB、MB、GB。请检查后重新输入。"
                        add_swap
                fi
        fi
	
	
	
	grep -q "swapfile" /etc/fstab
	if [ $? -ne 0 ];then
		echo -e "`red 正在创建swapfile...`"
		sleep 2s
		fallocate -l ${size} /swapfile
		chmod 600 /swapfile
		mkswap /swapfile
		swapon /swapfile
		echo '/swapfile none swap defaults 0 0' >> /etc/fstab
		echo -e "${RED}swap创建成功，信息如下：${END}"
		cat /proc/swaps
		cat /proc/meminfo | grep swap
	else
		echo -e "`red swapfile已存在，swap设置失败，请先运行脚本删除swap后重新设置！`"
	fi
}

del_swap(){
	grep -q "swapfile" /etc/fstab
	if [ $? -eq 0 ];then
		echo
		echo -e "`red 正在删除SWAP空间...`"
		sleep 2s
		sed -i '/swapfile/d' /etc/fstab
		echo "3" > /proc/sys/vm/drop_caches
		swapoff -a
		rm -f /wapfile
		echo
		echo -e "`red 删除成功！`"
	else
		echo
		echo -e "`red 未找到swapfile，删除失败！`"
	fi
}

menu_go_on(){
        echo
        echo -e "${RED}是否继续执行脚本?${END}"
        read -n1 -p "Y继续执行，N退出脚本[Y/n]" res
        echo
        case "$res" in
                Y |y)
                        ;;
                N | n)
                        exit 1;;
                *)
                        echo "输入错误"
                        menu_go_on;;
        esac
}

swap_menu(){
        clear
        echo
        echo
        echo -e "   ${RED_W}+-----------------------------------------------+${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}|      欢迎使用一键安装Rclone、Emby脚本         |${END}"
	echo -e "   ${RED_W}|    BUG反馈电报群:https://t.me/P11DrivePlus    |${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}+-----------------------------------------------+${END}"
        echo
        echo -e "   ${RED}[当前位置:主菜单 >> SWAP配置]：${END}"
        echo
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [1]：添加SWAP空间.  |${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [2]：删除SWAP空间.  |${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [3]：返回主菜单.    |${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo
        read  -p "   请选择输入菜单对应数字开始执行：" select_swap
	check_vz
	case "${select_swap}" in
		1)
			add_swap;;
		2)
			del_swap;;
		3)
			menu;;
		*)
			echo -e "选择错误，请重新输入！"
			swap_menu;;
	esac
	echo
	read -n1 -p "是否返回主菜单(按 Y 返回主菜单，其它任意键继续执行SWAP配置)[Y]..." rturn
	
	case "${rturn}" in
		Y | y)
			menu;;
		*)
			swap_menu;;
	esac
}
menu(){
        clear
        echo
        echo
        echo -e "   ${RED_W}+-----------------------------------------------+${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}|      欢迎使用一键安装Rclone、Emby脚本         |${END}"
	echo -e "   ${RED_W}|    BUG反馈电报群:https://t.me/P11DrivePlus    |${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}|                                               |${END}"
        echo -e "   ${RED_W}+-----------------------------------------------+${END}"
        echo
        echo -e "   ${RED}[主菜单]：${END}"
        echo
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [1]：安装Rclone.    |${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [2]：安装/更新Emby. |${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [3]：安装Rclone服务.|${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [4]：复制Emby削刮包.|${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [5]：swap配置.      |${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo -e "        ${RED}| [6]：退出脚本.      |${END}"
        echo -e "        ${RED}+---------------------+${END}"
        echo
        read  -p "   请选择输入菜单对应数字开始执行：" select_menu
	check_root
        check_release
        check_command pv
	check_command tar
        check_command curl
        check_command wget

        ip_addr=$(curl -s ifconfig.me)
        case "${select_menu}" in
                1)
                        setup_rclone;;
                2)
                        setup_emby;;
                3)
                        create_rclone_service;;
                4)
                        copy_emby_config;;
		5)
			swap_menu;;
                6)
                        exit 1;;
                *)
                        echo
                        echo -e "`curr_date` ${RED}选择错误，请重新选择。${END}"
                        menu;;
        esac
        menu_go_on
        menu
}

menu
