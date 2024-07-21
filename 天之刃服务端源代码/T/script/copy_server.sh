#!/bin/bash

##判断参数
if [ "$2" = '' ] ; then
	echo "使用语法:  ./copy_server.sh IP 端口"
	exit
fi

IP=$1
PORT=$2

ming2Dir=/data/mtzr
cd $ming2Dir
ExportDir=$ming2Dir/ming2Export
rm -rf $ExportDir
mkdir $ExportDir
echo 开始导出项目...

ServerName=common.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=world.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=common.doc
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=behavior.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=db.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=login.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=map.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=line.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
rm -rf $ExportDir/$ServerName/trunk/flashtest
echo 导出了$ServerName

ServerName=chat.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=port.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
rm -rf $ExportDir/$ServerName/security/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=receiver.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
rm -rf $ExportDir/$ServerName/security/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

ServerName=admin.server
rm -rf $ExportDir/$ServerName
cp $ServerName $ExportDir/$ServerName -R
rm -rf $ExportDir/$ServerName/trunk/src $ExportDir/$ServerName/tags
rm -rf $ExportDir/$ServerName/security/src $ExportDir/$ServerName/tags
echo 导出了$ServerName

echo 正在清除多余数据
find $ExportDir -type d -name ".svn"|xargs rm -rf
find $ExportDir -type f -name "Mnesia*"|xargs rm -rf
find $ExportDir -type f -name "*.log"|xargs rm -rf
find $ExportDir -type d -name "doc"|xargs rm -rf

echo 正在打包...
cd $ExportDir/
tar czvf $ming2Dir/ming2Export.tar.gz $ExportDir 
scp -P $PORT $ming2Dir/ming2Export.tar.gz root@$IP:/data/tmp