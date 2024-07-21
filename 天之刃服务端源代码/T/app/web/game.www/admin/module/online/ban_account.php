<?php
//TODO:需要增加用户的安全验证
//@1-10 添加踢摊位下线功能 by natsuki
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php"; 
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

$action = $_REQUEST['action'];
$keyWord = SS($_REQUEST['keyWord']);
$pageno = intval($_REQUEST['page']);
if ($pageno <= 0)
	$pageno = 1;
$tblRb = T_DB_ROLE_BASE_P;
$tblRa = T_DB_ROLE_ATTR_P;
$tblBanRole = T_BAN_ROLE_LIST;


if ('ajaxKickStall' == $action){
	$roleId = intval($_REQUEST['role_id']);
	$roleName = SS(trim($_REQUEST['role_name']));
	$logger = new AdminLogClass();
	$logger->Log(AdminLogClass::TYPE_KICK_STALL,'T摆摊',"",'',$roleId,$roleName);
	//logKickStall($roleId,trim(SS($_REQUEST['role_name'])));
	$result = getJson(ERLANG_WEB_URL."/account/kick_stall/$roleId");
	die($result['result']);
} else if ('search'==$action) {
	$sqlRoleCnt = " SELECT COUNT(`role_id`) as cnt FROM {$tblRa} WHERE `role_name`='{$keyWord}' OR `last_login_ip`='{$keyWord}'";
	$rsCnt = GFetchRowOne($sqlRoleCnt);
	$count_result = $rsCnt['cnt'];
	$offset = ($pageno-1) * LIST_PER_PAGE_RECORDS;
	$limit = LIST_PER_PAGE_RECORDS;
	$pagelist	= getPages($pageno, $count_result);
	
	$sqlRole = "SELECT rb.role_id, rb.role_name, rb.account_name, ra.last_login_ip, ra.level
					  FROM {$tblRb} rb, {$tblRa} ra
					  WHERE ( BINARY rb.role_name='{$keyWord}' OR ra.last_login_ip='{$keyWord}') AND rb.role_id=ra.role_id LIMIT {$offset},{$limit} ";
	$rsRole = GFetchRowSet($sqlRole);
	
	$arrRoleIDs = array();
	foreach ($rsRole as &$row) {
		array_push($arrRoleIDs,$row['role_id']);
	}
	$rsPay = getPayData($arrRoleIDs);
	$rsOnline = getOnlineData($arrRoleIDs);
	$arrSearchResult = formatData($rsRole, $rsPay, $rsOnline);
} else if ('doBan'==$action) {
	$ban = $_REQUEST['ban'];
	$banRoleID = intval($_REQUEST['banRoleID']);
	
	if ($banRoleID) {
		if ($ban[$banRoleID]) {
			$banRoles[] = $ban[$banRoleID];
		}
	}else{
		$banRoles = $ban;
	}
	if (!empty($banRoles)) {
		global $auth;
		$admin_name = $auth->username();
		$loger = new AdminLogClass();
		foreach ($banRoles as $banRole) {
			$role_id = $banRole['role_id'];
			$role_name = SS($banRole['role_name']);
			$account_name = SS($banRole['account_name']);
			$ban_time = intval($banRole['ban_time']);
			$ban_reason = SS($banRole['ban_reason']);
			if (99999 == $ban_time) {
				$end_time = 99999;
			}else{
				$end_time = time() + $ban_time*3600;
			}
			$sqlInsert = " INSERT INTO `{$tblBanRole}` 
								(`role_id`, `role_name`, `account_name`, `end_time`, `admin_name`, `ban_reason`) 
						   VALUES ({$role_id}, '{$role_name}', '{$account_name}', {$end_time}, '{$admin_name}', '{$ban_reason}')  
						   ON DUPLICATE KEY UPDATE `end_time`={$end_time}, `admin_name`='{$admin_name}', `ban_reason`='{$ban_reason}' ";
			GQuery($sqlInsert);
			$loger->Log(AdminLogClass::TYPE_BAN_USER,'封禁帐号',"",'','',$role_name);
		}
		rewriteCacheFile();//重新生成缓存文件
	}
} else if ('doUnBan' == $action) {
	$role_id = intval($_GET['role_id']);
	$role_name = SS($_GET['role_name']); 
	$sqlUnBanRole = " DELETE FROM {$tblBanRole} WHERE role_id={$role_id} ";
	GQuery($sqlUnBanRole);
	rewriteCacheFile();//重新生成缓存文件
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_UNBAN_USER,'解封帐号',"",'','',$role_name);
} else if ('kick' == $action) {
	$role_id = intval($_GET['role_id']);
	$role_name = SS($_GET['role_name']);
	$result = getWebJson("/online?method=kick&roleid={$role_id}");
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_KICK_USER,'踢玩家下线',"",'',$role_id,'');
	if ('ok'==$result['result']) {
		echo '<script language="javascript">alert("踢玩家下线成功，稍后会将玩家状态更新为离线");</script>';
	}else {
		echo '<script language="javascript">alert("踢玩家下线失败，可能服务没启动。");</script>';
	}
} else if ('rebuild'==$action) {
	rewriteCacheFile();//重新生成缓存文件
}


$where = $keyWord ?  " AND ( BINARY brl.role_name='{$keyWord}' OR ra.last_login_ip='{$keyWord}') " : '';
$sqlBanRoles = "SELECT brl.*,ra.level, ra.last_login_ip 
				FROM {$tblBanRole} brl, db_role_attr_p ra 
				WHERE ra.role_id = brl.role_id {$where} ";
$rsBanRoles = GFetchRowSet($sqlBanRoles);
$arrRoleIDs = array();
foreach ($rsBanRoles as &$row) {
	array_push($arrRoleIDs,$row['role_id']);
}
$rsPay = getPayData($arrRoleIDs);
$rsOnline = getOnlineData($arrRoleIDs);
$arrBanRoles = formatData($rsBanRoles, $rsPay, $rsOnline);	

$arrBanTime = array(
	72    =>'限制72小时',
	24*7  =>'限制一个星期',
	24*31 =>'限制一个月',
	24    =>'限制24小时',
	12    =>'限制12小时',
	6     =>'限制6小时',
	3     =>'限制3小时',
	1     =>'限制1小时',
	99999 =>'永久限制',
);
$data = array(
	'keyWord'=>$keyWord,
	'arrBanTime' => $arrBanTime,
	'arrSearchResult'=>$arrSearchResult,
	'arrBanRoles' => $arrBanRoles,
	'record_count' => $count_result,
	'page_list' => $pagelist,
	'page_count' => ceil($count_result / LIST_PER_PAGE_RECORDS),
	'arrBandReason'=>getReason()
);
$smarty->assign($data);
$smarty->display ( 'module/online/ban_account.tpl' );

exit();
/////////////////////

//查充值情况：
function getPayData($arrRoleIDs)
{
	if(!empty($arrRoleIDs)){
		$tblPay = T_DB_PAY_LOG_P;
		$strRoleIDs = implode(',',$arrRoleIDs);
		$sqlPay = "SELECT SUM(`pay_money`) AS total_pay, role_id 
				   FROM  {$tblPay}
				   WHERE role_id IN({$strRoleIDs})
				   GROUP BY role_id ";
		$rsPay = GFetchRowSet($sqlPay);
	}
	return $rsPay;
}

//查在线情况：
function getOnlineData($arrRoleIDs)
{
	if(!empty($arrRoleIDs)){
		$tblOnline = T_USER_ONLINE;
		$strRoleIDs = implode(',',$arrRoleIDs);
		$sqlOnline = "SELECT role_id FROM {$tblOnline} WHERE role_id IN({$strRoleIDs}) ";
		$rsOnline = GFetchRowSet($sqlOnline);
	}
	return $rsOnline;
}

function formatData($rsRoles, $rsPay, $rsOnline)
{
	foreach ($rsRoles as &$row) {
		if ($row['end_time']) {
			if( 99999 == $row['end_time'] ) {
				$row['end_time_str'] = '无限期封禁';
			}elseif (time() > $row['end_time']){
				$row['end_time_str'] = '过期已解禁';
			}else {
				$row['end_time_str'] = date('Y-m-d H:i:s',$row['end_time']);
			}
		}
		$row['total_pay'] = 0;
		$row['online']  = 0;
		if (is_array($rsPay)) {
			foreach ($rsPay as $key => &$pay){
				if ($pay['role_id'] == $row['role_id']) {
					$row['total_pay'] = $pay['total_pay'];
					unset($rsPay[$key]);
					break;
				}
			}
		}
		if (is_array($rsOnline)) {
			foreach ($rsOnline as $key => &$online){
				if ($online['role_id'] == $row['role_id']) {
					$row['online'] = 1;
					unset($rsOnline[$key]);
					break;
				}
			}
		}
	}
	return $rsRoles;
}

function getReason(){
	return array(
		'此账号涉及盗号问题',
		'此账号存在违规操作',
		'散布虚假信息，造成不良影响',
		'在游戏中假冒GM或其他客户服务人员',
		'使用第三方软件进行游戏，破坏游戏平衡',
		'使用违反命名规则之角色名称进行注册',
		'利用游戏提供的功能进行非法实物交易',
		'利用系统的BUG、漏洞为自己及他人牟利',
		'不断吵闹、重复发言、不断打广告、恶意刷屏',
		'辱骂、人身攻击其他玩家，妨碍他人正常游戏',
	);
}