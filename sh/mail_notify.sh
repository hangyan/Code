#/bin/bash 

source ~/.profile

output=`getmail 2>/dev/null |grep retrieved |awk '{print $1}'`

if [ "$output" != "0" ];then
    mplayer /home/yuyan/Music/mail.mp3 
fi

