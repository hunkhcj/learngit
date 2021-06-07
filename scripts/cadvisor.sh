#!/bin/bash
## 
##  Cadvisor install
## 

token=$1

# 下载文件
[ -d /opt/admin/ ] || mkdir -p /opt/admin/
# wget https://github.com/google/cadvisor/releases/download/v0.34.0/cadvisor -O /usr/local/bin/cadvisor
file-ladder down -C /usr/local/bin/ ${token} -y

# 准备启动文件
cat << EOF > /etc/default/cadvisor
CADVISOR_DOCKER_ENDPOINT="unix:///var/run/docker.sock"
CADVISOR_PORT="12345"
CADVISOR_STORAGE_DRIVER=""
CADVISOR_STORAGE_DRIVER_HOST="localhost:8086"
CADVISOR_STORAGE_DRIVER_PASSWORD="root"
CADVISOR_STORAGE_DRIVER_SECURE="false"
CADVISOR_STORAGE_DRIVER_USER="root"
CADVISOR_LOG_TO_STDERR="true"
DAEMON_ARGS="--disable_metrics=tcp,udp,sched"
EOF

cat << \EOF > /lib/systemd/system/cadvisor.service
[Unit]
Description=cAdvisor
Documentation=man:cadvisor
Documentation=https://github.com/google/cadvisor
After=docker.service
 
[Service]
EnvironmentFile=/etc/default/cadvisor
ExecStart=/usr/local/bin/cadvisor \
    --docker=${CADVISOR_DOCKER_ENDPOINT} \
    --port=${CADVISOR_PORT} \
    --storage_driver=${CADVISOR_STORAGE_DRIVER} \
    --storage_driver_host=${CADVISOR_STORAGE_DRIVER_HOST} \
    --storage_driver_password=${CADVISOR_STORAGE_DRIVER_PASSWORD} \
    --storage_driver_secure=${CADVISOR_STORAGE_DRIVER_SECURE} \
    --storage_driver_user=${CADVISOR_STORAGE_DRIVER_USER} \
    --logtostderr=${CADVISOR_LOG_TO_STDERR} \
    ${DAEMON_ARGS}
[Install]
WantedBy=multi-user.target
EOF
# 赋予权限
chmod +x /usr/local/bin/cadvisor
systemctl daemon-reload
systemctl enable cadvisor.service
service cadvisor start || systemctl start cadvisor
