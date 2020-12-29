#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear

goone_ver=1.0.3
give_info="请联系作者，QQ：962310113"

export_goorg_x() {
    goPath=$(go env | grep GOPATH | awk 'BEGIN{FS="\""}{print $2}')
    mkdir $goPath &>/dev/null
    cd $goPath
    if [ $? -ne 0 ]; then
        echo -e -n "\033[01;36m没有找到 ${goPath}\033[0m"
        return
    fi
    #创建 $GOPATH/src/golang.org/x 目录
    mkdir -p src/golang.org/x
    cd src/golang.org/x
    pwd
    echo -e -n "\033[01;36m已经安装的golang.org/x package\n[0m"
    ls
    echo -e -n "\033[01;36m下面一行 for in 中包的名字您可以自己来定义[0m"
    for name in "text" "glog" "image" "perf" "snappy" "term" "sync" "winstrap" "cwg" "leveldb" "net" "build" "protobuf" "dep" "sys" "crypto" "gddo" "tools" "scratch" "proposal" "mock" "oauth2" "freetype" "debug" "mobile" "gofrontend" "lint" "appengine" "geo" "review" "arch" "vgo" "exp" "time"; do
        if [ -d "$name" ]; then
            echo -e -n "\033[01;36m ${name} 包已经存在,请使用git pull来更新源码\n[0m"
            cd ${name}
            git pull
            cd ..
        else
            git_url="https://github.com/golang/${name}.git"
            echo -e -n "\033[01;36m开始clone golang.org/x 在github.com上的镜像代码:${git_url}[0m"
            git clone "$git_url"
        fi
        pwd
    done
}

show_options() {
    printf "
#######################################################################
#       GO辅助包 V${goone_ver} for Linux, Written by Letseeqiji              #
#######################################################################
#       1-安装最新版本的golang[需要root用户];                         #
#       2-升级golang到最新版本[需要root用户];                         #
#       3-当前配置概览;                                               #
#       4-配置GOPATH[需要root用户];                                   #
#       5-安装 golang.org/x 插件;                                     #
#       6-初始化 go module;                                           #
#       7-添加 go mod replace;                                        #
#       8-卸载golang[需要root用户];                                   #
#       e-exit;                                                       #
#######################################################################
"
    echo -e -n "\033[01;36m请输入您的选择: \033[0m"
}
while
    show_options
    read -p "" choose
do
    source /etc/profile &>/dev/null
    echo -e "\n"
    case $choose in
    1)
        go version &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e -n "\033[01;36m您已经安装了go,不用再次安装\033[0m"
            echo
            echo -e -n "\033[01;36mBye ^_^ \n\033[0m"
            echo
            break
        fi

        #检查网络是否畅通
        ping www.studygolang.com -c 1 &>/dev/null
        if [ $? -ne 0 ]; then
            echo -e -n "\033[01;36m网络未能到达源码网站，请检查网络设置或打开www.studygolang.com查看网站是否正常运行\n\033[0m"
            echo -e -n "\033[01;36m如确认没有问题，${give_info}\n\033[0m"
            echo
            exit 1
        fi

        #检查用户是否是root
        if [ $(id -u) != "0" ]; then
            echo -e -n "\033[01;36mError: 当前操作需要root用户运行该脚本\n\033[0m"
            echo
            exit 1
        fi

        #验证是否安装了curl
        curl --version &>/dev/null
        if [ $? -ne 0 ]; then
            echo -e -n "\033[01;36m请首先安装curl\n\033[0m"
            echo
            exit 0
        fi

        echo -e -n "\033[01;36m当前环境允许安装，你确认要开始安装吗[y|Y]:\033[0m"
        read -n1 install_choose
        echo -e "\n"
        if [[ $install_choose == 'y' ]] || [[ $install_choose == 'Y' ]]; then
            echo -e -n "\033[01;36mOK, 请稍后，马上就好.\n\033[0m"
            echo
        else
            echo -e -n "\033[01;36m取消成功.\n\033[0m"
            echo
            exit 0
        fi

        #下载最新的go版本
        gourl=$(curl -s https://studygolang.com/dl | sed -n '/dl\/golang\/go.*\.linux-amd64\.tar\.gz/p' | sed -n '1p' | sed -n '/1/p' | awk 'BEGIN{FS="\""}{print $4}')
        goweb="https://studygolang.com"
        gourl="${goweb}${gourl}"
        #防止已经下载过
        if [ ! -f "$(ls | grep linux-amd64.tar.gz | sed -n '1p')" ]; then
            wget $gourl
            if [ $? -ne 0 ]; then
                echo -e -n "\033[01;36m获取安装包失败，${give_info}\033[0m"
                echo
                exit 1
            fi
        fi

        gosrc=$(ls | grep linux-amd64.tar.gz | sed -n '1p')

        #下载完成后解压到对应的目录
        installPath="/usr/local"
        if [[ -f "$gosrc" ]] && [[ -d "$installPath" ]] && [[ ! -d "$installPath/go" ]]; then
            tar -C /usr/local -zxvf $gosrc
            if [ $? -ne 0 ]; then
                echo -e -n "\033[01;36m解压失败，${give_info}\033[0m"
                echo
                exit 1
            fi
        fi

        # 导入环境变量
        pathFile="/etc/profile"
        if [ ! -f "$pathFile" ]; then
            echo -e -n "\033[01;36m$pathFile 文件不存在\033[0m"
            echo
            exit 1
        fi

        # 导入之前应该先判断是否已经设置过对应的值[不仅仅是etc/profile这一个配置文件] 如果设置过  提示 1-覆盖 2-跳过并手动添加
        echo 'export GOROOT=/usr/local/go' >>$pathFile
        if [ $? -ne 0 ]; then
            echo -e -n "\033[01;36m导入环境变量失败，${give_info}\033[0m"
            echo
            exit 1
        fi
        echo 'export PATH=$PATH:$GOROOT/bin' >>$pathFile
        if [ $? -ne 0 ]; then
            echo -e -n "\033[01;36m导入环境变量失败，${give_info}\033[0m"
            echo
            exit 1
        fi

        source $pathFile
        if [ $? -ne 0 ]; then
            echo -e -n "\033[01;36m导入环境变量失败，${give_info}\033[0m"
            echo
            exit 1
        fi

        #再次验证安装
        go version
        if [ $? -eq 0 ]; then
            echo -e -n "\033[01;36m您已经成功安装了go\033[0m"
            echo
        else
            echo -e -n "\033[01;36m安装失败\033[0m"
            echo
        fi
        ;;
    2)
        go version &>/dev/null
        if [ $? -ne 0 ]; then
            echo -e -n "\033[01;36m并没有检测到您安装go,请首先安装go\033[0m"
            echo
            echo -e -n "\033[01;36mBye ^_^ \n\033[0m"
            echo
            break
        fi

        echo -e -n "\033[01;36m正在检测相关的环境，请稍等...\n\033[0m"
        echo

        local_version=$(go version | tr -cd "[0-9]")
        echo -e -n "\033[01;36m您当前的版本是:${local_version}\n\033[0m"
        echo

        new_version=$(curl -s https://studygolang.com/dl | sed -n '/dl\/golang\/go.*\.linux-amd64\.tar\.gz/p' | sed -n '1p' | sed -n '/1/p' | awk 'BEGIN{FS="\""}{print $4}' | awk 'BEGIN{FS="/"}{print $4}' | tr -cd "[0-9]")
        echo -e -n "\033[01;36m最新的版本是:${new_version}\n\033[0m"
        echo

        if [ $local_version -eq $new_version ]; then
            echo -e -n "\033[01;36m您已经安装了最新版本，不用升级\033[0m"
            echo -e -n "\033[01;36mBye ^_^ \n\033[0m"
            echo
            break
        elif [ $local_version -lt $new_version ]; then
            echo -e -n "\033[01;36m升级中....\033[0m"
            echo
            break
        fi
        ;;
    3)
        go env
        ;;
    4)
        #检查用户是否是root
        if [ $(id -u) != "0" ]; then
            echo -e -n "\033[01;36mError: 当前操作需要root用户运行该脚本\n\033[0m"
            exit 1
        fi
        goPath=$(go env | grep GOPATH | awk 'BEGIN{FS="\""}{print $2}')
        echo -e -n "\033[01;36m请输入您要设定的GOPATH(默认:$goPath): \033[0m"
        read -p "" go_path

        # 导入环境变量
        pathFile="/etc/profile"
        if [ ! -f "$pathFile" ]; then
            echo -e -n "\033[01;36m$pathFile 文件不存在\033[0m"
            echo
            exit 1
        fi

        echo "export GOPATH=${goPath}" >>$pathFile
        if [ $? -ne 0 ]; then
            echo -e -n "\033[01;36m导入环境变量失败，${give_info}\033[0m"
            echo
            exit 1
        fi

        source $pathFile
        echo -e -n "\033[01;36m导入成功 \n \033[0m"
        echo
        ;;
    5)
        export_goorg_x
        echo -e -n "\033[01;36m安装完毕\n\033[0m"
        echo
        ;;
    6)
        go mod init
        ;;
    7)
        echo "开发中 马上就来 \n"
        ;;
    8)
        echo "开发中 马上就来 \n"
        ;;
    e | E)
        echo
        echo -e -n "\033[31m	Bye 亲 .\033[0m"
        echo
        exit 0
        ;;
    *)
        echo
        echo -e -n "\033[31m	亲，别逗我，请按照提示输入.\033[0m"
        echo
        ;;
    esac
done
