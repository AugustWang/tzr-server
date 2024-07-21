#!/bin/bash

echo "================================命令提示==================================="
echo -e "输入 # 结束当前项配置"
echo "================================命令提示==================================="


#erlang读取配置文件的根目录
READ_CONFIG_DIR=../../../config/behavior

#erlang端口-ip配置文件
RECEIVER_HOST_CONFIG=$READ_CONFIG_DIR/receiver_hosts.config

ERLANG_HOST_IP_ARR=()
ERLANG_HOST_PORT_ARR=()

ERLANG_I=0

set_erlang_host_ip_port() {
    echo "==========================================================================="
    echo "输入Erlang 服务端 receiver IP-端口 配置"
    echo "IP地址:"
    read IP
    if [ "$IP" = '#' ]; then
        echo "Erlang 服务端配置结束"
        write_config
    else
        echo "端口:"
        read PORT
        if [ "$PORT" = '#' ]; then
            echo "Erlang 服务端配置结束"
            write_config
        else
            ERLANG_HOST_IP_ARR[$ERLANG_I]=$IP
            ERLANG_HOST_PORT_ARR[$ERLANG_I]=$PORT
            let ERLANG_I++
            set_erlang_host_ip_port
        fi
    fi
}


write_config() {
    
    if [ $ERLANG_I -gt 0 ]; then
        rm -rf $RECEIVER_HOST_CONFIG

        #ERLANG_HOST_IP_ARR_LEN=`expr ${#ERLANG_HOST_IP_ARR}+1`
        
        LEN_I=0
        while [ $LEN_I -lt $ERLANG_I ]
        do
            IP=${ERLANG_HOST_IP_ARR[$LEN_I]}
            ID=`expr ${LEN_I} + 1`
            PORT=${ERLANG_HOST_PORT_ARR[$LEN_I]}
            echo "{${ID}, \"${IP}\", ${PORT}}." >> $RECEIVER_HOST_CONFIG
            let LEN_I++
        done
        
        echo "写入Erlang 服务端配置"
    else
        echo "警告:配置有误,您最好重新进行配置"
    fi
}

set_erlang_host_ip_port