# 实用脚本合集

### VPS一键脚本【测试中】
```
apt-get install curl -y && bash <(curl -sL git.io/cg_toolbox)
```
[说明]()
### BBR加速一键脚本【转自未知】
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
### 网盘整理一键脚本【 rclone & fclone 】【未完成】
```
bash <(curl -sL git.io/cg_sort.sh)
```
[说明]()
### 转存备份一键脚本【 google drive & 6pan 】【未完成】
```
bash <(curl -sL git.io/cg_fqcopy)
```
[说明]()

### 挂载脚本【小组件】【 google drive & 6pan 】
```
bash <(curl -sL git.io/cg_auto_mount) [flags1] [flags2] [flags3] [flags4]
```
**[用法]**<br>
*注意：无参数则进入主菜单,参数少于3个显示help，即1,2,3为脚本参数执行方式必备!*<br>
*[flags1]可用参数(Available flags)：*<br>
*`L1` `L2` `L3`  临时创建挂载(1,2,3代表挂载方案)*<br>
*`S1` `S2` `S3`  服务创建挂载(1,2,3代表挂载方案)*<br>
*`D`             删除挂载*<br>
*`h`             命令帮助* <br>

*[flags1]可用参数(Available flags)：*<br>
`bash <(curl -sL https://git.io/cg_auto_mount) L1,2,3` 临时创建挂载(1,2,3代表挂载方案) <br>
`bash <(curl -sL https://git.io/cg_auto_mount) S1,2,3` 服务创建挂载(1,2,3代表挂载方案) <br>
`bash <(curl -sL https://git.io/cg_auto_mount) D` 删除挂载<br>
`bash <(curl -sL https://git.io/cg_auto_mount) H` 命令帮助<br>
  
*[flags2]可用参数(Available flags)：*<br>
*flags2 为需要创建挂载的remote名称，可查阅~/.config/rclone/rclone.conf*<br>

*[flags3]可用参数(Available flags)：*<br>
*flags3 为挂载盘或文件夹的ID*<br>

*[flags4]可用参数(Available flags)：*<br>
*flags4 为挂载路径*<br>
  
*例如：*<br>
`bash <(curl -sL https://git.io/cg_auto_mount) l1 remote 0AAa0DHcTPGi9Uk9PVA /mnt/gd`

### 影片媒体库脚本【刮削、EMBY、Jellyfin】【转自TG why大佬】
```
bash <(curl -sL git.io/11plus.sh)
```

我只是个搬运工！
