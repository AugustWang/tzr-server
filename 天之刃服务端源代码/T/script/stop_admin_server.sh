#!/bin/bash
ADMIN_DIR=/data/mtzr/admin.server
#停止admin.server
stop_admin()
{
	cd $ADMIN_DIR/trunk
	bash mgeeactl started
	if [ $? -eq 0 ] ; then
		bash mgeeactl stop
		sleep 2
	fi
	if [ $? -eq 0 ] ; then
		echo "停止Admin.server成功"
	else
		echo "停止Admin.server失败"
	fi
	
}

stop_admin
