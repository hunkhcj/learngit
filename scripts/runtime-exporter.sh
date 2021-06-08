#!/bin/bash
####2020-09-10:runtime-exporter

rm -rf ~/.file-ladder/download/${token} || echo "delete ~/.file-ladder/download/${token} failed"
file-ladder down -C /usr/local/bin/ $token -y;

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
