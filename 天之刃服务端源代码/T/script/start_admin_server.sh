#!/bin/bash
ADMIN_DIR=/data/mtzr/admin.server
#启动admin.server
start_admin()
{
	cd $ADMIN_DIR/trunk
	bash mgeeactl started
	if [ $? -eq 0 ] ; then
		echo "警告：Admin.server已经启动"
		exit 1
	else
	    chmod +x ./mgeeactl
		bash mgeeactl start
		retry=3
		while [ $retry -ne 0 ] ; do
			bash mgeeactl started
			if [ $? -eq 0 ] ; then
				echo "Admin.server启动成功"
				let "retry=0"
				exit 0;
			else
				echo "Admin.server启动失败，将再次尝试启动"
				let "retry=retry-1"
			fi
			sleep 3
		done
		echo 'Admin.server启动失败'
		exit 1
	fi
}

start_admin
