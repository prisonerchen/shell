#!/bin/bash
DIR=/usr/local/nginx/logs/access.log

#统计独立IP数
echo "独立IP数量为：$(awk '{print $1}' $DIR |sort -r|uniq -c|wc -l)"
#统计总PV量
echo "总PV量为：$(awk '{print $7}' $DIR |wc -l)"
#统计总UV量
echo "总UV量为：$(awk '{print $11}' $DIR |sort -r|uniq -c|wc -l)"
#统计访问量前20名IP列表及访问次数
echo -e "访问量前20的IP列表：\n$(awk '{print $1}' $DIR|sort|uniq -c|sort -nr|head -20)"
#统计时间段的总请求量
#ST=2019:09:00
#ET=2019:22:00
#echo "上午${ST#*:}到${ET#*:}的总请求量为：$(sed -n "/$ST/,/$ET/"p $DIR)" 

#分析访问日志状态码等错误页面次数较多的IP地址
#awk '{if ($9~/500|502|503|404/) print $1,$9}' $DIR|sort|uniq -c|sort -nr|awk '{if ($1 > 20) print $2}'

echo "统计访问页面最多的前20个页面："
awk '{print $7}' $DIR|sort|uniq -c|sort -nr|head -20

#echo "请求处理时间大于5s的URL，及访问IP"
#awk '{if ($NF >5) print $NF,$7,$1}' $DIR |sort -nr|more

