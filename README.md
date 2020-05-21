# GD分享链接转存脚本

## 前言：
已经在VPS配置好gclone

## 安装步骤：

1、ssh连接vps
2、安装脚本，输入命令

### 一键急速版

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/install.sh)"
```

### 自定义目录版(转存+分类)   

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/installa.sh)"
```

### 一键急速&自动备份版（15G用户福音）

未完成

3、根据提示填写gclone项目名称和需要转存到的固定地址ID

### 使用方法：

1、输入命令启动脚本

    一键急速版: ./gd.sh
    自定义目录版: ./gda.sh
    一键急速&自动备份版: 未完成
    2、输入分享链接地址，回车即自动在先前设定好的固定地址目录里面建立一个共享文件夹同名的文件夹，并自动往该文件夹中转存文件；

注意：

此为默认自动转存2遍，然后自动查重，而且会顾虑掉100K以下的小文件，如有特殊需要，可自行使用nao /root/gd.sh命令修改gd.sh

致谢

感谢TG的各位大佬的无私帮助，排名不分先后
shine，这个脚本最初版本的作者，https : //github.com/vcfe/gdgd
Kali Aska，他提供了提取共享文件夹名的核心代码
我只是个搬运工，惭愧！
