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

	$account = SS($_REQUEST['account']);
	$role_name = SS($_REQUEST['role_name']);
	
	if (!$account  && !$role_name){
		echo '<span style="color:red;">帐号不能为空</span>';
	}else {
		$role = UserClass::getUser($role_name, $account, NULL);
		if (!$role['role_id']) {
			die ('<span style="color:red;">该帐号不存在</span>');
		} else {
			$result = getWebJson("/ybc/syn_ybc_pos/?role_id={$role['role_id']}");
			if ('ok' == $result['result']) {
				echo '<span style="color:red;">同步玩家镖车位置成功</span>';
				//添加日志
				$loger = new AdminLogClass();
				$loger->Log( AdminLogClass::TYPE_SYN_YBC_POS , '', '','', '', '');
			}else {
				echo '<span style="color:red;">同步玩家镖车位置失败!</span>';
			}	
		}
	}
}	
$smarty->assign("AGENT_NAME",AGENT_NAME);
$smarty->assign("SERVER_NAME",SERVER_NAME);
$smarty->display("module/gamer/syn_ybc_pos.tpl");