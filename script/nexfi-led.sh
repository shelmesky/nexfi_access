#!/bin/sh
# leds driver interface file

LED_PATH="/sys/devices/platform/leds-gpio/leds"

GREEN_TRIGGER="nexfi:green/trigger" 
RED_TRIGGER="nexfi:red/trigger"

TRI_RED="nexfi:tb-red/brightness"
TRI_GREEN="nexfi:tb-green/brightness"
TRI_BLUE="nexfi:tb-blue/brightness"

# wireless channel.
get_channel_freq()
{
    return $(iw dev adhoc0 info | grep channel | awk -F ' ' '{ print $2 }')
}

# network led control
trig_green()
{
    echo $1 > $LED_PATH/$GREEN_TRIGGER
}

# system led control
trig_red()
{
    echo $1 > $LED_PATH/$RED_TRIGGER
}

# tri-base color control
turn_on_tri_red()
{
    echo 1 > $LED_PATH/$TRI_RED
    echo 1 > $LED_PATH/$TRI_GREEN
    echo 1 > $LED_PATH/$TRI_BLUE
}

turn_on_tri_green()
{
    echo 0 > $LED_PATH/$TRI_RED
    echo 0 > $LED_PATH/$TRI_GREEN
    echo 1 > $LED_PATH/$TRI_BLUE
}

turn_on_tri_blue()
{
    echo 0 > $LED_PATH/$TRI_RED
    echo 1 > $LED_PATH/$TRI_GREEN
    echo 0 > $LED_PATH/$TRI_BLUE
}

turn_off_tri_all()
{
    echo 0 > $LED_PATH/$TRI_RED
    echo 1 > $LED_PATH/$TRI_GREEN
    echo 1 > $LED_PATH/$TRI_BLUE
}

# network led finite state machine.
state_join="join"
state_alone="alone"
state_none="none"
priv_state=$state_none

net_led_fsm()
{
    nexhop=$(batctl n | sed '1,2 d' | grep -v "range")

    if [ -z "$nexhop" ]
    then
        curr_state=$state_alone 
    else
        curr_state=$state_join
    fi 

    if [ "$curr_state" != "$priv_state" ]
    then
        case $curr_state in
            $state_join )
                trig_green "default-on"
                ;;
            $state_alone )
                trig_green "timer"
                ;;
            * )
                echo "net_led_fsm function state error."
                ;;
        esac

        priv_state=$curr_state
    fi
}

# tri-base color finite state machine.
state_tri_red="tri-red"
state_tri_blue="tri-blue"
state_tri_green="tri-green"
state_tri_none="tri_none"
tri_priv_state=$state_tri_none

tri_led_fsm()
{
    get_channel_freq
    channel=$?

    tri_curr_state=$state_tri_none
    case $channel in
        "3" )
           tri_curr_state=$state_tri_red 
            ;;
        "8" )
            tri_curr_state=$state_tri_green
            ;;
        "11" )
            tri_curr_state=$state_tri_blue
            ;;
        * )
            tri_curr_state=$state_tri_none
            ;;
    esac

    if [ "$tri_priv_state" != "$tri_curr_state" ]
    then
        case $tri_curr_state in
            $state_tri_blue )
                turn_on_tri_blue 
                ;;
            $state_tri_red )
                turn_on_tri_red
                ;;
            $state_tri_green )
                turn_on_tri_green 
                ;;
            * )
                turn_off_tri_all
                ;;
        esac
        
        tri_priv_state=$tri_curr_state
    fi
}

trig_red "default-on"
trig_green "none"
turn_off_tri_all

while :
do
    net_led_fsm
    tri_led_fsm
    sleep 1
done
