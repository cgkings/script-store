# Use default SSH port 22. If you use another SSH port on your server
if [ -e "/etc/ssh/sshd_config" ];then
    [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`
    while :; do echo
        read -p "Please input SSH port(Default: $ssh_port): " SSH_PORT
        [ -z "$SSH_PORT" ] && SSH_PORT=$ssh_port
        if [ $SSH_PORT -eq 22 >/dev/null 2>&1 -o $SSH_PORT -gt 1024 >/dev/null 2>&1 -a $SSH_PORT -lt 65535 >/dev/null 2>&1 ];then
            break
        else
            echo "${CWARNING}input error! Input range: 22,1025~65534${CEND}"
        fi
    done
 
    if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "$SSH_PORT" != '22' ];then
        sed -i "s@^#Port.*@&\nPort $SSH_PORT@" /etc/ssh/sshd_config
    elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ];then
        sed -i "s@^Port.*@Port $SSH_PORT@" /etc/ssh/sshd_config
    fi
fi