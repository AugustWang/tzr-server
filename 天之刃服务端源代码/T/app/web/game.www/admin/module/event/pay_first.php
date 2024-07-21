<?php
/**
 * 首充活动管理
 * @author QingliangCn
 * @create 2011/1/26
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$action = trim($_GET['action']);
// 关闭首充
if ($action == 'close') {
	$result = getWebJson("/event/pay_first/close/");
} else if ($action == 'open') {
	$result = getWebJson("/event/pay_first/open/");
}

$result = getWebJson("/event/pay_first/get_flag/");
if ($result['result'] == 'error') {
	$smarty->assign('msg', '连接游戏服web异常，请联系开发人员');
} else {
	$flag = $result['flag'] ? '<font color="blue">开启</font>' : '<font color="red">关闭</font>';
	$smarty->assign('open', $result['flag']);
	$smarty->assign('msg', $flag);
}
$smarty->display("module/event/pay_first.html");