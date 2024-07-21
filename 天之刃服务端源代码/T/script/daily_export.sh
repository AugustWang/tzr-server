#!/bin/bash

##判断参数
if [ "$3" = '' ] ; then
	echo "===========本脚本用于【构建】一个分支到tags目录 如果传递服务器==========================="
	echo "使用语法:  ./daily_build.sh 日期(20xxyyzz) svn_user svn_passwd [服务器IP] [后台域名] [Receiver地址]  [Receiver端口]"
	exit
fi

SERVER_ROOT=/data/mtzr
DATA=$1
##svn用户名和密码
USERNAME=$2
PASSWORD=$3
IP=$4
PHP_ADMIN=$5

SVN_URL=svn://svn.tzr.com:3693/server/
TAG_DIR=$DATA
SVN_ARGS="--username ${USERNAME} --password ${PASSWORD} --non-interactive --no-auth-cache"

rm -rf $SERVER_ROOT.bk
mv $SERVER_ROOT $SERVER_ROOT.bk
svn co $SVN_URL/tags/$TAG_DIR $SERVER_ROOT
chmod +x $SERVER_ROOT -R
cd $SERVER_ROOT/script
./init.sh $IP $PHP_ADMIN
./rebuild_behavior_proto.sh
cd ..
./mgectl game rebuild
ps awux | grep erl | grep -v "grep" | awk '{print $2}' | xargs kill
./mgectl start
echo > $SERVER_ROOT/version.$DATA