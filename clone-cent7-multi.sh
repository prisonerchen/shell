#!/bin/bash
clear

##声明环境变量###################################################################

MOUNT_DIR=/mnt/vmdir			#虚拟机镜像挂载目录
IMG_DIR=/var/lib/libvirt/images	#虚拟机镜像存放目录

##动态效果模块#################################################################

array_stdout(){
	array=("|" "/" "-" "\\")
	a=0
  	while [ $(cat /opt/vmarray) == 1 ]	#触发条件
	do
		let a%=4	#a等于除以4后的余数，即0-3,4个数字，对应array变量的4个数组
		echo -ne "[${array[a]}]\b\b\b"	#-n不换行输出，\b退格输出
		let a+=1
		sleep 0.3
	done &
}

##创建虚拟机主要函数块############################################################
#vmname 虚拟机名
#vmmem 虚拟机内存G
#vmip 虚拟机IP


create_vmhosts(){			#创建虚拟机函数


if [ -e $IMG_DIR/${vmname}.img ];then	 #判断镜像是否存在
	echo "镜像已经存在！"
	exit 1
fi

qemu-img create -f qcow2 -b $IMG_DIR/cent7.img $IMG_DIR/${vmname}.img 100G &> /dev/null
cp /root/node.xml /opt/
sed -i "s/node/${vmname}/" /opt/node.xml


echo "1" >/opt/vmarray	#触发动态模块条件
echo -ne "正在配置虚拟机\e[31;1m${vmname}\e[0m，请稍后......"
array_stdout	


vmmem=${vmmem:-2}
vmmem=$[vmmem*1024*1024]
sed -i "s/2097152/${vmmem}/" /opt/node.xml &>/dev/null
virsh define /opt/node.xml &>/dev/null	#创建虚拟机


mkdir $MOUNT_DIR &>/dev/null	#创建虚拟机挂载目录
guestmount -a $IMG_DIR/${vmname}.img -i $MOUNT_DIR	#将创建的镜像挂载到本地/mnt/vmdir目录

echo "0" >/opt/vmarray	#关闭动态模块条件
echo

vmip=${vmip:-192.168.1.1}
sed -i "/IPADDR/s/192.168.1.1/$vmip/" $MOUNT_DIR/etc/sysconfig/network-scripts/ifcfg-eth0	#修改虚拟机IP地址
echo "$vmname" >$MOUNT_DIR/etc/hostname	#给虚拟机定义主机名

echo "$vmip $vmname" >>$MOUNT_DIR/etc/hosts	#写入虚拟机本机解析地址

grep "$vmip" /etc/hosts >/dev/null #如果之前有该IP的地址的域名解析则删除
if [ $? -eq 0 ]; then	
	sed -i "/$vmip/d" /etc/hosts
fi

echo "$vmip $vmname" >>/etc/hosts	#写入宿主机本机解析地址

mkdir $MOUNT_DIR/root/.ssh/
touch $MOUNT_DIR/root/.ssh/authorized_keys
cat /root/.ssh/id_rsa.pub >> $MOUNT_DIR/root/.ssh/authorized_keys #给虚拟机增加免密

umount $MOUNT_DIR
rm -rf $MOUNT_DIR

echo -e "IP地址为\e[31;1;5m${vmip}\e[0m的虚拟机\e[31;1;5m${vmname}\e[0m已经创建成功"
sleep 0.5
echo -e "\e[37;40m是否启动虚拟机 \e[1;31;40my/n\e[0m"
read start
start=${start:-y}
if [ $start == y ];then
	virsh start ${vmname} >/dev/null
	sleep 0.5
	echo -e "已经为您启动虚拟机\e[31;1m${vmname}\e[0m，谢谢使用！"
	echo
else
	sleep 0.5
	echo -e "未启动虚拟机\e[31;1m${vmname}\e[0m，如需使用请手动开启！"
	echo
fi
}

##收集创建虚拟机信息############################################################
echo -e "\e[37;40m请输入您需要创建的虚拟机的 \e[1;31;40m数量\e[0m"
read number

if [ -f /opt/vmcontent ];then
	rm -rf /opt/vmcontent
fi

for i in $(seq $number)
do 
echo -e "\e[37;40m请依次输入您创建虚拟机的 \e[1;31;40m名称\e[37;40m \e[1;31;40mIP地址\e[37;40m \e[1;31;40m内存大小\e[0m
\e[34m例如：name 192.168.1.1 4\e[0m" 
	read  vmname_ip_mem
	touch /opt/vmcontent
	echo ${vmname_ip_mem} >>/opt/vmcontent
done

##安装收集的信息过滤创建虚拟机###################################################
count=0
for i in $(seq ${number})
do 
	let count++
	vmname=$(sed -n "${count}p" /opt/vmcontent | awk '{print $1}')
	vmip=$(sed -n "${count}p" /opt/vmcontent | awk '{print $2}')
	vmmem=$(sed -n "${count}p" /opt/vmcontent | awk '{print $3}')
	create_vmhosts
done


rm -rf /opt/vmcontent	#清除虚拟机信息文本
rm -rf /opt/vmarray		#清除动态模块信息文本

############################################################################
#vmname 虚拟机名
#vmmem 虚拟机内存G
#vmip 虚拟机IP
#编码 颜色/动作
#0 重新设置属性到缺省设置
#1 设置粗体
#2 设置一半亮度（模拟彩色显示器的颜色）
#3 设置倾斜
#4 设置下划线（模拟彩色显示器的颜色）
#5 设置闪烁
#7 设置反向图象
#22 设置一般密度
#24 关闭下划线
#25 关闭闪烁
#27 关闭反向图象
#30 设置黑色前景
#31 设置红色前景
#32 设置绿色前景
#33 设置棕色前景
#34 设置蓝色前景
#35 设置紫色前景
#36 设置青色前景
#37 设置白色前景
#38 在缺省的前景颜色上设置下划线
#39 在缺省的前景颜色上关闭下划线
#40 设置黑色背景
#41 设置红色背景
#42 设置绿色背景
#43 设置棕色背景
#44 设置蓝色背景
#45 设置紫色背景
#46 设置青色背景
#47 设置白色背景
#49 设置缺省黑色背景
