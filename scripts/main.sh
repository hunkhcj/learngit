#!/bin/bash
## 0. Auto config something for Jumpserver
## config hostname and ssh key.
# eg:
echo `date` >> /var/log/cloudinit-userdata.log
echo "[Info] Config for jumpserver. host_name: ${host_name}, project_name: ${project_name}" >> /var/log/cloudinit-userdata.log
opsuserfile="/etc/ssh/tap4fun_principals_opsuser"
developerfile="/etc/ssh/tap4fun_principals_developer"

# hostname
if [ ${host_name} != "" ] ; then
    hostname ${host_name}
    sed  -i "1 a127.0.0.1 ${host_name}" /etc/hosts
    echo "${host_name}" > /etc/hostname
fi

# Jumpserver
## opsuserfile
cat << EOF > $opsuserfile
tap4fun
opsuser@${project_name}
opsuser@aws.`curl http://169.254.169.254/latest/meta-data/instance-id`
EOF

## developerfile
cat << EOF > $developerfile
tap4fun
developer@${project_name}
developer@aws.`curl http://169.254.169.254/latest/meta-data/instance-id`
EOF


## iptables
apt install net-tools -y;
defaut_gw=`route -n|egrep "^0.0.0.0" | awk '{print $2}'`
project_network=`echo "$defaut_gw 255.255.248.0" | awk -F '[ .]+' 'BEGIN{OFS="."} END{print and($1,$5),and($2,$6),and($3,$7),and($4,$8)"/21"}'`
iptables -A INPUT -s $project_network -j ACCEPT
iptables -A INPUT -s 10.0.76.0/23 -j ACCEPT
iptables -A INPUT -s 10.128.50.72/32 -j ACCEPT
iptables-save > /opt/admin/iptables/iptables.rule

## file-ladder
file-ladder update

## variable for install software
architecture=`arch`
os_type=`arch`-`lsb_release --release --short`
rm ./install-software
if [ $architecture = "x86_64" ]; then
   wget https://raw.githubusercontent.com/hunkjun/learngit/master/scripts/install-software -O install-software
elif [ $architecture = "aarch64" ]; then 
   wget https://raw.githubusercontent.com/hunkjun/learngit/master/scripts/install-software -O install-software
fi 
chmod +x ./install-software
./install-software "$os_type" "$userdata_opts_str"
rm install-software


## End log
echo "[Info] Config all done." >> /var/log/cloudinit-userdata.log

# check instance init status. Write by jiayang.li
# curl https://tap4fun-sre-tools.s3-us-west-2.amazonaws.com/terraform-userdata/boot_check_validation.sh | bash
