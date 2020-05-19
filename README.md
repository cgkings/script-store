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

step2：输入分享链接地址，回车即自动在先前设定好的固定地址目录里面建立一个共享文件夹同名的文件夹，并自动往该文件夹中转存文件；

注意：此为默认自动转存2遍，然后自动查重，而且会顾虑掉10M以下的小文件，如有特殊需要，可自行使用以下命令修改gd.sh
```
nao /root/gd.sh
```
<hr />
感谢TG的各位大佬的无私帮助，排名不分先后

shine，这个脚本最初版本的作者，https : //github.com/vcfe/gdgd

Kali Aska，他提供了提取共享文件夹名的核心代码

我只是个搬运工，惭愧！
