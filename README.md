# gclone懒人一键转存脚本

前言：

已经在vps配置好gclone
<hr />
安装步骤：

step1：ssh连接vps

step2：安装脚本，输入命令
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cgkings/gclone-assistant/master/install.sh)"
```
step3：根据提示填写gclone项目名称和需要转存到的固定地址ID
<hr />
使用方法：

step1：输入./gd.sh启动脚本

step2：输入分享链接地址，回车即自动在先前设定好的固定地址目录里面建立一个以分享ID为名的文件夹，并自动往该文件夹中转存文件；
<hr />
原作者：https : //github.com/vcfe/gdgd
