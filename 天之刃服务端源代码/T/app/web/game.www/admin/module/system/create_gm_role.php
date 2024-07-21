<?php
/*
 * Author: wuzesen
 *	
 * 管理员通过游戏后台，直接创建GM的角色
 * 
 * 注意，请勿滥用本功能。
 */

$_DCACHE = null;
define('DIRECT_LOGIN_PHP', "../../../user/game.php");
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$action = SS($_REQUEST['action']);


// 直接登录玩家帐号
if ($action == 'create') 
{
	$accname = SS($_REQUEST['accname']);
	if (empty($accname))
		errorExit ( "GM账号不能为空" );
	
	$roleName = SS($_REQUEST['rolename']);
	if (empty($roleName))
		errorExit('GM角色名不能为空');

	$sql = "SELECT `role_id`,`role_name`,`account_name` FROM `db_role_base_p` WHERE `account_name` = '{$accname}' LIMIT 1";

	$row = GFetchRowOne($sql);
	if ( isset($row['role_id']) )
		errorExit ('该GM账号已存在');
		
	$sql = "SELECT `role_id`,`role_name`,`account_name` FROM `db_role_base_p` WHERE `role_name` = '{$roleName}' LIMIT 1";

	$row = GFetchRowOne($sql);
	if ( isset($row['role_id']) )
		errorExit ('该GM角色名已存在');
		
	$faction = SS($_REQUEST['faction']);
	$sex = SS($_REQUEST['sex']);


	$log = new AdminLogClass();
	$log->Log( AdminLogClass::TYPE_CREATE_GM_ROLE, '创建GM角色: ' . $accname, 0, '', 0, $roleName);
	
	$result = getJson ( ERLANG_WEB_URL . "/gm_role?accname={$accname}&rolename={$roleName}" .
			"&faction={$faction}&sex={$sex}" );
	if ($result == 'ok') {
		infoExit ( "GM角色创建成功" );
	} else {
		$reason = $result['error'];
		errorExit ( $reason );
	}
	
}


$smarty->display("module/system/create_gm_role.tpl");
exit;