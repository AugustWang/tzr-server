<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$action = SS($_REQUEST['action']);

//显示添加，编辑界面
if($action == 'add' || $action == 'modify')
{
	if (isset($_REQUEST['id']))
	{
		$uid = intval($_REQUEST['id']);
		$enum = AdminUserClass::enum();
		$udata = $enum[$uid];
		$smarty->assign("udata", $udata);
		$smarty->assign("uid",$uid);
	}
	$groups = AdminGroupClass::enum();
	if (is_array($groups)) {
		foreach($groups as $groupid => $group) {
			if(!$auth->assertAdminGroupAccess($groupid)) {
				unset($groups[$groupid]);
			}
		}
	}
	$smarty->assign("groups", $groups);
	$smarty->assign("action", $action);
	$smarty->display("module/system/admin_user_edit.tpl");
	exit;
}

if($action == 'add_submit')
{
	$username = trim($_REQUEST['username']);
	$password = trim($_REQUEST['passwd']);
	$validUserName = validUsername($username);
	$validPassword = validPassword($password);
	if (true !== $validUserName) {
		die($validUserName);
	}
	if (true !== $validPassword) {
		die($validPassword);
	}
	if (strlen($password) < 6){
		die('密码要求至少6位');
	}
	$comment = SS(trim($_REQUEST['comment']));
	if (empty($comment)){
		die('描述说明不能为空');
	}
	$sqlChkExist = "SELECT `uid` FROM `".T_ADMIN_USER."` WHERE `username`='{$username}' ";
	$rsChkExist = GFetchRowOne($sqlChkExist);
	if ($rsChkExist['uid']) {
		die("用户名 {$username} 已经被使用");
	}
	$uid = AdminUserClass::create($username, $password, $comment);
	if(!empty($_REQUEST['groupid']))
	{
		$groupid = intval($_REQUEST['groupid']);
		AdminUserClass::changeGroup($uid, $groupid);
		$log = new AdminLogClass();
		$desc = '权限组：'.$groupid;
		$log->Log(AdminLogClass::TYPE_SYS_CREATE_ADMIN, $desc, 0, '', 0, $username);
	}
	if($uid){
		echo "添加新用户 {$username} 成功";
	}
}

if($action == 'modify_submit')
{
	$uid = intval($_REQUEST['id']);
	$enum = AdminUserClass::enum();
	$udata = $enum[$uid];
	if(!$udata) {
		die('用户不存在');
	}
	
	$password = trim($_REQUEST['passwd']);
	if ($password) {
		$validPassword = validPassword($password);
		if (true !== $validPassword) {
			die($validPassword);
		}
		if (strlen($password) < 6){
			die('密码要求至少6位');
		}
		$password = md5($password);
	}else {
		$password = null;
	}
	
	$comment = SS(trim($_REQUEST['comment']));
	if (empty($comment)){
		$comment = null;
	}
	if(!empty($_REQUEST['groupid'])) {
		$groupid = intval($_REQUEST['groupid']);
	} else{
		$groupid = null;
	}
	if(AdminUserClass::update($uid, $password, $groupid, $comment)) {
		$log = new AdminLogClass();
		if($groupid !== null) {
			$desc = '权限组：'.$groupid;
			$log->Log(AdminLogClass::TYPE_SYS_MODIFY_ADMIN_GROUPID, $desc, 0, '', 0, $username);
		}
		if($password !== null) {
			$log->Log(AdminLogClass::TYPE_SYS_MODIFY_ADMIN_PASSWORD, '', 0, '', 0, $username);
		}
	}
	echo "修改成功";
}

$enum = AdminUserClass::enum();
$admins = gen_admins($enum);
$smarty->assign("enum", array_values($admins));
$smarty->display("module/system/admin_user_list.tpl");
exit;

function gen_admins($enum) {
	global $auth;
	$admins = array();
	foreach($enum as $uid => $udata) {
		if($auth->assertAdminGroupAccess(intval($udata['groupid']))) {
			$admins[$uid] = $udata;
		}
	}
	return $admins;
}
