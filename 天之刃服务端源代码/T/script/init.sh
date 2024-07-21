#!/bin/bash

## 服务端初始化配置脚本
echo "==================================================================="
echo "使用语法: ./init.sh 机器IP [后台域名] [Receiver地址] [Receiver端口]"
echo "==================================================================="
if [ "$1" = '' ] ; then
	echo "请至少输入 [机器IP] 参数"
    exit 1
fi

IP=$1
PHP_ADMIN_URL=$2
if [ "$PHP_ADMIN_URL" = '' ] ; then
	PHP_ADMIN_URL=$IP
fi

RECEIVER_HOST=$3
if [ "$RECEIVER_HOST" = '' ] ; then
	RECEIVER_HOST=$IP
fi

RECEIVER_PORT=$4
if [ "$RECEIVER_PORT" = '' ] ; then
	RECEIVER_PORT=10001
fi

##获取脚本所在目录
here=`which "$0" 2>/dev/null || echo .`
base="`dirname $here`"
SCRIPT_ROOT=`(cd "$base"; echo $PWD)`
MGE_ROOT="`dirname $SCRIPT_ROOT`"

##一些变量
ERLANG_COOKIE=123456

echo "113.107.160.79 svn.mge.com:3691" >> /etc/hosts

## 统一cookie
echo "$ERLANG_COOKIE" > /root/.erlang.cookie 
## 本地虚拟机开发环境
echo "$ERLANG_COOKIE" > /.erlang.cookie

## 拷贝分线配置文件
cp -f $MGE_ROOT/config_example/lines.config $MGE_ROOT/config/
cp -f $MGE_ROOT/config_example/server_ip.config $MGE_ROOT/config/


## 日志文件目录
mkdir -p /data/logs
mkdir -p /data/logs/tzr

echo 'export PATH=$PATH:/usr/local/bin' >> /root/.bashrc

## 替换IP地址
sed "s/HOST/$IP/" -i $MGE_ROOT/config/lines.config
sed "s/HOST/$IP/" -i $MGE_ROOT/config/server_ip.config
sed "s/HOST/$IP/" -i $MGE_ROOT/config/map_slave.config
sed "s/HOST/$PHP_ADMIN_URL/" -i $MGE_ROOT/config/behavior/server.config
sed "s/URL/\/index.php/" -i $MGE_ROOT/config/behavior/server.config
sed "s/HOST/$RECEIVER_HOST/" -i $MGE_ROOT/config/behavior/receiver_hosts.config
sed "s/PORT/$RECEIVER_PORT/" -i $MGE_ROOT/config/behavior/receiver_hosts.config
sed "s/TEST_HOST/$IP/" -i $MGE_ROOT/config/admin/agent_servers.config

echo "======================================"
echo 初始化操作完毕
echo "======================================"
##需要改配置的几个地方
## ../../../config/map_slave.config
## /data/mtzr/map.server/trunk/.hosts.erlang
## ../../../config/server_ip.config
