<?php
/**
 * 传奇目标测试辅助工具
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php"; 
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

if (isPost()) {
	$account = SS(trim($_POST['account']));
	if (!$account) {
		errorExit("账号名不能为空");
	}
	if (!GFetchRowOne("select * from db_account_p WHERE account_name = '$account'")) {
		errorExit("账号不存在");
	}
	$days = intval($_POST['days']);
	if ($days > 9) {
		$days = 9;
	} else if ($days < 0) {
		$days = 1;
	}
	
	$result = getWebJson("/test/goal/?account={$account}&days={$days}");
	if (!$result) {
		errorExit("系统错误，请联系开发人员");
	}
	if ($result['result'] == 'ok') {
		infoExit("设置成功");
	}
	errorExit($result['reason']);
}
$smarty->display("module/test/test_goal.html");
