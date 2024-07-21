<?php


//TODO:需要增加用户的安全验证
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php"; 
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/online_user_class.php';


$data = OnlineUserClass::getOnlineList();
$showData = array();

if (is_array($data)){
	foreach($data as $key => $row ){
		$showData[ $key ] = $row;
		$factionId = $row['faction_id'];
		if( $factionId==1 ){
			$showData[ $key ]['faction_name'] = "云州";
		}else if( $factionId==2 ){
			$showData[ $key ]['faction_name'] = "沧州";
		}else if( $factionId==3 ){
			$showData[ $key ]['faction_name'] = "幽州";
		}
	}
}

if (is_array($data))
	$record_count = intval(count($data));
	else
	$record_count = 0;

	$iplist = array();

if ($record_count > 0)
{

	foreach($data as $key => $row)
	{

		$_ip = $row['login_ip'];
		if (empty($_ip))
			$_ip = '未记录到IP';

		$iplist[$_ip]['count'] ++;
		$iplist[$_ip]['nickname_list'] .= $row['role_name'] . ',';
		$iplist[$_ip]['accname_list'] .= $row['account_name'] . ',';
	}

	foreach($iplist as $key => $row)
	{
		$iplist[$key]['nickname_list'] = trim($iplist[$key]['nickname_list'], ',');
		$iplist[$key]['accname_list'] = trim($iplist[$key]['accname_list'], ',');

		$r_count[$key]  = $row['count'];
		$r_ip[$key] = $key;
	}

	// 将数据根据 volume 降序排列，根据 edition 升序排列
	// 把 $data 作为最后一个参数，以通用键排序
	array_multisort($r_count, SORT_DESC, $r_ip, SORT_ASC, $iplist);

	foreach ($data as $key => $row) {
		$real_online_time[$key]  = $row['real_online_time'];
		$role_name[$key] = $row['role_name'];
	}
 
	// 将数据根据 volume 降序排列，根据 edition 升序排列
	// 把 $data 作为最后一个参数，以通用键排序
	array_multisort($real_online_time, SORT_DESC, $role_name, SORT_ASC, $data);

}

$ip_count = intval(count($iplist));

$smarty->assign('record_count', $record_count);
$smarty->assign('ip_count', $ip_count);
$smarty->assign('data', $showData);
$smarty->assign('iplist', $iplist);

$smarty->display("module/online/cur_online_user.tpl");

exit;
