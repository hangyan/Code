#!/usr/bin/bash

source ~/.profile


while [ 1 ]
do
    new_mail=`getmail 2>/dev/null |grep retrieved |awk '{print $1}'`
    if [ "$new_mail" != "0" ];then
        notify-send "$new_mail New Mail"
	espeak "Please check your email box"
    fi
    sleep 60
    
    pct=$(cat /sys/class/power_supply/BAT1/capacity)
    if [ $pct -lt 25 ];then
        notify-send "Battery: $pct%" "请尽快插上电源"
	espeak "Please Checking the Status of the Battery"
    fi
    sleep 60
    
done

