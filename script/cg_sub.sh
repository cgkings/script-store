#!/bin/bash
apt update && apt-get upgrade
apt-get install -y nodejs npm
npm install -g yarn
cd /root && git clone https://github.com/CareyWang/sub-web.git && cd sub-web && yarn install
yarn config set ignore-engines true
sed -i 's/http\:\/\/127.0.0.1:25500/https\:\/\/x-clash.gq/g' /root/sub-web/src/views/Subconverter.vue
