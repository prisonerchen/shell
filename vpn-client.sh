#!/bin/bash
#Author:ChenYang
#Date:2019-02-03

#-------------获取变量------------------------#

read -p "请输入vpn客户端公网ip地址:" PUBNET
read -p "请输入vpn客户端连接用户名:" VPNUSER
read -p "请输入vpn客户端连接用户名$VONUSER对应的密码:" VPNPASSWD

#------------软件检测-------------------------#

rpm -q ppp >/dev/null || yum -y install ppp >/dev/null && echo "安装完成软件ppp"
rpm -q pptp >/dev/null || yum -y install pptp >/dev/null && echo "安装完成软件pptp"
rpm -q pptp-setup >/dev/null || yum -y install pptp-setup >/dev/null && echo "安装完成软件pptp-setup"
sleep 2

#------------执行连接-------------------------#
echo "正在连接服务端......"
pptpsetup --create pptpd --server ${PUBNET} --username ${VPNUSER} --password ${VPNPASSWD} --encrypt --start | tail -2

ip route|grep default >/opt/default_route	#备份原默认路由表
echo "原默认路由表备份在/opt/default_route"
ip route del default	#删除默认路由

ifconfig|grep ppp0 >/dev/null && ip route add default dev ppp0

#ip route replace `cat /opt/default_route`	#还原路由表
