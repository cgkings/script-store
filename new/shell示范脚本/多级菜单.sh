[root@web129 ~]# cat menu.sh 
#!/bin/bash
#shell菜单演示
function menu()
{
echo -e `date`
cat <<EOF
-----------------------------------
>>>菜单主页:
`echo -e "\033[35m 1)系统状态\033[0m"`
`echo -e "\033[35m 2)服务管理\033[0m"`
`echo -e "\033[35m 3)主菜单\033[0m"`
`echo -e "\033[35m Q)退出\033[0m"`
EOF
read -p "请输入对应序列号：" num1
case $num1 in
    1)
    echo -e "\033[32m >>>系统状态-> \033[0m"
    system_menu
    ;;
    2)
    echo -e "\033[32m >>>服务管理-> \033[0m"
    server_menu
    ;;
    3)
    echo -e "\033[32m >>>返回主菜单-> \033[0m"
    menu
    ;;
    Q|q)
    echo -e "\033[32m--------退出--------- \033[0m"
    exit 0
    ;;
    *)
    echo -e "\033[31m err：请输入正确的编号\033[0m"
    menu
esac
}
function system_menu()
{
cat<<EOF
------------------------
********系统状态********
------------------------
1）nginx 状态
2）http 状态
3）tomcat 状态
X）返回上一级目录
------------------------
EOF
read -p "请输入编号:" num2
case $num2 in
    1)
    `echo -e "systemctl status nginx.service"`
    system_menu
    ;;
    2)
     `echo -e "systemctl status httpd.service"`
    system_menu
    ;;
    3)
     `echo -e "systemctl status tomcat.service"`
    system_menu
    ;;
    x|X)
    echo -e "\033[32m---------返回上一级目录------->\033[0m"
    menu
    ;;
    *)
    echo -e "请输入正确编号"
    system_menu
esac
}
function server_menu()
{
cat<<EOF
------------------------
1）开启服务
2）停止服务
X）返回上一级目录
------------------------
EOF
read -p "请输入编号:" num3
case $num3 in
        1)
        op_menu
        ;;
        2)
        op_menu1
        ;;
        x|X)
        echo -e "\033[32m-- -----返回上一级目录---------> \033[0m"
        menu
        ;;
        *)
        echo -e "请输入正确编号"
        system_menu
esac
}

function op_menu()
{
cat<<EOF
------------------------
1）开启nginx服务
2）开启http服务
3）开启tomcat服务
X）返回上一级目录
------------------------
EOF
read -p "请输入编号:" num4
case $num4 in
        1)
    `echo -e "systemctl start nginx.service"`
    op_menu
        ;;
        2)
    `echo -e "systemctl start httpd.service"`
        op_menu
    ;;
    3)
    `echo -e "systemctl start tomcat.service"`
        op_menu
        ;;
        x|X)
        echo -e "\033[32m--------返回上一级目录------->\033[0m"
        server_menu
        ;;
        *)
        echo -e "请输入正确编号"
    op_menu
esac
}
function op_menu1()
{
cat<<EOF
------------------------
1）停止nginx服务
2）停止http服务
3）停止tomcat服务
X）返回上一级目录
------------------------
EOF
read -p "请输入编号:" num5
case $num5 in
        1)
        `echo -e "systemctl stop nginx.service"`
        op_menu1
        ;;
        2)
        `echo -e "systemctl stop httpd.service"`
        op_menu1
        ;;
        3)
        `echo -e "systemctl stop tomcat.service"`
        op_menu1
        ;;
        x|X)
        `echo -e "\033[32m >>>返回上一级目录---> \033[0m"`
        server_menu
        ;;
        *)
        echo -e "请输入正确编号"
        op_menu1
esac
}
menu
[root@web129 ~]# 