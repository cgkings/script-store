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
  systemctl stop emby-server #结束 emby 进程
  rm -f /opt/emby-server/system/System.Net.Http.dll
  wget https://github.com/cgkings/script-store/raw/master/config/System.Net.Http.dll -O /opt/emby-server/system/System.Net.Http.dll #(注意替换掉命令中的 emby 所在目录)下载破解程序集替换原有程序
  sleep 3s
  systemctl daemon-reload
  systemctl start emby-server #启动 Emby 进程
}

################## 修改emby服务,fail自动重启 ##################
sys_emby() {
  sudo -i #切换为 root 用户
  systemctl stop emby-server #结束 emby 进程
  sed -i '/[Service]/a\Restart=on-failure\nRestartSec=5' /usr/lib/systemd/system/emby-server.service
  sleep 3s
  systemctl daemon-reload && systemctl start emby-server
}

################## 卸载emby ##################
del_emby() {
  dpkg -r --purge emby-server
}

################## 备份emby ##################
bak_emby() {
  check_emby
  systemctl stop emby-server #结束 emby 进程
  rm -rf /var/lib/emby/cache/* #清空cache
  cd /var/lib && tar -cvf emby_bak.tar emby #打包/var/lib/emby
  rclone move 'emby_bak.tar' "$my_remote": -vP #上传gd
  systemctl start emby-server
}

################## 还原emby ##################
revert_emby() {
    systemctl stop emby-server #结束 emby 进程
    fclone copy wdc:emby_bak.tar /root -vP
    rm -rf /var/lib/emby
    tar -xvf emby_bak.tar -C /var/lib && rm -f emby_bak.tar
    systemctl start emby-server
}

################## 前置变量 ##################
check_sys
check_release




/usr/lib/systemd/system/rclone-mntgd.service

/usr/lib/systemd/system/emby-server.service
