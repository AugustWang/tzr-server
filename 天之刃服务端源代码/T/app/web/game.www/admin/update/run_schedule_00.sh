#!/bin/bash

#############################################
## 该脚本必须让crontab每天凌晨(00:01)运行一次
#############################################

INIT_DIR=`dirname $0`
cd ${INIT_DIR}/


echo =====================update_stat_money_consume.php==================
DATETIME10=`date "+%Y%m%d%H%M%S"`
/usr/bin/php update_stat_money_consume.php >> /data/logs/run_schedule_update.log
DATETIME11=`date "+%Y%m%d%H%M%S"`
echo " ,cost $[ $DATETIME11-$DATETIME10 ] secs" >> /data/logs/run_schedule_update.log
