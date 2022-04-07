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

#set -e #异常则退出整个脚本，避免错误累加
#set -x #脚本调试，逐行执行并输出执行的脚本命令行

################## 前置变量设置 ##################
# shellcheck source=/dev/null
source <(curl -sL git.io/cg_script_option)
setcolor

################## 安装配置aria2自动下载上传 ##################


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
    read -r -t 10 -p "请输入你的flexget的config.yml备份下载网址(10秒超时或回车默认作者地址，有需要自行修改，路径为：/root/.config/flexget/config.yml：" config_yml_link
    config_yml_link=${config_yml_link:-https://raw.githubusercontent.com/cgkings/script-store/master/config/cn_yml/config.yml}
    mkdir -p 755 /root/.config/flexget && wget -qN "${config_yml_link}" -O /root/.config/flexget/config.yml
    aria2_key=$(grep "rpc-secret" /root/.aria2c/aria2.conf | awk -F= '{print $2}')
    sed -i "s/secret:.*$/secret: $aria2_key/g" /root/.config/flexget/config.yml
    #建立软连接
    ln -sf /home/software/flexget/bin/flexget /usr/local/bin/
    #设置为自动启动，在 rc.local 中增加启动命令
    /home/software/flexget/bin/flexget -L error -l /var/log/flexget/flexget.log daemon start -d
  fi
  if [ -z "$(crontab -l | grep "flexget")" ]; then
    crontab -l | {
                   cat
                        echo "*/10 * * * * /usr/local/bin/flexget -c /root/.config/flexget/config.yml --cron execute"
    }                                            | crontab -
  else
    #删除包含flexget的计划任务，重新创建
    sed -i '/flexget/d' /var/spool/cron/crontabs/root
    crontab -l | {
                   cat
                        echo "*/10 * * * * /usr/local/bin/flexget -c /root/.config/flexget/config.yml --cron execute"
    }                                            | crontab -
  fi
  flexget --test execute
  echo -e "flexget已完成部署动作，等10分钟，用<flexget status>命令看一下状态吧！"
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
  install_flexget
else
  case "$1" in
    A | a)
      echo
      install_aria2
      ;;
    R | r)
      echo
      install_rsshub
      ;;
    F | f)
      echo
      install_flexget
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
