#!/bin/bash

#---------------------------------------------------------------------
# author: Xiaosheng
# desc: 设置日志级别
# create_date: 2010-07-25
#---------------------------------------------------------------------
if [ "$1" = '' -o "$2" = '' -o "$3" = '' ] ; then
    echo "使用语法: IP Cookie Level"
    exit 1
fi

IP=$1
Cookie=$2
Level=$3

erl -pa /data/tzr/server/ebin/common -name set_log_level@$IP -setcookie $Cookie -eval "pong=net_adm:ping('login@$IP'), timer:sleep(3000), common_loglevel:set_all($Level), init:stop()."
