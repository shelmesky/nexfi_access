#!/bin/sh	

CFG_PATH="/root/nexfi-std/config"
source $CFG_PATH/config.in

SLEEP="/bin/sleep"
IFCONFIG="/sbin/ifconfig"
IW="/usr/sbin/iw"
BRCTL="/usr/sbin/brctl"

if [ $TYPE = "NEXFI-PRO" ];
then
    $SLEEP 5
    $IFCONFIG br-lan down
    $IFCONFIG eth1 down
    $IFCONFIG adhoc0 down
    $IFCONFIG eth1 hw ether $MAC
    $IFCONFIG br-lan hw ether $MAC
    $IFCONFIG eth1 up
    $IFCONFIG adhoc0 up
    $SLEEP 2
    $IW dev adhoc0 set type ibss
    $IW dev adhoc0 ibss leave
    $IW dev adhoc0 ibss join $MESHID $FREQ HT20 fixed-freq $BSSID
    $SLEEP 5
    $IFCONFIG bat0 up
    $IFCONFIG br-lan up
    $BRCTL addif br-lan bat0
fi
