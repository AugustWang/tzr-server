<?php
/**
 * 管理后台清理拉镖状态
 * @author chixiaosheng
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN.'/include/dict.php';
if (!empty($_POST)) {

	$result = getWebJson("/ybc/clear_state/");
	if ('ok' == $result['result']) {
		echo '<span style="color:red;">成功清理</span>';
		
		//添加日志
		$loger = new AdminLogClass();
		$loger->Log( AdminLogClass::TYPE_CLEAR_YBC_STATE , '', '','', '', '');
	}else {
		echo '<span style="color:red;">清理失败!</span>';
	}	
}	
$smarty->assign("AGENT_NAME",AGENT_NAME);
$smarty->assign("SERVER_NAME",SERVER_NAME);
$smarty->display("module/gamer/clear_ybc_state.tpl");