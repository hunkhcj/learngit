#!/bin/bash
## download node_exporter binary file
# cd /tmp && wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz && tar -xvzf node_exporter-0.18.1.linux-amd64.tar.gz 
# cp -a /tmp/node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/node_exporter

token=$1;
echo "Download.$token"
file-ladder down -C /usr/local/bin/ $token -y;

useradd -rs /bin/false node_exporter
## touch config file
cat << EOF > /lib/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=default.target
EOF

echo "restart node_exporter"
## start node_exporter
systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter || service node_exporter start
echo "end..."
