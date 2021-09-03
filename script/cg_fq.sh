#!/bin/bash
# bash <(curl -sL git.io/cg_fq)
v2ray_install() {
  #启动v2ray官方安装脚本
  #bash <(curl -sL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) -h
  bash <(curl -sL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
  #Created symlink /etc/systemd/system/multi-user.target.wants/v2ray.service → /etc/systemd/system/v2ray.service
  #/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
  rm -rf /usr/local/etc/v2ray/config.json
  wget -qN https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -O /usr/local/etc/v2ray/config.json
  systemctl enable v2ray && systemctl start v2ray
}

v2ray_uninstall() {
  bash <(curl -sL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove
}
