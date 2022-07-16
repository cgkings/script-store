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
default_username="admin"
default_password="adminadmin"
ip_addr=$(curl -sL ifconfig.me)
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
  unset docker_name i
  i=1
  while [ -n "$(docker ps -aqf name="$docker_name")" ]; do
    i=$((i + 1))
    if [ $i -gt 2 ]; then
      whiptail --backtitle "Hi,欢迎使用。有关脚本问题,请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "错误提示" --msgbox "${curr_date}\n Docker重名,请重新命名" 9 42
    fi
    docker_name=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name docker 命名" --nocancel "注:回车继续,ESC退出脚本" 10 68 "$docker_default_name" 3>&1 1>&2 2>&3)
    esc_key "$docker_name"
  done
}

################## 端口设置 ##################
docker_port_set() {
  unset webui_port i
  i=1
  while netstat -tunlp | grep -q "$webui_port"; do
    i=$((i + 1))
    if [ $i -gt 2 ]; then
      whiptail --backtitle "Hi,欢迎使用。有关脚本问题,请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "错误提示" --msgbox "${curr_date}\n 端口占用,请选择其他端口" 9 42
    fi
    webui_port=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name webui 端口" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$webui_default_port" 3>&1 1>&2 2>&3)
    esc_key "$webui_port"
  done
  unset connect_port i
  i=1
  while netstat -tunlp | grep -q "$connect_port"; do
    i=$((i + 1))
    if [ $i -gt 2 ]; then
      whiptail --backtitle "Hi,欢迎使用。有关脚本问题,请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "错误提示" --msgbox "${curr_date}\n 端口占用,请选择其他端口" 9 42
    fi
    connect_port=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name 连接端口" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$connect_default_port" 3>&1 1>&2 2>&3)
    esc_key "$connect_port"
  done
}

################## 下载目录设置 ##################
download_dir_set() {
  download_dir=$(whiptail --inputbox --backtitle "Hi,欢迎使用cg_dl。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "$docker_default_name 下载目录设置" --nocancel "注：回车继续,ESC退出脚本" 10 68 "$download_default_dir" 3>&1 1>&2 2>&3)
  esc_key "$download_dir"
}

################## 检查安装qbt ##################
check_qbt() {
  docker_default_name="qbittorrent"
  webui_default_port="8070"
  connect_default_port="51414"
  download_default_dir="/home/qbt/downloads"
  docker_name_set
  docker_port_set
  download_dir_set
  docker run -d --name="$docker_name" \
    -e PUID="$UID" \
    -e PGID="$GID" \
    -e TZ=Asia/Shanghai \
    -e WEBUI_PORT="$webui_port" \
    -p "$webui_port":"$webui_port" \
    -p "$connect_port":"$connect_port" \
    -p "$connect_port":"$connect_port"/udp \
    -v /home/qbt/config:/config \
    -v "$download_dir":/downloads \
    -v /usr/bin/fclone:/usr/bin/fclone \
    -v /home/vps_sa/ajkins_sa:/home/vps_sa/ajkins_sa \
    --restart=unless-stopped \
    lscr.io/linuxserver/qbittorrent:latest
  #备份配置文件: cd /home && zip -qr qbt_bat.zip qbt
  #还原qbt配置:
  docker stop "$docker_name"
  #wget -qN https://github.com/cgkings/script-store/raw/master/config/qbt_bat.zip && rm -rf /home/qbt && unzip -q qbt_bat.zip -d /home && rm -f qbt_bat.zip
  wget -qN https://github.com/cgkings/script-store/raw/master/script/cg_qbt.sh -O /home/qbt/config/cg_qbt.sh && chmod 755 /home/qbt/config/cg_qbt.sh
  mkdir -p /home/qbt/config/rclone && cp /root/.config/rclone/rclone.conf /home/qbt/config/rclone
  docker start "$docker_name"
  cat >> /root/install_log.txt << EOF
-----------------------------------------------------------------------------
${curr_date} [INFO] qbittorrent - $docker_name 安装完成!
-----------------------------------------------------------------------------
容器名称: $docker_name
网页地址: http://$ip_addr:$webui_port
默认用户: $default_username
默认密码: $default_password
配置目录: /home/qbt/config
下载目录: $download_dir
qb信息: /root/install_log.txt
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt | sed '/.*qb信息.*/q'
}

################## 检查安装transmission ##################
check_tr() {
  docker_default_name="transmission"
  webui_default_port="9070"
  connect_default_port="51413"
  download_default_dir="/home/tr/downloads"
  docker_name_set
  docker_port_set
  download_dir_set
  docker run -d --name="$docker_name" \
    -p "$webui_port":"$webui_port" \
    -p "$connect_port":"$connect_port" \
    -p "$connect_port":"$connect_port"/udp \
    -e USERNAME=$default_username \
    -e PASSWORD=$default_password \
    -v /home/tr/config:/data/transmission \
    -v "$download_dir":/data/downloads \
    --restart=unless-stopped \
    helloz/transmission
  cat >> /root/install_log.txt << EOF
------------------------------------------------------------------------
${curr_date} [INFO] transmission - $docker_name 安装完成!
------------------------------------------------------------------------
容器名称: $docker_name
网页地址: http://$ip_addr:$webui_port
默认用户: $default_username
默认密码: $default_password
配置目录: /home/tr/config
下载目录: $download_dir
tr信息 : /root/install_log.txt
------------------------------------------------------------------------
EOF
  tail -f /root/install_log.txt | sed '/.*tr信息.*/q'
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
rpc_secret    : $aria2_rpc_secret
aria2下载目录  : $download_dir
访问地址:http://$ip_addr:6880/#!/settings/rpc/set/http/$ip_addr/6800/jsonrpc/$aria2_rpc_secret_bash64
-----------------------------------------------------------------------------
EOF
    tail -f /root/install_log.txt | sed '/.*6880.*/q'
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
check_amt() {
  if [ -z "$(command -v autoremove-torrents)" ]; then
    echo -e "${curr_date} [DEBUG] 未找到autoremove-torrents.正在安装..."
    sleep 1s
    pip install autoremove-torrents && mkdir -p /home/amt
    cat > /home/amt/config.yml << EOF
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
    strategy1:
      # Part II: 筛选过滤器,过滤器定义了删除条件应用的范围,多个过滤器是且的关系,顺序执行过滤
      excluded_status:
        - Downloading
      excluded_trackers:
        - tracker.totheglory.im
      # Part III: 删除条件,多个删除条件之间是或的关系,顺序应用删除条件
      last_activity: 900
      free_space:
        min: 100
        path: /home/qbt/downloads
        action: remove-inactive-seeds
    strategy2:
      status: Downloading
      remove: last_activity > 900 or download_speed < 50
      #delete_data: true
    # 一个任务块可以包括多个策略块...
# Part 4: 是否在删除种子的同时也删除数据。如果此字段未指定,则默认值为false
  delete_data: true
# 该模板策略块1为:对于非下载状态且非TTG的种子,删除900秒未活动的种子,或硬盘小于100G时,尽量删除不活跃种子
EOF
    echo -e "${curr_date} [INFO] autoremove-torrents 安装完成!" | tee -a /root/install_log.txt
    # crontab -l | {
    #                cat
    #                     echo "*/15 * * * * $(command -v autoremove-torrents) -c /home/amt/config.yml --log=/home/amt"
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
check_flexget() {
  if [ -z "$(command -v flexget)" ]; then
    #建立flexget独立的 python3 虚拟环境
    mkdir -p 755 /home/software/flexget/
    virtualenv --system-site-packages --no-setuptools --no-wheel /home/software/flexget/
    #在python3虚拟环境里安装flexget
    /home/software/flexget/bin/pip3 install -U flexget
    #建立 flexget 日志存放
    mkdir -p 755 /var/log/flexget && chown root:adm /var/log/flexget
    #建立 flexget 的配置文件
    read -r -t 10 -p "请输入你的flexget的config.yml备份下载网址(10秒超时或回车默认作者地址,有需要自行修改,路径为:/root/.config/flexget/config.yml:" config_yml_link
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
  echo -e "flexget已完成部署动作,等10分钟,用<flexget status>命令看一下状态吧!"
  echo -e "如安装有异常,请联系作者"
}

################## 安装rsshub ##################
check_rsshub() {
  if [ -z "$(docker ps -a | grep aria2)" ]; then
    docker pull diygod/rsshub
    docker run -d --name rsshub -p 1200:1200 diygod/rsshub
  fi
}

################## 脚本参数帮助 ##################
dl_help() {
  cat << EOF
用法(Usage):
  bash <(curl -sL git.io/cg_dl) [flags]

可用参数(Available flags):
  bash <(curl -sL git.io/cg_dl) --qb      安装配置qbittorrent套件
  bash <(curl -sL git.io/cg_dl) --tr      安装配置transmission套件
  bash <(curl -sL git.io/cg_dl) --aria2   安装配置aria2套件
  bash <(curl -sL git.io/cg_dl) -h       命令帮助
注:无参数则使用菜单模式
EOF
}

################## dl 主 菜 单 ##################
dl_menu() {
  whiptail --clear --ok-button "Enter键开始检查安装" --backtitle "Hi,欢迎使用cg_pt工具包。本脚本仅适用于debian ubuntu,有关问题,请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --title "大锤 PT 工具包" --checklist --separate-output --nocancel "请按空格及方向键来选择安装软件,ESC键退出脚本" 15 58 7 \
        "install_qbt" " : 安装qbittorrent" off \
        "install_tr" " : 安装transmission" off \
        "install_aria2" " : 安装aria2套件,带ariang" off \
        "install_rsshub" " : 安装rsshub" off \
        "install_amt" " : 安装Autoremove" on \
        "install_mktorrent" " : 安装mktorrent" on \
        "install_flexget" " : 安装flexget" off 2> results
  while read -r choice; do
        case $choice in
          "install_qbt")
            check_qbt
            ;;
          "install_tr")
            check_tr
            ;;
          "install_aria2")
            check_aria2
            ;;
          "install_rsshub")
            check_rsshub
            ;;
          "install_amt")
            check_amt
            ;;
          "install_mktorrent")
            check_mktorrent
            ;;
          "install_flexget")
            check_flexget
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
      check_amt
      check_qbt
      ;;
    --tr)
      check_mktorrent
      check_amt
      check_tr
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
