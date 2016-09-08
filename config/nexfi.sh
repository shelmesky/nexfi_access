#!/bin/sh	

SLEEP="/bin/sleep"
IFCONFIG="/sbin/ifconfig"
IW="/usr/sbin/iw"
BRCTL="/usr/sbin/brctl"

CFG_PATH="/root/nexfi-std/config"

TYPE=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].type)
MAC=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].mac)
BRMAC=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].brmac)
BSSID=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].bssid)
MESHID=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].meshid)
FREQ=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].freq)


if [ $TYPE = "NEXFI-PRO" ];
then
    $SLEEP 5
    $IFCONFIG br-lan down
    $IFCONFIG eth1 down
    $IFCONFIG adhoc0 down
    $IFCONFIG eth1 hw ether $MAC
    $IFCONFIG br-lan hw ether $BRMAC
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
    batctl dat 0
fi

$SLEEP 1
/root/nexfi-std/script/nexfi_ebtables.sh
