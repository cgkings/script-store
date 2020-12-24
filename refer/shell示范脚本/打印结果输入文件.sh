#!/bin/bash
# 覆盖写入,终端不显示
echo "日志内容"  > /root/日志.txt
# 覆盖写入,终端显示
echo "日志内容" | tee /root/日志.txt
# 追加写入,终端不显示
echo "日志内容" >> /root/日志.txt
# 追加写入,终端显示
echo "日志内容" | tee -a /root/日志.txt