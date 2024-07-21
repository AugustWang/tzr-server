<?php
/*
 * Author: sam, MSN: samual2004@hotmail.com 2009-4-30
 * 交易的查询
 */
 
 
 //如果什么都没有的话列出今天的


//1。默认今日交易
//2。找不到用户显示空

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);
define('NEVER', strtotime("2012-12-16"));
define('LEN_PER_PAGE',15);

//ajax显示某比交易的详情
if (isset($_REQUEST['id'])) {
	die("detail");
}

$accountName = SS(trim($_REQUEST['accountName']));
$roleName = SS(trim($_REQUEST['roleName']));
$start = strtotime($_REQUEST['start']) or $start = GetTime_Today0();

$end = strtotime($_REQUEST['end']) or $end = time();
$end += 60*60*24-1;

$pageId = intval($_REQUEST['pageId']) or $pageId = 1;


$userAry = UserClass::getUser($roleName,$accountName);
if ($userAry == false){
	$uid = 0;
}else{
	$uid = $userAry['role_id'];
	$roleName = $userAry['role_name'];
	$accountName = $userAry['account_name'];
}



$importantItems = array(
	20100003,20200003,20300003,20400003,20500003,20600003,20700003,20800003,20900003,10402125,
	21000003,21100003,21200003,21300003,21400003,21500003,21600003,21700003,21800003,20100004,
	20200004,20300004,20400004,20500004,20600004,20700004,20800004,20900004,21000004,21100004,
	21200004,21300004,21400004,21500004,21600004,21700004,21800004,20100005,20200005,20300005,
	20400005,20500005,20600005,20700005,20800005,20900005,21000005,21100005,21200005,21300005,
	21400005,21500005,21600005,21700005,21800005,20100006,20200006,20300006,20400006,20500006,
	20600006,20700006,20800006,20900006,21000006,21100006,21200006,21300006,21400006,21500006,
	21600006,21700006,21800006,10402123,10402223,10402323,10402423,10402523,10402124,10402224,
	10402225,10402325,10402425,10402525,10402126,10402226,10402326,10402426,10402526,10401003,
	10401004,10401005,10401006,10402324,10402424,10402524
);


//$uid = getUid($accountName,$roleName);

if (!isset($_REQUEST['accountName']) && !isset($_REQUEST['roleName'])) {
	$list = getTodayList($start,$end,$pageId);
	if (count($list) < 1) {
		echo "<font color='red'>今日无记录</font>";
	}
}else{
	$list = getResultList($uid,$start,$end,$pageId);

}

$count = $list['count'];
$list = $list['result'];

$other = array(
	'accountName'=>$accountName,
	'roleName'=>$roleName,
	'start'=>date('Y-m-d',$start),
	'end'=>date('Y-m-d',$end)
);

$pager = renderPageIndicator('exchange_manage.php',$pageId,$count,LEN_PER_PAGE,$other,'pageId');
$smarty->assign("URL_SELF", $_SERVER['PHP_SELF']);
$smarty->assign('start',date("Y-m-d",$start));
$smarty->assign('end',date("Y-m-d",$end));
$smarty->assign('accountName',$accountName);
$smarty->assign('roleName',$roleName);
$smarty->assign('list',$list);
$smarty->assign('pager',$pager);
//$smarty->assign('pageId',$pageId)
$smarty->display('module/gamer/exchange_manage.tpl');


function getTodayList($start,$end,$pageId){
	$start = $start or $start = strtotime('today');
	$end = $end or $end = strtotime('+1 day');
	return getResultList(0,$start,$end,$pageId);
}


function getNameOf($id){	
	$sql = "SELECT item_name from t_item_list where typeid = $id";
	$result = GFetchRowOne($sql);
	if (is_array($result)) {
		return $result['item_name'];
	}else {
		return "不知名物品($id)";
	}
}




/* 
punch_num 					= 48;	//当前打孔个数
stone_num 					= 49;	//当前镶嵌宝石个数
stones                      = 51;   //镶嵌的宝石的ID列表
five_ele_attr               = 58;   //装备五行属性
reinforce_result_list       = 60;   //强化结果历史的列表（强化等级和星级的结合整数）
*/


function getResultList($uid,$start,$end,$pageId = 1){
	$start = $start or $start = 0;
	$startIndex = ($pageId-1)*LEN_PER_PAGE;
	$end = $end or $end = strtotime('2012-12-16');
	if ($uid == 0) {
		$sql = "select SQL_CALC_FOUND_ROWS * from t_log_exchange where time > $start and time < $end order by id desc limit $startIndex,".LEN_PER_PAGE;
	}else {
		$sql = "select SQL_CALC_FOUND_ROWS * from t_log_exchange where time > $start and time < $end and (from_role_id = $uid or to_role_id = $uid) order by id desc limit $startIndex,".LEN_PER_PAGE;	
	}
	$result = GFetchRowSet($sql);
	$count = GFetchRowOne("select FOUND_ROWS() as counts");
	$count  = $count['counts'];
	
	foreach ($result as &$item) {
		$color_one = getDisplayColor($item['from_goods']);
		$color_two = getDisplayColor($item['to_goods']);
				
		$item['from_goods'] =  expandJson($item['from_goods']);
		$item['to_goods']  = expandJson($item['to_goods']);
		$from_silver =  expandJson($item['from_silver']);
		$item['from_silver'] = exchange_eilver($from_silver);
		$to_silver =  expandJson($item['to_silver']);
		$item['to_silver']= exchange_eilver($to_silver);
		$item['date_format'] = date("Y-m-d H:i:s",$item['time']);
		if ($color_one || $color_two) {
			$item['color'] = "#ff9999";
		}
		
	}
	return array(
		'result'=>$result,
		'count'=>$count
	) ;
}



/**
 * 潘婷需求,如果银票*数量*大于50,才会警报
 * Enter description here ...
 * @param $id
 * @param $num
 */
function judgeIfCashOverLimit($id,$num){
	$cashes = array(
		10100008,
		10100009,
		10100010,
		10100011,
		10100012
	);
	if(in_array($id, $cashes) && $num > 49){
		return true;
	}
	return false;
}




/*
家奇重新确认了
    内容是：
    交易整条为红色，表示某方交易的元宝数量大于 10 锭银子、灵石等级≥3级、材料等级≥3级、强化石≥4级、所有银票、装备颜色≥紫色
其中灵石、材料、强化石、银票的道具ID家奇已经给了
*/
function getDisplayColor($itemStr){
	global $importantItems;
	$ary = json_decode($itemStr,true);
	//malformated cause no color
	if (!is_array($ary) ){
		return false;
	}
	foreach ($ary as $item){
		$id = $item['id'] or $id = 0;
		$num = $item['num'] or $num = 0;
		//目前无装备颜色
		if (in_array($id, $importantItems) || $num > 99999 || judgeIfCashOverLimit($id,$num)){
			return true;
		}
	}
	return false;	
}





function expandJson($str){
	$colorAry = array(
		1=>'白色的',
		2=>'绿色的',
		3=>'蓝色的',
		4=>'紫色的',
		5=>'橙色的',
		6=>'金色的',
	);
	
	$finenessAry = array(
		1=>'普通的',
		2=>'精良的',
		3=>'优质的',
		4=>'无暇的',
		5=>'完美的'
	);	
	
	$ary = json_decode($str,true);
	//兼容错误格式,直接全部打出
	if (!is_array($ary)){
		return $str;	
	} 
	
	//兼容三种格式
	//1.只有id
	//2.id,num
	//3.id,num,color,fineness
	//
	
	
	
/*	 
punch_num 					= 48;	//当前打孔个数
stone_num 					= 49;	//当前镶嵌宝石个数
stones                      = 51;   //镶嵌的宝石的ID列表
reinforce_result_list       = 60;   //强化结果历史的列表（强化等级和星级的结合整数）	 
optional p_equip_five_ele               five_ele_attr               = 58;   //装备五行属性
*/
	$itemsAry = array();
	foreach ($ary as $item){
		$newAry = array();
		if (!is_array($item)){
			$newAry['name'] = getNameOf(intval($item));
			continue;
		}
		$newAry['name'] = getNameOf(intval($item['id']));
		$newAry['num'] = intval($item['num']);
		
		if (isset($item['color'])){
			$newAry['color'] = $colorAry[intval($item['color'])];
			$newAry['fineness'] = $finenessAry[intval($item['fineness'])];
		}		
		if (isset($item['punch_num'])){
			$newAry['punch_num'] = intval($item['punch_num']);	
		}
		if (isset($item['stones'])){
			$newAry['stones'] = $item['stones'];
		}
		if (isset($item['rein_id'])){
			$newAry['rein_id'] = $item['rein_id'];
		}				
		$itemsAry[] = $newAry;
	}
	return $itemsAry;
}





function getUid($accountName,$roleName){
	$sql = "select role_id from db_role_base_p where 1 = 1 ";
	if ($accountName) {
		$sql .= " and account_name = '$accountName' ";
	}
	if ($roleName) {
		$sql .= " and role_name = '$roleName' ";
	}
	
	$result = GFetchRowOne($sql);
	if (!is_array($result) || count($result) != 1) {
		return 0;	
	}
	return intval($result['role_id']);
}

function exchange_eilver($num){
	$wen = 0;
	$liang = 0;
	$ding = 0;
	$wen = $num%100;
	$liang = ($num/100)%100;
	$ding = floor($num/10000);
	if($wen!=0){$s1 = $wen.'文';}
	if($liang!=0){$s2 = $liang.'两';}
	if($ding!=0){$s3 = $ding.'锭';}
	
	$result = $s3.$s2.$s1;
	if($result==""){$result = "无";}
	return $result;
	
	
}
