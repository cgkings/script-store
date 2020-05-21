# TD分享链接一键转存脚本

前言：已经在vps配置好gclone
<hr />
##  快速分类转存版：
安装时设置好固定转存目录，使用就可以一键转存不需要任何设置！

安装步骤：

step1：ssh连接vps

step2：安装脚本，输入命令
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/install.sh)"
```
step3：根据提示填写gclone项目名称和需要转存到的固定地址ID
<hr />
使用方法：

step1：输入./gd.sh启动脚本

step2：输入分享链接地址，回车即自动在先前设定好的固定地址目录里面建立一个共享文件夹同名的文件夹，并自动往该文件夹中转存文件；

注意：    
1、此为默认自动转存2遍，然后自动查重，虑掉100k以下的小文件，保存日志文件（需要在/root/AutoRclone路径下建立“LOG”文件夹）   
2、入想实现批量输入链接自动下载或者下载完自动提示输入下一链接继续下载，请把“gd.sh”文件最后一行代码最前面的“#”去掉即可；或者直接在vps上输入“nano /root/gd.sh”回车修改最后一行代码；   
3、如有特殊需要，可自行使用以下命令修改gd.sh   
```
nano /root/gd.sh
```
<hr />
## 简单分类版：    
配合FinalShell或Termius的快捷命令，可以实现简单的

安装步骤：

step1：ssh连接vps

step2：安装脚本，输入命令
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/installa.sh)"
```
step3：根据提示填写gclone项目名称
<hr />
使用方法：

step1：输入./gda.sh启动脚本

step2：输入分享链接地址，回车   

step3：输入分类文件夹ID，回车即自动在该分类文件夹里面建立一个共享文件夹同名的文件夹，并自动往该文件夹中转存文件；

注意：    
1、此为默认自动转存2遍，然后自动查重，虑掉100k以下的小文件，保存日志文件（需要在/root/AutoRclone路径下建立“LOG”文件夹）   
2、入想实现批量输入链接自动下载或者下载完自动提示输入下一链接继续下载，请把“gda.sh”文件最后一行代码最前面的“#”去掉即可；或者直接在vps上输入“nano /root/gda.sh”回车修改最后一行代码；   
3、如有特殊需要，可自行使用以下命令修改gda.sh   
```
nano /root/gda.sh
```
<hr />
感谢TG的各位大佬的无私帮助，排名不分先后

shine，这个脚本最初版本的作者，https : //github.com/vcfe/gdgd

Kali Aska，他提供了提取共享文件夹名的核心代码

CG 修改了shine的代码

我只是个搬运工，惭愧！
