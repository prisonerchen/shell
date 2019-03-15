#!/bin/bash
#Author:ChenYang
#Date:2019-02-03
#------------变量可调整区-------------------#

VPNUSER=cy	#vpn客户端连接的用户名
VPNPASSWD=123456	#vpn客户端连接用户对应的密码
IPPOOL="192.168.100.100-200"	#分配给vpn客户端的IP地址池

#------------变量非调整区-------------------#

NETSEGMENT="${IPPOOL%.*}.0/24"	#VPN客户端地址池网段
LOCALIP=$(ifconfig eth0|awk '/inet /{print $2}') #服务端本机IP
#------------程序执行区---------------------#

echo "正在安装服务端软件......"
rpm -q pptpd >/dev/null || yum install -y pptpd >/dev/null

sed -i "\$a\localip $LOCALIP" /etc/pptpd.conf 
sed -i "\$a\remoteip $IPPOOL" /etc/pptpd.conf
sed -i "/^#ms-dns 10.0.0.2/a\ms-dns 8.8.8.8" /etc/ppp/options.pptpd
sed -i "\$a${VPNUSER} * ${VPNPASSWD} *" /etc/ppp/chap-secrets 

echo "正在启动服务pptpd......"
systemctl start pptpd
sleep 1
PPTPDSTATUS=$(systemctl status pptpd|awk '/Active/{print $2}') #服务状态
sleep 0.5

echo "正在开启路由转发功能......"
sysctl -w net.ipv4.ip_forward=1 >/dev/null
echo 1 >/proc/sys/net/ipv4/ip_forward
sleep 0.5

echo "正在修改防火墙伪装策略......"
iptables -t nat -A POSTROUTING -s $NETSEGMENT -j MASQUERADE
sleep 0.5

echo -e "pptpd服务状态为:\e[31;1m$PPTPDSTATUS\e[0m"
echo -e "vpn客户端分配地址池为:\e[31;1m$IPPOOL\e[0m"
echo -e "vpn客户端登录用户为:\e[31;1m$VPNUSER\e[0m 密码为:\e[31;1m$VPNPASSWD\e[0m"
echo -e "可使用\e[31;1mvpnuser add <username> <passwd>\e[0m创建多名登录用户"
