#!/bin/bash
RECEIVER_DIR=/data/mtzr/receiver.server
export LANG=zh_CN.UTF-8
#启动Receiver.server
if [ "$1" = ""  ] ; then
	echo "请使用命令: start_receiver_server ID号"
	echo "=====================================可选配置==========================================="
	cat "../../../config/behavior/receiver_hosts.config"
    echo  ""
	echo "=====================================可选配置==========================================="
	exit 1
fi
ID=$1
start_receiver()
{
	cd $RECEIVER_DIR/trunk
	bash mgeerctl started -id $ID
	if [ $? -eq 0 ] ; then
		echo "警告：Receiver.server已经启动"
		exit 0
	else
	    chmod +x ./mgeerctl
		bash mgeerctl start -id $ID
		retry=3
		while [ $retry -ne 0 ] ; do
			bash mgeerctl started -id $ID
			if [ $? -eq 0 ] ; then
				echo "Receiver.server启动成功"
				let "retry=0"
				exit 0;
			else
				echo "Receiver.server启动失败，将再次尝试启动"
				let "retry=retry-1"
			fi
			sleep 3
		done
		echo 'Receiver.server启动失败'
		exit 1
	fi
}

start_receiver
