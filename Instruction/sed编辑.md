删除每行空格；每行前添加"符号；每行末添加"符号；每行的;前添加"符号;每行的;后添加"符号;替换每行的;为4个空格
sed 's/ //g;s/^/\"/g;s/$/\"/g;s/\;/\"&/;s/\;/&\"/;s/\;/    /g' ~/.config/rclone/td_list.txt

test.txt
zhangsan=zheren,feichang,youqian
lisi=zheren,feichang,youqian
laowang=zheren,feichang,youqian
现在我们要指定删除包含字符串(lisi)这一行的字符串(feichang)
sed -r ‘s@lisi(.*)feichang(.*)@lisi\1\2@’ test.txt
sed -r ‘s@lisi(.)feichang(.)@lisi\1\2@’ test.txt