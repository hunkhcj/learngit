#!/bin/bash

token=$1
param="$2"
system_arch=`dpkg --print-architecture`
if [ "$system_arch"  != "amd64" ]; then
  echo "Not is amd64 architecture ,don't install exporter_exporter"
  exit 1
fi
# wget -P /tmp  https://github.com/QubitProducts/exporter_exporter/releases/download/v0.4.2/expexp_0.4.2-3_amd64.deb
# dpkg -i /tmp/expexp_0.4.2-3_amd64.deb

file-ladder down -y ${token} -C /usr/local/bin/

config=/etc/exporter_exporter.yaml

expexp="modules:"
if [ `echo $param|grep -e node-exporter` ];then
    expexp=${expexp}"""
    node-exporter:
      method: http
      http:
         port: 9100
    """
fi
if [ `echo $param|grep -e cadvisor` ];then
  expexp=${expexp}"""
    cadvisor:
      method: http
      http:
         verify: false
         port: 12345
         
    runtime-exporter:
      method: http
      http:
         verify: false
         port: 12346
    """
fi

if [ `echo $param|grep -e mongodb` ];then
  expexp=${expexp}"""
    mongodb:
      method: http
      http:
         port: 9216
    """
fi

if [ `echo $param|grep -e process-exporter` ];then
  expexp=${expexp}"""
    process-exporter:
      method: http
      http:
         port: 9256
    """
fi

if [ `echo $param|grep -e log-agent` ];then
  expexp=${expexp}"""
    log-agent:
      method: http
      http:
         port: 40000
    """
fi


echo "${expexp}">${config}

cat << EOF > /lib/systemd/system/exporter_exporter.service

[Unit]
Description=prometheus exporter proxy
Requires=network.target
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/exporter_exporter -config.file /etc/exporter_exporter.yaml
Restart=always

[Install]
WantedBy=multi-user.target

EOF

systemctl start exporter_exporter
systemctl enable exporter_exporter
