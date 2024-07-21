<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ADMIN."/include/global.php";
global $smarty, $auth, $ADMIN_SYS_QUANTITY;

//取得用户信息用于跟其它后台通信
$user_info = $auth->user_info();

//通过帐号ID取得用户的权限数组
$gid 	   = getAdminGroupID($_SESSION['uid']);
$power_arr = AdminGroupClass::enum();
$woner_arr = $power_arr[$gid];
$new_arr   = empty($woner_arr)?array():$woner_arr[rule_arr][0];

//把用户有权限访问的页面ID重组为一个新数组
if(ROOT_USERNAME!=$user_info['username']){
	foreach($new_arr as $k=>$v){
		if($v==1){
			$new_page_arr[] = $k;
		}
	}
	$new_page_str = @implode("|",$new_page_arr);
}else{
	$new_page_str = 'all';
}

$flag = md5($user_info['username'].$new_page_str.$user_info['uid'].$user_info['last_op_time'].ADMIN_FLAG_KEY);

$smarty->assign('username', $user_info['username']);
$smarty->assign('user_info', $user_info);
$smarty->assign('user_power', $new_page_str);
$smarty->assign('flag', $flag);
$smarty->assign('agent_name', AGENT_NAME);
$smarty->assign('admin_url', ADMIN_USE_URL);
$smarty->assign('admin_sys_quantity', $ADMIN_SYS_QUANTITY);
$smarty->assign('isdebug', $_SESSION['admin_debug']);
$smarty->assign('admin_url_prefix', ADMIN_URL_PREFIX);
$smarty->assign('adminGatewayUrl', ADMIN_GATEWAY_URL);
$smarty->display("top.html");

function getAdminGroupID($uid)
{
        global $db;
        $sql = "SELECT `groupid` FROM `".T_ADMIN_USER
                        ."` where `uid`='$uid'";
        $row = $db->fetchOne($sql);
        return intval($row['groupid']);
}
