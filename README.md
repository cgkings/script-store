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

### 分类转存版(转存+分类)   

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/installa.sh)"
```

### 分类转存&自动备份版（15G用户福音）

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vitaminx/gclone-assistant/master/installb.sh)"
```

3、配置参数

- 一键极速版根据提示输入“gclone配置名”和“转存到的固定地址文件夹ID”
+ 自定义目录版根据提示输入“gclone配置名”后，**在VPS上“root/AutoRclone/”路径下建立“LOG”文件夹保存日志文件否者报错**

### 使用方法：

#### 1、一键极速版

+ 输入“./gd.sh”启动脚本   
+ 按提示输入TD分享链接回车执行脚本   

#### 2、分类转存版   

+ 输入“./gda.sh”启动脚本  
+ 按提示输入“TD分享链接”回车
+ 按提示输入“分类文件夹ID”回车执行脚本   

#### 3、分类转存&自动备份版

+ 未完成
    
#### 说明：

+ 此脚本所有版本默认自动转存2遍，自动查重，虑掉100k以下的小文件，保存日志文件（需要在/root/AutoRclone路径下建立“LOG”文件夹）
+ 一键极速版可以实现批量输入链接自动下载或者下载完自动提示输入下一链接继续下载，具体方法是“gd.sh”文件最后一行代码最前面的“#”去掉即可；或者直接在vps上输入“nano /root/gd.sh”回车修改最后一行代码；
+ 此脚本实现方式比较“简单粗暴”，容易读懂容易理解，如有特殊需要，可自行修改脚本；  

#### 致谢
    感谢TG的各位大佬的无私帮助，排名不分先后
+ shine，这个脚本最初版本的作者，https : //github.com/vcfe/gdgd
+ Kali Aska，他提供了提取共享文件夹名的核心代码
+ cgking，对shine的代码进行了简化
+ 我在cgking的基础上加了分类转存，只是个搬运工，惭愧！
