#!/bin/bash
## 创建数据库，升级数据
php dump_cent_data.php
mysqldump -uroot -p`cat /data/save/mysql_root` tzr_logs t_log_pay_tmp t_log_gold_tmp  > ./m2_cent_data.sql 
php drop_cent_tmp.php