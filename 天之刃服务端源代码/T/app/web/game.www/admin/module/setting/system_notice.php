<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty, $db;
$auth->assertModuleAccess(__FILE__);

$action = trim($_REQUEST['action']);
if ($action == 'do') {
	// 设置系统公告，只是保存到数据库
	$content = trim( $_POST ['content'] );
	if ($content == '') {
		errorExit ( "公告内容不能为空" );
	}
	GQuery("TRUNCATE TABLE `t_system_notice`");
	$arr = array('content' => SS($content));
	$sql = makeInsertSqlFromArray($arr, 't_system_notice');
	try {
		GQuery($sql);
		$msg = "公告保存成功";
	} catch (Exception $e) {
		$msg = "公告保存失败:" + $e->getMessage();
		$loger = new AdminLogClass();
		$loger->Log( AdminLogClass::TYPE_SET_SYSTEM_NOTICE, $content, '','', 0, "");
	}
	$smarty->assign('msg', $msg);
	$smarty->assign('content', $content);
	$smarty->display ( 'module/setting/system_notice.html' );
} else if ($action == 'syn') {
	$sql = "SELECT `content` FROM `t_system_notice` WHERE id = 1";
	$result = GFetchRowOne($sql);
	// 同步数据中的公告内容到游戏
	$result = getWebJson('/setting/system_notice/?content=' . base64_encode(base64_encode(stripslashes($result['content']))));
	//发送
	if ($result ['result'] == 'ok') {
		$msg = "系统公告同步成功";
		//添加日志
		$loger = new AdminLogClass();
		$loger->Log( AdminLogClass::TYPE_SYN_SYSTEM_NOTICE, $result['content'], '','', 0, "");
	} else {
		$msg = "系统公告同步失败" ;
	}
	errorExit( $msg );
} else if ($action == 'export') {
	
} else {
	$sql = "SELECT `content` FROM `t_system_notice` WHERE id = 1";
	$result = GFetchRowOne($sql);
	$smarty->assign('content', $result['content']);
	$smarty->display ( 'module/setting/system_notice.html' );
}
