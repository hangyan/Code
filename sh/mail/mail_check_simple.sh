#!/bin/bash

mail_dir=/home/yuyan/Mail

source $HOME/.profile

inboxs=("inbox" "Department" "Service" "RDM" "EAS")
while [ : ]
do
	echo "start" > $mail_dir/start_point
	output=`getmail 2>/dev/null |grep retrieved |awk '{print $1}'`
	
	if [ "$output" != "0" ];then
	    cd $mail_dir
	    for box in ${inboxs[$@]} 
	    do
		find . -newer start_point | grep $box
		a=$?
		if [ $a -eq 0 ];then
		     notify-send 'Mutt' "$box:  $output New Message " --icon=dialog-information
		fi
	    done

	fi
	sleep 60
done
