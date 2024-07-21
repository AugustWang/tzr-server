#!/bin/bash

source /data/mtzr/common.doc/trunk/scripts/set_receiver_host.sh

#http服务器ip配置文件
RECEIVER_HTTP_HOST_CONFIG=$READ_CONFIG_DIR/server.config

RECEIVER_SERVER_ROOT=/data/mtzr/receiver.server/trunk

PHP_HOST_IP_ARR=()
PHP_HOST_URL_ARR=()
PHP_I=0
set_php_host() {
    echo "==========================================================================="
    echo "输入PHP 服务端 receiver IP 配置"
    echo "主机地址(域名/IP):"
    read HOST
    if [ "$HOST" = '#' ]; then
        echo "PHP 服务端配置结束"
        write_config
    else
        echo "输入URL(以/打头,如/behavior/index.php):"
        read URL
		if [ "$URL" = '#' ]; then
			echo "PHP 服务端配置结束"
			write_config
		else
			PHP_HOST_IP_ARR[$PHP_I]=$HOST
			
			CHECK=`expr substr $URL 1 1`
			
			if [ $CHECK != '/' ]; then
				URL="/$URL"
			fi
			
			PHP_HOST_URL_ARR[$PHP_I]=$URL
			let PHP_I++
			set_php_host
		fi
    fi
}

write_config() {
    if [ $PHP_I -gt 0 ]; then
        rm -rf $RECEIVER_HTTP_HOST_CONFIG
       
        #PHP_HOST_IP_ARR_LEN=`expr ${#ERLANG_HOST_IP_ARR}+1`
        
        LEN_I=0
        while [ $LEN_I -lt $PHP_I ]
        do
            IP=${PHP_HOST_IP_ARR[$LEN_I]}
            URL=${PHP_HOST_URL_ARR[$LEN_I]}
            echo "{http_host, \"${IP}\", \"${URL}\"}." >> $RECEIVER_HTTP_HOST_CONFIG
            let LEN_I++
        done
        echo "写入PHP 服务端配置"
    else
        echo "警告:配置有误,您最好重新进行配置"
    fi
}

set_php_host

if [ $ERLANG_I -gt 0 ]; then
    
    cd $RECEIVER_SERVER_ROOT

    ps awux | grep mgeer |  grep -v 'grep'  | awk '{print $2}' | xargs kill

    make
    chmod +x . -R
    LEN_I=0
    while [ $LEN_I -lt $ERLANG_I ]
    do
        ID=`expr ${LEN_I} + 1`
        ./mgeerctl start -id $ID
        echo "等待receiver.server启动..."
        sleep 3
        let LEN_I++
    done
    
else
    echo "配置有误 无法启动 receiver.server"
fi

echo "操作结束...请自行检查启动是否正常"