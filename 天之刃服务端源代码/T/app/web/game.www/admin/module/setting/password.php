<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $smarty;

$auth->assertModuleAccess(__FILE__);

$userid = $auth->userid();
$username = $auth->username();
$smarty->assign('username', $username);

if(!$userid) {
	die('不可修改此用户的密码');
}

if ($_POST['action'] == 'update')
{
	$oldpass = trim($_POST['oldpass']);
	$newpass1 = trim($_POST['newpass1']);
	$newpass2 = trim($_POST['newpass2']);
	$validResult = validPassword($newpass1);
	if (true !== $validResult) {
		echo($validResult);
		display();
	}
	if ($newpass1 != $newpass2) {
		echo('两次输入的密码不一致！');
		display();
	}
	if ($oldpass == $newpass1) {
		echo('输入的新旧密码一样，不执行修改！');
		display();
	}
	$md5old = strtolower(md5($oldpass));
	$md5new = strtolower(md5($newpass1));
	$sql = "SELECT * FROM `".T_ADMIN_USER."` WHERE `uid`='{$userid}' AND `passwd`='{$md5old}' LIMIT 1";
	$result = GFetchRowOne($sql);
	if ($result['uid'] != $userid) {
		echo("旧密码错误");
		display();
	}
	$sql = "UPDATE `".T_ADMIN_USER."` SET `passwd`='{$md5new}' WHERE `uid`='{$userid}' LIMIT 1";
	if (($result = GQuery($sql)) != NULL) {
		$log = new AdminLogClass();
		$log->Log(AdminLogClass::TYPE_SYS_MODIFY_ADMIN_PASSWORD, '', 0, '', 0, $username);
		echo('修改密码成功');
		display();
	} else {
		echo('修改密码出错，请联系管理员解决！');
		display();
	}
} else {
	display();
}
exit;

function display() {
	global $smarty;
	$smarty->display("module/setting/password.tpl");
	exit;
}