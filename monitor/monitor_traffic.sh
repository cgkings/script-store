#!/bin/bash
#===============================================================
# https://github.com/cgkings/script-store
# File Name: monitor_traffic.sh
# Author: 王大锤
# Created Time : 2024.8.14
# Description:流量限流控制
# System Required: Debian/Ubuntu
# Version: 1.0

# ======================      定义变量     ======================
# 设置机器名字
VPSNAME="ali-hk1"
# 设置流量限制（单位：GB）
LIMIT=150
LIMIT2=180
# 设置网卡名称
INTERFACE=$(ip route | grep default | awk '{print $5}')
SRV_HOSTNAME=$(hostname -f)
# 脚本路径
# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
green='\e[32m'
none='\e[0m'

# ====================== 检查并安装依赖程序 ======================
# 定义一个通用的检查并安装函数
check_command() {
  local cmd=$1
  local install_cmd=$2
  if ! command -v "$cmd" &> /dev/null; then
    apt-get update    
    echo -e "${green}正在安装 ${cmd}...${none}"
    eval "$install_cmd"
  fi
}

  # 检查并安装 vnstat
  check_command "vnstat" "sudo apt-get install vnstat"
  # 检查并安装 bc
  check_command "bc" "sudo apt install -y bc"

# ====================== 检查并设置计划任务 ======================
CRON_JOB="*/5 * * * * $SCRIPT_DIR/monitor_traffic.sh"
CRON_EXISTS=$(crontab -l 2>/dev/null | grep -F "$CRON_JOB")

if [ -z "$CRON_EXISTS" ]; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Added cron job for traffic monitoring"
fi

# ======================    流量监控信息    ======================
# 获取当前流量（单位为MiB）
VNSTAT_OUTPUT=$(vnstat -i "$INTERFACE" --oneline)

# 提取当月的入流量、出流量和总流量（单位为MiB）
RX=$(echo "$VNSTAT_OUTPUT" | cut -d ';' -f 9 | cut -d ' ' -f 1)
TX=$(echo "$VNSTAT_OUTPUT" | cut -d ';' -f 10 | cut -d ' ' -f 1)
TOTAL=$(echo "$VNSTAT_OUTPUT" | cut -d ';' -f 11 | cut -d ' ' -f 1)

# 计算总流量（单位：GB）
RX_GB=$(echo "$RX" | awk '{print $1/1024}')
TX_GB=$(echo "$TX" | awk '{print $1/1024}')
TOTAL_GB=$(echo "$TOTAL" | awk '{print $1/1024}')

# 定义流量信息输出函数，带有一个参数作为附加信息
log_traffic_info() {
    cat << EOF | tee -a "$SCRIPT_DIR"/traffic_monitor.log
${green}${VPSNAME}(${SRV_HOSTNAME}) 当前流量使用情况:${none}
入流量（接受流量）: ${RX_GB} GB
出流量（发送流量）: ${TX_GB} GB
总流量（接受发送）: ${TOTAL_GB} GB
$1
时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF
}

# ======================    流量控制处理    ======================
if (($( echo "$RX_GB >= $LIMIT2" | bc -l)))  || (($( echo "$TX_GB >= $LIMIT2" | bc -l))); then

  log_traffic_info "已超过${LIMIT2}GB，执行关机操作！！！"
  sudo shutdown -h now

elif (($( echo "$RX_GB >= $LIMIT" | bc -l)))  || (($( echo "$TX_GB >= $LIMIT" | bc -l))); then

  log_traffic_info "已超过${LIMIT}GB，超过160GB将执行关机操作！！！"

else

  log_traffic_info "正常使用暂未超过${LIMIT}GB！！！"

fi
