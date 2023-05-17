// Centos 8
curl -O https://raw.githubusercontent.com/duchuyta/proxy6/develop/install.sh
bash install.sh "eth0" "2600:3c01:e000:07e8::/64"


// DO
```
vi /etc/sysconfig/network-scripts/ifcfg-eth0

IPV6INIT=yes
IPV6ADDR=primary_ipv6_address/64
IPV6_DEFAULTGW=ipv6_gateway
IPV6_AUTOCONF=no
DNS1=2001:4860:4860::8844
DNS2=2001:4860:4860::8888
DNS3=209.244.0.3

sudo systemctl restart network

curl -O https://raw.githubusercontent.com/duchuyta/proxy6/develop/install_do.sh
bash install_do.sh "eth0" "2604:a880:400:d0::1a9a:900"

ping6 2001:4860:4860::8888
```