#!/bin/sh

######### Config Openwrt OS for nexfi ######################

echo "nexfi configuration install......."

/etc/init.d/firewall disable
/etc/init.d/dnsmasq disable

rm -f /etc/rc.d/K89network
rm -f /etc/rc.d/S21nexfi

ln -s `pwd`/config/network.sh /etc/rc.d/K89network
ln -s `pwd`/config/nexfi.sh /etc/rc.d/S21nexfi

chmod +x /etc/rc.local
cp script/rc.user /etc/rc.local
cp config/conf_version /root

echo "/etc/" >> /etc/sysupgrade.conf
echo "/root/" >> /etc/sysupgrade.conf


echo "0 */12 * * *       /root/nexfi-std/script/upgrade.sh" >> /etc/crontabs/root

echo "nexfi configuration installed."

reboot
