<?php
/**
 * 玩家下线原因查询
 * @author QingliangCn
 * @create 2011/1/29
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$arrayMsg = array('10001' =>"服务器维护",
                 '10002' =>"账号在别处登录",
                 '10003' =>"走到一个不可走的格子上!地图数据有问题!",
                 '10004' =>"认证出错",
                 '10005' =>"认证信息过期",
                 '10006' =>"您已进入不健康游戏时间，请您暂离游戏进行适当休息和运动，合理安排您的游戏时间",
                 '10007' =>"系统维护中",
                 '10008' =>"系统维护中",
                 '10009' =>"系统维护中",
                 '10010' =>"系统检测到您的网络太猛",
                 '10011' =>"网络不稳定，已从服务器断开连接",
                 '10012' =>"玩家接受包超时，通常是网络不稳定",
                 '10013' =>"服务器维护",
                 '10014' =>"您触犯游戏守则，被管理员踢下线",
                 '10015' =>"玩家接受包超时，通常是网络不稳定",
                 '10017' =>"累计下线时间不满5小时(防沉迷)",
                 '10016' =>"系统维护中",
                 '10018' =>"背包数据异常，请联系GM！"
);

$accountName = SS(trim($_POST['acname']));
$roleID = intval($_POST['uid']);
$roleName = SS(trim($_POST['nickname']));
if ($accountName != '' || $roleID > 0 || $roleName != '') {
	if ($roleID > 0 ) {
		$sql = "SELECT account_name FROM db_role_base_p WHERE role_id = {$roleID}";
		$result = GFetchRowOne($sql);
		if (!$result['account_name']) {
			errorExit("角色ID输入错误");
		}
		$accountName = $result['account_name'];
	} else if ($roleName != '') {
		$sql = "SELECT account_name FROM db_role_base_p WHERE role_name = '{$roleName}'";
		$result = GFetchRowOne($sql);
		if (!$result['account_name']) {
			errorExit("角色名输入错误");
		}
		$accountName = $result['account_name'];
	}
	$pageno = getUrlParam('pid');
	//要显示的内容
	$count_result = 0;
	$keywordlist = getList("t_log_user_offline", "`account_name` = '{$accountName}'", $pageno, "offline_time desc", LIST_PER_PAGE_RECORDS, $count_result);
	$pagelist = getPages($pageno, $count_result);
	$results = array();
	foreach($keywordlist as $k=>$v) {
		if ($v['offline_reason_no'] == 0) {
			$v['offline_reason'] = "正常断线";
		} else {
			$v['offline_reason'] = $arrayMsg[trim($v['offline_reason_no'])];
		}
		
		$results[$k] = $v;
	}
	$smarty->assign('results', $results);
	$smarty->assign('pageHTML', $pagelist);
	$smarty->assign('acname', $accountName);
	$smarty->assign('role_id', $roleID);
	$smarty->assign('role_name', $roleName);
}

$smarty->display("module/gamer/user_offline.html");