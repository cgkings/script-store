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
check_sys
check_release
ip_addr=$(hostname -I | awk '{print $1}')

################## 安装emby ##################
check_emby_version() {
  #获取官网最新正式版版本号(排除beta版)
  emby_version=$(curl -s https://github.com/MediaBrowser/Emby.Releases/releases/ | grep -Eo "tag/[0-9.]+\">([0-9.]+.*)" | grep -v "beta" | grep -Eo "[0-9.]+" | head -n1)
  #获取本地emby版本号
  if [[ "${release}" == "centos" ]]; then
    emby_local_version=$(rpm -q emby-server | grep -Eo "[0-9.]+\.[0-9]+")
  elif [[ "${release}" == "debian" ]] || [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "armdebian" ]]; then
    emby_local_version=$(dpkg -l emby-server | grep -Eo "[0-9.]+\.[0-9]+")
  fi
}

check_emby() {
  #判断emby本地安装状态
  if [ -f /usr/lib/systemd/system/emby-server.service ]; then
    #如已安装，获取本地安装的emby版本
    check_emby_local_version
    if [ "${emby_local_version}" = "${emby_version}" ]; then
      sleep 1s
      echo
      echo -e "${curr_date} ${green}[INFO]${normal} 您的系统已安装最新版emby。"
      return 0
    else
      sleep 1s
      echo -e "${curr_date} ${green}[INFO]${normal} 已安装版本为：${emby_local_version}.最新版本为:${emby_version}.请自便！"
      return 0
    fi
  else
    #如未安装，则进行安装
    echo -e "${curr_date} ${green}[INFO]${normal} 您的系统是 ${release}。正在为您准备安装包,请稍等..."
    if [[ "${release}" == "centos" ]]; then
      yum install https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-rpm_"${emby_version}"_x86_64.rpm
    elif [[ "${release}" == "debian" ]] || [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "armdebian" ]]; then
      wget -vN https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-deb_"${emby_version}"_amd64.deb
      dpkg -i emby-server-deb_"${emby_version}"_amd64.deb
      sleep 1s
      rm -f emby-server-deb_"${emby_version}"_amd64.deb
    fi
    echo -e "${curr_date} ${green}[INFO]${normal} Emby安装成功.您可以访问  http://${ip_addr}:8096 进一步配置Emby."
  fi
}

################## 破解emby ##################
pojie_emby() {
  sudo -i #切换为 root 用户
  systemctl stop emby-server.service #结束 emby 进程
  rm -f /opt/emby-server/system/System.Net.Http.dll
  wget https://github.com/cgkings/script-store/raw/master/config/System.Net.Http.dll -O /opt/emby-server/system/System.Net.Http.dll #(注意替换掉命令中的 emby 所在目录)下载破解程序集替换原有程序
  systemctl start emby-server.service #启动 Emby 进程
}

################## 修改emby服务,fail自动重启 ##################
sys_emby() {
  sudo -i #切换为 root 用户
  systemctl stop emby-server #结束 emby 进程
  sed -i '/[Service]/a\Restart = on-failure\nRestartSec = 5' /usr/lib/systemd/system/emby-server.service
  


}

################## 卸载emby ##################
dpkg -r --purge emby-server

################## 备份emby ##################
bak_emby() {
  check_emby

}

echo "Restarting Emby server.."
sudo systemctl restart emby-server

################## 还原emby ##################

renew_emby() {
        if [ -d /var/lib/emby.bak ]; then
                 echo -e "$(curr_date) 找到已备份的emby配置文件，正在还原..."
                 mv -f /var/lib/emby.bak /var/lib/emby
                 systemctl start emby-server.service
                 echo
                 echo -e "$(curr_date) 已还原Emby."
  else
                echo
                 echo -e "$(curr_date) ${red}未知错误.还原失败!${END}"
  fi
}
get_nfo_db_path() {
  echo
  echo -e "请输入削刮包安装路径，留空则默认为 $(red /home/Emby).\n如果是相对路径则是默认在 $(red /home) 目录下创建输入的目录名称."
  read -p "请输入路径(例如:/mnt/xg)：" nfo_db_path
  if [ -d /home/Emby ]; then
    temp_date=$(date +%y%m%d%H%M%S)
    echo
    echo -e "找到 $(red /home/Emby) 正备份为 $(red /home/Emby_${temp_date}.bak)..."
    sleep 1s
    mv /home/Emby /home/Emby_${temp_date}.bak
  fi
  if [ "${nfo_db_path}" == "" ]; then
    nfo_db_path="/home/Emby"
  elif [ "${nfo_db_path:0:1}" != "/" ]; then
                nfo_db_path="/home/${nfo_db_path}"
    echo -e "正在创建 $(red ${nfo_db_path}) 链接到$(red /home/Emby)"
    ln -s "${nfo_db_path}" /home/Emby
  else
    ln -s "${nfo_db_path}" /home/Emby
    echo -e "正在创建 $(red ${nfo_db_path}) 链接到$(red /home/Emby)"
  fi
}

copy_emby_config() {
        db_path="/mnt/video/EmbyDatabase/"
        nfo_db_file="Emby削刮库.tar.gz"
        opt_file="Emby-server数据库.tar.gz"
        var_config_file="Emby-VarLibEmby数据库.tar.gz"

        check_dir_file "/usr/lib/systemd/system/emby-server.service"
        [ "$?" -ne 0 ] && echo -e "${curr_date} ${red}未检测到Emby程序.请重新运行脚本安装Emby.${END}" && exit 1

  get_nfo_db_path
        if [ -f /usr/lib/systemd/system/emby-server.service ]; then
                echo -e "$(curr_date) 停用Emby服务..."
                systemctl stop emby-server.service
                sleep 2s
                echo
                echo -e "$(curr_date) 已停用Emby服务"
  else
                sleep 2s
                echo
                echo -e "$(curr_date) 未找到emby.请重新执行安装脚本安装."
                exit 1
  fi

        if [ -d /var/lib/emby ]; then
                echo
                echo -e "$(curr_date) 已找到emby配置文件，正在备份..."
                mv -f /var/lib/emby /var/lib/emby.bak
                sleep 2s
                echo -e "$(curr_date) 已将 ${red}/var/lib/emby${END} 备份到当前目录."
                echo
  elif        [ -d /var/lib/emby.bak ]; then
                echo -e "$(curr_date) 已备份，无需备份."
                sleep 2s
  fi
        echo -e "$(curr_date) 正在安装削刮库到 ${red}${nfo_db_path}${END} 需要很长时间,请耐心等待..."
        if [ ! -d "${nfo_db_path}" ]; then
                mkdir ${nfo_db_path}
  fi
        if [  -d ${db_path} ]; then
                if [ -f "${db_path}${nfo_db_file}" ]; then
                        untar ${db_path}${nfo_db_file}  ${nfo_db_path}
    else
                        echo -e "$(curr_date) 未能找到削刮包 ${red}${db_path}${nfo_db_file}${END} 请确认无误后重新运行脚本."
                        echo
                        renew_emby
                        exit 1
    fi
                if [ "$?" -eq 0 ]; then
                        echo -e "$(curr_date) Emby削刮包安装完成."
    else
                        echo -e "$(curr_date) 异常退出.请检查挂载并从新运行脚本."
                        exit 1
    fi
                echo

                sleep 2s
                echo -e "$(curr_date) 正在安装emby配置文件.请稍等..."

                if [ -f ${db_path}${var_config_file} ]; then
                        untar ${db_path}${var_config_file} /var/lib
    else
                        echo -e "$(curr_date) 未能找到配置文件包 ${red}${db_path}${var_config_file}${END} 请确认无误后重新运行脚本."
                        echo
                        renew_emby
                        exit 1

    fi

                if [ "$?" -eq 0 ]; then
                        echo -e "$(curr_date) Emby程序配置完成."
    else
                        echo -e "$(curr_date) 异常退出.请检查挂载并从新运行脚本."
                        exit 1
    fi
                echo

  else
                echo -e "$(curr_date) 未找到 ${red}${db_path}${END},请检查是否正确挂载。确认无误后重新执行脚本."
                echo
                renew_emby
                exit 1

  fi

        echo -e "$(curr_date) 启动emby服务..."
        systemctl start emby-server.service

        sleep 1s
        echo -e "$(curr_date) 配置完成."
        echo
        echo -e "访问地址为:${red}http://${ip_addr}:8096。账号：admin 密码为空${END}"
}

################## 前置变量 ##################
setup_emby

#安装命令
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/3.5.3.0/emby-server-deb_3.5.3.0_amd64.deb

dpkg -i emby-server-deb_3.5.3.0_amd64.deb

或者

filename=$(ls ./*.deb)
dpkg -i "$filename"
