#!/bin/sh

CFG_PATH="/root/nexfi-std/config"
source $CFG_PATH/config.in

# create network configuration

if [ $TYPE = "NEXFI-PRO" ];
then

echo "# configuration for /etc/config/network

config interface 'loopback'
    option ifname 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

#config globals 'globals'
#    option ula_prefix 'fd0b:89b7:a4be::/48'

config interface 'lan'
    option ifname 'eth1'
    option force_link '1'
    option type 'bridge'
    option proto 'dhcp'
    option netmask '255.255.255.0'
    option ip6assign '60'

#config interface 'wan'
    #option ifname 'eth0'  
    #option proto 'dhcp' 

#config interface 'wan6'                               
#    option ifname '@wan'  
#    option proto 'dhcpv6'

config interface 'batnet'
    option mtu '1532'
    option proto 'batadv'
    option mesh 'bat0'
    
" > $CFG_PATH/network


# create wireless configuration  
echo "# configuraion for /ect/config/wireless

config wifi-device 'radio0'
    option type 'mac80211'
    option channel '6'
    option hwmode '11g'
    option path 'platform/ar933x_wmac'
    option htmode 'HT40'
    option txpower '30'
    option country 'US'

config wifi-iface
    option device 'radio0'
    option encryption 'none'
    option macaddr '$WMAC'
    option ssid '$MESHID'
    option mode 'adhoc'
    option ifname 'adhoc0'
    option network 'batnet'

" > $CFG_PATH/wireless
   /bin/mv $CFG_PATH/network /etc/config/
    /bin/mv $CFG_PATH/wireless /etc/config/
fi
