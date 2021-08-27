#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_emby)
# File Name: cg_emby.sh
# Author: cgkings
# Created Time : 2021.3.4
# Description:swap一键脚本
# System Required: Debian/Ubuntu
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
ip_addr=$(hostname -I | awk '{print $1}')
#emby版本
emby_version="4.6.4.0"
emby_local_version=$(dpkg -l emby-server | grep -Eo "[0-9.]+\.[0-9]+")
emby_local_version=${emby_local_version:-"未安装"}

################## 初始化检查安装emby rclone ##################
initialization() {
  #step1:系统检查 & rclone检查安装
  check_sys
  check_rclone
  sleep 0.5s
  echo 20
  #step2:fuse检查安装
  if [ ! -f /etc/fuse.conf ]; then
    echo -e "${curr_date} [DEBUG] 未找到fuse包.正在安装..."
    sleep 1s
    sudo apt-get install fuse -y > /dev/null
    echo -e "${curr_date} [INFO] fuse 安装完成!" >> /root/install_log.txt
    echo
  fi
  sleep 0.5s
  echo 40
  #step3：caddy2检测安装
  if [ -z "$(command -v caddy)" ]; then
    echo -e "${curr_date} [DEBUG] caddy2 不存在.正在为您安装，请稍后..."
    sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https > /dev/null
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt-get install -y caddy > /dev/null
    systemctl enable caddy.service
    echo -e "${curr_date} [INFO] caddy2 安装完成!" | tee -a /root/install_log.txt
  fi
  sleep 0.5s
  echo 60
  #step4:emby检查安装
  if [ ! -f "/usr/lib/systemd/system/emby-server.service" ]; then
    echo -e "${curr_date} [INFO] emby $emby_version 不存在.正在为您安装，请稍等..." | tee -a /root/install_log.txt
    wget -qN https://github.com/MediaBrowser/Emby.Releases/releases/download/"${emby_version}"/emby-server-deb_"${emby_version}"_amd64.deb
    dpkg -i emby-server-deb_"${emby_version}"_amd64.deb > /dev/null
    sleep 1s
    rm -f emby-server-deb_"${emby_version}"_amd64.deb
    echo -e "${curr_date} [INFO] 恭喜您emby $emby_version 安装成功，请访问：http://${ip_addr}:8096 进一步配置" | tee -a /root/install_log.txt
  else
    if [[ "$emby_local_version" != "$emby_version" ]]; then
      echo -e "${curr_date} [ERROR] 本机emby版本为 $emby_local_version，本脚本仅支持 $emby_version,请运行命令卸载后重新运行本脚本\nsystemctl stop emby-server && dpkg --purge emby-server" | tee -a /root/install_log.txt
      exit 1
    fi
  fi
  sleep 0.5s
  echo 80
  #step5:emby破解检查
  if grep -q "破解成功" /root/install_log.txt; then
    echo > /dev/null
  else
    systemctl stop emby-server
    #破解emby
    rm -rf /opt/emby-server/system/System.Net.Http.dll /opt/emby-server/system/dashboard-ui/embypremiere/embypremiere.js /opt/emby-server/system/Emby.Web.dll
    wget -q https://github.com/cgkings/script-store/raw/master/config/emby/System.Net.Http.dll -O /opt/emby-server/system/System.Net.Http.dll --no-check-certificate
    wget -q https://raw.githubusercontent.com/cgkings/script-store/master/config/emby/464crack/embypremiere.js -O /opt/emby-server/system/dashboard-ui/embypremiere/embypremiere.js --no-check-certificate
    wget -q https://github.com/cgkings/script-store/raw/master/config/emby/464crack/Emby.Web.dll -O /opt/emby-server/system/Emby.Web.dll --no-check-certificate
    sleep 3s
    systemctl daemon-reload && systemctl restart emby-server
    echo -e "${curr_date} [INFO] 恭喜您emby破解成功，请您访问：http://${ip_addr}:8096 输入任意值密钥解锁会员" | tee -a /root/install_log.txt
  fi
  sleep 0.5s
  echo 100
}

################## 备份emby ##################
bak_emby() {
  remote_choose
  td_id_choose
  systemctl stop emby-server #结束 emby 进程
  #rm -rf /var/lib/emby/cache/* #清空cache
  cd /var/lib && tar -cvf emby_bak_"$(date "+%Y-%m-%d")".tar emby #打包/var/lib/emby
  fclone move emby_bak_"$(date "+%Y-%m-%d")".tar "$my_remote": --drive-root-folder-id "${td_id}" -vP #上传gd
  systemctl start emby-server
  echo -e "${curr_date} [INFO] emby备份完毕."
}

################## 还原emby ##################
revert_emby() {
    remote_choose
    td_id_choose
    fclone lsf "$my_remote": --drive-root-folder-id "${td_id}" --include 'emby_bak*' --files-only -F "pt" | sed 's/ /_/g;s/\;/    /g' > ~/.config/rclone/bak_list.txt
    bak_list=($(cat ~/.config/rclone/bak_list.txt))
    bak_name=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "备份文件选择" --menu --nocancel "注：上下键回车选择,ESC退出脚本！" 18 62 10 \
    "${bak_list[@]}" 3>&1 1>&2 2>&3)
    if [ -z "$bak_name" ]; then
      rm -f ~/.config/rclone/bak_list.txt
      myexit 0
  else
      systemctl stop emby-server #结束 emby 进程
      fclone copy "$my_remote":"$bak_name" /root --drive-root-folder-id "${td_id}" -vP
      rm -rf /var/lib/emby
      tar -xvf "$bak_name" -C /var/lib && rm -f "$bak_name"
      systemctl start emby-server
      rm -rf ~/.config/rclone/bak_list.txt
      echo -e "${curr_date} [INFO] emby还原完毕."
  fi
}

################## 卸载emby ##################
del_emby() {
  systemctl stop emby-server #结束 emby 进程
  systemctl disable emby-server
  dpkg --purge emby-server
  sed -i '/emby/d' /root/install_log.txt
}

################## 创建开机挂载服务 ##################
mount_server_creat() {
  choose_mount_tag
  if [ ! -d /mnt/gd ]; then
    echo -e "$curr_date [警告] /mnt/gd 不存在，正在创建..."
    mkdir -p 755 /mnt/gd
    sleep 1s
    echo -e "$curr_date [Info] /mnt/gd 创建完成！"
  fi
  echo -e "$curr_date [Info] 正在创建服务 rclone-mntgd.service 请稍等..."
  cat > /lib/systemd/system/rclone-mntgd.service << EOF
[Unit]
Description = rclone-mntgd
AssertPathIsDirectory = /mnt/gd
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
KillMode=none
User=root
ExecStart=fclone mount ${my_remote}: /mnt/gd --drive-root-folder-id ${td_id} ${mount_tag}
ExecStop=fusermount -qzu /mnt/gd
Restart=on-abort
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
  sleep 2s
  echo -e "$curr_date [Info] 服务创建成功。"
  sleep 2s
  echo -e "$curr_date [Info] 启动服务..."
  systemctl start rclone-mntgd.service
  sleep 1s
  echo -e "$curr_date [Info] 添加开机启动..."
  systemctl enable rclone-mntgd.service
  if [[ $? ]]; then
    echo -e "$curr_date [Info] 创建服务 rclone-mntgd.service.并已添加开机挂载.\n您可以通过 systemctl [start|stop|status] 进行挂载服务管理。"
    sleep 2s
  else
    echo -e "$curr_date [警告] 未知错误."
  fi
  df -h
}

################## 选择挂载参数 ##################
choose_mount_tag() {
  choose_mount_tag_status=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_mount。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "选择挂载参数" --menu --nocancel "注：默认缓存目录为/home/cache，ESC退出脚本" 12 80 3 \
    "1" "扫库参数[单文件内存缓冲 16M,缓存块 1M,缓存步进32M ]" \
    "2" "观看参数[单文件内存缓冲512M,缓存块32M,缓存步进128M,硬盘缓冲辅助512M]" \
    "3" "退出脚本" 3>&1 1>&2 2>&3)
  case $choose_mount_tag_status in
    1)
      mount_tag="--use-mmap --umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-chunk-size 1M"
      ;;
    2)
      mount_tag="--use-mmap --umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --cache-dir=/home/cache --vfs-cache-mode full --buffer-size 256M --vfs-read-ahead 512M --vfs-read-chunk-size 32M --vfs-read-chunk-size-limit 128M --vfs-cache-max-size 20G"
      ;;
    3 | *)
      myexit 0
      ;;
  esac
}

################## 切换挂载参数 ##################
switch_mount_tag() {
  if [ -z "${curr_mount_tag_status}" ]; then
    TERM=ansi whiptail --title "警告" --infobox "还没挂载，切换个锤子的挂载参数" 8 68
  elif [ "${curr_mount_tag_status}" == "扫库参数" ]; then
    systemctl stop rclone-mntgd.service
    sed -i 's/--vfs-read-chunk-size 1M/--buffer-size 256M --vfs-read-ahead 512M --vfs-read-chunk-size 32M --vfs-read-chunk-size-limit 128M --vfs-cache-max-size 20G/g' /lib/systemd/system/rclone-mntgd.service
    systemctl daemon-reload && systemctl restart rclone-mntgd.service
  elif [ "${curr_mount_tag_status}" == "观看参数" ]; then
    systemctl stop rclone-mntgd.service
    sed -i 's/--buffer-size 256M --vfs-read-ahead 512M --vfs-read-chunk-size 32M --vfs-read-chunk-size-limit 128M --vfs-cache-max-size 20G/--vfs-read-chunk-size 1M/g' /lib/systemd/system/rclone-mntgd.service
    systemctl daemon-reload && systemctl restart rclone-mntgd.service
  fi
  sleep 3s
}

################## 删除挂载 ##################
mount_del() {
  echo -e "$curr_date [Info] 正在执行fusermount -qzu /mnt/gd..."
  fusermount -qzu /mnt/gd
  echo -e "$curr_date [Info] fusermount -qzu /mnt/gd [done]"
  echo -e "$curr_date [Info] 正在检查服务是否存在..."
  if [ -f /lib/systemd/system/rclone-mntgd.service ]; then
    echo -e "$curr_date [Info] 找到服务 rclone-mntgd.service 正在删除，请稍等..."
    systemctl stop rclone-mntgd.service
    systemctl disable rclone-mntgd.service
    rm /lib/systemd/system/rclone-mntgd.service
    sleep 2s
    echo -e "$curr_date [Info] 删除服务[done]"
  else
    echo -e "$curr_date [Debug] 你没创建过服务!"
  fi
  echo -e "$curr_date [Info] 删除挂载[done]"
}

################## 检查emby安装版本及rclone挂载状态 ##################
check_status() {
  #emby破解状态
  if grep -q "破解成功" /root/install_log.txt; then
    emby_crack_status="已破解"
  else
    emby_crack_status="未破解"
  fi
  #挂载状态
  if [ -f /lib/systemd/system/rclone-mntgd.service ]; then
    if systemctl | grep -q "rclone"; then
      curr_mount_status="已挂载，挂载盘ID为 $(ps -eo cmd | grep "fclone mount" | grep -v grep | awk '{print $6}')"
    else
      systemctl daemon-reload && systemctl restart rclone-mntgd.service
      sleep 2s
      curr_mount_status="已挂载，挂载盘ID为 $(ps -eo cmd | grep "fclone mount" | grep -v grep | awk '{print $6}')"
    fi
  else
    curr_mount_status="未挂载"
  fi
  #挂载参数状态
  curr_mount_tag=$(ps -eo cmd | grep "fclone mount" | grep -v grep | awk '{for (i=7;i<=NF;i++)printf("%s ", $i);print ""}')
  if [ -n "$curr_mount_tag" ]; then
    if echo "$curr_mount_tag" | grep -q "1M"; then
      curr_mount_tag_status="扫库参数"
    elif echo "$curr_mount_tag" | grep -q "buffer-size"; then
      curr_mount_tag_status="观看参数"
    fi
  fi
}

################## 主菜单 ##################
cg_emby_main_menu() {
  emby_local_version=$(dpkg -l emby-server | grep -Eo "[0-9.]+\.[0-9]+")
  emby_local_version=${emby_local_version:-"未安装"}
  check_status
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用cg_emby。有关脚本问题，请访问: https://github.com/cgkings/script-store 或者 https://t.me/cgking_s (TG 王大锤)。" --title "cg_emby 主菜单" --menu --nocancel "Emby版本：$emby_local_version\nEmby破解：$emby_crack_status\n挂载状态：$curr_mount_status\n挂载参数：$curr_mount_tag_status\n注：本脚本适配emby$emby_version，默认挂载/mnt/gd，ESC退出" 18 55 6 \
    "Bak" "      ==>备 份 emby" \
    "Revert" "      ==>还 原 emby" \
    "Uninstall" "      ==>卸 载 emby" \
    "restart_mount" "      ==>重新挂载" \
    "switch_tag" "      ==>切换参数" \
    "Exit" "      ==>退 出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Bak)
      bak_emby
      cg_emby_main_menu
      ;;
    Revert)
      revert_emby
      cg_emby_main_menu
      ;;
    Uninstall)
      del_emby
      cg_emby_main_menu
      ;;
    restart_mount)
      mount_del
      remote_choose
      td_id_choose
      mount_server_creat
      cg_emby_main_menu
      ;;
    switch_tag)
      switch_mount_tag
      cg_emby_main_menu
      ;;
    Exit | *)
      myexit 0
      ;;
  esac
}

################## 执行命令 ##################
initialization | whiptail --backtitle "Hi,欢迎使用cg_toolbox。本脚本仅适用于debian ubuntu,有关问题，请访问: https://github.com/cgkings/script-store (TG 王大锤)。" --gauge "初始化(initializing),过程可能需要几分钟，请稍后.........." 6 60 0
cg_emby_main_menu
