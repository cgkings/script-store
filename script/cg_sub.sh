#!/bin/bash
apt update && apt-get upgrade
apt-get install -y nodejs npm
npm install -g yarn
cd /root && git clone https://github.com/CareyWang/sub-web.git && cd sub-web && yarn install
yarn config set ignore-engines true
yarn build
cd /root && wget https://github.com/tindy2013/subconverter/releases/download/v0.6.3/subconverter_linux64.tar.gz && tar -zxvf subconverter_linux64.tar.gz && rm -f subconverter_linux64.tar.gz
systemctl daemon-reload && systemctl start sub && systemctl enable sub && systemctl status sub