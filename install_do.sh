#!/bin/sh
random() {
	tr </dev/urandom -dc A-Za-z0-9 | head -c5
	echo
}

NIC=$1
IP6=$2
GATEWAY=$3
IP4=$(curl -4 -s icanhazip.com)

install_3proxy() {
    echo "installing 3proxy"
    URL="https://github.com/3proxy/3proxy/archive/0.9.4.tar.gz"
    wget -qO- $URL | bsdtar -xvf-
    cd 3proxy-0.9.4
    make -f Makefile.Linux
    mkdir -p /usr/local/etc/3proxy/{bin,logs,stat}
    cp bin/3proxy /usr/local/etc/3proxy/bin/

    echo "* hard nofile 999999" >>  /etc/security/limits.conf
    echo "* soft nofile 999999" >>  /etc/security/limits.conf
    echo "net.ipv6.conf.$NIC.proxy_ndp=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.proxy_ndp=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.forwarding=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
    echo "net.ipv6.ip_nonlocal_bind = 1" >> /etc/sysctl.conf

    sysctl -p
    cd $WORKDIR
}

config_ipaddress() {
    cat >>/etc/sysconfig/network-scripts/ifcfg-$NIC <<EOF
IPV6INIT=yes
IPV6ADDR=${IP6}0/64
IPV6_DEFAULTGW=${GATEWAY}
IPV6_AUTOCONF=no
DNS1=2001:4860:4860::8844
DNS2=2001:4860:4860::8888
DNS3=209.244.0.3
EOF
}

gen_ifconfig() {
    cat <<EOF
ifconfig $NIC inet6 add ${IP6}1/64
ifconfig $NIC inet6 add ${IP6}2/64
ifconfig $NIC inet6 add ${IP6}3/64
ifconfig $NIC inet6 add ${IP6}4/64
ifconfig $NIC inet6 add ${IP6}5/64
ifconfig $NIC inet6 add ${IP6}6/64
ifconfig $NIC inet6 add ${IP6}7/64
ifconfig $NIC inet6 add ${IP6}8/64
ifconfig $NIC inet6 add ${IP6}9/64
ifconfig $NIC inet6 add ${IP6}a/64
ifconfig $NIC inet6 add ${IP6}b/64
ifconfig $NIC inet6 add ${IP6}c/64
ifconfig $NIC inet6 add ${IP6}d/64
ifconfig $NIC inet6 add ${IP6}e/64
ifconfig $NIC inet6 add ${IP6}f/64
EOF
}

gen_iptables() {
    cat <<EOF
iptables -I INPUT -p tcp --dport 10000  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10001  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10002  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10003  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10004  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10005  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10006  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10007  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10008  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10009  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10010  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10011  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10012  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10013  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10014  -m state --state NEW -j ACCEPT
iptables -I INPUT -p tcp --dport 10015  -m state --state NEW -j ACCEPT
EOF
}

gen_3proxy() {
    cat <<EOF
daemon
maxconn 2000
nserver 1.1.1.1
nserver 8.8.4.4
nserver 2001:4860:4860::8888
nserver 2001:4860:4860::8844
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
stacksize 6291456
flush
auth strong

users huytd:CL:ytb2023

auth strong
allow huytd
proxy -6 -n -a -p10000 -i${IP4} -e${IP6}0
proxy -6 -n -a -p10001 -i${IP4} -e${IP6}1
proxy -6 -n -a -p10002 -i${IP4} -e${IP6}2
proxy -6 -n -a -p10003 -i${IP4} -e${IP6}3
proxy -6 -n -a -p10004 -i${IP4} -e${IP6}4
proxy -6 -n -a -p10005 -i${IP4} -e${IP6}5
proxy -6 -n -a -p10006 -i${IP4} -e${IP6}6
proxy -6 -n -a -p10007 -i${IP4} -e${IP6}7
proxy -6 -n -a -p10008 -i${IP4} -e${IP6}8
proxy -6 -n -a -p10009 -i${IP4} -e${IP6}9
proxy -6 -n -a -p10010 -i${IP4} -e${IP6}a
proxy -6 -n -a -p10011 -i${IP4} -e${IP6}b
proxy -6 -n -a -p10012 -i${IP4} -e${IP6}c
proxy -6 -n -a -p10013 -i${IP4} -e${IP6}d
proxy -6 -n -a -p10014 -i${IP4} -e${IP6}e
proxy -6 -n -a -p10015 -i${IP4} -e${IP6}f
flush
EOF
}

echo "installing apps"
yum -y install gcc net-tools bsdtar zip make >/dev/null

install_3proxy

echo "working folder = /root/proxy-installer"
WORKDIR="/root/proxy-installer"
mkdir -p $WORKDIR && cd $_

config_ipaddress
gen_iptables >$WORKDIR/boot_iptables.sh
gen_ifconfig >$WORKDIR/boot_ifconfig.sh
chmod +x $WORKDIR/boot_*.sh /etc/rc.local

gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg

cat >>/etc/rc.local <<EOF
bash ${WORKDIR}/boot_iptables.sh
bash ${WORKDIR}/boot_ifconfig.sh
ulimit -n 65535
/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg &
EOF

echo "OK"