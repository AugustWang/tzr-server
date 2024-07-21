#!/bin/bash
## 对www/admin的打包 

if [ "$1" = '' ] ; then
    echo '====================提示======================'
    echo 请使用语法: ./pack_admin.sh [当前SVN版本号]
    echo '====================提示======================'
    exit 1
fi

SVN_VERSION=$1
Date=`date "+%Y-%m-%d-%H%M%S"`


##-----------------------------------------------------------------
## 打包www文件
##-----------------------------------------------------------------
WWW_TAR="tzr.admin.bugfix.${SVN_VERSION}.${Date}.tar.gz"
cd /data/tzr/web/
rm -rf www_release
cp -r /data/mtzr/app/web/game.www/ www_release
cd www_release

## 删除此次不更新的文件
rm -rf user/
rm -rf config/
rm -rf api/
rm -rf library/
rm -rf template_c/
rm -f  *.php

## 删除svn文件
find . -type d -name "*svn*" | xargs rm -rf


cd ..
tar cfz $WWW_TAR www_release
mv $WWW_TAR /data/tzr/release/