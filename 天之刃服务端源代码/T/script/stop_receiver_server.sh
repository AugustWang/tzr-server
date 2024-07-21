#!/bin/bash
#脚本根目录
ROOT_DIR=/data/mtzr

RECEIVER_DIR=/data/mtzr/receiver.server
#停止Receiver.server
if [ "$1" = ""  ] ; then
	echo "请使用命令: stop_receiver_server ID号"
	echo "===================="
	echo "ID号请查看../../../config/behavior/receiver_hosts.config"
	exit 1
fi
ID=$1
stop_receiver()
{
	cd $RECEIVER_DIR/trunk
	bash mgeerctl started -id $ID
	if [ $? -eq 0 ] ; then
		bash mgeerctl stop -id $ID
		sleep 2
	fi
	if [ $? -eq 0 ] ; then
		echo "停止Receiver.server成功"
		exit 0
	else
		echo "停止Receiver.server失败"
		exit 1
	fi
	
}

stop_receiver

cd $ROOT_DIR/common.doc/trunk/scripts
bash ./stop_receiver_server.sh 1

