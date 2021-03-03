#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# bash <(curl -sL git.io/cg_dl)
# File Name: cg_dl一键脚本
# Author: cgkings
# Created Time : 2020.12.25
# Description:flexget
# System Required: Debian/Ubuntu
# 感谢wuhuai2020、moerats、github众多作者，我只是整合代码
# Version: 1.0
#=============================================================

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 安装配置aria2自动下载上传 ##################
install_aria2() {
  cd /root || exit
  bash <(curl -sL git.io/aria2.sh) << EOF
1 
EOF
  #修改默认本地下载路径为/home/download
  [ ! -e /home/download ] && mkdir -p 755 /home/download
  [ -z "$(grep "/home/download" /root/.aria2c/aria2.conf)" ] && sed -i 's/dir=.*$/dir=\/home\/download/g' /root/.aria2c/aria2.conf
  #修改完成后执行的脚本为自动上传
  [ -z "$(grep "upload.sh" /root/.aria2c/aria2.conf)" ] && sed -i 's/clean.sh/upload.sh/g' /root/.aria2c/aria2.conf
  #修改自动上传的工具，由rclone改为fclone
  [ -z "$(grep "fclone move" /root/.aria2c/upload.sh)" ] && sed -i 's/rclone move/fclone move/g' /root/.aria2c/upload.sh
  #选择fclone remote
  remote_choose
  #设置自动上传的fclone remote*****从此行开始未修改******
  [ -z "$(grep "$my_remote" /root/.aria2c/script.conf)" ] && sed -i 's/drive-name=.*$/drive-name='$my_remote'/g' /root/.aria2c/script.conf
  #设置自动上传网盘目录为/Download
  [ -z "$(grep "drive-dir=/Download" /root/.aria2c/script.conf)" ] && sed -i 's/#drive-dir=.*$/drive-dir=\/Download/g' /root/.aria2c/script.conf
  #通知remote选择结果及自动上传目录
  echo -e "$curr_date ${green}[INFO]${normal} 您选择的remote为：${my_remote}，自动上传目录为：/Download，如有需要，请bash <(curl -sL git.io/aria2.sh)自行修改"
  service aria2 restart
  #检查是否安装成功
  aria2_install_status=$(/root/.aria2c/upload.sh | sed -n '4p')
  if [ "$aria2_install_status" = success ]; then
    echo -e "${curr_date} ${green}[INFO]${normal} aria2自动上传已安装配置成功！"
    echo -e "${curr_date} [INFO] aria2自动上传已安装配置成功！本地下载目录为：/home/download,remote为：${my_remote}，自动上传目录为：/Download" >> /root/install_log.txt
  else
    echo -e "${curr_date} ${red}[ERROR]${normal} aria2自动上传已安装配置成功！"
    echo -e "${curr_date} [ERROR] aria2自动上传安装配置失败！" >> /root/install_log.txt
  fi
}

################## 搭建RSSHUB ##################
install_rsshub() {
  [ -e /home/RSSHub ] && rm -rf /home/RSSHub
  mkdir -p 755 /home/RSSHub && git clone https://github.com/cgkings/RSSHub /home/RSSHub
  sleep 5s
  cd /home/RSSHub || exit
  npm cache clean --force
  npm install
  echo -e "CACHE_TYPE=redis\nCACHE_EXPIRE=600" > /home/RSSHub/.env
}

################## 运行rsshub ##################

run_rsshub() {
  tmux new -s rsshub -d
  tmux send -t "rsshub" "cd /home/RSSHub && git pull && npm install & npm start" Enter
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
    read -r -t 10 -p "请输入你的flexget的config.yml备份下载网址(10秒超时或回车默认作者地址，有需要自行修改，路径为：/root/.config/flexget/config.yml：" config_yml_ip
    config_yml_ip=${config_yml_ip:-https://raw.githubusercontent.com/cgkings/script-store/master/config/config.yml}
    wget -qN ${config_yml_ip} -O /root/.config/flexget/config.yml
    aria2_key=$(cat /root/.aria2c/aria2.conf | grep "rpc-secret" | awk -F= '{print $2}')
    sed -i 's/secret:.*$/secret: '$aria2_key'/g' /root/.config/flexget/config.yml
    #建立软连接
    ln -sf /home/software/flexget/bin/flexget /usr/local/bin/
    #设置为自动启动，在 rc.local 中增加启动命令
    /home/software/flexget/bin/flexget -L error -l /var/log/flexget/flexget.log daemon start -d
  fi
}

################## 配置flexget刷新时间 ##################
config_flexget() {
  read -r -t 5 -p "flexget刷新时间设置为(单位：分钟,5秒超时或回车默认20分钟)：" fresh_time
  fresh_time=${fresh_time:-15}
  config_flexget_do
}

config_flexget_do() {
  cron_list=$(echo $(crontab -l))
  flexget_dir=$(echo $(which flexget))
  cron_config="*/${fresh_time} * * * * /usr/local/bin/flexget -c /root/.config/flexget/config.yml --cron execute"
  if [[ ${cron_list} =~ ${cron_config} ]]; then
    echo "该配置计划任务已添加，无须重复添加"
  else
    if [[ ${cron_list} =~ ${flexget_dir} ]]; then
      sed -i '/\/usr\/local\/bin\/flexget/d' /var/spool/cron/crontabs/root
      crontab -l | {
                   cat
                        echo "${cron_config}"
      }                                          | crontab -
    else
      crontab -l | {
                   cat
                        echo "${cron_config}"
      }                                          | crontab -
    fi
  fi
  flexget --test execute
  echo -e "flexget已完成部署动作，等${fresh_time}分钟，用<flexget status>命令看一下状态吧！"
  echo -e "如安装有异常，请联系作者"
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

################## 执  行  命  令 ##################
check_sys
check_command wget
check_rclone
check_python
check_nodejs
if [ -z "$1" ]; then
  install_aria2
  install_rsshub
  run_rsshub
  install_flexget
  config_flexget
else
  case "$1" in
    A | a)
      echo
      install_aria2
      ;;
    R | r)
      echo
      install_rsshub
      run_rsshub
      ;;
    F | f)
      echo
      install_flexget
      config_flexget
      ;;
    H | h)
      echo
      dl_help
      ;;
    *)
      echo
      dl_help
      ;;
  esac
fi