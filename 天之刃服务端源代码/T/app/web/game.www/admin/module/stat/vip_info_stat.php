<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';

$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN."/class/vip_class.php";

$start = SS($_REQUEST['start']);
$end = SS($_REQUEST['end']);
if(empty($start)) $start = date('Y-m-d');
if(empty($end)) $end = date('Y-m-d');
$startstamp = strtotime($start);
$endstamp = strtotime($end) + 24*60*60-1;
$where = " pay_time > $startstamp AND pay_time < $endstamp ";
$sql = " SELECT a.role_id,b.role_name,b.account_name,a.pay_type,a.pay_time,a.is_first 
FROM `t_log_vip_pay` as a,`db_role_base_p` as b  WHERE $where and (a.role_id=b.role_id)";
$result = GFetchRowSet($sql);
$datalist =  groupByRole($result);
$all_count =  VipClass::getVipAllCount();
$over_time_count = VipClass::getVipOverTimeCount();
//-------------------------------------------------------
	
$smarty->assign('start',$start);
$smarty->assign('end',$end);
$smarty->assign('datalist',$datalist);
$smarty->assign('vip_all_count',$all_count);
$smarty->assign('vip_over_time_count',$over_time_count);
$smarty->display('module/stat/vip_info_stat.tpl');

//-------------------local function ------------------------
function groupByRole($resultList)
{
	global $db;
	
	$sqlVip = "SELECT role_id,pay_time FROM `t_log_vip_pay`  WHERE `is_first` = 1  ";
	$res_arr = GFetchRowSet($sqlVip);
	$pay_first = array();
	foreach ($res_arr as $val){
		$pay_first[$val['role_id']] = $val;
	}
	$datalist= array();
	foreach ($resultList as $item){
		$role_id = intval($item['role_id']);
		if (!isset($datalist[$role_id])){
			$datalist[$role_id] = array();
			$datalist[$role_id]['account_name'] = $item['account_name'];
			$datalist[$role_id]['role_name'] = $item['role_name'];
			$datalist[$role_id]['start_time'] =date('Y-m-d H:i:s', $pay_first[$role_id]['pay_time']);
			$datalist[$role_id]['open_type'] = getTypeContent($item['pay_type']);
			$vipRole = VipClass::getVipInfo($role_id);
			$datalist[$role_id]['total_time'] = $vipRole['total_time'];
			$datalist[$role_id]['vip_level'] = $vipRole['vip_level'];	
			$datalist[$role_id]['vip_end_time'] = date('Y-m-d H:i:s', $vipRole['end_time']);
			$datalist[$role_id]['is_over_time'] = true;
			if($vipRole['end_time']>time()) {
				$datalist[$role_id]['is_over_time'] = false;
			}
		}
		
		if($item['is_first']){
			$datalist[$role_id]['add_time'] .=date("Y-m-d H:i:s",$item['pay_time'])." : ".getTypeContent($item['pay_type'])."(首次)<br/>";	
		}else{
			$datalist[$role_id]['add_time'] .=date("Y-m-d H:i:s",$item['pay_time'])." : ".getTypeContent($item['pay_type'])."(续费)<br/>";
		}
	}
	return $datalist;
}
function getTypeContent($Type)
{
	$VipPayTypeArr = array(
		'11'=>"【VIP十日卡】",
		'12'=>"208元宝",
		'21'=>"【VIP月卡】",
		'22'=>"388元宝",
		'31'=>"【VIP季卡】",
		'32'=>"988元宝",
		'41'=>"【VIP半年卡】",
		'42'=>"1688元宝",
		'51'=>"【VIP年卡】",
		'52'=>"3376元宝",
		'101'=>"【VIP体验卡】",
		'111'=>"【vip三日卡】",
	);
	return $VipPayTypeArr[$Type];
}

