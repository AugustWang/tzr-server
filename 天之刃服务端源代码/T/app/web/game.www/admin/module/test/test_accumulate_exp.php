<?php
/**
 * 累积经验测试辅助工具
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
	$accID = intval($_POST['acc_id']);
	$days = intval($_POST['days']);
	if ($days > 7) {
		$days = 7;
	} else if ($days < 0) {
		$days = 0;
	}
	
	$year = intval($_POST['year']);
	$month = intval($_POST['month']);
	$day = intval($_POST['day']);
	
	$result = getWebJson("/test/accumulate_exp/?account={$account}&id={$accID}&days={$days}&year={$year}&month={$month}&day={$day}");
	if (!$result) {
		errorExit("系统错误，请联系开发人员");
	}
	if ($result['result'] == 'ok') {
		infoExit("设置成功");
	}
	errorExit($result['reason']);
}
$smarty->display("module/test/test_accumulate_exp.html");


