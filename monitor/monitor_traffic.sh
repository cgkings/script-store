#!/usr/bin/env bash

# This script is called on SSH login by /etc/profile.d/sshd_telegram.sh
# Modified from https://github.com/MyTheValentinus/ssh-login-alert-telegram

# Your USERID or Channel ID to display alert and key, we recommend you create new bot with @BotFather on Telegram
#你要修改的都在这里USERID,KEY,VPSNAME,PFTIME,LIMIT,LIMIT2
#========================================================
# 设置机器名字
VPSNAME="ali-hk1"
# 设置流量限制（单位：GB）
LIMIT=150
LIMIT2=160
#=========================================================

# 设置网卡名称
INTERFACE="ens5"

SRV_HOSTNAME=$(hostname -f)

# 获取当前流量（单位：KB）====================================
VNSTAT_JSON=$(vnstat -i $INTERFACE --json)

# 使用 jq 解析 JSON 数据获取接收和发送的流量（单位：KB）
RX=$(echo $VNSTAT_JSON | jq -r '.interfaces[0].traffic.total.rx')
TX=$(echo $VNSTAT_JSON | jq -r '.interfaces[0].traffic.total.tx')

# 检查 RX 和 TX 是否为有效的数字
if ! [[ $RX =~ ^[0-9]+$ ]] || ! [[ $TX =~ ^[0-9]+$ ]]; then
    exit 1
fi

# 计算总流量（单位：GB）
TOTAL=$(echo "scale=2; ($RX + $TX) / 1024 / 1024" | bc)
RX_GB=$(echo "scale=2; $RX / 1024 / 1024" | bc)
TX_GB=$(echo "scale=2; $TX / 1024 / 1024" | bc)

# 定义流量信息输出函数，带有一个参数作为附加信息
log_traffic_info() {
    cat << EOF
时间: $(date '+%Y-%m-%d %H:%M:%S')
${VPSNAME}(${SRV_HOSTNAME}) 当前流量使用情况:
入流量（接受流量）: ${RX_GB} GB
出流量（发送流量）: ${TX_GB} GB
总流量（接受发送）: ${TOTAL} GB
$1
EOF
}

#判断执行语句==============================================================
if (($( echo "$RX_GB >= $LIMIT2" | bc -l)))  || (($( echo "$TX_GB >= $LIMIT2" | bc -l))); then

  log_traffic_info "已超过160GB，执行关机操作！！！"
  #sudo shutdown -h now

elif (($( echo "$RX_GB >= $LIMIT" | bc -l)))  || (($( echo "$TX_GB >= $LIMIT" | bc -l))); then

  log_traffic_info "已超过150GB，超过160GB将执行关机操作！！！"

else

  log_traffic_info "正常使用暂未超过150GB！！！"

fi
