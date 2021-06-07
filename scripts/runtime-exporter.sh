#!/bin/bash
####2020-09-10:runtime-exporter

if [ -f "/usr/local/bin/runtime-exporter" ];
then
    rm /usr/local/bin/runtime-exporter
fi
if [[ `cat /etc/issue|grep '18.04'|wc -l` == 1 ]];
then
    cd /usr/local/bin
    file-ladder down Z2xvYmFsLzIwMjAvOS8xNC9ydW50aW1lLWV4cG9ydGVyJiYmJjE2MDAwNTkwNjE3NTAwNTE= -y
else
     cd /usr/local/bin
    file-ladder down Z2xvYmFsLzIwMjAvOS8xNC9ydW50aW1lLWV4cG9ydGVyJiYmJjE2MDAwNTkzNzQ3ODA5ODQ= -y
fi
cat << EOF > /lib/systemd/system/runtime-exporter.service
[Unit]
Description=runtime-exporter
After=docker.service

[Service]
ExecStart=/usr/local/bin/runtime-exporter
ExecReload=/bin/kill -SIGHUP $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID
[Install]
WantedBy=multi-user.target
EOF
chmod +x /usr/local/bin/runtime-exporter
systemctl daemon-reload
systemctl enable runtime-exporter.service
systemctl restart runtime-exporter
