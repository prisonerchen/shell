#!/bin/bash
while inotifywait -rqq /opt
do
rsync --delete -az /opt/ root@192.168.4.207:/opt/
done &
