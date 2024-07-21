#!/bin/bash

#---------------------------------------------------------------------
# author: flexsns.com <flexsns@gmail.com>
# desc: 服务端启动脚本
# create_date: 2010-09-14
#---------------------------------------------------------------------

ROOT=/data/tzr/server/script
SERVER_LIST=()
SERVER_KEY=0
add_server() {
	SERVER_LIST[$SERVER_KEY]="SERVER_NAME='${1}'; SERVER_CTL='${2}'; "
	let SERVER_KEY++
}

add_server 'erlang_web' 'mgeewebctl'
add_server 'line' 'mgeelinectl'
add_server 'chat' 'mgeecctl'
add_server 'world' 'mgeewctl'
add_server 'map' 'mgeemctl'
add_server 'login' 'mgeelctl'
add_server 'db' 'mgeedctl'
add_server 'behavior' 'mgeebctl'
add_server 'security' 'mgeesctl'


stop_server() {
	if [ "$1" = '' ]; then
		KEY=0
	else
		KEY=$1
	fi
	eval "${SERVER_LIST[$KEY]}"
	if [ ${#SERVER_LIST[@]} -eq $KEY ]; then	
		echo ''
		echo '===============================关闭天之刃游戏服完毕================================='
		ps awux | grep erl | grep -v "grep" | awk '{print $26}'
		exit 0
	fi
	
	cd $ROOT/
	
	CHECK=`ps awux | grep ${SERVER_NAME} | grep "erl" | grep -v "grep" | awk '{print $2}'`
	if [ "$CHECK" = '' ]; then
		echo "提示：$SERVER_NAME 已经停止，跳过"
		let KEY++
		stop_server $KEY
		exit 0
	else
		echo "准备关闭$SERVER_NAME"
		bash ./$SERVER_CTL stop
		RETRY=0
		while [ true ] ; do
			let RETRY++
			sleep 1
			CHECK=`ps awux | grep ${SERVER_NAME} | grep "erl" | grep -v "grep" | awk '{print $2}'`
			if [ "$CHECK" = '' ]; then
				let KEY++
				echo "关闭：$SERVER_NAME 成功"
				stop_server $KEY
				exit 0
			else
				echo "注意：等待$SERVER_NAME关闭中 $RETRY..."
				if [ $RETRY -gt 60 ]; then
					echo "警告：关闭$SERVER_NAME所用时间过长，请单独检查"
					exit 0
				fi
			fi
		done
	fi
	
}
echo '==============================正在关闭天之刃游戏服================================='
stop_server
