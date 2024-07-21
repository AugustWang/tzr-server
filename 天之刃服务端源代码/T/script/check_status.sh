#!/bin/bash
cd /data/tzr/server

##端口配置
WEB_OUT_PORT=80
WEB_ERLANG_PORT=8000
SECURITY_PORT=843
LOGIN_PORT=6222
CHAT_PORT=4398



##function echo_port_listening
echo_port_listening()
{
    if  netstat -an |grep ":$PORT " |grep -i "tcp" > /dev/null 2>&1
    then 
        echo -e "TCP_Port:$PORT \tis listening......"
    elif netstat -an |grep ":$PORT " |grep -i "udp" > /dev/null 2>&1
    then 
        echo -e "UDP_Port:$PORT \tis listening......"
    else
        echo -e "Port:$PORT \tis listening......"
    fi
}
##function check_port
check_port()
{
    PORT=$1
    RETRY_COUNT=$3
    case $2 in
        'start')
            if  netstat -an |grep ":$PORT " > /dev/null 2>&1
            then
                echo_port_listening
                return 0;
            else
                echo -e "Port:$PORT \tis closed"
                if [ $RETRY_COUNT -gt 1 ]; then
                    sleep 10
                    check_port $PORT 'start' $[RETRY_COUNT-1]
                    return $?
                else
                    return 1;
                fi
            fi
            ;;
        'stop')
            if  netstat -an |grep ":$PORT " > /dev/null 2>&1
            then
                echo_port_listening
                if [ $RETRY_COUNT -gt 1 ]; then
                    sleep 10
                    check_port $PORT 'stop' $[RETRY_COUNT-1]
                    return $?
                else
                    return 1;
                fi
            else
                echo -e "Port:$PORT \tis closed"
                return 0;
            fi
            ;;
        *);;
    esac
    
}
echo "=============当前客户端版本: ============="
cat /data/tzr/server/version_client.txt 
echo "=============当前服务端版本: ============="
cat /data/tzr/server/version_server.txt 

echo "=============Erlang进程如下: ============="
ps -ef| grep beam |grep -v grep | awk '{print $2,$30,$31}'

echo "=============常用端口状态如下：============="
    check_port ${WEB_OUT_PORT} 'start' 1
    check_port ${WEB_ERLANG_PORT} 'start' 1
    check_port ${SECURITY_PORT} 'start' 1
    check_port ${LOGIN_PORT} 'start' 1
    check_port ${CHAT_PORT} 'start' 1
    check_port ${EMPD_PORT} 'start' 1
    

