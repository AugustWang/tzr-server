#!/bin/bash

##判断参数
if [ "$3" = '' ] ; then
	echo "===========本脚本用于【删除】一个分支目录==========================="
	echo "使用语法:  ./daily_del.sh 日期(20xxyyzz) svn_user svn_passwd"
	exit
fi

DATA=$1
##svn用户名和密码
USERNAME=$2
PASSWORD=$3

SVN_URL=svn://svn.tzr.com:3693/server/
TAG_DIR=$DATA
SVN_ARGS="--username ${USERNAME} --password ${PASSWORD} --non-interactive --no-auth-cache"

build_vs() {
	echo "准备删除, 标签号:$DATA..."
	svn delete $SVN_URL/tags/$TAG_DIR/ -m "删除无效每日构建版本" $SVN_ARGS
	if [ $? != 0 ]; then
		echo "删除标签号:$DATA 出错"
	else
		echo "删除标签号:$DATA 成功"
	fi
}

build_vs