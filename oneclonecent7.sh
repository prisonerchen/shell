#!/bin/bash
IMG_DIR=/var/lib/libvirt/images
BASEVM=cent7

read -p "Enter VM Numbser:" VMNUM
if [ $VMNUM -le 9 ];then
VMNUM=0$VMNUM
fi

if [ -z $VMNUM ];then
	echo "You must input a number."
	exit 1
elif [ $VMNUM -eq 0 ];then
	echo "You must input a number"
	exit 2
elif [ $VMNUM -lt 1 -o $VMNUM -gt 99 ];then
	echo "Input out of range"
	eixt 3
fi

NEWVM=centos$VMNUM

if [ -e $IMG_DIR/${NEWVM}.img ];then	 #判断镜像是否存在
	echo "File exists."
	exit 4
fi

echo -en "Creating Virtual Machine disk image......\t"
qemu-img create -f qcow2 -b $IMG_DIR/${BASEVM}.img $IMG_DIR/${NEWVM}.img &> /dev/null
echo -e "\e[32;1m[OK]\e[0m"

cat /var/lib/libvirt/images/cent7.xml > /tmp/myvm.xml
sed -i "/<name>${BASEVM}/s/${BASEVM}/${NEWVM}/" /tmp/myvm.xml
#更改虚拟机名
sed -i "/${BASEVM}\.img/s/${BASEVM}/${NEWVM}/" /tmp/myvm.xml
#更改前端文件名

echo -en "Defining new virtual machine......\t\t"
virsh define /tmp/myvm.xml &> /dev/null	#用xml文件生成新的虚拟机
echo -e "\e[32;1m[OK]\e[0m"

