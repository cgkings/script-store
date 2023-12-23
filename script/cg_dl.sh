#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_dl)
# File Name: cg_dl一键脚本
# Author: cgkings
# Created Time : 2022.10.15
# Description:flexget
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本,避免错误累加
#set -x #脚本调试,逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
default_username="admin"
default_password="adminadmin"
ip_addr=$(curl https://ipinfo.io/ip)
rclone_remote="upsa"

################## 检查安装docker ##################
check_docker() {
  if [ -z "$(command -v docker)" ]; then
    echo -e "检测到系统未安装docker,开始安装docker"

    if bash <(curl -sL https://get.docker.com); then
      echo -e "docker安装成功······"
    else
      echo -e "docker安装失败······"
      exit 1
    fi
  fi
  if [ -z "$(which docker-compose)" ]; then
    echo -e "检测到系统未安装docker-compose,开始安装docker-compose"
    if curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose; then
       echo -e "docker-compose安装成功······"
    else
      echo -e "docker-compose安装失败······"
      exit 1
    fi
  fi
}

################## ESC退出 ##################
esc_key() {
  if [ -z "$1" ]; then
    TERM=ansi whiptail --title "正常退出" --infobox "感谢使用大锤系列脚本\n每次离别,都是为了下一次更好的相遇\n下次见咯,Goodbye！！！" --scrolltext 10 68
    sleep 2s
    clear
    exit 0
  fi
}

################## docker命名 ##################
docker_name_set() {
  docker_name=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name docker 命名" --nocancel "注:回车继续,ESC退出脚本" 10 68 "$docker_default_name" 3>&1 1>&2 2>&3)
  esc_key "$docker_name"
  while [ -n "$(docker ps -aqf name="$docker_name")" ]; do
    whiptail --backtitle "Hi,欢迎使用。有关脚本问题,请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "错误提示" --msgbox "${curr_date}\n Docker重名,请重新命名" 9 42
    docker_name=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name docker 命名" --nocancel "注:回车继续,ESC退出脚本" 10 68 "$docker_default_name" 3>&1 1>&2 2>&3)
    esc_key "$docker_name"
  done
}

################## 端口设置 ##################
docker_port_set() {
  webui_port=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name webui 端口" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$webui_default_port" 3>&1 1>&2 2>&3)
  esc_key "$webui_port"
  while netstat -tunlp | grep -q "$webui_port"; do
    whiptail --backtitle "Hi,欢迎使用。有关脚本问题,请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "错误提示" --msgbox "${curr_date}\n 端口占用,请选择其他端口" 9 42
    webui_port=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name webui 端口" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$webui_default_port" 3>&1 1>&2 2>&3)
    esc_key "$webui_port"
  done
  connect_port=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name 连接端口" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$connect_default_port" 3>&1 1>&2 2>&3)
  esc_key "$connect_port"
  while netstat -tunlp | grep -q "$connect_port"; do
    whiptail --backtitle "Hi,欢迎使用。有关脚本问题,请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "错误提示" --msgbox "${curr_date}\n 端口占用,请选择其他端口" 9 42
    connect_port=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name 连接端口" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$connect_default_port" 3>&1 1>&2 2>&3)
    esc_key "$connect_port"
  done
}

################## config目录设置 ##################
config_dir_set() {
  config_dir=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "config目录设置" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$config_default_dir" 3>&1 1>&2 2>&3)
  esc_key "$config_dir"
}

################## 下载目录设置 ##################
download_dir_set() {
  download_dir=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "下载目录设置" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$download_default_dir" 3>&1 1>&2 2>&3)
  esc_key "$download_dir"
}

# ################## 用户名密码设置 ##################
passwd_set() {
  webui_username=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "webui用户名设置" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$default_username" 3>&1 1>&2 2>&3)
  esc_key "$webui_username"
  webui_passwd=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "webui密码设置" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$default_password" 3>&1 1>&2 2>&3)
  esc_key "$webui_passwd"
}

################## 检查安装qbt ##################
check_qbt() {
  webui_default_port="8070"
  connect_default_port="34567"
  config_default_dir="/home/qbt"
  download_default_dir="/home/qbt/downloads"
  passwd_set
  docker_port_set
  config_dir_set
  download_dir_set
  # passwd_set
  ## 更新系统
  apt-get -qqy update && apt-get -qqy upgrade
  apt-get -qqy install sudo sysstat htop curl psmisc
  ## 选择下载qb安装版本
  qb_latest_version=$(curl -s "https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases/latest" | jq -r .tag_name | sed 's/release-//')
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_dl。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "选择" --menu --nocancel "注:本脚本适配Debian11,ESC退出" 18 55 7 \
    "4.3.9" "      ==>安装qBittorrent 4.3.9_v2.0.5" \
    "4.5.5" "      ==>安装qBittorrent 4.5.5_v2.0.9" \
    "latest_version" "      ==>安装qBittorrent $qb_latest_version" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    4.3.9)
      sudo wget -qNO /usr/bin/qbittorrent-nox "https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-4.3.9_v2.0.5/x86_64-qbittorrent-nox" && sudo chmod +x /usr/bin/qbittorrent-nox
      ;;
    4.5.5)
      sudo wget -qNO /usr/bin/qbittorrent-nox "https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-4.5.5_v2.0.9/x86_64-qbittorrent-nox" && sudo chmod +x /usr/bin/qbittorrent-nox
      ;;
    latest_version)
      sudo wget -qNO /usr/bin/qbittorrent-nox "https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox" && sudo chmod +x /usr/bin/qbittorrent-nox
      ;;
  esac
  ## 创建系统服务
    test -e /etc/systemd/system/qbittorrent-nox.service && rm /etc/systemd/system/qbittorrent-nox.service
    touch /etc/systemd/system/qbittorrent-nox.service
    cat << EOF > /etc/systemd/system/qbittorrent-nox.service
[Unit]
Description=qBittorrent
After=network.target

[Service]
Type=forking
User=root
LimitNOFILE=infinity
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port="$webui_port" --profile="$config_dir"
ExecStop=/usr/bin/killall -w -s 9 /usr/bin/qbittorrent-nox
Restart=on-failure
TimeoutStopSec=20
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
  mkdir -p "$download_dir" && mkdir -p "$config_dir"/qBittorrent/data/GeoIP
  ## 下载最新GeoLite2-Country.mmdb
  curl -kLo "$config_dir"/qBittorrent/data/GeoIP/GeoLite2-Country.mmdb https://github.com/helloxz/qbittorrent/raw/main/GeoLite2-Country.mmdb
  ## 计算密码
  wget -qN https://github.com/cgkings/script-store/raw/master/tools/qb_password_gen && chmod +x "$HOME"/qb_password_gen
  PBKDF2password=$("$HOME"/qb_password_gen "$webui_passwd")
  rm -f "$HOME"/qb_password_gen
  ## 调整qBittorrent.conf参数
  cat << EOF > "$config_dir"/qBittorrent/config/qBittorrent.conf

[General]
ported_to_new_savepath_system=true

[AutoRun]
enabled=true
program=/"$config_dir"/qBittorrent/cg_qbt.sh \"%N\" \"%F\" \"%C\" \"%Z\" \"%I\" \"%L\"

[BitTorrent]
Session\AddExtensionToIncompleteFiles=true
Session\AddTrackersEnabled=true
Session\AdditionalTrackers=$(curl -s https://githubraw.sleele.workers.dev/XIU2/TrackersListCollection/master/best.txt | awk '{if(!NF){next}}1' | sed ':a;N;s/\n/\\n/g;ta')
Session\AsyncIOThreadsCount=12
Session\SendBufferLowWatermark=5120
Session\SendBufferWatermark=20480
Session\SendBufferWatermarkFactor=250

[LegalNotice]
Accepted=true

[Preferences]
General\Locale=zh
General\UseRandomPort=false
Queueing\QueueingEnabled=true
Queueing\MaxActiveDownloads=5
Queueing\MaxActiveTorrents=-1
Queueing\MaxActiveUploads=-1
Connection\PortRangeMin=${connect_port}
Downloads\DiskWriteCacheSize=2048
Downloads\SavePath="$download_dir"
WebUI\Enabled=true
WebUI\CSRFProtection=false
WebUI\LocalHostAuth=false
WebUI\Port="$webui_port"
WebUI\Username=$webui_username
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
EOF
  systemctl enable qbittorrent-nox.service && systemctl start qbittorrent-nox.service
  #备份配置文件: cd /home/qbt/config && zip -qr qbt_bat.zip ./*
  # sleep 2s
  # docker exec -it "$docker_name" curl -X POST -d 'json={"web_ui_username":"${webui_username}","web_ui_password":"${webui_passwd}"}' http://127.0.0.1:"${webui_port}"/api/v2/app/setPreferences
  cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
${curr_date} [INFO] qbittorrent - $docker_name 安装完成!
-----------------------------------------------------------------------------
网页地址: http://$ip_addr:$webui_port
登录用户: ${webui_username}
登录密码: ${webui_passwd}
配置目录: $config_dir
下载目录: $download_dir
qb信息: /root/install_log.txt
------------------------------------------------------------------------qb-end
EOF
    tail -f /root/install_log.txt | sed '/.*qb-end.*/q'
}

################## 检查安装aria2 ##################
check_aria2() {
  docker_default_name="aria2-pro"
  if [ -z "$(docker ps -a | grep aria2)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到aria2.正在安装..."
    aria2_rpc_secret=$(tr -cd '0-9a-zA-Z' < /dev/urandom | head -c 12)
    download_default_dir="/home/aria2/downloads"
    download_dir_set
    docker run -d \
      --name aria2-pro \
      --restart unless-stopped \
      --log-opt max-size=1m \
      --network host \
      -e PUID=$UID \
      -e PGID="$GID" \
      -e RPC_SECRET="$aria2_rpc_secret" \
      -e RPC_PORT=6800 \
      -e LISTEN_PORT=6888 \
      -v /root/aria2:/config \
      -v "$download_dir":/downloads \
      -v /usr/bin/fclone:/usr/local/bin/rclone \
      -v /home/vps_sa/ajkins_sa:/home/vps_sa/ajkins_sa \
      -e SPECIAL_MODE=rclone \
      p3terx/aria2-pro
    docker run -d \
      --name ariang \
      --restart unless-stopped \
      --log-opt max-size=1m \
      -p 6880:6880 \
      p3terx/ariang
    [ -z "$(grep $rclone_remote /root/aria2/script.conf)" ] && sed -i 's/drive-name=.*$/drive-name='$rclone_remote'/g' /root/aria2/script.conf
    cp /root/.config/rclone/rclone.conf /root/aria2
    aria2_rpc_secret_bash64=$(echo -n "$aria2_rpc_secret" | base64)
    cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
$(date '+%Y-%m-%d %H:%M:%S') [INFO] install done!
-----------------------------------------------------------------------------
aria2  容器名称: aria2-pro
aria2ng容器名称: ariang
aria2配置目录  : /root/aria2
aria2下载目录  : $download_dir
rpc_secret    : $aria2_rpc_secret
访问地址:http://$ip_addr:6880/#!/settings/rpc/set/http/$ip_addr/6800/jsonrpc/$aria2_rpc_secret_bash64
--------------------------------------------------------------------aria2-end
EOF
    tail -f /root/install_log.txt | sed '/.*aria2-end.*/q'
  fi
}

################## 检查安装mktorrent ##################
check_mktorrent() {
  if [ -z "$(command -v mktorrent)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到mktorrent包.正在安装..."
    sleep 1s
    git clone https://github.com/Rudde/mktorrent.git && cd mktorrent && make && make install > /dev/null
    echo -e "${curr_date} [INFO] mktorrent 安装完成!" | tee -a /root/install_log.txt
    echo
  fi
}

################## 检查安装autoremove-torrents ##################
check_art() {
  if [ -z "$(command -v autoremove-torrents)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到autoremove-torrents.正在安装..."
    sleep 1s
    pip install autoremove-torrents && mkdir -p /home/art/logs
    cat > /home/art/config.yml << EOF
# 任务模板: YAML语法,不能使用tab,要用空格来缩进,每个层级要用两个空格缩进,否则必定报错!
# Part 1: 任务块名称,左侧不能有空格
my_task:
# Part 2: BT客户端登录信息,可以管理其他机的客户端
  client: qbittorrent
  host: http://127.0.0.1:8070
  username: admin
  password: adminadmin
# Part 3: 策略块（删除种子的条件）
  strategies:
    # Part I: 策略名称
    remove_low_disk:
      # Part II: 筛选过滤器,过滤器定义了删除条件应用的范围,多个过滤器是且的关系,顺序执行过滤
      excluded_status: Downloading
      excluded_categories: 1.pt-down
      excluded_trackers: tracker.totheglory.im
      # Part III: 删除条件,多个删除条件之间是或的关系,顺序应用删除条件
      free_space:
        min: 300
        path: /home/qbt-pter/downloads
        action: remove-slow-upload-seeds
    remove_low_download:
      status: Downloading
      excluded_categories: 1.pt-down
      remove: last_activity > 900 or download_speed < 50 or create_time > 1800 and connected_leecher < 1 and average_uploadspeed < 10 or create_time > 1800 and ratio = 0
    remove_low_upload:
      status: uploading
      excluded_categories: 1.pt-down
      remove: upload_speed < 2 or connected_leecher < 1
      #delete_data: true
    # 一个任务块可以包括多个策略块...
# Part 4: 是否在删除种子的同时也删除数据。如果此字段未指定,则默认值为false
  delete_data: true
# 该模板策略块1为:对于非下载状态且非TTG的种子,删除900秒未活动的种子,或硬盘小于100G时,尽量删除不活跃种子
EOF
    echo -e "${curr_date} [INFO] autoremove-torrents 安装完成!" | tee -a /root/install_log.txt
    # crontab -l | {
    #                cat
    #                     echo "*/15 * * * * $(command -v autoremove-torrents) -c /home/art/config.yml -l /home/art/logs"
    # }                                            | crontab -
  fi
}

################## 卸载qbt ##################
Uninstall_qbt() {
  if [[ "$(command -v qbittorrent-nox)" ]]; then
    systemctl stop qbt && systemctl disable qbt && rm -f /etc/systemd/system/qbt.service && rm -f /usr/bin/qbittorrent-nox
  elif docker ps -a | grep -q qbittorrent; then
    docker stop qbittorrent && docker rm qbittorrent && docker rmi "$(docker images | grep qbittorrent | awk '{print $3}')"
  fi
}

################## 安装rsshub ##################
check_rsshub() {
  if [ -z "$(docker ps -a | grep rsshub)" ]; then
    docker run -d --name rsshub -p 1200:1200 --restart=always diygod/rsshub
  fi
}

################## 脚本参数帮助 ##################
dl_help() {
  cat << EOF
用法(Usage):
  bash <(curl -sL git.io/cg_dl) [flags]

可用参数(Available flags):
  bash <(curl -sL git.io/cg_dl) --qb      安装配置qbittorrent套件
  bash <(curl -sL git.io/cg_dl) --aria2   安装配置aria2套件
  bash <(curl -sL git.io/cg_dl) -h       命令帮助
注:无参数则使用菜单模式
EOF
}

################## dl 主 菜 单 ##################
dl_menu() {
  whiptail --clear --ok-button "Enter键开始检查安装" --backtitle "Hi,欢迎使用cg_pt工具包。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "大锤 PT 工具包" --checklist --separate-output --nocancel "请按空格及方向键来选择安装软件,ESC键退出脚本" 15 58 7 \
        "install_qbt" " : 安装qbittorrent" off \
        "install_aria2" " : 安装aria2套件,带ariang" off \
        "install_rsshub" " : 安装rsshub" off \
        "install_art" " : 安装Autoremove" on \
        "install_mktorrent" " : 安装mktorrent" on 2> results
  while read -r choice; do
        case $choice in
          "install_qbt")
            check_qbt
            ;;
          "install_aria2")
            check_aria2
            ;;
          "install_rsshub")
            check_rsshub
            ;;
          "install_art")
            check_art
            ;;
          "install_mktorrent")
            check_mktorrent
            ;;
          *)
            esc_key " "
            ;;
    esac
  done < results
}

################## 执  行  主 命  令 ##################
check_docker
if [ -z "$1" ]; then
  dl_menu
else
  case "$1" in
    --qb)
      check_mktorrent
      check_art
      check_qbt
      ;;
    --aria2)
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
