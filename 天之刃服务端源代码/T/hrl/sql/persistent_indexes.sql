-- ----------------------------
-- 为mnesia的持久化表增加索引
-- ----------------------------


-- ----------------------------
-- for table `db_role_base_p`
-- ----------------------------
ALTER TABLE `db_role_base_p` ADD INDEX ( `account_name` ) ;
ALTER TABLE `db_role_base_p` ADD INDEX ( `role_name` ) ;
ALTER TABLE `db_role_base_p` ADD INDEX ( `create_time` ) ;

-- ----------------------------
-- for table `db_pay_log_p`
-- ----------------------------
ALTER TABLE `db_pay_log_p` ADD INDEX ( `role_id`  ) ;
ALTER TABLE `db_pay_log_p` ADD INDEX ( `account_name`  ) ;
ALTER TABLE `db_pay_log_p` ADD INDEX ( `pay_time`  ) ;
ALTER TABLE `db_pay_log_p` ADD INDEX ( `pay_gold`  ) ;
ALTER TABLE `db_pay_log_p` ADD INDEX ( `pay_money`  ) ;
ALTER TABLE `db_pay_log_p` ADD INDEX (  `year` , `month` , `day` , `hour` ) ;

ALTER TABLE `db_pay_log_p` ADD INDEX ( `role_level`  ) ;
ALTER TABLE `db_pay_log_p` ADD INDEX ( `is_first` ) ;


#=========start 2011-1-7  ========
-- ----------------------------
-- for table `db_role_category_p`
-- ----------------------------
ALTER TABLE `db_role_category_p` ADD INDEX ( `category` ) ;

#=========end 2011-1-7  ========

#=========end 2011-02-21  ========
ALTER TABLE `db_role_attr_p` ADD INDEX ( `level` ) ;


#=========start 2011-2-26  ========
ALTER TABLE `db_role_base_p` ADD INDEX ( `sex` ) ;
ALTER TABLE `db_role_give_flowers_yesterday_rank_p` ADD INDEX ( `score` ) ;
ALTER TABLE `db_role_rece_flowers_yesterday_rank_p` ADD INDEX ( `charm` ) ;
#=========end 2011-2-26  ========

#=========start 2011-03-05  ========
ALTER TABLE `db_pet_p` ADD INDEX ( `type_id` ) ;
ALTER TABLE `db_pet_p` ADD INDEX ( `role_id` ) ;
ALTER TABLE `db_pet_p` ADD INDEX ( `get_tick` ) ;
#=========end 2011-03-05  ========