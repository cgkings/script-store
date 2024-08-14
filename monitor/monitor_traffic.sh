#!/usr/bin/env bash

# Your USERID or Channel ID to display alert and key, we recommend you create new bot with @BotFather on Telegram
#你要修改的都在这里USERID,KEY,VPSNAME,PFTIME,LIMIT,LIMIT2
#========================================================
USERID=(这里也要改电报机器人id)
KEY="填电报机器人key"
# 设置机器名字
VPSNAME="ali-hk1"
# 设置流量限制（单位：GB）
LIMIT=150
LIMIT2=160
# 设置间隔时间（单位：秒）
PFTIME=1800
#=========================================================

for i in "${USERID[@]}"; do
  URL="https://api.telegram.org/bot${KEY}/sendMessage"
  DATE="$(date "+%Y-%m-%d %H:%M:%S")"

  # 设置网卡名称
  INTERFACE=$(ip route | grep default | awk '{print $5}')

  SRV_HOSTNAME=$(hostname -f)

  # 获取当前流量（单位：KB）====================================
  VNSTAT_JSON=$(vnstat -i "$INTERFACE" --json)

  # 使用 jq 解析 JSON 数据获取接收和发送的流量（单位：KB）
  RX=$(echo "$VNSTAT_JSON" | jq -r '.interfaces[0].traffic.total.rx')
  TX=$(echo "$VNSTAT_JSON" | jq -r '.interfaces[0].traffic.total.tx')

  # 检查 RX 和 TX 是否为有效的数字
  if ! [[ $RX =~ ^[0-9]+$ ]] || ! [[ $TX =~ ^[0-9]+$ ]]; then
    exit 1
  fi

  # 计算总流量（单位：GB）
  TOTAL=$(echo "scale=2; ($RX + $TX) / 1024 / 1024" | bc)
  RX_GB=$(echo "scale=2; $RX / 1024 / 1024" | bc)
  TX_GB=$(echo "scale=2; $TX / 1024 / 1024" | bc)

  # 获取上次运行时间==========================================================

  # 当前时间（秒）
  current_time=$(date +%s)

  # 默认上次执行时间为很久之前（这样首次运行时会执行else分支）
  last_exec_time=0

  # 时间戳文件路径
  timestamp_file="/usr/unitls/else_exec_time.txt"

  # 检查时间戳文件是否存在
  if [ -f "$timestamp_file" ]; then
    # 读取上次执行时间
    last_exec_time=$(cat "$timestamp_file")
  else
    touch /usr/unitls/else_exec_time.txt
    echo "else_exec_time.txt 文件已经创建."  # 可选：输出提示信息
  fi

  # 计算时间差值
  time_diff=$((current_time - last_exec_time))

  #判断执行语句==============================================================
  if (($(echo "$RX_GB >= $LIMIT2" | bc -l))) || (($( echo "$TX_GB >= $LIMIT2" | bc -l))); then

    TEXT="${VPSNAME}(${SRV_HOSTNAME})当前流量使用情况:
入流量（接受流量）: *${RX_GB}*
出流量（发送流量）: *${TX_GB}*
总流量（接受发送）: *${TOTAL}
时间: ${DATE}
[ Info ] 已超过160GB，执行关机操作"
    # curl -s -d "chat_id=$i&text=${TEXT}&disable_web_page_preview=true&parse_mode=markdown" $URL > /dev/null
    sudo shutdown -h now

  elif (($(echo "$RX_GB >= $LIMIT" | bc -l))) || (($( echo "$TX_GB >= $LIMIT" | bc -l))); then

    TEXT="${VPSNAME}(${SRV_HOSTNAME})当前流量使用情况:
入流量（接受流量）: *${RX_GB}*
出流量（发送流量）: *${TX_GB}*
总流量（接受发送）: *${TOTAL}
时间: ${DATE}
[ Info ] 已超过150GB，超过160GB将执行关机操作"
    # curl -s -d "chat_id=$i&text=${TEXT}&disable_web_page_preview=true&parse_mode=markdown" $URL > /dev/null

  else
    if ((time_diff >= PFTIME)); then
      # 记录操作时间
      echo "$current_time" > "$timestamp_file"

      TEXT="${VPSNAME}(${SRV_HOSTNAME})当前流量使用情况:
入流量（接受流量）: *${RX_GB}*
出流量（发送流量）: *${TX_GB}*
总流量（接受发送）: *${TOTAL}
时间: ${DATE}
[ Info ] 正常使用暂未超过150GB"

      # curl -s -d "chat_id=$i&text=${TEXT}&disable_web_page_preview=true&parse_mode=markdown" $URL > /dev/null
    fi
  fi
done
