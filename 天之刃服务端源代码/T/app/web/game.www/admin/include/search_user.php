<?php
if (isset($_GET['search'])) {
	$roleName = $_GET['rolename'];
	$accountName = $_GET['accountname'];
	$roleId = $_GET['roleid'];
	$userLists = UserClass::getUser($roleName,$accountName,$roleId);	
	if ($userLists) {
		$smarty->assign('item',$userLists);
		$smarty->display('module/online/ajax_search_user.tpl');	
		
		
		die();
	}else {
		die("没有该用户");
	}
}