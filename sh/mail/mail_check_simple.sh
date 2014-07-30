#!/bin/bash

mail_dir=/home/yuyan/Mail


inboxs=("Inbox" "Department" "Service" "RDM" "EAS")
while [ : ]
do
	output=`getmail 2>/dev/null |grep retrieved |awk '{print $1}'`
	
	if [ "$output" != "0" ];then
	    cd $mail_dir
	    files=$(find . -mmin 1)
	    for box in ${inboxs[@]} 
	    do
		echo $files | grep $box
		a=$?
		if [ $a -eq 0 ];then
		    from_line=$(grep "^From:" $box  | tail -1)
		    encode=$(echo $from_line | awk 'BEGIN{FS="?"} {print $2}')
		    
		    ### get sender's name
		    user_name=$(echo $from_line | awk '{print $2}')
		    if [ ! -z "$encode" -a "$encode" != " " ];then
			en_str=$(echo $user_name | awk 'BEGIN{FS="?"} {print $4}')
			user_name=$(echo $en_str | base64 -d | iconv -f $encode  -t UTF-8)
		    fi


		    ### get sender's email
		    user_email=$(echo $from_line | awk '{print $NF}')
		    if [ "$user_email" = "$user_name" ];then
			user_email=""
		    fi

		    ### subject 
		    subject_line=$(grep "^Subject:" $box | tail -1)
		    encode=$(echo $subject_line | awk 'BEGIN{FS="?"} { print $2}')
		    en_type=$(echo $subject_line | awk 'BEGIN{FS="?"} { print $3}')
		    #subject=$(echo $subject_line | awk '{print $2}')
		    subject=$subject_line
		    if [ ! -z "$encode" -a "$encode" != " " ];then
			en_str=$(echo $subject | awk 'BEGIN{FS="?"} {print $4}')
			program="base64"
			if [ "$en_type" = "Q" ];then
			    program="qprint"
			fi
			subject=$(echo $en_str | $program -d | iconv -f $encode  -t UTF-8)
		    else 
			subject=${subject:9}
		    fi

		    expire=300000
		    if [ "$box" = "Spam" ];then
			expire=3000
		    fi

		    notify-send -t $expire --icon=dialog-information  "New Message In [$box]" "From     : $user_name $user_email\nSubject : $subject" 
		fi
	    done

	fi
	sleep 60
done
