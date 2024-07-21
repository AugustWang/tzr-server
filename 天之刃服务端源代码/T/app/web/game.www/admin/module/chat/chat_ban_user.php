<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN . '/class/chat_ban_class.php';
include_once SYSDIR_ADMIN . '/class/user_class.php';


include_once SYSDIR_ADMIN."/include/search_user.php";

//清除过期的数据
if(isset($_REQUEST['clear_old'])) {
	$now = time();
	$clearCount = 0;
	$unban = array();
	$CHAT_BAN_USER = ChatBanClass :: getList();
	if( is_array($CHAT_BAN_USER) ){
		foreach($CHAT_BAN_USER as $v)
		if($v['time_end'] < $now)
			$unban[] = intval($v['role_id']);
	}
	
	$clearCount = count($unban);
	if($clearCount > 0) {
		ChatBanClass :: unbanArray($unban);
		echo '<font color=blue>清除过期数据成功，总共清除 ' . $clearCount . ' 条数据</font>' . CRLF . CRLF;
	} else
		echo '<font color=red>没有可以清除的过期数据</font>' . CRLF . CRLF;
}

if($_GET['del'] > 0) {
	$del_id = intval($_GET['del']);
	ChatBanClass :: unban($del_id);
	$loger = new AdminLogClass();
	$roleName = UserClass::getRoleNameByRoleId($del_id);

	$loger->Log( AdminLogClass::TYPE_UNBAN_CHAT,'解除禁言','','',$del_id,$roleName);
}



if(!empty($_POST['nickname']) && !empty($_POST['interval'])) {
	$nickname = trim($_POST['nickname']);
	$minuteInterval = intval($_POST['interval']); //间隔多少秒发一次

	if(strlen($minuteInterval) > 9)$minuteInterval = 999999999;

	$content = $_POST['content'];
	if(get_magic_quotes_gpc()) {
		$content = stripslashes($content);
	}
	$content = trim(str_replace("\n", ' ', str_replace("\r\n", ' ', $content)));

	$userid = UserClass::getUseridByRoleName($nickname);

	if($userid <= 0)
		echo '<font color=red>不存在该玩家，请检查并重新输入。</font>' . CRLF . CRLF;
	else {
		$content = str_replace('{USERNAME}', '['.$nickname.']', $content);
		$content = str_replace('{MINUTE}', $minuteInterval, $content);

		ChatBanClass :: ban($userid, $nickname, $minuteInterval, $content);

		$loger = new AdminLogClass();
		$loger->Log( AdminLogClass::TYPE_BAN_CHAT,'禁言'.$minuteInterval.'分钟', '','',$userid,$nickname);
		
	}
} else {
	$timeStartStr = strftime("%Y-%m-%d", time()) . ' 00:00:00';
	$timeEndStr =(strftime("%Y", time()) + 1) . strftime("-%m-%d", time() + 86400) . ' 23:59:59';
	$minuteInterval = 30;
}

$arr = ChatBanClass :: getList();

$smarty->assign("minuteInterval", $minuteInterval);
$smarty->assign('keywordlist', $arr);

$smarty->display("module/chat/chat_ban_user.tpl");




exit;