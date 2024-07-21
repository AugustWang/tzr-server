<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ADMIN."/include/global.php";
include_once SYSDIR_ADMIN."/class/admin_log_class.php";
global $smarty, $auth, $domain;


$action = trim($_REQUEST['action']);
if ($action == 'login') {
	if ($auth->alreadyLogin()) {
		header("Location:/index.php");
		exit();
	}
	$username = trim($_POST['username']);
	$password = trim($_POST['password']);
	
	if (($result = validUsername($username)) !== true) {
		$smarty->assign(array('errorMsg' => $result));
		$smarty->display("login.html");
		exit();
	}
	if (($result = validPassword($password)) !== true) {
		$smarty->assign(array('errorMsg' => $result));
		$smarty->display("login.html");
		exit();
	}
	if ($auth->login($username, $password)) {
		//写日志
		$log = new AdminLogClass();
		$log->Log(AdminLogClass::TYPE_SYS_LOGIN,'','','','','');
		//登录成功，跳转到首页
		header("Location:index.php");
		exit();
	} else {
		$errorMsg = "用户名或者密码错误，请重新输入";
		$smarty->assign(array('errorMsg' => $errorMsg));
		$smarty->display("login.html");
		exit();
	}
} elseif ($action == 'logout') {
	$auth->logout();
	header("Location:/admin/");
} else {
	//检查是否已经登录
	if ($auth->auth()) {
		header("Location:/admin/index.php");
		exit();
	} else {
		$smarty->display("login.html");
		exit();
	}
}
