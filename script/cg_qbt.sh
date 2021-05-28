#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_qbt.sh)
# File Name: cg_qbt.sh
# Author: cgking
# Created Time : 2021.5.28
# Description:qbittonrrent脚本
# System Required: Debian/Ubuntu
# Version: final
#=============================================================
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

check_qbt() {
    if [ -z "$(dpkg --get-selections | grep qbittorrent-nox)" ]; then
    install_qbt
  fi
}
install_qbt() {
  clear
  apt-get remove qbittorrent-nox -y
  qbtver=$(curl -s "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  wget -qN https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/"${qbtver}"/qbittorrent-nox_x86_64-linux-musl_static.zip
  unzip -o qbittorrent*.zip && rm -f qbittorrent*.zip
  mv -f qbittorrent-nox /usr/bin/
  chmod +x /usr/bin/qbittorrent-nox
  mkdir -p /home/qbt & chmod 755 /home/qbt
  cat > '/etc/systemd/system/qbt.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --webui-port=8070 --profile=/home/qbt -d
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload && systemctl enable qbt.service
  cd /usr/share/nginx/qBittorrent/data/GeoIP/
  curl -LO --progress-bar https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/binary/GeoLite2-Country.mmdb
  systemctl restart qbittorrent.service
  clear
}

install_qbt_origin() {
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装Qbt原版中..." 7 68
  colorEcho ${INFO} "安装原版Qbittorrent(Install Qbittorrent ing)"
  if [[ ${dist} == debian ]]; then
    apt-get update
    apt-get install qbittorrent-nox -y
  elif [[ ${dist} == ubuntu ]]; then
    add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
    apt-get update
    apt-get install qbittorrent-nox -y
  else
    echo "fail"
  fi
  #useradd -r qbittorrent --shell=/usr/sbin/nologin
  cat > '/etc/systemd/system/qbittorrent.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --profile=/usr/share/nginx/
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable qbittorrent.service
  mkdir /usr/share/nginx/qBittorrent/
  mkdir /usr/share/nginx/qBittorrent/downloads/
  mkdir /usr/share/nginx/qBittorrent/data/
  mkdir /usr/share/nginx/qBittorrent/data/GeoIP/
  cd /usr/share/nginx/qBittorrent/data/GeoIP/
  curl -LO --progress-bar https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/binary/GeoLite2-Country.mmdb
  cd
  chmod 755 /usr/share/nginx/
  chown -R nginx:nginx /usr/share/nginx/
  systemctl restart qbittorrent.service
  clear
}

