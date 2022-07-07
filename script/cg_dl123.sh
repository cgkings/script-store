#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_dl)
# File Name: cg_dl一键脚本
# Author: cgkings
# Created Time : 2020.12.25
# Description:flexget
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本,避免错误累加
#set -x #脚本调试,逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
#/home/qbt/cg_qbt.sh "%N" "%F" "%C" "%Z" "%I" "%L"
torrent_name=$1 # %N: Torrent名称=mide-007-C
content_dir=$2 # %F: 内容路径=/home/btzz/mide-007-C
#files_num=$3 # %C
#torrent_size=$4 #%Z
file_hash=$5 #%I
file_category=$6 #%L: 分类
qpt_username="admin"
qpt_password="adminadmin"
aria2_rpc_secret="abc12345678"
ip_addr=$(hostname -I | awk '{print $1}')
qb_web_url="http://$ip_addr:8070"
tr_web_url="http://$ip_addr:9070"
rclone_remote="upsa"

################## 检查安装qbt ##################
check_qbt() {
  if [ -z "$(command -v qbittorrent-nox)" ] && [ -z "$(docker ps -a | grep qbittorrent)" ]; then
    clear
    echo -e "${curr_date} [DEBUG] 未找到qbittorrent.正在安装..."
    docker run -d \
      --name=qbittorrent \
      -e PUID=$UID \
      -e PGID=$GID \
      -e TZ=Asia/Shanghai \
      -e WEBUI_PORT=8070 \
      -p 8070:8070 \
      -p 51414:51414 \
      -p 51414:51414/udp \
      -v /home/qbt/config:/config \
      -v /home/qbt/downloads:/downloads \
      --restart unless-stopped \
      lscr.io/linuxserver/qbittorrent:latest
    #备份配置文件: cd /home/qbt/config && zip -qr qbt_bat.zip qBittorrent
    #还原qbt配置:
    wget -qN https://github.com/cgkings/script-store/raw/master/config/qbt_bat.zip && rm -rf /home/qbt/config/qBittorrent && unzip -q qbt_bat.zip -d /home/qbt/config && rm -f qbt_bat.zip
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done!
-----------------------------------------------------------------------------
容器名称: qbittorrent
网页地址: ${qb_web_url}
默认用户: admin
默认密码: adminadmin
下载目录: /home/qbt/downloads
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt|sed '/.*downloads.*/q'
  fi
}

################## 检查安装transmission ##################
check_tr() {
  if [ -z "$(command -v transmission-daemon)" ] && [ -z "$(docker ps -a | grep transmission)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到transmission.正在安装..."
    docker run -d --name="transmission" \
      -p 51413:51413 \
      -p 51413:51413/udp \
      -p 9070:9070 \
      -e USERNAME=admin \
      -e PASSWORD=adminadmin \
      -v /data/downloads:/home/tr/downloads \
      -v /data/transmission:/home/tr/config \
      --restart=always \
      helloz/transmission
    cat >> /root/install_log.txt << EOF
------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done!
------------------------------------------------------------------------
容器名称: transmission
网页地址: ${tr_web_url}
默认用户: admin
默认密码: adminadmin
下载目录: /home/tr/downloads
------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt|sed '/.*downloads.*/q'
  fi
}

################## 检查安装aria2 ##################
check_aria2() {
  if [ -z "$(docker ps -a | grep aria2)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到aria2.正在安装..."
    docker run -d \
      --name aria2-pro \
      --restart unless-stopped \
      --log-opt max-size=1m \
      --network host \
      -e PUID=$UID \
      -e PGID=$GID \
      -e RPC_SECRET=$aria2_rpc_secret \
      -e RPC_PORT=6800 \
      -e LISTEN_PORT=6888 \
      -v /root/aria2:/config \
      -v /home/dl:/downloads \
      -v /usr/bin/fclone:/usr/local/bin/rclone \
      -v /home/vps_sa/ajkins_sa:/home/vps_sa/ajkins_sa \
      -e SPECIAL_MODE=rclone \
      p3terx/aria2-pro
    cp ~/.config/rclone/rclone.conf ~/aria2
    [ -z "$(grep "$rclone_remote" ~/aria2/script.conf)" ] && sed -i 's/drive-name=.*$/drive-name='$rclone_remote'/g' ~/aria2/script.conf
    docker run -d \
      --name ariang \
      --restart unless-stopped \
      --log-opt max-size=1m \
      -p 6880:6880 \
      p3terx/ariang
    aria2_rpc_secret_bash64=$(echo $aria2_rpc_secret | base64 | tr -d "\n")
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done！
-----------------------------------------------------------------------------
容器名称: aria2-pro & ariang
网页地址: ${tr_web_url}
默认用户: admin
默认密码: adminadmin
下载目录: /home/tr/downloads
访问地址: http://$ip_addr:6880/#!/settings/rpc/set/http/$ip_addr/6800/jsonrpc/$aria2_rpc_secret_bash64
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt|sed '/.*6880.*/q'
  fi
}

################## 检查安装mktorrent ##################
check_mktorrent() {
  if [ -z "$(command -v mktorrent)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到mktorrent.正在安装..."
    sleep 1s
    git clone https://github.com/Rudde/mktorrent.git && cd mktorrent && make && make install
    echo -e "${curr_date} [INFO] mktorrent 安装完成!" >> /root/install_log.txt
    echo
  fi
}

################## 检查安装autoremove-torrents ##################
check_amt() {
  if [ -z "$(command -v autoremove-torrents)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到autoremove-torrents.正在安装..."
    sleep 1s
    pip install autoremove-torrents && mkdir -p /home/amt && wget -qN https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -O /home/amt/config.yml
    echo -e "${curr_date} [INFO] mktorrent 安装完成!" >> /root/install_log.txt
    echo
  fi
}

################## 卸载qbt ##################
Uninstall_qbt() {
  systemctl stop qbt && rm -f /etc/systemd/system/qbt.service && rm -f /usr/bin/qbittorrent-nox
}

################## 卸载transmission-daemon ##################
Uninstall_transmission-daemon() {
  systemctl disable transmission-daemon
  service transmission-daemon stop
  bash <(curl -sL https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh) << EOF
1
EOF
  sudo apt remove -y transmission-daemon
  sudo apt autoremove -y
  rm -f /lib/systemd/system/transmission-daemon.service
}


################## 安装flexget ##################
install_flexget() {
  if [ -z "$(command -v flexget)" ]; then
    #建立flexget独立的 python3 虚拟环境
    mkdir -p 755 /home/software/flexget/
    virtualenv --system-site-packages --no-setuptools --no-wheel /home/software/flexget/
    #在python3虚拟环境里安装flexget
    /home/software/flexget/bin/pip3 install -U flexget
    #建立 flexget 日志存放
    mkdir -p 755 /var/log/flexget && chown root:adm /var/log/flexget
    #建立 flexget 的配置文件
    read -r -t 10 -p "请输入你的flexget的config.yml备份下载网址(10秒超时或回车默认作者地址,有需要自行修改,路径为：/root/.config/flexget/config.yml：" config_yml_link
    config_yml_link=${config_yml_link:-https://raw.githubusercontent.com/cgkings/script-store/master/config/cn_yml/config.yml}
    mkdir -p 755 /root/.config/flexget && wget -qN "${config_yml_link}" -O /root/.config/flexget/config.yml
    aria2_key=$(grep "rpc-secret" /root/.aria2c/aria2.conf | awk -F= '{print $2}')
    sed -i "s/secret:.*$/secret: $aria2_key/g" /root/.config/flexget/config.yml
    #建立软连接
    ln -sf /home/software/flexget/bin/flexget /usr/local/bin/
    #设置为自动启动,在 rc.local 中增加启动命令
    /home/software/flexget/bin/flexget -L error -l /var/log/flexget/flexget.log daemon start -d
  fi
  if [ -z "$(crontab -l | grep "flexget")" ]; then
    crontab -l | {
                   cat
                        echo "*/10 * * * * /usr/local/bin/flexget -c /root/.config/flexget/config.yml --cron execute"
    }                                            | crontab -
  else
    #删除包含flexget的计划任务,重新创建
    sed -i '/flexget/d' /var/spool/cron/crontabs/root
    crontab -l | {
                   cat
                        echo "*/10 * * * * /usr/local/bin/flexget -c /root/.config/flexget/config.yml --cron execute"
    }                                            | crontab -
  fi
  flexget --test execute
  echo -e "flexget已完成部署动作,等10分钟,用<flexget status>命令看一下状态吧！"
  echo -e "如安装有异常,请联系作者"
}

################## 脚本参数帮助 ##################
dl_help() {
  cat << EOF
用法(Usage):
  bash <(curl -sL git.io/cg_dl) [flags]

可用参数(Available flags)：
  bash <(curl -sL git.io/cg_dl) a  安装配置aria2
  bash <(curl -sL git.io/cg_dl) r  安装配置rsshub
  bash <(curl -sL git.io/cg_dl) f  安装配置flexget
  bash <(curl -sL git.io/cg_dl) h  命令帮助
注：无参数则顺序安装配置aria2\rsshub\flexget
EOF
}

################## dl 主 菜 单 ##################
dl_menu() {
  whiptail --clear --ok-button "Enter键开始安装" --backtitle "Hi,欢迎使用cg_pt工具包。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "大锤 PT 工具包" --checklist --separate-output --nocancel "请按空格及方向键来选择安装软件,ESC键退出脚本" 14 57 6 \
        "install_qbt      " ": 安装qbittorrent" off \
        "install_tr       " ": 安装transmission" off \
        "install_aria2    " ": 安装aria2套件,带ariang" off \
        "install_amt      " ": 安装Autoremove" off \
        "install_mktorrent" ": 安装mktorrent" off \
        "install_flexget  " ": 安装flexget" off 2> results
  case $dd_mainmenu in
        Pure_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl wget" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Basic_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --basic" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Emby_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --emby" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Jellyfin_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --jellyfin" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Pt_dd)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --pt" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Preload_package)
          dd_input
          cmd_bash64=$(echo "apt install -y curl && bash <(curl -sL git.io/cg_1key_dd) --package" | base64 | tr -d "\n")
          bash <(curl -sL raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -a -p "${dd_passwd}" -port "${dd_port}" -cmd "${cmd_bash64}"
          ;;
        Exit | *)
          exit 0
          ;;
  esac
}

################## 执  行  主 命  令 ##################
check_sys
check_command wget
check_rclone
check_python
check_nodejs
if [ -z "$1" ]; then
  dl_menu
else
  case "$1" in
    --qbt)
      check_qbt
      ;;
    --tr)
      check_tr
      ;;
    --aria2)
      check_aria2
      ;;
    --all)
      check_qbt
      check_tr
      check_aria2
      ;;
    --help)
      echo
      dl_help
      ;;
    *)
      echo
      dl_help
      ;;
  esac
fi
