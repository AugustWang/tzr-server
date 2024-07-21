#!/bin/bash

#---------------------------------------------------------------------
# author: flexsns.com <flexsns@gmail.com>
# desc: 初始化测试客户端配置
# create_date: 2010-09-14
#---------------------------------------------------------------------
SVN_USER=readonly
SVN_PASSWORD='e7OrqULBrEUFn7luX2hM'


if [ "$1" = '' ] ; then
	echo '====================警告======================'
	echo 请使用语法: ./init_dev_client.sh IP地址 站点所在目录 [前端版本号]
	echo '====================警告======================'
	exit 1
fi

HOST=$1
GAME_ROOT=$2user
if [ "$3" = '' ] ; then
	CLIENT_VS=''
	CLIENT_ROOT=$GAME_ROOT
	CLIENT_ROOT_URL=http://www.ming2game-local.com/user
else
	CLIENT_VS=$3
	CLIENT_ROOT=$GAME_ROOT/$CLIENT_VS
	CLIENT_ROOT_URL=http://www.ming2game-local.com/user/$CLIENT_VS
fi
if [ ! -d $CLIENT_ROOT ] ; then
	echo '====================警告======================'
	echo '目录不存在:'$CLIENT_ROOT
	echo '====================警告======================'
	exit 1
fi

FCM_API_URL=''

cp $GAME_ROOT/configure.template.xml $CLIENT_ROOT/configure.xml
sed "s#<{\$clientRootUrl}>#$CLIENT_ROOT_URL#" -i $CLIENT_ROOT/configure.xml
sed "s#<{\$loginServer}>#$HOST#" -i $CLIENT_ROOT/configure.xml
sed "s#<{\$chatServer}>#$HOST#" -i $CLIENT_ROOT/configure.xml
sed "s#<{\$portServer}>#$HOST#" -i $CLIENT_ROOT/configure.xml
sed "s#<{\$fcmApiUrl}>#$FCM_API_URL#" -i $CLIENT_ROOT/configure.xml
sed "s#<{$clientRoot}>#$CLIENT_ROOT_URL#" -i $CLIENT_ROOT/configure.xml

echo -e "\
<?php
define('SERVER_VERSION', '');\n\
define('CLIENT_VERSION', '${CLIENT_VS}');\n\
define('FCM_API_URL', '');\n\
define('CLIENT_ROOT_URL', '${CLIENT_ROOT_URL}');\n\
define('HOST', '${HOST}');\n\
" > $GAME_ROOT/../config/game.php

echo '====================成功======================'
echo -e "初始化成功\n"
echo -e "请确保你导出了 svn://svn.tzr.com:3693/client/trunk/src/client/releases 到\n\
$CLIENT_ROOT\n"
echo -e "请确保你导出了 svn://svn.tzr.com:3693/client/trunk/src/client/elements/com 到\n\
$CLIENT_ROOT/com\n"
echo 上面两个svn的帐号:$SVN_USER 密码:$SVN_PASSWORD
echo '====================成功======================'