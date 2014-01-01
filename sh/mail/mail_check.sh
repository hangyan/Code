#!/bin/bash


source $HOME/.profile

while [ : ]
do
	output=`getmail 2>/dev/null |grep retrieved |awk '{print $1}'`
	
	if [ "$output" != "0" ];then
	    notify-send "$output New Mail"
	fi
	sleep 60
done
