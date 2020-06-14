# gclone实用脚本合集

### 一键清空回收站脚本<br>
### 一键备份同步脚本<br>
### 一键自动分类整理脚本<br>
### 一键转存脚本<br>
### google drvie 15G普通用户生存手册<br>
by cgking & oneking

### 前言：
已经在vps配置好gclone<hr />
### 安装步骤：
1.ssh连接vps<br>
2.安装脚本，输入命令<br>
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cgkings/gclone-assistant/master/installt.sh)"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/cgkings/gclone-assistant/master/install.sh)"
```
3.根据提示填写以下信息：gclone项目名称///固定地址ID//固定地址所在团队盘ID//备份用团队盘ID <hr />
### 使用方法：
建议先tmux或screen建议个对话 <br>
1.输入命令启动脚本 `./gdt.sh` <br>
2.输入分享链接地址并回车，如果不需要自定义或全盘备份，这时候可以去干别的事了，后面脚本会无人值守完成转存 <br>
3.如果需要自定义转存或全盘备份，看到选项菜单请尽快按提示进行选择，因为我设置了5秒不选，自动固定地址极速转存； <hr />
### 注意：
此脚本提示的信息及功能包括：
分享链接ID/转入文件夹名称/2次转存过程/查重过程/自动比对过程
另外，所有gclone命令默认会顾虑掉10M以下的小文件，如有特殊需要，可自行使用`nao /root/gdt.sh`命令修改gdt.sh <hr />
### 致谢
感谢TG的各位大佬的无私帮助，排名不分先后<br>
shine，这个脚本最初版本的作者，https : //github.com/vcfe/gdgd<br>
Kali Aska，他提供了提取共享文件夹名的核心代码<br>
vitaminx，脚本开发路上的小伙伴，自定义gda.sh出自他手，https://github.com/vitaminx/gclone-assistant<br>
我只是个搬运工，惭愧！
