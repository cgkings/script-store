# 实用脚本合集

### VPS一键脚本【测试中】
```
apt-get install curl -y && bash <(curl -sL git.io/cg_toolbox)
```
[说明]()
### BBR加速一键脚本【转自HJM】
```
bash <(curl -sL git.io/cg_bbr)
```

### swap一键脚本
```
bash <(curl -sL git.io/cg_swap) [参数]
```
**[用法]**<br>
*无参数进入主菜单*<br>
*`a` 自动添加swap*<br>
*`m` 手动添加swap*<br>
*`d` 删除现有swap*<br>
*`h` 脚本参数帮助*<br>
[说明](github.com/cgkings/script-store/blob/master/Instruction/swap.md)

### v2ray一键脚本【转自boy233】
```
bash <(curl -sL git.io/cg_v2ray)
```
[说明](github.com/cgkings/v2ray/blob/master/README.md)

### 离线下载一键脚本【 aira2 & flexget & rsshub & youtube-dl 】
```
bash <(curl -sL git.io/cg_toolbox)
```
[说明]()
### 影片整理一键脚本【 rclone & fclone 】
```
bash <(curl -sL git.io/cg_sort.sh)
```
**[用法]**<br>
  `bash <(curl -sL git.io/cg_sort.sh) [flags 1]`
  *注1：无参数则进入帮助信息*<br>
   注2：条件整理，需要根目录下为单文件，否则需要修改脚本内，条件移动--include "\*/" <br>

*可用参数(Available flags)：*<br>
  *S  提取单文件到当前要整理的文件夹根目录下；*<br>
  *Z  step1:提取单文件到当前要整理的文件夹根目录下；*<br>
     *step2:移动中文字幕到c_forder参数文件夹下；*<br>
     *step3:按照FC2,素人，有码，无码分别移至相应参数设置下；*<br>
  *C  自定义模式：可自行修改脚本，添加自己需要的功能模块；*<br>

### 转存备份一键脚本【 google drive & 6pan 】【未完成】
```
bash <(curl -sL git.io/cg_fqcopy)
```
[说明]()

### 一键挂载脚本
```
bash <(curl -sL git.io/cg_mount.sh) [flags1] [flags2] [flags3] [flags4]
```
**[用法]**<br>
*注意：无参数则进入主菜单,使用命令参数直接创建挂载，参数不够4个进入帮助!!*<br>

*[flags1]可用参数(Available flags)：*<br>
*`L`  临时创建挂载*<br>
*`S`  服务创建挂载*<br>
*`D`  删除挂载*<br>
*`h`  命令帮助* <br>  

*[flags2]可用参数(Available flags)：*<br>
*flags2 为需要创建挂载的remote名称，可查阅~/.config/rclone/rclone.conf*<br>

*[flags3]可用参数(Available flags)：*<br>
*flags3 为挂载盘或文件夹的ID（网盘ID）*<br>

*[flags4]可用参数(Available flags)：*<br>
*flags4 为挂载路径（本地路径）*<br>
  
*例如：*<br>
`bash <(curl -sL git.io/cg_mount.sh) L remote 0AAa0DHcTPGi9Uk9PVA /mnt/gd`

### 影片媒体库脚本【刮削、EMBY】
```
bash <(curl -sL git.io/cg_emby)
```
