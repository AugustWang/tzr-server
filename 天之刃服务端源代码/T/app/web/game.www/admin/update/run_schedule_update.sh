#!/bin/bash

#############################################
## 该脚本必须让crontab每天定时(例如03:00)运行一次
#############################################

####################### MING2_GMAE begin ##################################
## 1 0 * * *   /data/tzr/web/www/admin/update/run_schedule_00.sh
## 0 3 * * *   /data/tzr/web/www/admin/update/run_schedule_update.sh
####################### MING2_GMAE end ####################################

INIT_DIR=`dirname $0`
cd ${INIT_DIR}/


name=([0]="init_tables.php"
      [1]="update_stat_user_online.php"
      [2]="update_stat_item_buy_order.php"
      [3]="update_stat_item_consume_order.php"
      [4]="update_use_gold_log.php"
      [5]="update_stat_use_gold.php"
      [6]="update_stat_loyal_user.php"
      [7]="update_stat_use_gold_with_pay.php"
      [8]="update_stat_use_silver.php"
      [9]="update_stat_bank_sheet.php"
      [10]="update_stat_educate.php"
      [11]="update_get_pet_log.php"
      [12]="clear_old_logs.php")

for i in ${name[*]}
do
echo =====================$i==================
DATETIME1=`date "+%Y%m%d%H%M%S"`
/usr/bin/php $i >> /data/logs/run_schedule_update.log
DATETIME2=`date "+%Y%m%d%H%M%S"`
echo " ,cost $[ $DATETIME1-$DATETIME2 ] secs" >> /data/logs/run_schedule_update.log
done
