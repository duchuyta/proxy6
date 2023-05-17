// Centos 8
curl -O https://raw.githubusercontent.com/duchuyta/proxy6/develop/install.sh
bash install.sh "eth0" "2600:3c01:e000:07e8::/64"


// Centos7

```
yum install wget
vi /etc/sysconfig/network-scripts/ifcfg-eth0

IPV6INIT=yes
IPV6ADDR=2604:a880:400:d0::22d3:7000/64
IPV6_DEFAULTGW=2604:a880:400:d0::1
IPV6_AUTOCONF=no
DNS1=2001:4860:4860::8844
DNS2=2001:4860:4860::8888
DNS3=209.244.0.3

sudo systemctl restart network

/usr/local/etc/3proxy/3proxy.cfg
```


// DO - Centos8
```
yum install iptables wget net-tools

vi /etc/sysconfig/network-scripts/ifcfg-eth0

IPV6INIT=yes
IPV6ADDR=2604:a880:400:d0::1d6c:e000/64
IPV6_DEFAULTGW=2604:a880:400:d0::1
IPV6_AUTOCONF=no
DNS1=2001:4860:4860::8844
DNS2=2001:4860:4860::8888
DNS3=209.244.0.3

sudo systemctl restart NetworkManager.service
reboot

curl -O https://raw.githubusercontent.com/duchuyta/proxy6/develop/install_do.sh
bash install_do.sh "eth0" "2604:a880:400:d0::1d6c:e00"

ping6 2001:4860:4860::8888
```