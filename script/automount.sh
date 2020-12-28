#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# File Name: automount
# Author: cgkings
# Created Time : 2020.12.25
# Description:挂载一键脚本
# System Required: Debian/Ubuntu
# 感谢wuhuai2020、moerats、github众多作者，我只是整合代码
# Version: 1.0
#=============================================================

################## 前置变量设置 ##################
source <(wget -qO- https://git.io/cg_script_option)
curr_date=$(date "+%Y-%m-%d %H:%M:%S")
setcolor
check_root
check_vz

################## 选择remot ##################[done]
remote_chose(){
  bash <(curl -L -s https://rclone.org/install.sh)
  remote_list=$(sed -n "/\[.*\]/p" ~/.config/rclone/rclone.conf | grep -Eo "[0-9A-Za-z-]+" | awk '{ print FNR " " $0}' )
  if [ -z $remote_list ]; then
    echo "~/.config/rclone/rclone.conf为空，请先创建remot,再运行本脚本"
    exit 1
  fi
  echo -e "   本地已配置网盘列表:"
  echo
  echo -e "${red} +-------------------------+"
  echo -e "${red}$remote_list${normal}"
  echo -e "${red} +-------------------------+"
  echo
  read -n1 -p "请选择需要挂载的网盘（输入数字即可）：" rclone_chose_num
  if [[ $remote_list =~ $rclone_chose_num ]]; then
  mount_remote=$(echo -e "$remote_list" | awk '{print $2}' | sed -n ''$rclone_chose_num'p')
  echo
  echo -e "$curr_date 您选择了：${red}${mount_remote}${normal}"
  else
  echo
  echo "输入不正确，请重新输入。"
  echo
  remote_chose
  fi
}
################## 选择挂载路径 ##################[done]
dir_check(){
  if [[ $mount_path =~ "/" ]]; then
    if [ ! -d $mount_path ]; then
      echo -e "$curr_date  ${red}${mount_path}${normal} 不存在，正在创建..."
      mkdir -p -m 755 $mount_path
      sleep 1s
      echo
      echo -e "$curr_date 创建完成！"
      fi
    else
    mount_path="/home/$mount_path"
      if [ ! -d $mount_path ]; then
        echo -e "$curr_date  ${red}${mount_path}${normal} 不存在，正在创建..."
        mkdir -p -m 755 $mount_path
        sleep 1s
        echo
        echo -e "$curr_date 创建完成！"
      fi
  fi
  mount_path_name=$(echo "$mount_path" | sed 's/[/]//g' | sed 's/ //g')
}

dir_chose(){
  read -p "请输入需要挂载目录的路径（回车默认/home,非绝对路径：含/创建该路径，不含为/home/输入文件夹名）:" mount_path
  mount_path=${mount_path:-/home}
  dir_check
  echo -e "您的挂载目录为 ${mount_path}"
}

################## 删除服务 ##################
mount_del(){
  check_fuse
  echo -e "$curr_date [Info]正在执行fusermount -qzu "${mount_path}"..."
  fusermount -qzu "${mount_path}"
  echo -e "$curr_date [Info]fusermount -qzu "${mount_path}"[done]"
  echo -e "$curr_date [Info]正在检查服务是否存在..."
  if [[ -f /lib/systemd/system/rclone-${mount_path_name}.service ]];then
    echo -e "$curr_date [Info]找到服务 \"${red}rclone-${mount_path_name}.service${normal}\"正在删除，请稍等..."
    systemctl stop rclone-${mount_path_name}.service &> /dev/null
    systemctl disable rclone-${mount_path_name}.service &> /dev/null
    rm /lib/systemd/system/rclone-${mount_path_name}.service &> /dev/null
    sleep 2s
    echo -e "$curr_date [Info]删除服务[done]"
  else
    echo -e "$curr_date [Debug]你没创建过服务!"
  fi
  echo -e "$curr_date [Info]删除挂载[done]"
}

################## 挂载参数选择 ##################
tag_chose(){
  echo -e "1、256G硬盘或以上[回车默认值]
2、小硬盘，2G内存以上
3、小硬盘，512M-1G内存
注：如参数不合适，可自行修改脚本内挂载参数行，已备注"
  read -n1 -p "请选择挂载参数:" tag_chose_result
  tag_chose_result=${tag_chose_result:-1}
  case $tag_chose_result in
    1)
      echo
      mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
      ;;
    2)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
      ;;
    3)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
      ;;
    *)
      echo
      echo "输入错误，请重新输入"
      mount_menu
      ;;
  esac
}

################## 临  时  挂  载 ##################

mount_creat(){
  mount_del
  echo -e "$curr_date 开始临时挂载..."
  echo -e "$curr_date fclone mount "$mount_remote": "$mount_path" "$mount_tag" &"
  fclone mount $mount_remote: $mount_path $mount_tag &
  echo -e "$curr_date 临时挂载[done]"
  df -h
}

################## 创建开机挂载服务 ##################
mount_server_creat(){
  mount_del
  echo -e "$curr_date 正在创建服务 \"${red}rclone-${mount_path_name}.service${normal}\"请稍等..."
cat >/lib/systemd/system/rclone-${mount_path_name}.service<<'EOF'
  [Unit]
  Description = rclone-${mount_path_name}
  AssertPathIsDirectory = ${mount_path}
  Wants = network-online.target
  After = network-online.target
  
  [Service]
  Type = notify
  KillMode = none
  Restart = on-failure
  RestartSec = 5
  User = root
  ExecStart = fclone mount ${mount_path_name}: ${path} ${mount_tag}
  ExecStop = fusermount -qzu ${mount_path}

  [Install]
  WantedBy = multi-user.target
EOF
  sleep 2s
  echo -e "$curr_date 服务创建成功。"
  sleep 2s
  echo
  echo -e "$curr_date 启动服务..."
  systemctl start rclone-${mount_path_name}.service &> /dev/null
  sleep 1s
  echo -e "$curr_date 添加开机启动..."
  systemctl enable rclone-${mount_path_name}.service &> /dev/null
  if [[ $? ]];then
    echo
    echo -e "已为网盘 ${red}${mount_path_name}${normal} 创建服务 ${red}reclone-${mount_path_name}.service${normal}.并已添加开机挂载.\n您可以通过 ${red}systemctl [start|stop|status]${normal} 进行挂载服务管理。"
    echo
    echo
    sleep 2s
  else
    echo
    echo -e "$curr_date 警告:未知错误."
  fi
}

################## 脚本参数帮助 ##################
mount_help(){
  echo -e "用法(Usage):
  bash <(curl -sL https://git.io/cg_auto_mount) [flags1] [flags2] [flags3]
  注意：无或缺少参数则进入主菜单

[flags1]可用参数(Available flags)：
  bash <(curl -sL https://git.io/cg_auto_mount) l  临时创建挂载
  bash <(curl -sL https://git.io/cg_auto_mount) s  服务创建挂载
  bash <(curl -sL https://git.io/cg_auto_mount) d  删除挂载
  bash <(curl -sL https://git.io/cg_auto_mount) h  命令帮助
  
[flags2]可用参数(Available flags)：
  flags2 为需要创建挂载的remote名称，可查阅~/.config/rclone/rclone.conf

[flags3]可用参数(Available flags)：
  flags3 为挂载路径"
}

################## 开  始  菜  单 ##################

mount_menu(){
  clear
  echo -e "———————————————————————————————————————"
  echo -e "${green}mount一键脚本 by cgkings${normal}"
  echo -e "${green}1、临时挂载${normal}"
  echo -e "${green}2、服务挂载${normal}"
  echo -e "${green}3、删除挂载${normal}"
  echo -e "${green}4、退出${normal}"
  echo -e "———————————————————————————————————————"
  read -n1 -p "请输入数字 [1-4]:" num
  case "$num" in
    1)
      echo
      remote_chose
      dir_chose
      tag_chose
      mount_creat
      ;;
    2)
      echo
      remote_chose
      dir_chose
      tag_chose
      mount_server_creat
      ;;
    3)
      echo    
      mount_del
      ;;
    4)
      exit
      ;;
    *)
      echo
      echo "输入错误，请重新输入"
      mount_menu
      ;;
  esac
}

################## 执  行  命  令 ##################
if [ $# -ne 3 ]; then
  mount_menu
else
  mount_remote=$2
  mount_path=$3
  case "$1" in
  L*|l*)
    case * in
      1)
      echo
      mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
      ;;
      2)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
      ;;
      3)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
      ;;
      *)
      echo
      mount_help
      ;;
    esac
    echo
    dir_check
    mount_del
    mount_creat
    ;;
  S*|s*)
    case * in
      1)
      echo
      mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
      ;;
      2)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
      ;;
      3)
      echo
      mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
      ;;
      *)
      echo
      mount_help
      ;;    
    echo
    dir_check
    mount_del
    mount_server_creat
    ;;
  D|d)
    echo    
    mount_del
    ;;
  H|h)
    echo
    mount_help
    ;;
  *)
    echo
    mount_help
    ;;
  esac
fi