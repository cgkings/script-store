#!/bin/bash

# 颜色设置
green='\e[32m'
none='\e[0m'
config_file="/usr/local/etc/xray/config.json"

# 定义一个通用的检查并安装函数
check_command() {
  local cmd=$1
  local install_cmd=$2
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "${green}正在安装 ${cmd}...${none}"
    eval "$install_cmd"
  fi
}

check_install() {
  # 更新包列表
  apt-get update
  # 检查并安装 ntp,避免时间误差导致错误
  check_command "ntpq" "sudo apt install -y ntp"
  # 检查并安装 jq
  check_command "jq" "sudo apt install -y jq"
  # 检查并安装 uuid-runtime
  check_command "uuidgen" "sudo apt install -y uuid-runtime"
  # 检查并安装 xray
  check_command "xray" "bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install"
}

# 创建配置文件
create_config() {
  # 生成一个随机端口号（10000以上）
  PORT=$(awk -v min=10000 -v max=65535 'BEGIN{srand(); print int(min + (max-min+1)*rand())}')
  # 生成一个随机 UUID
  UUID=$(uuidgen)
  # 生成一个 6 位的随机英文字符串作为路径
  RANDOM_PATH=$(tr -dc 'a-z' < /dev/urandom | head -c 6)
  printf '%s\n' "{
  \"log\": {
    \"loglevel\": \"warning\"
  },
  \"inbounds\": [
    {
      \"port\": $PORT,
      \"protocol\": \"vmess\",
      \"settings\": {
        \"clients\": [
          {
            \"id\": \"$UUID\",
            \"alterId\": 0
          }
        ]
      },
      \"streamSettings\": {
        \"network\": \"ws\",
        \"security\": \"none\",
        \"wsSettings\": {
          \"path\": \"/$RANDOM_PATH\"
        },
        \"tcpSettings\": {
          \"noDelay\": true,
          \"header\": {
            \"type\": \"none\"
          },
          \"mtu\": 1350
        },
        \"mux\": {
          \"enabled\": true,
          \"concurrency\": 8
        }
      },
      \"listen\": \"0.0.0.0\"
    }
  ],
  \"outbounds\": [
    {
      \"protocol\": \"freedom\",
      \"settings\": {}
    }
  ],
  \"routing\": {
    \"rules\": [
      {
        \"type\": \"field\",
        \"inboundTag\": [\"inbound0\"],
        \"outboundTag\": \"direct\"
      }
    ]
  }
}" > "$config_file"
}

# 显示配置信息
show_inbound_config() {
  local ip
  if ! ip=$(curl -s http://ipinfo.io/ip); then
    echo -e "${green}无法获取 IP 地址。${none}"
    return
  fi
  local vmess_link
  vmess_link=$(printf '{"v":"2","ps":"vmess+ws","add":"%s","port":%d,"id":"%s","aid":"0","net":"ws","path":"/%s","type":"none","host":"","tls":""}' "$ip" "$PORT" "$UUID" "$RANDOM_PATH" | base64 -w 0)
  echo -e "${green}Vmess-ws节点链接:${none}"
  echo "vmess://$vmess_link"
}

check_install
create_config
show_inbound_config
systemctl restart xray
systemctl enable xray
echo -e "${green}Xray 服务已启动。${none}"