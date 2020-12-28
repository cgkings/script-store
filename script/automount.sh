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
  check_rclone
  remote_list=$(sed -n "/\[.*\]/p" ~/.config/rclone/rclone.conf | grep -Eo "[0-9A-Za-z-]+" | awk '{ print FNR " " $0}' )
  echo -e "   本地已配置remote列表:"
  echo -e "${red} +-------------------------+"
  echo -e "${red}$remote_list${normal}"
  echo -e "${red} +-------------------------+"
  read -n1 -p "请选择需要挂载的remote（输入数字即可）：" rclone_chose_num
  echo
  if [[ $remote_list =~ $rclone_chose_num ]]; then
    mount_remote=$(echo -e "$remote_list" | awk '{print $2}' | sed -n ''$rclone_chose_num'p')
    fclone backend lsdrives $mount_remote: | awk '{ print FNR " " $0}' > ~/.config/rclone/"$mount_remote"_drivelist.txt
    drive_id=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | awk '/team_drive/{print $3}' | sed -n '1p')
    if [ -z $drive_id ];then
      echo -e "$curr_date ${red}[Info]您的team_drive id为空，在下面添加一个吧${normal}"
      sleep 3s
      drive_chose_list
      rootid=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | grep 'root_folder_id' | sed -n '1p')
      sed -i "s/$rootid/root_folder_id = /g" ~/.config/rclone/rclone.conf
      team_drive_id=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | grep 'team_drive' | sed -n '1p')
      sed -i "s/$team_drive_id/team_drive = $drive_change_id/g" ~/.config/rclone/rclone.conf
      drive_id=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | awk '/team_drive/{print $3}' | sed -n '1p')
      echo -e "$curr_date ${red}[Info]您选择的remote为：${mount_remote}，挂载盘名为：${drive_name},挂载盘ID为${drive_id}${normal}"
      return
    fi
    drive_name=$(cat ~/.config/rclone/"$mount_remote"_drivelist.txt | awk '/'$drive_id'/{print $3}')
    echo
    echo -e "$curr_date ${red}[Info]您选择的remote为：${mount_remote}，挂载盘名为：${drive_name},挂载盘ID为${drive_id}${normal}"
    read -n1 -p "是否要修改挂载盘[Y/n],除输入Y|y默认n ：" result
    echo
    result=${result:-n}
    case ${result} in
      Y | y)
        drive_chose_list
        drive_change;;
      n | N)
        echo;;
      *)
        echo;;
      esac
  else
  echo
  echo "输入不正确，请重新输入。"
  echo
  remote_chose
  fi
}

################## 网盘选择列表 ##################[done]
drive_chose_list(){
  echo -e "$mount_remote 的网盘列表："
  sleep 2s
  echo -e "${red} +-------------------------+"
  echo -e "${red}$(cat ~/.config/rclone/"$mount_remote"_drivelist.txt)${normal}"
  echo -e "${red} +-------------------------+"
  read -p "请选择需要挂载的网盘（输入数字即可）：" drive_chose_num
  drive_change_id=$(cat ~/.config/rclone/"$mount_remote"_drivelist.txt | awk '{print $2}' | sed -n ''$drive_chose_num'p')
  echo $drive_change_id
}
    
################## 修改挂载盘 ##################[done]
drive_change(){
  fclone backend lsdrives $mount_remote: | awk '{ print FNR " " $0}' > ~/.config/rclone/"$mount_remote"_drivelist.txt
  drive_id=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | awk '/team_drive/{print $3}' | sed -n '1p')
  if [ -z $drive_id ];then
      echo -e "$curr_date ${red}[Info]您的team_drive id为空，在下面添加一个吧${normal}"
      drive_chose_list
      rootid=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | grep 'root_folder_id' | sed -n '1p')
      sed -i "s/$rootid/root_folder_id = /g" ~/.config/rclone/rclone.conf
      team_drive_id=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | grep 'team_drive' | sed -n '1p')
      sed -i "s/$team_drive_id/team_drive = $drive_change_id/g" ~/.config/rclone/rclone.conf
      drive_id=$(sed -n '/'$mount_remote'/,/\[/p' ~/.config/rclone/rclone.conf | awk '/team_drive/{print $3}' | sed -n '1p')
      drive_name=$(cat ~/.config/rclone/"$mount_remote"_drivelist.txt | awk '/'$drive_id'/{print $3}')
      echo -e "$curr_date ${red}[Info]您选择的remote为：${mount_remote}，挂载盘名为：${drive_name},挂载盘ID为${drive_id}${normal}"
      return
  fi
  if [ -z $drive_change_id ];then
  return
  fi
  if [ $drive_change_id == $drive_id ]; then
  echo -e "$curr_date ${red}[Info]你要改的挂载盘id与conf文件id相同，无需修改${normal}"
  else
  echo -e "$curr_date ${red}[Info]即将修改挂载盘ID为：${drive_change_id}${normal}..."
  sed -i "s/$drive_id/$drive_change_id/g" ~/.config/rclone/rclone.conf
  drive_change_name=$(cat ~/.config/rclone/"$mount_remote"_drivelist.txt | awk '/'$drive_change_id'/{print $3}')
  echo -e "$curr_date ${red}[Info]已将挂载盘ID修改为：${drive_change_id},挂载盘名为：${drive_change_name}[done]${normal}"
  sleep 3s
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
  sleep 5s
  echo -e "$curr_date 临时挂载[done]"
  df -h
}

################## 创建开机挂载服务 ##################
mount_server_creat(){
  mount_del
  echo -e "$curr_date 正在创建服务 \"${red}rclone-${mount_path_name}.service${normal}\"请稍等..."
cat >/lib/systemd/system/rclone-${mount_path_name}.service<< EOF
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
  注意：无或少于3个参数则进入主菜单

[flags1]可用参数(Available flags)：
  bash <(curl -sL https://git.io/cg_auto_mount) l1,2,3  临时创建挂载(1,2,3代表挂载方案)
  bash <(curl -sL https://git.io/cg_auto_mount) s1,2,3  服务创建挂载(1,2,3代表挂载方案)
  bash <(curl -sL https://git.io/cg_auto_mount) d       删除挂载
  bash <(curl -sL https://git.io/cg_auto_mount) h       命令帮助
  
[flags2]可用参数(Available flags)：
  flags2 为需要创建挂载的remote名称，可查阅~/.config/rclone/rclone.conf

[flags3]可用参数(Available flags)：
  flags3 为挂载路径
[flags4]可用参数(Available flags)：
  flags4 为要修改为的挂载盘ID"
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
  drive_change_id=$4
  case "$1" in
  L1|l1)
    echo
    mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
    dir_check
    drive_change
    mount_creat
    ;;
  L2|l2)
    echo
    mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
    dir_check
    drive_change
    mount_creat
    ;;
  L3|l3)
    echo
    mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
    dir_check
    drive_change
    mount_creat
    ;;
  S1|s1)
    echo
    mount_tag="--transfers 64 --buffer-size 400M --cache-dir=/home/cache --vfs-cache-mode full --vfs-read-ahead 100G --vfs-cache-max-size 100G --allow-non-empty --allow-other --dir-cache-time 1000h --vfs-cache-max-age 336h --umask 000"
    dir_check
    drive_change
    mount_server_creat
    ;;
  S2|s2)
    echo
    mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 1G --dir-cache-time 12h --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 1G"
    dir_check
    drive_change
    mount_server_creat
    ;;
  S3|s3)
    echo
    mount_tag="--transfers 16 --umask 0000 --default-permissions --allow-other --vfs-cache-mode full --buffer-size 512M --dir-cache-time 12h --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 512M"
    dir_check
    drive_change
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