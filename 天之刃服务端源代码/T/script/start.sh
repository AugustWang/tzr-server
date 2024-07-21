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
	SERVER_LIST[$SERVER_KEY]="SERVER_NAME='${1}'; SERVER_CTL_DIR='${2}'; SERVER_CTL='${3}'; SERVER_ACTION='${4}'; "
	let SERVER_KEY++
}

add_server 'security' 'security' 'mgeesctl' ' start'
add_server 'behavior' 'trunk' 'mgeebctl' ' start'
add_server 'db' 'trunk' 'mgeedctl' ' start'
add_server 'login' 'trunk' 'mgeelctl' ' start'
add_server 'map' 'trunk' 'mgeemctl' ' start'
add_server 'world' 'trunk' 'mgeewctl' ' start'
add_server 'chat' 'trunk' 'mgeecctl' ' start'
add_server 'line' 'trunk' 'mgeelinectl' ' start'
add_server 'erlang_web' 'trunk' 'mgeewebctl' ' start'

run_server() {
	if [ "$1" = '' ]; then
		KEY=0
	else
		KEY=$1
	fi
	eval "${SERVER_LIST[$KEY]}"
	
	if [ ${#SERVER_LIST[@]} -eq $KEY ]; then
		
		echo ''
		echo '====================服务器全部启动成功 已启动的服务器列表======================'
		ps awux | grep mgee | grep -v "grep" | awk '{print $26}'
		echo '==============================天之刃启动完毕================================='
		exit 0
	fi
	
	cd $ROOT/
	chmod +x ./$SERVER_CTL
	CHECK_START_ACTION=$(echo $SERVER_ACTION | sed 's/start/started/')
	bash ./$SERVER_CTL $CHECK_START_ACTION
	if [ $? = 0 ]; then
		let KEY++
		echo "警告：$SERVER_NAME 已经启动"
		run_server $KEY
		exit 0
	else
		bash ./$SERVER_CTL $SERVER_ACTION
	
		RETRY=0
		while [ true ] ; do
			let RETRY++
			sleep 1
			bash $SERVER_CTL $CHECK_START_ACTION
			if [ $? = 0  ]; then
				let KEY++
				echo "启动：$SERVER_NAME 成功"
				run_server $KEY
				exit 0
			else
				if [ $RETRY -gt 60 ]; then
					STOP_ACTION=$(echo $SERVER_ACTION | sed 's/start/stop/')
					bash ./$SERVER_CTL $STOP_ACTION
					echo "警告：由于等待时间过长，系统将尝试停止后再次启动 $SERVER_NAME"
					sleep 3
					run_server $KEY
					exit 0
				else
					if [ $RETRY -gt 100 ]; then
						echo "!!!!!!!!!!服务器 $SERVER_NAME 可能有错误 请检查!!!!!!!!!!"
						echo '==============================天之刃启动失败================================='
						exit 1
					else
						echo "注意：等待$SERVER_NAME启动中 $RETRY..."
					fi
				fi
			fi
		done
	fi
	
}
echo '==============================开始启动天之刃================================='
run_server
