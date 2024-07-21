<?php
/**
 * 管理后台开启国探
 * @author linruirong
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN.'/include/dict.php';
if (!empty($_POST)) {
	$factionId = intval($_POST['factionId']); 
	$startH = intval($_POST['startH']); 
	$startM = intval($_POST['startM']);
	$result = getWebJson("/guotan/admin_start_guotan/?factionId={$factionId}&startH={$startH}&startM={$startM}");
	if ('ok' == $result['result']) {
		echo '<span style="color:red;">成功开启</span>';
		//添加日志
		$loger = new AdminLogClass();
		$loger->Log( AdminLogClass::TYPE_SET_GUOTAN, '', '','', '', '');
	}else {
		echo '<span style="color:red;">开启国探失败!</span>';
	}	
}	
$smarty->assign("dictFaction",$dictFaction);
$smarty->assign("factionId",$factionId);
$smarty->assign("AGENT_NAME",AGENT_NAME);
$smarty->assign("SERVER_NAME",SERVER_NAME);

$smarty->display("module/event/guotan.tpl");