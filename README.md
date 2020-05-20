<h2 align="center">gclone懒人一键转存脚本</h2> 

### 前言：<br>
已经在vps配置好gclone<hr />
### 安装步骤：<br>
step1：ssh连接vps<br>
step2：安装脚本，输入命令<br>
```
# 一键急速版
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cgkings/gclone-assistant/master/install.sh)" <br>
# 自定义目录版
npm run pack:dir <br>
# 一键急速&自动备份版（15G用户福音）
npm run pack
```
step3：根据提示填写gclone项目名称和需要转存到的固定地址ID<hr />
### 使用方法：<br>
step1：输入./gd.sh启动脚本<br>
step2：输入分享链接地址，回车即自动在先前设定好的固定地址目录里面建立一个共享文件夹同名的文件夹，并自动往该文件夹中转存文件；<br>
### 注意：<br>
此为默认自动转存2遍，然后自动查重，而且会顾虑掉10M以下的小文件，如有特殊需要，可自行使用`nao /root/gd.sh`命令修改gd.sh<br>
<hr />
感谢TG的各位大佬的无私帮助，排名不分先后<br>
shine，这个脚本最初版本的作者，https : //github.com/vcfe/gdgd<br>
Kali Aska，他提供了提取共享文件夹名的核心代码<br>
我只是个搬运工，惭愧！
