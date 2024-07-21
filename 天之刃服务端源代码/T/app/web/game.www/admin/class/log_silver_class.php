<?php

/*
 * 银两的使用、获得记录
 */

if (!defined('INCLUDE_CLASS_LOG_SILVER_CLASS_PHP_FILE')) {
	define('INCLUDE_CLASS_LOG_SILVER_CLASS_PHP_FILE', true);

	if (!defined('INCLUDE_CLASS_DATABASE_PHP_FILE')) {
		include_once SYSDIR_CLASS."/db.class.php";
	}

	class LogSilverClass {
		/**
               *@警告:所有流通类型必须加到此处一份
               */
		public static function getCirculationSilverTypes(){
			return array(1003,1004,1006,2003,2004,2005);
		}
		
		
		
		
		
		
		const TYPE_BUY_ITEM			= 1002;		//系统商店购买道具

		public static function GetTypeList() {
			return array (
				//消费
				1001=>'GM后台扣除银两',
				1002=>'系统商店购买道具',
				1003=>'通过交易失去银两，属于流通',
				1004=>'钱庄购买元宝，属于流通',
				1005=>'钱庄购买元宝的手续费',
				1006=>'摆摊购买道具，属于流通',
				1007=>'摆摊的手续费',
				1008=>'死亡掉落的失去银两',
				1009=>'创建门派手续费',
				1010=>'国库捐款的扣银两',
				//1011=>'押镖车的扣银两', (已废弃)
				1012=>'升级技能的扣银两',
				1013=>'修理装备的扣银两',
				1014=>'发送喇叭消息的扣银两',
				1015=>'刷新任务的扣银两',
				1016=>'人物五行属性刷新的扣银两',
				1017=>'复活扣除银两',
				1018=>'车夫扣除银两',
				1019=>'信件扣除银两',
				1020=>'开通仓库扣除银两',
				1022=>'任务押镖扣钱',
				1023=>'摆摊交易税',
				1024=>'发型扣银两',
				1025=>'门派拉镖扣银两',
				1026=>'种植升级技能扣银两',
				1027=>'进入大明宝藏副本扣银两',	
				1028=>'变换头像扣除银两',
				1029=>'取消变身扣除银两',
				1030=>'装备强化',
				1031=>'材料合成',
				1032=>'装备打孔',
				1033=>'宝石镶嵌',
				1034=>'宝石拆卸',
				1035=>'装备绑定',
				1036=>'装备打造',
				1037=>'装备品质改造',
				1038=>'装备签名',
				1039=>'装备升级',
				1040=>'装备分解',
				1041=>'装备五行改造',
				1042=>'向国库捐款扣银两',
				1043=>'强行出狱扣除银两',
				1044=>'连续登录奖励购买',
				1050=>'宠物学技能扣除银两',
				1051=>'宠物洗灵扣除银两',
				1052=>'宠物提悟扣除银两',
				1053=>'宠物延寿扣除银两',
				1054=>'世界聊天扣除银两',
                1055=>'训宠能力等级提升消耗银子',	
                1056=>'训宠遗忘技能扣除银子',
                1057=>'门派采集玩家刷新奖励',
                1058=>'宠物炼制扣除银两',
                
                1059=>'提升装备颜色：绿',
                1060=>'提升装备颜色：蓝',
                1061=>'提升装备颜色：紫',
                1062=>'提升装备颜色：橙',
                1063=>'提升装备颜色：金',
				1064=>'市场购买扣除银两',
				1065=>'宠物学习或刷新特技',
				1066=>'买回物品扣去银两',
				1067=>'回门派扣去银两',
				1068=>'宠物训练消费银两',
                1069=>'门派捐献消费银两',
                1070=>'装备附魔消费银两',
                
				//获得
				2001=>'GM后台赠送银两',
				2002=>'创建角色默认银两',
				2003=>'摆摊出售道具，属于流通',
				2004=>'通过交易获得银两，属于流通',
				2005=>'通过钱庄获得银两，属于流通',
				//2006=>'任务获得银两', (已废弃)
				2007=>'向系统出售道具',
				2008=>'拾取获得银两',
				2009=>'钱庄撤消买单，退回银两',
				2010=>'雇佣摆摊未到期退回部分手续费',
				2011=>'镖车任务',
				2012=>'普通任务',
				2013=>'物品出售给npc商店',
				2014=>'使用银票道具获得银子',
				//2015=>'成就系统获得银子',
				2016=>'商贸获得银子',
				2017=>'NPC兑换获得银子',
				2018=>'(副)掌门放弃门派拉镖退还银子',
				2019=>'帮众放弃了门派拉镖退还银子',
				2020=>'门派拉镖扣银两',
				2021=>'极速讨伐敌营活动获取银子',
				2023=>'市场出售获得银两',
				//GM指令
				5001=>'GM指令获得银两'
			);
		} 

		public static function GetTypeName($typeid) {
			$arr = self :: GetTypeList();
			if (isset ($arr[$typeid]))
				return $arr[$typeid];
			else
				return '未知';
		}

		/*
		 * 获得所有消耗类型的操作(银两使用日志类型)
		 *
		 * 如果银两使用后，就消失了（系统回收了），则这种操作属于消耗类型
		 * 但是类似玩家之间交易，或者玩家在市场上花银两买东西，则不属于消耗，
		 * 因为银两只是从一个玩家跑到另外一个玩家帐号里去而已。
		 */
		public static function GetConsumeTypeList() {
			
			$data = self :: GetTypeList();
			$arr = array();
			//删掉获得类型
			foreach($data as $k=>$v){
				if( $k >= 1000 && $k < 2000 ){
					$arr[$k] = $v;
				}
			}
			//删掉流通类型
			unset($arr[1003]);
			unset($arr[1004]);
			unset($arr[1006]);
			return $arr;
		}

		/*
		 * 获得所有 非消耗类型的操作
		 */
		public static function GetNotConsumeTypeList() {
			$data = self :: GetConsumeTypeList();
			$all = self :: GetTypeList();

			//根据KEY计算数组差集
			return array_diff_key($all, $data);
		}

		//指定玩家的购买历史记录统计
		public static function getBuyLogStats($userid, $order, $timeStampStart = null, $timeStampEnd = null) {
			$timeStampStart = $timeStampStart or $timeStampStart = strtotime(date('Y-m-00',time()));
			$timeStampEnd = $timeStampEnd or $timeStampEnd = time();
			$tableName = date("Y_m",$timeStampStart);
			$tableName = DB_MING2_LOGS.'.t_log_use_silver_'.$tableName;
			
			if(!$userid){
				$sql = "SELECT `itemid`, SUM(`amount`) as amount, (sum(`silver_bind`)+sum(`silver_unbind`)) AS silver , SUM(`silver_bind`) as silver_bind , SUM(`silver_unbind`) as silver_unbind "
					. " FROM ".$tableName." WHERE `mtype`=" . self::TYPE_BUY_ITEM;
				
				if ($timeStampStart)
					$sql .= " AND `mtime` >= {$timeStampStart} ";
				if ($timeStampEnd)
					$sql .= " AND `mtime` <= {$timeStampEnd} ";
				
				$sql .= " GROUP BY `itemid` ";
				
				if (!empty($order))
					$sql .= " ORDER BY {$order} DESC ";
			} else {
				$sql = "SELECT `itemid`, SUM(`amount`) as amount, (sum(`silver_bind`)+sum(`silver_unbind`)) AS silver ,SUM(`silver_bind`) as silver_bind , SUM(`silver_unbind`) as silver_unbind "
					. " FROM ".$tableName." WHERE `mtype`=" . self::TYPE_BUY_ITEM
					. " AND `user_id`={$userid} "
					. " GROUP BY `itemid` ORDER BY `silver_bind` desc, `silver_unbind` desc, `amount` desc;";
			}
			$rs = GFetchRowSet($sql);
			
			return $rs;
		}

	}

}