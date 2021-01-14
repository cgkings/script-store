#!/bin/bash
#=============================================================
# https://github.com/cgkings/script-store
# File Name: flexget一键脚本
# Author: cgkings
# Created Time : 2020.12.25
# Description:flexget
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
#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 搭建RSSHUB ##################
install_rsshub(){
  mkdir -p /home/RSSHub && git clone https://github.com/cgkings/RSSHub /home/RSSHub
  sleep 5s
  cd /home/RSSHub
  npm cache clean --force
  npm install
  echo -e "CACHE_TYPE=redis\nCACHE_EXPIRE=600" > /home/RSSHub/.env
}

################## 运行rsshub ##################

run_rsshub(){
  tmux new -s rsshub -d
  tmux send -t "rsshub" "cd /home/RSSHub && git pull && npm install & npm start" Enter
}

################## 安装flexget ##################
install_flexget(){
  #建立flexget独立的 python3 虚拟环境
  mkdir -p /home/software/flexget/
  virtualenv --system-site-packages --no-setuptools --no-wheel /home/software/flexget/
  #在python3虚拟环境里安装flexget
  /home/software/flexget/bin/pip3 install -U flexget
  #建立 flexget 日志存放
  mkdir -p /var/log/flexget && chown root:adm /var/log/flexget
  #建立 flexget 的配置文件
  read -t 10 -p "请输入你的flexget的config.yml备份下载网址(10秒超时或回车默认作者地址，有需要自行修改，路径为：/home/software/flexget/config.yml)：" config_yml_ip
  config_yml_ip=${config_yml_ip:-https://raw.githubusercontent.com/cgkings/script-store/master/config/config.yml}
  wget -qN ${config_yml_ip} -O /home/software/flexget/config.yml
  aria2_key=$(cat /root/.aria2c/aria2.conf | grep "rpc-secret" | awk -F= '{print $2}')
  sed -i 's/secret:.*$/secret: '$aria2_key'/g' /home/software/flexget/config.yml
  #建立软连接
  ln -sf /home/software/flexget/bin/flexget /usr/local/bin/
  #设置为自动启动，在 rc.local 中增加启动命令
  /home/software/flexget/bin/flexget -L error -l /var/log/flexget/flexget.log daemon start -d
}

################## 配置flexget刷新时间 ##################
config_flexget(){
  read -t 5 -p "flexget刷新时间设置为(单位：分钟,5秒超时或回车默认20分钟)：" fresh_time
  fresh_time=${fresh_time:-15}
  config_flexget_do
}

config_flexget_do(){
  cron_list=$(echo `crontab -l`)
  flexget_dir=$(echo `which flexget`)
  cron_config="*/${fresh_time} * * * * /usr/local/bin/flexget --cron execute"
  if [[ ${cron_list} =~ ${cron_config} ]]; then
  echo "该配置计划任务已添加，无须重复添加"
  else
    if [[ ${cron_list} =~ ${flexget_dir} ]]; then
    sed -i '/\/usr\/local\/bin\/flexget/d' /var/spool/cron/crontabs/root
    crontab -l | { cat; echo "${cron_config}"; } | crontab -
    else
    crontab -l | { cat; echo "${cron_config}"; } | crontab -
    fi
  fi
  flexget --test execute
}

################## 执  行  命  令 ##################

if [ -z $1 ]; then
  install_rsshub
  run_rsshub
  install_flexget
  config_flexget
else
  fresh_time=$1
  run_rsshub
  config_flexget_do
fi