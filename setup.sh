#!/bin/bash
srv=01_it
user=metahash
#use 8M for 8 GIG!!! of swap
swap=8M
files=1048576

dpkg-reconfigure tzdata
service cron restart

echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[1;31m\]\u\[\033[0;37m\]@\[\033[0;32m\]SERVER_"$srv"\[\033[0;37m\]:\w\\\$ '" | tee -a /root/.bashrc

apt-get install mc -y
apt-get install htop -y
apt-get install dnsutils -y
apt-get install host -y
apt-get update && apt-get dist-upgrade -y

adduser $user
usermod -a -G sudo $user

echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[1;37m\]\u\[\033[0;37m\]@\[\033[0;32m\]SERVER_"$srv"\[\033[0;37m\]:\w\\\$ '" | tee -a /home/$user/.bashrc

echo ""
echo "*************************************************** SWAP CREATING, please wait... ***************************************************"
echo ""
dd if=/dev/zero of=/swap bs=1024 count=$swap
mkswap /swap
swapon /swap
echo "/swap swap swap defaults 0 0" | sudo tee -a /etc/fstab

echo ""
echo "*************************************************** SYSCTL EDIT ***************************************************"
echo ""

echo "net.ipv4.conf.all.accept_redirects = 0" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.secure_redirects = 0" | tee -a /etc/sysctl.conf

echo "net.ipv4.conf.all.send_redirects = 0" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" | tee -a /etc/sysctl.conf

echo "net.ipv4.conf.all.rp_filter = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 1" | tee -a /etc/sysctl.conf

echo "net.ipv4.conf.all.accept_source_route = 0" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" | tee -a /etc/sysctl.conf

echo "net.ipv4.ip_local_port_range = 1024 65535" | tee -a /etc/sysctl.conf
echo "net.ipv4.ip_forward = 0" | tee -a /etc/sysctl.conf

echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" | tee -a /etc/sysctl.conf


echo "net.ipv4.tcp_mem = 2097152 4194304 8388608" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 8192 65536 16777216" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 8192 65536 16777216" | tee -a /etc/sysctl.conf

echo "net.core.rmem_default = 65536" | tee -a /etc/sysctl.conf
echo "net.core.wmem_default = 65536" | tee -a /etc/sysctl.conf
echo "net.core.rmem_max = 16777216" | tee -a /etc/sysctl.conf
echo "net.core.wmem_max = 16777216" | tee -a /etc/sysctl.conf

echo "net.ipv4.tcp_window_scaling = 1" | tee -a /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 32768" | tee -a /etc/sysctl.conf
echo "net.core.somaxconn = 262144" | tee -a /etc/sysctl.conf

echo "net.ipv4.tcp_syncookies = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 262144" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_synack_retries = 1" | tee -a /etc/sysctl.conf

echo "net.ipv4.tcp_timestamps = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 10" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_no_metrics_save = 1" | tee -a /etc/sysctl.conf

echo "net.ipv4.tcp_sack = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_rfc1337 = 1" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = htcp" | tee -a /etc/sysctl.conf

echo "net.ipv4.tcp_orphan_retries = 0" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_max_orphans = 65536" | tee -a /etc/sysctl.conf

echo "vm.swappiness = 10" | tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure = 1000" | tee -a /etc/sysctl.conf
echo "vm.dirty_ratio = 60" | tee -a /etc/sysctl.conf
echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.conf

echo "kernel.randomize_va_space = 2" | tee -a /etc/sysctl.conf
echo "kernel.msgmnb = 65536" | tee -a /etc/sysctl.conf
echo "kernel.msgmax = 65536" | tee -a /etc/sysctl.conf
echo "kernel.msgmni = 1024" | tee -a /etc/sysctl.conf
echo "kernel.shmmax = 68719476736" | tee -a /etc/sysctl.conf
echo "kernel.shmall = 4294967296" | tee -a /etc/sysctl.conf

echo fs.file-max = $files | tee -a /etc/sysctl.conf

sysctl -p

echo ""
echo "*************************************************** PRELINK & PRELOAD ***************************************************"
echo ""
apt-get -y install prelink
nano /etc/default/prelink
/etc/cron.daily/prelink
apt-get -y install preload

echo ""
echo "*************************************************** LIMITS EDIT ***************************************************"
echo ""
echo root soft nproc 65000 | tee -a /etc/security/limits.conf
echo "*" soft nproc 65000 | tee -a /etc/security/limits.conf
echo root hard nproc 65000 | tee -a /etc/security/limits.conf
echo "*" hard nproc 65000 | tee -a /etc/security/limits.conf
echo root - nofile $files | tee -a /etc/security/limits.conf
echo "*" - nofile $files | tee -a /etc/security/limits.conf
echo root - memlock unlimited | tee -a /etc/security/limits.conf
echo "*" - memlock unlimited | tee -a /etc/security/limits.conf

echo "session required pam_limits.so" | tee -a /etc/pam.d/common-session

echo ""
echo "*************************************************** SSHD EDIT ***************************************************"
echo ""
echo "AddressFamily inet" | tee -a /etc/ssh/sshd_config
echo AllowUsers $user | tee -a /etc/ssh/sshd_config

nano /etc/ssh/sshd_config

/etc/init.d/ssh restart

echo ""
echo "*************************************************** MEMORY ***************************************************"
echo ""
free

echo ""
echo "*************************************************** DISK SPACE ***************************************************"
echo ""
df -h

rm -rf /root/setup.sh

echo ""
echo NOW YOU MUST LOGIN UNDER $user !!!!!!! DO NOT CLOSE THIS SESSION BEFORE LOGIN UNDER $user and sussess sudo su !!!!!
