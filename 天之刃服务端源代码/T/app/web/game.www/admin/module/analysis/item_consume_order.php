<?php
/**
 * 道具使用排行
 * @author linruirong@mingchao.com
 *
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include SYSDIR_ADMIN."/class/admin_item_class.php"; //道具列表
include SYSDIR_ADMIN."/class/item_log_class.php";//道具使用日志


if ( !isset($_REQUEST['dateStart'])){
	$start_day = GetTime_Today0() - 7*86400;
	$dateStart = strftime("%Y-%m-%d",$start_day);
}
elseif ( $_REQUEST['dateStart'] == 'ALL') {
    $dateStart  = SERVER_ONLINE_DATE;
}
else
	$dateStart  = trim(SS($_REQUEST['dateStart']));

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time() );
elseif ( $_REQUEST['dateStart'] == 'ALL') {
    $dateEnd = strftime ("%Y-%m-%d", time() );
}
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));
	
$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59');
$dateStartStamp = $dateStartStamp ? $dateStartStamp : strtotime(SERVER_ONLINE_DATE);
$dateEndStamp = $dateEndStamp ? $dateEndStamp : time();


$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);

$dateStrPrev  = strftime ("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime ("%Y-%m-%d");
$dateStrNext  = strftime ("%Y-%m-%d", $dateStartStamp + 86400);

$days = ceil(($dateEndStamp - $dateStartStamp)/86400);
$last_days_start = $dateStartStamp - $days * 86400;

$sql = "SELECT `consume_count` FROM ".T_STAT_ITEM_CONSUME." WHERE `mtime`>={$dateStartStamp} AND `mtime`<={$dateEndStamp}";
$rs  = GFetchRowSet($sql);

$tmp_rs = array();
foreach($rs as $key=>$value){
	$tmp_rs[$key] = extractData($value['consume_count']);
}

$consume_data = array();
if (is_array($tmp_rs)) {
	foreach($tmp_rs as $key=>$value){
		if (is_array($value)) {
			foreach($value as $k=>$v){
				$consume_data[$k] += $v;
			}
		}
	}	
}


$order_data = array();
$num = count($consume_data);
for($i=1;$i<=$num;$i++){
	$max_consume = 0;
	$max_key = 0;
	foreach($consume_data as $key=>$value){
		if($value >$max_consume){
			$max_consume = $value;
			$max_key = $key;
		}
	}
	$order_data[$max_key] = $max_consume;
	unset($consume_data[$max_key]);
}


$sql2 = "SELECT `consume_count` FROM ".T_STAT_ITEM_CONSUME." WHERE `mtime`>={$last_days_start} AND `mtime` < {$dateStartStamp}";
$rs2 = GFetchRowSet($sql2);

$tmp_rs2 = array();
foreach($rs2 as $key=>$value){
	$tmp_rs2[$key] = extractData($value['consume_count']);
}

$consume_data2 = array();
foreach($tmp_rs2 as $key=>$value){
	foreach($value as $k=>$v){
		$consume_data2[$k] += $v;
	}
}

$order_data2 = array();
$num = count($consume_data2);
for($i=1;$i<=$num;$i++){
	$max_consume = 0;
	$max_key = 0;
	foreach($consume_data2 as $key=>$value){
		if($value >$max_consume){
			$max_consume = $value;
			$max_key = $key;
		}
	}
	$order_data2[$max_key] = $max_consume;
	unset($consume_data2[$max_key]);
}

$order1 = array_keys($order_data);
$order2 = array_keys($order_data2);

foreach($order1 as $key=>$value){
	foreach($order2 as $k=>$v){
		if($value == $v){
			if($key > $k)$order[$value]['down'] = $key - $k;
			elseif($key < $k)$order[$value]['up'] = $k - $key;
		}
	}
	$order[$value]['today_order'] = $key+1;
}

$items = AdminItemClass::getItemHash();

$smarty->assign("order",$order);
$smarty->assign("items",$items);
//$smarty->assign("consume_data",$consume_data);
$smarty->assign("order_data",$order_data);

$smarty->assign("search_keyword1", $dateStartStr);
$smarty->assign("search_keyword2", $dateEndStr);

$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->display("module/analysis/item_consume_order.tpl");
?>







