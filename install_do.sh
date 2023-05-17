#!/bin/sh
random() {
	tr </dev/urandom -dc A-Za-z0-9 | head -c5
	echo
}

NIC=$1

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
    # systemctl stop firewalld
    # systemctl disable firewalld

    cd $WORKDIR
}

echo "installing apps"
yum -y install gcc net-tools bsdtar zip make >/dev/null

install_3proxy

echo "working folder = /root/proxy-installer"
WORKDIR="/root/proxy-installer"
mkdir $WORKDIR && cd $_
