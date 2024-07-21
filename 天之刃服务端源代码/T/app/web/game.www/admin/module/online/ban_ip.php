<?php
//TODO:需要增加用户的安全验证
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php"; 
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$action = $_REQUEST['action'];
$ip = SS($_REQUEST['ip']);

$tblBanIP = T_BAN_IP_LIST;
$tblOnline = T_USER_ONLINE;
if ('chkOnline'==$action) {
	$sqlOnline = "SELECT count(*) as online_cnt FROM {$tblOnline} WHERE login_ip='{$ip}' ";
	$rsOnline = GFetchRowOne($sqlOnline);
	echo intval($rsOnline['online_cnt']);
	exit();
}

if ('add'==$action) {
	$ip = SS($_REQUEST['ip']);
	$ban_time = intval($_REQUEST['ban_time']);
	$end_time = time() + $ban_time*3600;
	$ban_reason = $_REQUEST['ban_reason'];
	global $auth;
	$admin_name = $auth->username();
	$err = array();
	if (!ereg("^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$",$ip)) {
		$err[] = "IP地址格式不正确";
	}
	if (!$ban_time) {
		$err[] = "请选择时间";
	}
	if (!$ban_reason) {
		$err[] = "请填写封禁的原因";
	}
	if ( empty($err) ) {
		$sqlInsert = " INSERT INTO `{$tblBanIP}` 
							(`ip`, `end_time`,`admin_name`,`ban_reason`) 
					   VALUES ('{$ip}', {$end_time}, '{$admin_name}', '{$ban_reason}')  
					   ON DUPLICATE KEY UPDATE `end_time`={$end_time}, `admin_name`='{$admin_name}', `ban_reason`='{$ban_reason}' ";
		GQuery($sqlInsert);
	}
	rewriteCache();//重新生成缓存文件
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_BAN_IP,'封禁IP:'.$ip,"",'','','');
}

if ('remove' == $action) {
	$ip = SS($_GET['ip']);
	$sqlUnBanIp = " DELETE FROM {$tblBanIP} WHERE ip='{$ip}' ";
	GQuery($sqlUnBanIp);
	rewriteCache();//重新生成缓存文件
	
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_BAN_IP,'解封IP:'.$ip,"",'','','');
}

if ('clear' == $action) {
	$ip = SS($_GET['ip']);
	$sqlUnBanIp = " DELETE FROM {$tblBanIP} WHERE end_time > ".time();
	GQuery($sqlUnBanIp);
	rewriteCache();//重新生成缓存文件
}

if ('rebuild'==$action) {
	rewriteCache();//重新生成缓存文件
}

$sql="SELECT * FROM {$tblBanIP} ORDER BY `end_time` DESC ";
$arrBanIPs = GFetchRowSet($sql);
foreach ($arrBanIPs as &$row) {
	$row['end_time_str'] = time() > $row['end_time'] ? '过期已解禁' : date('Y-m-d H:i:s', $row['end_time']);
}
//echo '<pre>';print_r($arrBanIPs);die();
$arrBanTime = array(
	72    =>'72小时后',
	24*7  =>'一个星期后',
	24*31 =>'一个月后',
	24    =>'24小时后',
	12    =>'12小时后',
	6     =>'6小时后',
	3     =>'3小时后',
	1     =>'1小时后',
);

$strErr = empty($err) ? '' : '错误：'.implode('<br />',$err);
$data = array(
	'arrBanTime' => $arrBanTime,
	'arrBanIPs' => $arrBanIPs,
	'strErr' => $strErr,
	'arrBandReason'=>getReason()
);
//echo '<pre>';print_r($arrSearchResult);die();
$smarty->assign($data);
$smarty->display ( 'module/online/ban_ip.tpl' );

exit();
/////////////////////

//重写缓存文件
function rewriteCache()
{
	$tblBanIP = T_BAN_IP_LIST;
	$file = SYSDIR_ROOT.'cache/data/base_limit_ip.php';
	$sqlBanList = " SELECT `ip`, `end_time` FROM {$tblBanIP} WHERE `end_time` >= ".time();
	$banList = GFetchRowSet($sqlBanList);
	
	$strFileContent = 
	"<?php\n\n//key值为ip\n\n\$_DCACHE['limit_ip'] = array(\n";
	foreach ($banList as &$ban) {
		$strFileContent .= "\t '{$ban['ip']}' => array('end_time'=>{$ban['end_time']},),\n";
	}
	$strFileContent .=");";
	if (is_writable(dirname($file))) {
		file_put_contents($file,$strFileContent);
	}else {
		die('无权限写入'.$file);
	}
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