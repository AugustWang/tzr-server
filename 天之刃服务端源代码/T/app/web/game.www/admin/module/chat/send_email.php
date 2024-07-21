<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$action = trim($_GET['action']);
if ($action=='search') {
	$role = UserClass::getUser($_POST['role_name'],$_POST['account_name'],$_POST['role_id']);
}

if ($action == 'do') {
	$role = $_POST['role'];
	if ( !$role['role_id'] ) {
		errorExit ( "请先查找玩家" );
	}
	
	$content = stripslashes( $_POST ['content'] );
	if ($content == '') {
		errorExit ( "信件内容不能为空" );
	}
	
	if (is_int(strpos($content,'~')))
		{
			errorExit ("信件内容不能包含符号‘~’");
		}
	
	$title = SS($_POST['title']);
	if ($title == '') {
		errorExit ( "信件标题不能为空" );
	}
	
	$url =ERLANG_WEB_URL . "/email/send_email" ;
	$title = base64_encode(base64_encode($title));
	$content = base64_encode(base64_encode($content));
	$params = 'role_id='.$role['role_id'].'&content='.$content.'&title='.$title;
	$data = curlPost($url, $params);
	$result = json_decode($data,true);
	
	//发送
	if ($result ['result'] == 'ok') {
		$msg = "信件发送成功";
		//添加日志
		$loger = new AdminLogClass();
		$loger->Log( AdminLogClass::TYPE_MSG_SENDEMAIL,'信件内容：'.$_POST['content'], '','', $role['role_id'], $role['role_name']);
	} else {
		$msg = "信件发送失败" ;
	}
	infoExit ( $msg );
}

$data = array(
	'role'=>$role,
	'found'=> in_array($action,array('search','do')) && !intval($role['role_id']) ? false : true,
);
$smarty->assign($data);

$smarty->display ( 'module/chat/send_email.html' );