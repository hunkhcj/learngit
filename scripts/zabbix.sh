#!/bin/bash

echo "install zabbix-agent start ...." >> /var/log/cloudinit-userdata.log

token=$1
rm -rf ~/.file-ladder/download/${token} || echo "delete ~/.file-ladder/download/${token} failed"
file-ladder down ${token}


tar -zxf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4

apt-get update
apt-get -y install libpcre3
apt-get -y install libpcre3-dev 

./configure --disable-static --prefix=/usr --sysconfdir=/etc/zabbix --runstatedir=/var/run --enable-agent && make && make install

cat > /etc/zabbix/zabbix_agentd.conf << EOF
PidFile=/var/run/zabbix_agentd.pid
LogFile=/var/log/zabbix_agentd.log
EnableRemoteCommands=1
Server=zabbix-server.internal.tap4fun.com,0.0.0.0/0
ServerActive=zabbix-server.internal.tap4fun.com
AllowRoot=1
Include=/etc/zabbix/app.d
Include=/etc/zabbix/zabbix.d
EOF

mkdir -p /etc/zabbix/app.d
cp -a ./files/zabbix.d  /etc/zabbix/
cp -a ./files/zabbix-agent.service /lib/systemd/system/zabbix-agent.service  
cp -a ./files/zabbix-agent /etc/init.d/zabbix-agent
chmod 755 /etc/init.d/zabbix-agent

echo 'service zabbix-agent start' >> /etc/rc.local

systemctl daemon-reload
service zabbix-agent start || systemctl start zabbix-agent
systemctl enable zabbix-agent

cd - 
rm -rf zabbix-3.4.4 zabbix-3.4.4.tar.gz

echo "install zabbix-agent end ...." >> /var/log/cloudinit-userdata.log
