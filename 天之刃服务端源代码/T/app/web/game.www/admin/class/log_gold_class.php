<?php

if ( ! defined('INCLUDE_CLASS_LOG_GOLD_CLASS_PHP_FILE') )
{
    define('INCLUDE_CLASS_LOG_GOLD_CLASS_PHP_FILE', 1);
include_once SYSDIR_ADMIN."/dict/gold_dic.php";	

class LogGoldClass
{
	const TYPE_BUY_ITEM			= 3003;		//购买道具
	
	/**
	 * WARNIING:流通类型必须全部再次加一次!!!!
	 * Enter description here ...
	 */

	
	public static function  getCirculationGoldTypes(){
		return array(3002,4003,4005);
	}
	
	
	public static function GetTypeName($typeid)
	{
		$arr = LogGoldClass::GetTypeList();
		if (isset($arr[$typeid]))
			return $arr[$typeid];
		else
			return '未知';
	}

	public  function GetTypeList(){
		global $GOLD_OPTION_LIST;
		$list = $GOLD_OPTION_LIST;
		$result_arr = array(); 
		foreach ($list as $key => $value){
			$result_arr[$key] = $value['item_name'];
		}
		return $result_arr;
	
	}			
	
	/**
	 * 哪些元宝开支被算入"消费"统计
	 * 用于消费统计
	 */
	public static function getSpendTypeList() {
		return 	array(
			//消费
//			3001=>'GM后台扣除元宝',   //暂时没用
			3003=>'系统商店购买道具',
			3004=>'训练场离线挂机',
//			3005=>'复活失去元宝',		//暂时没用
			3006=>'开启门派地图扣除元宝',
//			3007=>'镖车任务消费元宝',	//暂时没用
			3008=>'变性扣除元宝',
			3009=>'师徒副本刷幸运积分扣除元宝',
			3010=>'捐献监狱建设费扣除元宝',
			3015=>'刷新累积经验消耗元宝',
			3014=>'自动任务扣除元宝',
			3011=>'连续登录奖励购买',
			3012=>'购买活跃度扣除元宝',
            3013=>'宠物改名扣除元宝',
			3014=>'自动任务扣除元宝',
			3015=>'刷新累积经验消耗元宝',
			3016=>'坐骑续期消耗元宝',
			3019=>'开通VIP',
			3020=>'购买活动勋章扣除元宝',
            3021=>'宠物训宠加速完成',
            3022=>'鄱阳湖副本门票',
  			3023=>'宠物面板延寿', 
  			3024=>'宠物增加技能栏',  
  			3025=>'宠物强行训练', 
            3026=>'交易失去元宝',
            3027=>'摆摊购买道具获得元宝',  
			3028=>'自动个人拉镖消耗元宝',
			3029=>'购买英雄副本次数消耗元宝',
			3030=>'刷新宠物蛋消耗元宝',
			3031=>'开箱子消耗元宝',
			3032=>'市场购买失去元宝',
			3033=>'VIP开通远程仓库失去元宝',
			3034=>'创建门派手续费',
			3035=>'改变宠物训练模式消费元宝',
			3036=>'添加宠物训练空位消费元宝',
			3037=>'清除宠物突飞猛进冷却时间消费元宝',
			3038=>'门派捐献消费元宝',
		);
	}
	
    /*
     * 获得所有消耗类型的操作(元宝使用日志类型)
     *
     * 如果元宝使用后，就消失了（系统回收了），则这种操作属于消耗类型
     * 但是类似玩家之间交易，或者玩家在市场上花元宝买东西，则这种属于流通类型
     * 					因为元宝只是从一个玩家跑到另外一个玩家帐号里去而已。
     * 如果元宝是从充值，或者GM后台赠送等，则这种属于新增类型。
     */
    public static function GetConsumeTypeList()
    {
    	$all = self::GetTypeList();
		$gain = self::GetGainTypeList();
    	$circulated = self::GetCirculatedTypeList();

    	foreach($gain as $k=>$v)
    		unset($all[$k]);
    	foreach($circulated as $k=>$v)
    		unset($all[$k]);

    	//根据KEY计算数组差集
    	// 消耗类型 = 所有类型  - 新增类型 - 流通类型
    	return $all;

//		unset($data[self::TYPE_MARKET_BUY_ITEM]);
//		unset($data[self::TYPE_HERO_TRAINING_REFUND]);
//		unset($data[self::TYPE_GAIN_PAY_GOLD]);
//		unset($data[self::TYPE_GAIN_EXCHANGE]);
//		unset($data[self::TYPE_LOSE_EXCHANGE]);
//		unset($data[self::TYPE_GAIN_MARKET_SELL]);
//		unset($data[self::TYPE_GAIN_USE_ITEM]);
//		unset($data[self::TYPE_GAIN_GM_GIVE]);
//		unset($data[self::TYPE_SELL_ITEM]);
//
//		return $data;
    }

    /*
     * 获得所有新增类型的操作(元宝使用日志类型)
     */
    public static function GetGainTypeList()
    {
    	$data = array(
    			4001,
    			4002,
    			4004,
    			4006,
    			4007,
    			4008,
    			//4009,
    			4010,
    			);
    	return array_flip($data);	//返回的数组下标是各个类型的ID值，而数组项的值，请忽略

    }

    /*
     * 获得所有 流通类型的操作
     */
    public static function GetCirculatedTypeList()
    {
    	$data = array(
    			3002,
    			4003,
    			4005
    			);
    	return array_flip($data);   //返回的数组下标是各个类型的ID值，而数组项的值，请忽略
    }

	/**
	 * 查询[start, end]期间"消费量"达到sum值的玩家的数量
	 * @return array((`user_id`=>UserID, `gold_spent`=>GoldSpent), ...)
	 */
	public static function filterSpentSumInTimespan($start, $end, $sum) {
		$_uid_arr = array();
		$sql = "SELECT `user_id`, SUM(`gold_bind`)+SUM(`gold_unbind`) AS `gold_spent` FROM `t_log_use_gold` " . 
				"WHERE `mtime`>=" . $start  ." AND `mtime`<=" . $end . " AND ";
		if($types = self::getSpendTypeList()) {
			$sql .= "(";
			foreach($types as $mtype => $_desc) {
				$sql .= "`mtype`=$mtype or ";
			}
			$sql = trim($sql, " or ");
			$sql .= ") ";
			$sql .= "GROUP BY `user_id` HAVING SUM(`gold_bind`)+SUM(`gold_unbind`)>=" . $sum;
			$_uid_arr = GFetchRowSet($sql);
		}
		return $_uid_arr;
	}


	/**
	 * 查询[start, end]期间玩家充值元宝量
	 */
	public function getPaySumInTimespan($start, $end) {
		$sql = "select sum(`pay_gold`) as G from `tlog_pay` where `user_id`=" . $this->userid . " and ";
		if($start)
			$sql .= " `mtime`>=$start and ";
		if($end)
			$sql .= " `mtime`<=$end ";
		$sql = trim($sql, "and ");
		$rs = GFetchRowOne($sql);
		return intval($rs['G']);
	}

	/**
	 * 查询[start, end]期间玩家充值和被给予的元宝量
	 */
	public function getPayAndGivenSumInTimespan($start, $end) {
		$sql = "select sum(`pay_gold`) as G1, sum(`give_gold`) as G2 from `tlog_pay` where `user_id`=" . $this->userid . " and ";
		if($start)
			$sql .= " `mtime`>=$start and ";
		if($end)
			$sql .= " `mtime`<=$end ";
		$sql = trim($sql, "and ");
		$rs = GFetchRowOne($sql);
		return intval($rs['G1'] + $rs['G2']);
	}
	
	/**
	 * 查询[start, end]期间玩家消费的元宝量
	 */
	public function getSpentSumInTimespan($start, $end) {
		global $cache;
		$cache_key = GUserGoldSpentInTimespan . $this->userid;
		$rs = $cache->fetch($cache_key);
		if(!is_array($rs))
			$rs = array();
		if($rs['start'] != $start || $rs['end'] != $end) {
			$sum = array();
			if($types = self::getSpendTypeList()) {
				$sql = "select SUM(`gold_bind`)+SUM(`gold_unbind`) as g from `t_log_use_gold` where `user_id`=" . $this->userid . " and ";
				if($start)
					$sql .= " `mtime`>=$start and ";
				if($end)
					$sql .= " `mtime`<=$end and ";
				$sql .= "(";
				foreach($types as $mtype => $_desc) {
					$sql .= "`mtype`=$mtype or ";
				}
				$sql = trim($sql, " or ");
				$sql .= ") ";
				$sum = GFetchRowOne($sql);
			}
			$rs = array('start' => $start, 'end' => $end, 'sum' => intval($sum['g']));
			$cache->store($cache_key, $rs);
		}
		return $rs['sum'];
	}
	
	/**
	 * 清空消费量缓存
	 */
//	public static function clearSpentSumCache($userid, $for_time = 0) {
//		global $cache;
//		$cache_key = GUserGoldSpentInTimespan . $userid;
//		$rs = $cache->fetch($cache_key);
//		if($rs['start'] <= $for_time && $rs['end'] >= $for_time)
//			$cache->delete($cache_key);
//	}
	
	/*
	 * 计算玩家 累积总共充值RMB金额在多少元以下，默认为0表示非RMB玩家
	 * 暂时分3个区间，[0,50]  (50,200]   (200, 很大的不可能的一个数:9个9]
	 */
	public function CalcPayMoneyLevel()
	{
		$sql = "SELECT SUM(`pay_money`) AS `s` FROM `tlog_pay` WHERE `user_id`='{$this->userid}' ";

		
		$row = GFetchRowOne($sql);
		$sum = intval($row['s']);

		$f = array();
		$f['id'] = $this->userid;
		if ($sum <= 50)
		{
			$f['pay_money_level'] = 50;
		}
		else if ($sum <= 200)
		{
			$f['pay_money_level'] = 200;
		}
		else if ($sum <= 999999999)
		{
			$f['pay_money_level'] = 999999999;
		}
		else
		{
			$f['pay_money_level'] = -1;
		}

		$sqlUpdate = makeUpdateSqlFromArray($f, TBL_USER, 'id');
		$dbW->sql_query($sqlUpdate);

	}


	/**
	 * 是否已经记录有该订单
	 * 无事务处理
	 */
	public function isExistPayOrderId($order_id)
	{
		$sql = "SELECT count(id) as c FROM `tlog_pay` WHERE pay_num='{$order_id}'";
		$rs = GFetchRowOne($sql, getDbConnWrite());
		if (! isset($rs['c']) )
			return true;  //数据库查询出错时，当做该订单已经记录

		return ($rs['c']>0);
	} 

}

}
