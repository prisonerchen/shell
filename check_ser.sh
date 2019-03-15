#!/bin/bash
server_state=$(nmap -n -sT $1 -p $2 |sed -n '6p'|awk -F 'END{print $2}')
echo "$1主机的$2端口服务状态为$server_state"
