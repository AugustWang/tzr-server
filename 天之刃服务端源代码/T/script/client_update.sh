#!/bin/bash

##判断参数
if [ "$1" = '' ] ; then
	echo "===========本脚本用于更新前端文件==========================="
	echo "使用语法:  ./client_update.sh 源文件(前端压缩包)"
	exit
fi

RAR_FILE=$1
if [ ! -f $RAR_FILE ] ; then 
	echo "文件不存在"
	exit 1
fi

cd /data/tmp
rm -rf /data/tmp/client_update
mkdir client_update
cd client_update
unrar x $RAR_FILE
cd bin-debug
rm -rf configure.xml Main.html MingChao.html

cd /data/web/ming2
rm -rf com assets history lang

\cp /data/tmp/client_update/* /data/web/ming2 -R