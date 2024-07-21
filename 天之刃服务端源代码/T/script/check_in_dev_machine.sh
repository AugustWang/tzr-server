#!/bin/bash
IP=`ifconfig eth0 | grep inet | cut -d : -f 2 | cut -d " " -f 1`
ALLOW_IP_PREFIX='192.168.26.'
MATCH_ALLOW_IP_PREFIX=`ifconfig eth0 | grep $ALLOW_IP_PREFIX`
if [ "$MATCH_ALLOW_IP_PREFIX" = '' ] ; then
    echo -e '===此脚本为危险脚本，不能在开发机以外的机子上运行===\n=======如果你强烈要求使用，请大喊三声我信春哥======='
    exit 1
else
    exit 0
fi

#危险工具调用该检测工具的方式
#bash ./check_in_dev_machine.sh
#if [ $? = 1 ] ; then
    #exit 1
#fi
