#!/bin/sh

######### Config Openwrt OS for nexfi ######################

echo "nexfi configuration install......."

# disable dns and firewall
/etc/init.d/firewall disable
/etc/init.d/dnsmasq disable

# openwrt start script.
rm -f /etc/rc.d/K89network
rm -f /etc/rc.d/S21nexfi

ln -s `pwd`/config/network.sh /etc/rc.d/K89network
ln -s `pwd`/config/nexfi.sh /etc/rc.d/S21nexfi

chmod +x /etc/rc.local
cp script/rc.user /etc/rc.local

# button configuration.
cp script/BTN_0 /etc/rc.button
uci add system button
uci set system.@button[-1].button=BTN_0
uci set system.@button[-1].action=released
uci set system.@button[-1].handler='/root/nexfi-std/script/channel-sw.sh'
uci set system.@button[-1].min=0
uci set system.@button[-1].max=3
uci -c /etc/config commit system

# upgrade configuration.
cp config/conf_version /root
echo "/etc/" >> /etc/sysupgrade.conf
echo "/root/" >> /etc/sysupgrade.conf
echo "0 */12 * * *       /root/nexfi-std/script/upgrade.sh" >> /etc/crontabs/root

echo "nexfi configuration installed."

reboot
