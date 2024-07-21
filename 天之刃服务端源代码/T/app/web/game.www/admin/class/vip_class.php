<?php

/*
 * 2011.3.26
 * vip信息类
 */

if (!defined('INCLUDE_CLASS_VIP_CLASS_PHP_FILE')) {
	define('INCLUDE_CLASS_VIP_CLASS_PHP_FILE', 1);
	class VipClass{
		//根据玩家id获取vip信息
		public static function getVipInfo($RoleID){
			//已将vip表导入到mysql，不需要再去操作mnesia
			//return getJson ( ERLANG_WEB_URL ."/vip?fun=getVipInfo&arg0=".$RoleID);
			$sql = "SELECT `role_id`,`end_time`,`total_time`,`vip_level`,`is_expire` FROM `db_role_vip_p` WHERE `role_id` = {$RoleID} ";
			$result = GFetchRowOne($sql);
			return $result;
		}		
		// 获取全部vip人数
		public static function getVipAllCount(){
			$sql = "SELECT count(`role_id`) as all_count FROM `db_role_vip_p` ";
			$result = GFetchRowOne($sql);
			$all_count = $result['all_count'];
			return $all_count;
		}
		// 获取过期vip人数
		public static function getVipOverTimeCount(){
			$sql = "SELECT count(`role_id`) as over_time_count FROM `db_role_vip_p` where `is_expire` = 1 ";
			$result = GFetchRowOne($sql);
			$over_time_count = $result['over_time_count'];
			return $over_time_count;
		}
	}
}

?>