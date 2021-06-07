#!/bin/bash
##
##  Docker install.
##
# 为防止/data及磁盘挂载未挂载完成，先 sleep 30;
sleep 5
# prepare docker apt source
apt-get update;
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable";
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -;
apt-key fingerprint 0EBFCD88;
apt-get update;
apt-get install -y apt-transport-https ca-certificates curl software-properties-common; 
if [[ `lsb_release -a|grep Release|awk '{print $NF}'` == "20.04" ]]; then
    apt-get install -y docker-ce=5:20.10.6~3-0~ubuntu-focal;
else
    apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu;
fi
docker ps
gpasswd -a developer docker

## 关闭防火墙
ufw disable

## 用户权限设置
#gpasswd -a developer docker
#chmod a+rw /var/run/docker.sock
#systemctl restart docker

## 修改docker目录
[ -d /data/docker ] || mkdir -p /data/docker/
if [[ `docker -v| awk '{print $3}'| awk -F',' '{print $1}'` == '20.10.6' ]];then
    systemctl stop docker.socket
    systemctl stop docker
    sleep 1;
    sed -i 's#^ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock$#ExecStart=/usr/bin/dockerd -H fd:// --data-root="/data/docker/" --containerd=/run/containerd/containerd.sock#g' /lib/systemd/system/docker.service
else
    systemctl stop docker
    sleep 1;
    sed -i 's#^ExecStart=/usr/bin/dockerd -H fd://$#ExecStart=/usr/bin/dockerd -H fd:// --data-root="/data/docker/"#g' /lib/systemd/system/docker.service
fi
mv /var/lib/docker /tmp/
systemctl daemon-reload
service docker start || systemctl start docker
