#!/bin/bash
#---------------------------------------------------------------------
# author: larrouse <larrouse.sc@gmail.com>
# desc: 服务端整理游戏日志脚本
# create_date: 2010-11-7
#---------------------------------------------------------------------

echo "==================================================================="
echo "使用语法: $0  [日期DATE] "
echo "==================================================================="
if [ $# = 0 ] ; then
	echo "默认整理前一天的游戏日志"
	YEAR=`date --date='yesterday' +%Y`
	MONTH=`date --date='yesterday' +%m`
	MONTH2=$((10#$MONTH))
	DAY=`date --date='yesterday' +%d`
	DAY2=$((10#$DAY))   #这里必须要两个括号
	DATE=${YEAR}_${MONTH2}_${DAY2}
else 
	DATE=$1
fi


LOG_ROOT=/data/logs
cd $LOG_ROOT


if [ -d $DATE ]; then
	 echo "再次备份日志，日期:$DATE"
else
	mkdir $DATE
fi


LogName=tzr_all_$DATE*
	mv $LogName $DATE
echo "游戏日志转移完毕，日期:$DATE"
