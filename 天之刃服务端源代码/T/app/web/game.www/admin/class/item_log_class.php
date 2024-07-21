<?php

if ( ! defined('ADMIN_CLASS_ITEM_LOG_CLASS_PHP_FILE') )
{
	define('ADMIN_CLASS_ITEM_LOG_CLASS_PHP_FILE', 1);
	class ItemLogClass{

		function __construct(){
		}

		function __destruct(){
		}

		function getItemLog($userid, $itemid, $start_time, $end_time, $tableSuffix, $orderby, $pageno,&$rowcnt,$itemPerPage=LIST_PER_PAGE_RECORDS)
		{
			$table = DB_MING2_LOGS.'.'.T_LOG_ITEM_PREF.$tableSuffix;
			$where = " AND `userid`={$userid} AND start_time BETWEEN {$start_time} AND {$end_time} ";
			$where .= $itemid ? " AND itemid={$itemid} " : '';
			$sqlCnt = " SELECT COUNT(*) AS cnt FROM {$table}  WHERE TRUE {$where} ";
			$rsCnt = GFetchRowOne($sqlCnt);
			$rowcnt = intval( $rsCnt['cnt'] );
			$itemPerPage = intval($itemPerPage);
			$totalPage = ceil($rowcnt/$itemPerPage);
			$offset = $totalPage > 0 ? ($pageno-1) * $itemPerPage : 0 ;
			$sql = " SELECT * FROM {$table} WHERE TRUE {$where} ORDER BY {$orderby} LIMIT {$offset} ,{$itemPerPage} ";
			echo $sql;
			return GFetchRowSet($sql);
		}

		function getItemLogManage($userid, $start_date, $end_date, $itemid, $actions, $pageno,&$rowcnt,$itemPerPage=LIST_PER_PAGE_RECORDS)
		{
			$startTime=strtotime($start_date);
			$endTime = strtotime($end_date)+86400-1;
			$startYear = date('Y',$startTime);
			$endYear = date('Y',$endTime);
			$startWeek = intval(date('z',$startTime)/7)+1;
			$endWeek = intval(date('z',$endTime)/7)+1;

			$totalWeek = $endYear * 53 + $endWeek - ( $startYear * 53 + $startWeek ) + 1; //需要查的总共有几周
			for ($i=0;$i<$totalWeek;$i++){
				$year = $startYear + ceil($i/53);
				$week = ($startWeek + $i) % 53;
				$week = 0 == $week ? 53 : $week;
				$suffix = $week < 10 ? $year.'_0'.$week : $year.'_'.$week;
				$tables[] = DB_MING2_LOGS.'.'.T_LOG_ITEM_PREF.$suffix;
			}

			$whereUserID = $userid ?  " AND `userid`={$userid} " : '';
			$whereItemID = $itemid ?  " AND itemid={$itemid} " : '';
			$whereAction = is_array($actions) && !empty($actions) ? ' and `action` in ('.implode(',',$actions).')' : '';
			$where = " WHERE TRUE {$whereUserID} AND start_time BETWEEN {$startTime} AND {$endTime} {$whereItemID} {$whereAction} ";
			foreach ($tables as &$table) {
				$sqls['cnt'][] = "SELECT count(*) as cnt FROM {$table} {$where} ";
				$sqls['log'][] = "SELECT * FROM {$table} {$where} ";
			}
			$sqlCnt = implode( ' UNION ',$sqls['cnt']);
			$sqlLog = implode( ' UNION ',$sqls['log']);
			$offset = $pageno > 1 ? ($pageno-1) * $itemPerPage : 0;
			$sqlLog .= " ORDER BY `start_time` DESC LIMIT {$offset} , {$itemPerPage} ";
			//echo "$sqlLog";
			$rsCnt = GFetchRowSet($sqlCnt);
			$rsLog = GFetchRowSet($sqlLog);
			foreach ($rsCnt as &$row) {
				$rowcnt += $row['cnt'];
			}
			return $rsLog;

		}

		/**
		 * 格式化日期
		 *
		 * @param string $startDate
		 * @param string $endDate
		 * @return array
		 */
		function formatTime($startDate,$endDate)
		{

			if (!$startDate || !$endDate) {
				$currentWeekStartDiff = intval(date('z')/7) * 7 ;
				$currentWeekEndDiff = $currentWeekStartDiff + 6;
				$tmpYearStartTime = strtotime(date('Y').'-01-01');
				$tmpStartTime = strtotime("+{$currentWeekStartDiff}day",$tmpYearStartTime);
				$tmpEndTime = strtotime("+{$currentWeekEndDiff}day",$tmpYearStartTime);
			}else{
				$tmpStartTime = strtotime($startDate);
				$tmpEndTime = strtotime($endDate);
				$tmpStartTime = $tmpStartTime ? $tmpStartTime : time();
				$tmpEndTime = $tmpEndTime ? $tmpEndTime : time();
			}
			$startDateOfYear = date('z',$tmpStartTime); //算出 $startDate 是一年中的第几天
			$endDateOfYear = date('z',$tmpEndTime);
			$startWeekOfYear = ceil(($startDateOfYear+1)/7);  //算出 $startDate 属于一年中的第几周（非自然周）
			$endWeekOfYear = ceil(($endDateOfYear+1)/7);

			$year = date('Y',$tmpStartTime);
			$yearStartTime = strtotime($year.'-01-01');
			$week = $startWeekOfYear > 9 ?  $startWeekOfYear : '0'.$startWeekOfYear ;

			if ($startWeekOfYear == $endWeekOfYear) {
				$arr['start_time'] = strtotime("+{$startDateOfYear}day",$yearStartTime);
				$arr['end_time'] = strtotime("+{$endDateOfYear}day",$yearStartTime)+86400 -1;
				$arr['startDate'] = date('Y-m-d',$arr['start_time']);
				$arr['endDate'] = date('Y-m-d',$arr['end_time']);
			}else {
				$diffDay = $week*7;
				$arr['start_time'] = strtotime("+{$startDateOfYear}day",$yearStartTime);
				$arr['end_time'] = strtotime("+{$diffDay}day",$yearStartTime)-1;
				$arr['startDate'] = date('Y-m-d',$arr['start_time']);
				$arr['endDate'] = date('Y-m-d',$arr['end_time']);
			}
			$arr['week'] = $week;
			$arr['year'] = $year;
			$arr['suffix'] = $year.'_'.$week;
			return $arr;
		}

		//=====注意：以下配置若有修改，也必须同时更新 update/stat_item_consume_order.php============
		public static $itemLogType = array(
			1000 => '（其他）获得',
			1001 => '后台赠送',
			1002 => '系统赠送',
			1003 => '使用礼包获得',
			1004 => '采集获得',
			1005 => '拾取获得',
			1006 => '任务获得',
			1007 => '师徒奖励',
			1008 => '活动奖品',
			1009 => '新手目标奖品',
			1010 => '商店购买',
			1011 => '交易获得',
			1012 => '摆摊获得',
			1013 => '打造获得',
			1014 => '合成获得',
			1015 => '拆卸获得',
			1016 => '装备升级获得',
			1017 => '装备分解获得',
			1018 => '炼制获得',
			1019 => '开孔获得',
			1020 => '信件附件获得',
			1021 => 'NPC兑换获得',
			1022 => '节日活动获得',
			1023 => '大明宝藏活动的采集获得',
			1024 => '进入师门同心副本获得',
			1025 => '活跃度奖励获得',
			//1026 => '领取连续登录奖励获得',
			1027 => '领取官印',
			1028 => '门派仓库领取获得',
			1029 => '日常福利获得',
			1030 => '场景大战副本获得',
			1031 => '场景大战副本采集获得',
			1032 => '道具奖励获得',
			1033 => '强化获得',
			1034 => '镶嵌获得',
			1035 => '天工炉取回物品获得',
			1036 => '提升装备颜色获得',
			1037 => '宠物炼制获得',
			1038 => '首充礼包获得',
			1039 => '单次充值礼包获得',
			1040 => '天工开物获得',
			1042 => '市场购买获得',
			1043 => '宝物空间获得',
			1044 => '个人副本翻牌获得',
			1045 => '声望兑换获得',
			1046 => '装备重铸获得',
			1047 => '特殊活动获得',
			1048 => '装备附魔获得',
			1049 => '特殊使用物品获得',
			1050 => '刃目标获得',
			2000 => '（其他）失去',
			2001 => '出售给系统',
			2002 => '交易失去',
			2003 => '摆摊出售',
			2004 => '手动丢弃',
			2005 => '使用失去',
			2006 => '任务扣除',
			2007 => '活动扣除',
			2008 => '装备重铸失去',
			2009 => '重新绑定失去',
			2010 => '强化失去',
			2011 => '打造失去',
			2012 => '合成失去',
			2013 => '拆卸失去',
			2014 => '镶嵌失去',
			2015 => '装备升级失去',
			2016 => '装备分解失去',
			2017 => '五行改造失去',
			2018 => '炼制失去',
			2019 => '掉落失去(死亡掉落)',
			2020 => '开孔失去',
			2021 => '信件附件失去',
			2022 => 'NPC兑换失去',
			2023 => '退出师门同心副本失去',
			2024 => '回收官印',
			2025 => '门派仓库存入失去',
			2026 => '天工炉取回物品失去',
			2027 => '提升装备颜色失去',
			2028 => '市场出售',
			2029 => '宝物空间提取失去',
			2030 => '宝物空间销毁失去',
			2031 => '宠物突飞猛进失去',
			2032 => '装备附魔失去',
			2033 => '任务扣除物品失去',
			2034 => '特殊使用物品扣除',

			3001 => '把物品移出摊位',
			3002 => '把物品移入摊位',
            3003 => '刷新累积经验失去',
            3004 => '鲜花赠送失去',
		);
		//=====注意：以上配置若有修改，也必须同时更新 update/stat_item_consume_order.php============

		/**
		 * 取得所有消耗类别
		 * @return array
		 */
		public static function getConsumType(){
			$types = array();
			foreach (self::$itemLogType as $k => $v){
				if ($k>=2000 && $k <3000) {
					$types[$k] = $v;
				}
			}
			return $types;
		}
	}

}