#!/usr/bin/env bash
# cleanremotes现在接受命令行过滤。例如`./cleanremotes cgking`将
# 仅清理remotes列表中名叫`cgking`
# cleanremotes也支持rclone flags
# 用法: ./cleanremotes cgking --flag1 --flag2

filter="$1"
shift
rc_flags="$@"
# 本机remotes账号列表 | 筛选出filter变量
fmod listremotes | grep "$filter"

readarray mounts < <( fmod listremotes | grep "$filter" )
for i in ${mounts[@]}; do
  echo; echo "从'$i'账户开始删除相同文件"; echo
  fmod dedupe skip $i -v --drive-use-trash=false --no-traverse --transfers=256 $rc_flags
  echo; echo "从'$i'账户开始删除空目录"; echo
  fmod rmdirs $i -v --drive-use-trash=false --fast-list --transfers=256 $rc_flags
  echo; echo "从'$i'账户永久清空垃圾桶"; echo
  fmod delete $i --fast-list --drive-trashed-only --drive-use-trash=false -v --transfers 256 $rc_flags
  fmod cleanup $i -v $rc_flags
done
