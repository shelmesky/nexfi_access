#!/bin/sh

RM="/bin/rm"
KILLALL="/usr/bin/killall"
SLEEP="/bin/sleep"
IFCONFIG="/sbin/ifconfig"
IW="/usr/sbin/iw"
BRCTL="/usr/sbin/brctl"

CFG_PATH="/root/nexfi-std/config"
TYPE=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].type)
WMAC=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].wmac)
MAC=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].mac)
BSSID=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].bssid)
MESHID=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].meshid)
FREQ=$(uci -c $CFG_PATH get netconfig.@adhoc[-1].freq)

# channel six
CHANNEL_FREQ="2447"

get_channel_freq()
{
    return $(iw dev adhoc0 info | grep channel | awk -F ' ' '{ print $2 }')
}

get_channel_freq;
curr_freq=$?

if [ "$curr_freq" = "3" ];
then
    CHANNEL_FREQ="2447"
elif [ "$curr_freq" = "8" ];
then
    CHANNEL_FREQ="2462"
elif [ "$curr_freq" = "11" ];
then
    CHANNEL_FREQ="2422"
fi

uci -c $CFG_PATH set netconfig.@adhoc[-1].freq=$CHANNEL_FREQ
uci -c $CFG_PATH commit netconfig

$IFCONFIG br-lan down
$IFCONFIG adhoc0 down
$IFCONFIG adhoc0 up
$SLEEP 1
$IW dev adhoc0 set type ibss
$IW dev adhoc0 ibss leave
$IW dev adhoc0 ibss join $MESHID $CHANNEL_FREQ HT20 fixed-freq $BSSID
$SLEEP 2
$IFCONFIG bat0 up
$IFCONFIG br-lan up
$BRCTL addif br-lan bat0

batctl dat 0
/root/nexfi-std/script/nexfi_ebtables.sh

echo "change channel to $CHANNEL_FREQ MHz."
