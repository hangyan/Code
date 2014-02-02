#!/usr/bin/env bash

LOG_FILE=/log/flume/logs/flume.log
CP_FILE=/flume-log/checkpoint/checkpoint

test -e $LOG_FILE && mv $LOG_FILE $LOG_FILE/../flume.log.$(date +"%Y-%m-%d--%H:%M:%S")
value=$(awk 'BEGIN{FS="="} $1 ~ /writerFlushID/  {print $2}' $CP_FILE) && sed "s/readerEventID=[0-9].*/readerEventID=$value/g" $CP_FILE
