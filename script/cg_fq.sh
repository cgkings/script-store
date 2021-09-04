#!/bin/bash
# bash <(curl -sL git.io/cg_fq)
v2ray_install() {
  #启动v2ray官方安装脚本
  #bash <(curl -sL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) -h
  bash <(curl -sL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
  #Created symlink /etc/systemd/system/multi-user.target.wants/v2ray.service → /etc/systemd/system/v2ray.service
  #/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
  rm -rf /usr/local/etc/v2ray/config.json
  wget -qN https://raw.githubusercontent.com/cgkings/script-store/master/config/v2ray/config.json -O /usr/local/etc/v2ray/config.json
  systemctl enable v2ray && systemctl start v2ray
}

v2ray_uninstall() {
  bash <(curl -sL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove
}

################## 脚本参数帮助 ##################
v2ray_help() {
  cat << EOF
用法(Usage):
  bash <(curl -sL git.io/cg_fq) [flags]

可用参数(Available flags)：
  bash <(curl -sL git.io/cg_fq) -i  安装v2ray
  bash <(curl -sL git.io/cg_fq) -u  卸载v2ray
  bash <(curl -sL git.io/cg_fq) -h  命令帮助
注：无参数则默认为安装v2ray
EOF
}

################## 执  行  命  令 ##################
check_sys
if [ -z "$1" ]; then
  v2ray_install
else
  case "$1" in
    -i | -I)
      echo
      v2ray_install
      ;;
    -u | -U)
      echo
      v2ray_uninstall
      ;;
    -h | -H)
      echo
      v2ray_help
      ;;
    *)
      echo
      v2ray_help
      ;;
  esac
fi