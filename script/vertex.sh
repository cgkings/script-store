#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
if [[ $EUID -ne 0 ]]; then
  echo -e "${red}本脚本必须root账号运行，请切换root用户后再执行本脚本!${plain}"
  exit 1
fi
install_vertex(){
  local_ip=$(ip a 2>&1 | grep -w 'inet' | grep 'global' | grep -E '\ 1(92|0|72|00|1)\.' | sed 's/.*inet.//g' | sed 's/\/[0-9][0-9].*$//g' | head -n 1)
  baseip=$(curl -s ipip.ooo)  > /dev/null
  if test -z "$(which docker)"; then
    echo -e "${yellow}检测到系统未安装docker，开始安装docker${plain}"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    if [[ "$#" -eq 0 ]]; then
      echo -e "${green}docker安装成功······${plain}"
    else
      echo -e "${red}docker安装失败······${plain}"
      exit 1
    fi
  fi
  if test -z `which docker-compose`;then
    echo -e "${yellow}检测到系统未安装docker-compose，开始安装docker-compose${plain}"
    curl -L https://get.daocloud.io/docker/compose/releases/download/v2.4.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    if [[ "$#" -eq 0 ]]; then
       echo -e "${green}docker-compose安装成功······${plain}"
    else
      echo -e "${red}docker-compose安装失败······${plain}"
      exit 1
    fi
  fi
  mkdir -p /root/vertex && chmod 777 /root/vertex
  cd /root
  cat >/root/docker-compose.yml <<EOF
version: "2.0"
services:
  vertex:
    image: lswl/vertex:latest
    container_name: vertex
    restart: always
    tty: true
    network_mode: bridge
    hostname: vertex
    volumes:
      - /root/vertex:/vertex
    environment:
      - TZ=Asia/Shanghai
    ports: 
      - 3000:3000
  vertex-base:
    image: lswl/vertex-base:latest
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: always
    tty: true
    network_mode: bridge
    hostname: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - TZ=Asia/Shanghai
    command: vertex --cleanup --schedule "0 0 4 * * *"
EOF
  docker-compose up -d
  sleep 5s
  password=`cat /root/vertex/data/password`
  echo -e "${green}Vertex安装完毕，面板访问地址：http://${baseip}:3000 或 http://${local_ip}:3000\n用户名:admin\n密  码:${plain} ${red}${password}${plain}${green}\n进入vertex面板后通过${plain} ${red}全局设置${plain} ${green}修改密码 ${plain}"
}
install_qBittorrent(){
    if test -z "$(which docker)"; then
    echo -e "${yellow}检测到系统未安装docker，开始安装docker${plain}"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    if [[ "$#" -eq 0 ]]; then
      echo -e "${green}docker安装成功······${plain}"
    else
      echo -e "${red}docker安装失败······${plain}"
      exit 1
    fi
  fi
  if test -z `which docker-compose`;then
    echo -e "${yellow}检测到系统未安装docker-compose，开始安装docker-compose${plain}"
    curl -L https://get.daocloud.io/docker/compose/releases/download/v2.4.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    if [[ "$#" -eq 0 ]]; then
       echo -e "${green}docker-compose安装成功······${plain}"
    else
      echo -e "${red}docker-compose安装失败······${plain}"
      exit 1
    fi
  fi
  echo -ne "${yellow}请输入qBittorrent下载文件存放目录的绝对路径：${plain}"
  read down_dir
  cat>/root/qBittorrent.yml<<EOF
version: "2.1"
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Aisa/Shanghai
      - WEBUI_PORT=8080
    volumes:
      - /root/qbittorrent/config:/config
      - ${down_dir}:/downloads
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
EOF
  cd /root
  docker-compose -f qBittorrent.yml up -d
  if [[ "$#" -eq 0 ]]; then
    echo -e "${green}qBittorrent安装成功······\n下载文件存放路径:${down_dir}${plain}"
    echo -e "${green}默认用户名：admin\n默认密码：adminadmin\n请登录面板后及时修改默认密码${plain}"
  else
    echo -e "${red}qBittorrent安装失败······${plain}"
    exit 1
  fi
}
restore_rule(){
  cd /root/vertex/data
  if test -z `which unzip`; then
    echo -e "${yellow}检测到系统未安装unzip，开始安装unzip······${plain}"
    apt install unzip -y||yum install unzip -y
    if [[ "$#" -eq 0 ]]; then
      echo -e "${green}unzip安装成功，开始导入刷流所需相关规则······${plain}"
    else
      echo -e "${red}出错了，unzip安装失败，程序退出······${plain}"
      exit 1
    fi
  fi
  wget https://ghproxy.20120714.xyz/https://github.com/07031218/normal-shell/raw/main/vertex_ruler/rule.zip -O rule.zip
  unzip -o rule.zip
  if [[ "$#" -eq 0 ]]; then
    echo -e "${green}刷流相关规则导入成功······${plain}"
  else
  echo -e "${red}出错了，刷流相关规则导入失败，程序退出······${plain}"
  exit 1
  fi
}
uninstall_vertex(){
  cd /root
  docker-compose down
  echo -ne "${yellow}是否删除vertex映射目录和相关本地镜像[Yy/Nn]${plain}"
  read yn
  if [[ $yn == "Y" ]]||[[  $yn == "y" ]]; then
    rm -rf /root/vertex
    rm /root/docker-compose.yml
    docker rmi lswl/vertex:latest
    docker rmi lswl/vertex-base:latest
    echo -e "${yellow}vertex映射目录和相关本地镜像已删除${plain}"
  else
    echo -e "${yellow}按照您的选择，vertex映射目录给予保留，程序自动退出${plain}"
  fi
}
menu_go_on(){
  echo
  echo -e "${red}是否继续执行脚本?${plain}"
  read -n1 -p "Y继续执行，N退出脚本[Y/n]" res
  echo
  case "$res" in
    Y |y)
        ;;
    N | n)
        exit 1;;
    *)
        echo "输入错误"
  menu_go_on;;
  esac
}
copyright(){
echo -e "
${green}###########################################################${plain}
${green}#                                                         #${plain}
${green}#              Vertex 一键部署脚本                        #${plain}
${green}#              Powered  by 翔翎                           #${plain}
${green}#                                                         #${plain}
${green}###########################################################${plain}"
}
main(){
  echo -e "
${red}0.${plain} 退出脚本
${green}1.${plain} 安装vertex
${green}2.${plain} 安装qBittorrent
${green}3.${plain} 导入vertex刷流相关规则
${green}4.${plain} 卸载vertex
"
  read -p "请输入数字 :" num
  case "$num" in
  0)
    exit 0
    ;;
  1)
    install_vertex
    ;;
  2)
    install_qBittorrent
    ;;
  3)
    restore_rule
    ;;
  4)
    uninstall_vertex
    ;;
  *)
  clear
    echo -e "${Error}:请输入正确数字 [0-4]"
    sleep 3s
    main
    ;;
  esac
  menu_go_on
  clear
  copyright
  main
}
copyright
main
