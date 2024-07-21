#!/bin/bash
if [ "$3" = '' ]; then
	echo "使用语法:  ./checkout_all_server IP svn_user svn_passwd [clear]"
	echo "clear如果为1 则清空整个项目 否则会检查项目是否存在再决定是否checkout"
	exit
fi

IP=$1
USERNAME=$2
PASSWORD=$3
CLEAR=$4

ROOT='/data/mtzr'

SVN_ROOT='svn://svn.mge.com:3691/mge'
SVN_ARGS="--username ${USERNAME} --password ${PASSWORD} --non-interactive --no-auth-cache"

cd $ROOT

checkout () {
	SERVER=$1
	DIR=$2
	if [ -d "$ROOT/$SERVER" ] && [ "$CLEAR" = '' ] ; then
		echo "警告：$SERVER已检出"
	else
		rm -rf $ROOT/$SERVER
		svn checkout $SVN_ROOT/$SERVER/$DIR $SERVER/$DIR $SVN_ARGS
		if [ $? != 0 ]; then
			echo "检出${SERVER}出错, 请检查您的svn权限是否足够"
			exit
		else
			echo "检出${SERVER}成功"
		fi
	fi
}

checkout common.doc trunk/
checkout common.server trunk/
checkout world.server trunk/
checkout db.server trunk/
checkout login.server trunk/
checkout line.server trunk/
checkout map.server trunk/
checkout chat.server trunk/
checkout receiver.server trunk/
checkout behavior.server trunk/
checkout admin.server trunk/
checkout port.server ./security

ps awux | grep erl |  grep -v 'grep'  | awk '{print $2}' | xargs kill

chmod +x . -R
cd $ROOT/common.doc/trunk/scripts
bash init.sh $IP

cd $ROOT/receiver.server/trunk/
make
bash ./mgeerctl start -id 1

cd $ROOT/admin.server/trunk/
make
bash ./mgeeactl start -id 1

cd $ROOT/common.doc/trunk/scripts
bash rebuild_and_start.sh