#/bin/bash 

source $HOME/.profile

output=`getmail 2>/dev/null |grep retrieved |awk '{print $1}'`

if [ "$output" != "0" ];then
    notify-send "$output New Message" 
fi

