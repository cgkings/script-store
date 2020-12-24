#!/bin/bash
 
apt-get update -y
apt-get dist-upgrade -y
 
apt-get install -y nmap vim build-essential gcc  g++ netcat git curl wget  python-dev openssl  zip automake make libncurses5-dev aptitude tmux proxychains python-pip python3-pip libssl-dev tor php apache2 php-mysql php-gd php-curl default-jdk
 
 
pip install requests requests[security] BeautifulSoup4 shadowsocks dnspython
 
pip3 install requests requests[security] BeautifulSoup4
 
 
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
./msfinstall
 
cd ~
git clone https://github.com/lijiejie/subDomainsBrute
git clone https://github.com/sqlmapproject/sqlmap
git clone https://github.com/maurosoria/dirsearch
ssserver  -p 7788 -k nihaodehena -d start