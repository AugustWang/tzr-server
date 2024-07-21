<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/log_gold_class.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';

if (!isset($_REQUEST['level_type']))
	$level_type = -1;
else
{
	$level_type = trim(SS($_REQUEST['level_type']));
}


if ( !isset($_REQUEST['dateStart'])){
	$start_day = GetTime_Today0() - 7*86400;
	$dateStart = strftime("%Y-%m-%d",$start_day);
}
else if ( $_REQUEST['dateStart'] == 'ALL') {
    $dateStart  = SERVER_ONLINE_DATE;
}
else
	$dateStart  = trim(SS($_REQUEST['dateStart']));

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time() );
else if ( $_REQUEST['dateStart'] == 'ALL') {
    $dateEnd = strftime ("%Y-%m-%d", time() );
}
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

if (! isset($_REQUEST['order']))
	$order = 'amount desc';
else
	$order = SS($_REQUEST['order']);

$nickname = trim($_POST['nickname']);
$acname = trim($_POST['acname']);


if((!empty($nickname) || !empty($acname))) {
	$role = UserClass::getUser(SS($nickname),SS($acname),null);
	if($role['role_id'] <= 0)
		echo '<font color=red>不存在该玩家，请检查并重新输入。</font>' . CRLF . CRLF;
}



$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59');
if( !$dateStartStamp || $dateStartStamp<strtotime(SERVER_ONLINE_DATE) ){
	$dateStartStamp = strtotime(SERVER_ONLINE_DATE);
}
$dateEndStamp = $dateEndStamp ? $dateEndStamp : time();

$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);

$dateStrPrev  = strftime ("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime ("%Y-%m-%d");
$dateStrNext  = strftime ("%Y-%m-%d", $dateStartStamp + 86400);


$type = $_REQUEST['type'] ? intval($_REQUEST['type']) : 0;

//获取道具列表
$itemMapArray = getItemMapArray();

if ($level_type != 'all')
{
	$userid = $role['role_id'];
	$checkArr = array('uid'=>$userid,'level_type'=>$level_type);
	$data = getGoldUseStatData($dateStartStamp, $dateEndStamp, $checkArr);
	
	$buy_stat = getBuyLogStats($level_type, $userid, $order, $dateStartStamp, $dateEndStamp);
	foreach ($buy_stat as $id => $row)
	{
		$iid = intval($row['itemid']);
		$buy_stat[$id]['item_data'] = $itemMapArray[$iid];
	}
}
else
{
	$data = getGoldUseStatDataAll($dateStartStamp, $dateEndStamp );
	
	
	$buy_stat = getUseGoldBuyItemDataAll($dateStartStamp, $dateEndStamp);
	foreach ($buy_stat as $id => $row)
	{
		
		foreach($row as $k => $v)
		{
			$iid = intval($v['itemid']);
			$buy_stat[$id][$k]['item_data'] = $itemMapArray[$iid];
		}
	}

	//将items中的每个ID对应的非RMB、50元以内...归类
	$all_case_by_id = array();
	foreach($itemMapArray as $key => $value)
	{
		foreach($buy_stat as $k => $v)
		{
			foreach($v as $kk => $vv)
			{
				if( $key == $vv['itemid'])
				{
					$all_case_by_id[ $key][$k] = $buy_stat[$k][$kk];
					$all_case_by_id[ $key]['name'] = $value['item_name'];
				}
			}
		}
	}
}

$tlist = LogGoldClass :: GetTypeList();

$typelistopgion  = getTypeListOption();

$order_list = getOrderList();

$smarty->assign("all_case_by_id",$all_case_by_id);
$smarty->assign("order_list",$order_list);
$smarty->assign("typeoption", $typelistopgion);
$smarty->assign("level_type", $level_type);
$smarty->assign("level_type_name", $typelistopgion[$level_type]);

$smarty->assign("buy_stat", $buy_stat);

$smarty->assign("typeoption", $typelistopgion);
$smarty->assign("level_type", $level_type);
$smarty->assign("level_type_name", $typelistopgion[$level_type]);

$smarty->assign("tlist", $tlist);
$smarty->assign("search_keyword1", $dateStartStr);
$smarty->assign("search_keyword2", $dateEndStr);

$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->assign("type", $type);
$smarty->assign("order", $order);

$smarty->assign("data", $data);
$smarty->assign("type_list_count", count(getTypeListOption2()) + 1);
$smarty->assign("search1", $acname);
$smarty->assign("search2", $nickname);

//$smarty->assign("buy_stat", $buy_stat);

$smarty->display("module/analysis/gold_use_stat.tpl");
exit;
//////////////////////////////////////////////////////////////

function getItemMapArray(){
	$itemMapArray = array();
	$itemList = AdminItemClass::getItemList();
	
	foreach($itemList as  $row) {
		$id = $row["typeid"];
		$itemMapArray[$id] = $row;
	}
	return $itemMapArray;
}

function getTypeListOption()
{
	return array(
			-1 => '全部玩家',
			0 => '非RMB玩家', 
//TODO:此处需要增加玩家的消费级别			
//			50 => '充值总额在50元以内的玩家', 
//			200 => '充值总额在50到200之间的玩家', 
//			999999999 => '充值总额大于200元的玩家',			
//			'all' => '各个付费级别段放一起来看',
			);
}

function getOrderList()
{
	return array(
			"amount desc" => '总个数↓',
			"amount asc"  => '总个数↑',
			"gold_bind desc" => '总元宝↓',
			"gold_bind asc"  => '总元宝↑',
			"op_count desc" => '操作次数↓',
			"op_count asc"  => '操作次数↑',
			"itemid desc" => '道具ID↓',
			"itemid asc"  => '道具ID↑',
			);
}

function getTypeListOption2()
{
	$type_list = getTypeListOption();
	unset($type_list[-1]);
	unset($type_list['all']);
	return $type_list;
}

/*
 * 各个付费级别段放一起来看
 */
function getGoldUseStatDataAll( $startTime, $endTime )
{
	$type_list = getTypeListOption2();
	
	//$txt_search = "<font color=red>各个付费级别段放一起来看</font>";
	
	$data =  array();
	foreach($type_list as $k=>$v)
	{
		$checkArr = array('level_type'=>$k);
		$data[ $k ] = getGoldUseStatData($startTime, $endTime, $checkArr); 
	}
	
	//new dBug($data);
	//return $data;
	
	$goldTypeList = LogGoldClass::GetTypeList();
	
	$datalist = array();
	foreach($goldTypeList as $_type => $_type_name)
	{
		$datalist[$_type]['name'] = $_type_name;
		
		foreach($type_list as $type_list_key=>$type_list_val)
		{
			$datalist[$_type]['gold_bind'][$type_list_key] = '-';
			$datalist[$_type]['c'][$type_list_key] = '-';
			$datalist[$_type]['ss'][$type_list_key] = '-';
			
			foreach($data as $pLv => $dataLv)
			{
				if ($pLv != $type_list_key)
					continue;
					
				foreach($dataLv as $pType=>$pData)
				{
					if ($pType == 'title')
						continue;
					
					foreach($pData['data'] as $item)
					{
						$desc = $item['desc'];
						if ($desc != $_type_name)
							continue;
							
						$datalist[$_type]['gold_bind'][$pLv] = $item['gold_bind'];
						$datalist[$_type]['c'][$pLv] 	= $item['c'];
						$datalist[$_type]['ss'][$pLv]   = $item['ss'];				
					}
				}
			}
		}
	}
	
	//new dBug($datalist);

	
	$type_consume = LogGoldClass::GetConsumeTypeList();
	$type_gain    = LogGoldClass::GetGainTypeList();
	$type_circula = LogGoldClass::GetCirculatedTypeList();
	
	$result = array();
	//$result['title'] = array('text' => $txt_search, 'day1' => GetDayString($startTime), 'day2' => GetDayString($endTime) );
	$result['元宝消耗'] = array();
	$result['元宝新增'] = array();
	$result['元宝流通'] = array();
	
	foreach($type_consume as $k=>$v)
	{
		$result['元宝消耗']['data'][] = $datalist[$k];
	}
	foreach($type_gain as $k=>$v)
	{
		$result['元宝新增']['data'][] = $datalist[$k];
	}
	foreach($type_circula as $k=>$v)
	{
		$result['元宝流通']['data'][] = $datalist[$k];
	}
	foreach($result as $k=>$v)
		$result[$k]['count'] = count($v['data']);
	
//	new dBug($result);
	return $result;
}

function getGoldUseStatData($startTime, $endTime, $checkArr = array())
{
	
	$userid = $checkArr['uid'];
	$level_type = $checkArr['level_type'];
		
	if ($userid > 0)	//统计指定的玩家，自动忽略其它任何条件
	{
		$txt_search = "统计<font color=red>玩家ID：" . $userid . "</font>的元宝使用情况";
		$sql = "SELECT l.`mtype`, count( l.`id` ) AS c, sum( l.`amount` ) AS ss ,( sum(`gold_bind`)+sum(`gold_unbind`) ) as gold, sum(l.`gold_bind`) AS gold_bind ,sum(l.`gold_unbind`) AS gold_unbind "
		 . " FROM `t_log_use_gold` as l, `db_role_base_p` as u"
		 . " WHERE `mtime`>={$startTime} AND `mtime`<={$endTime} "
		 . " AND l.`user_id`=u.`role_id` AND u.`role_id`=" . $userid
		 . " GROUP BY `mtype` " 
		 . " ORDER BY gold_bind DESC, ss DESC, c DESC ";
	}
	else	//以下 不针对特定某个人进行统计
	{
		if ($level_type == -1)
		{	//统计全部人的
			$txt_search = "统计<font color=red>全部玩家</font>的元宝使用情况";
			$sql = "SELECT `mtype`, count( `id` ) AS c, sum( `amount` ) AS ss ,( sum(`gold_bind`)+sum(`gold_unbind`) ) as gold, sum(`gold_bind`) AS gold_bind ,sum(`gold_unbind`) AS gold_unbind "
				. " FROM `t_log_use_gold` "
				. " WHERE `mtime`>={$startTime} AND `mtime`<={$endTime} "
				. " GROUP BY `mtype` ORDER BY gold_bind DESC, ss DESC, c DESC ";
		}
		else if ($level_type === 'all') 
		{	//各个付费级别段放一起来看
			$txt_search = "<font color=red>各个付费级别段放一起来看</font>";
			
			die('all');
		}
		else 
		{	//统计哪一个付费级别段的
			$_tmp_ll = getTypeListOption();
			$txt_search = "统计<font color=red>" .$_tmp_ll[$level_type] . "</font>的元宝使用情况";
			$sql = "SELECT l.`mtype`, count( l.`id` ) AS c, sum( l.`amount` ) AS ss ,( sum(`gold_bind`)+sum(`gold_unbind`) ) as gold, sum(l.`gold_bind`) AS gold_bind ,sum(l.`gold_unbind`) AS gold_unbind "
			 . " FROM `t_log_use_gold` as l, `db_role_base_p` as u"
			 . " WHERE `mtime`>={$startTime} AND `mtime`<={$endTime} "
			 . " AND l.`user_id`=u.`role_id` "
			 . " GROUP BY `mtype` " 
			 . " ORDER BY gold_bind DESC, ss DESC, c DESC ";
		}
	}
	//echo $sql ;

	$rs = GFetchRowSet($sql);   //取统计数据，并缓存数据库SQL查询结果
	if(!is_array($rs))
		return array();

	$tlist = LogGoldClass :: GetTypeList();
	$type_consume = LogGoldClass::GetConsumeTypeList();
	$type_gain    = LogGoldClass::GetGainTypeList();
	$type_circula = LogGoldClass::GetCirculatedTypeList();
	
	$result = array();
	$result['title'] = array('text' => $txt_search, 'day1' => GetDayString($startTime), 'day2' => GetDayString($endTime) );
	$result['元宝消耗'] = array();
	$result['元宝新增'] = array();
	$result['元宝流通'] = array();
	
	
	foreach($rs as $row) {
		$mtype = intval($row['mtype']);
		$row['desc'] = $tlist[$mtype];
		
		if (isset( $type_consume[$mtype] )) {
			$result['元宝消耗']['count'] ++;
			$result['元宝消耗']['data'][] = $row;
		}
		else if (isset( $type_gain[$mtype] )) {
			$result['元宝新增']['count'] ++;
			$result['元宝新增']['data'][] = $row;
		}
		else if (isset( $type_circula[$mtype] )) {
			$result['元宝流通']['count'] ++;
			$result['元宝流通']['data'][] = $row;
		}
		else { 
			$result['不明类型']['count'] ++;
			$result['不明类型']['data'][] = $row;
		}
	}
	
	foreach($result as $key=>$vv)
	if (is_array($vv) && $vv['count'] > 1)
	{
		$_sum_gold = 0;
		$_sum_bind_gold = 0;
		$_sum_unbind_gold = 0;
		foreach($vv['data'] as $v)
		{
			$_sum_gold += $v['gold'];
			$_sum_bind_gold += $v['gold_bind'];
			$_sum_unbind_gold += $v['gold_unbind'];
		}
		$result[$key]['count'] ++;
		$result[$key]['data'][] = array('desc' => '---汇总---', 
				'gold' => $_sum_gold, 
				'gold_bind' => $_sum_bind_gold, 
				'gold_unbind' => $_sum_unbind_gold, 
				'ss' => '--', 'c' => '--',
				'bgColor' => ' bgcolor="#EBF9FC"');
	}
	
	
	//new dBug($result);	

	return $result;
}


//指定玩家的购买历史记录统计
function getBuyLogStats ($level_type, $userid, $order, $timeStampStart = null, $timeStampEnd = null)
{
	$typeBuyItem = LogGoldClass::TYPE_BUY_ITEM;
	if (! $userid)
	{
		if($level_type == -1 || ($level_type == null && $level_type != 'all'))
		{
			$sql = "SELECT user_id,itemid,COUNT(itemid) as op_count, SUM(amount) as amount, " .
					"( sum(`gold_bind`)+sum(`gold_unbind`) ) as gold," .
					" SUM(`gold_bind`) as gold_bind , SUM(`gold_unbind`) as gold_unbind " . " FROM `t_log_use_gold` WHERE mtype={$typeBuyItem} ";
			if ($timeStampStart)
				$sql .= " AND mtime >= {$timeStampStart} ";
			if ($timeStampEnd)
				$sql .= " AND mtime <= {$timeStampEnd} ";
		}
		else
		{
			$sql = "SELECT tl.user_id,tl.itemid,COUNT(tl.itemid) as op_count, SUM(tl.amount) as amount, " .
					"( sum(`gold_bind`)+sum(`gold_unbind`) ) as gold," .
					" SUM(tl.gold_bind) as gold_bind,us.role_id " . " FROM `t_log_use_gold` tl,`db_role_base_p` us WHERE tl.mtype={$typeBuyItem} ";
			if ($timeStampStart)
				$sql .= " AND tl.mtime >= {$timeStampStart} ";
			if ($timeStampEnd)
				$sql .= " AND tl.mtime <= {$timeStampEnd} ";

			$sql .= " AND tl.user_id = us.role_id ";
			//$sql .= " AND tl.user_id = us.id AND us.pay_money_level =". $level_type;
		}


		if($level_type == -1 || ($level_type == null && $level_type != 'all'))
		{
			$sql .= " GROUP BY itemid ";
			if (! empty($order))
				$sql .= " ORDER BY {$order}";
		}
		else
		{
			$sql .= " GROUP BY tl.itemid ";
			if (! empty($order))
				$sql .= " ORDER BY {$order}";
		}



	}
	else
	{
		$sql = "SELECT `itemid`,COUNT(`itemid`) as op_count, SUM(`amount`) as amount, " .
				"( sum(`gold_bind`)+sum(`gold_unbind`) ) as gold," .
				" SUM(`gold_bind`) as gold_bind , SUM(`gold_unbind`) as gold_unbind " . " FROM `t_log_use_gold` WHERE `mtype`={$typeBuyItem} AND `user_id`={$userid} " ;
		if ($timeStampStart)
			$sql .= " AND mtime >= {$timeStampStart} ";
		if ($timeStampEnd)
			$sql .= " AND mtime <= {$timeStampEnd} ";
		$sql .= " GROUP BY itemid ";
		if (! empty($order))
				$sql .= " ORDER BY {$order}";
	}
	$rs = GFetchRowSet($sql);

	return $rs;
}

function getUseGoldBuyItemDataAll($dateStartStamp, $dateEndStamp)
{
	$type_list = getTypeListOption2();

	$data = array();
	foreach($type_list as $k => $v)
	{
		$data[$k] = getBuyLogStats ($k, $userid = null, $order = null, $dateStartStamp, $dateEndStamp);
	}
	return $data;
}

