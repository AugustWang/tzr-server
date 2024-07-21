<?php
/*
 * dqj 2010-07-15
 *
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ROOT."/config/config.key.php";

$tablename = T_LOG_PAY_REQUEST;
$action = $_REQUEST['action'];
$msg = array();
if ('update'==$action) {
	$id = intval($_GET['id']);
	if (!empty($_POST)) {
		$Log = $_POST['Log'];
		$Log['id'] = intval($Log['id']);
		$Log['IP'] = SS($Log['IP']);
		$Log['IP'] = $Log['IP'] ? $Log['IP'] : $_SERVER['REMOTE_ADDR'];
		$Log['PayNum'] = SS($Log['PayNum']);
		$Log['PayToUser'] = SS($Log['PayToUser']);
		$Log['PayMoney'] = floatval($Log['PayMoney']);
		$Log['PayGold'] = intval($Log['PayGold']);
		$Log['PayTime'] = intval(strtotime($Log['PayTime']));
		$Log['PayTime'] = $Log['PayTime'] ? $Log['PayTime'] : time();
		$Log['ticket'] =  md5($API_SECURITY_TICKET_PAY . $Log['PayNum'] . $Log['PayToUser'] . $Log['PayMoney'] . $Log['PayGold'] . $Log['PayTime']);
		$Log['detail'] = "PayNum={$Log['PayNum']};PayToUser={$Log['PayToUser']};PayMoney={$Log['PayMoney']};PayGold={$Log['PayGold']};PayTime={$Log['PayTime']};ticket={$Log['ticket']}";
		$role = UserClass::getUser('',$Log['PayToUser'],'');
		if (!$role['role_id']) {
			array_push($msg , "不存在玩家 {$Log['PayToUser']}");
		}
		if (!$Log['PayNum']) {
			array_push($msg , "订单号不能为空");
		}
		if (!$Log['PayMoney']) {
			array_push($msg , "充值金额必须为正数");
		}
		if (!$Log['PayGold']) {
			array_push($msg , "充值获得元宝数必须为正数");
		}
		if (empty($msg)) {
			if ($Log['id']) {
				$sqlDoOrder = " UPDATE {$tablename} set `payto_user`='{$Log['PayToUser']}', `user_ip`='{$Log['IP']}', `detail`='{$Log['detail']}', `desc`='true', `mtime`={$Log['PayTime']} WHERE `id`={$Log['id']} ";
			}else {
				$sqlDoOrder=" INSERT INTO `{$tablename}` (`payto_user`, `user_ip`, `detail`, `desc`, `mtime`) VALUES ('{$Log['PayToUser']}','{$Log['IP']}','{$Log['detail']}','true',{$Log['PayTime']} ) ";
			}
			$result = GQuery($sqlDoOrder);
			if ($result) {
				$ok = "操作成功";
				$loger = new AdminLogClass();
				if ($Log['id']) {
					$sqlTmp = " SELECT * FROM {$tablename} WHERE `id`={$Log['id']} ";
					$arrTmp = GFetchRowOne($sqlTmp);
					$oldDetail = SS($arrTmp['detail']);
					$Log['detail'];
					$logDesc = "日志详情由 {$oldDetail} 改为 {$Log['detail']}";
					$loger->Log( AdminLogClass::TYPE_DO_ORDERS,$logDesc, '','',$role['role_id'],$role['role_name']);
				}else {
					$loger->Log( AdminLogClass::TYPE_DO_ORDERS,SS($arrTmp['detail']), '','',$role['role_id'],$role['role_name']);
				}
				$Log = array();
			}
		}
	}else {
		$sqlLog = " SELECT * FROM {$tablename} WHERE `id`={$id} ";
		$arrLog = GFetchRowOne($sqlLog);
		$arr = explode(';',$arrLog['detail']);
		$Log = array();
		if (is_array($arr)) {
			foreach ($arr as &$item) {
				$subArr = explode('=',$item);
				$Log[$subArr[0]] = $subArr[1];
			}
		}
	}
	if (!empty($Log)) {
		$Log['id'] = $arrLog['id'];
		$Log['IP'] = $Log['IP'] ? $Log['IP']  : $arrLog['user_ip'];
		$Log['PayTime'] = date('Y-m-d H:i:s',intval($Log['PayTime']));
	}/*
	echo '<pre>';print_r($arrLog);echo '</pre>';echo '<hr />';
	echo '<pre>';print_r($Log);echo '</pre>';die();*/
}

if (! isset($_REQUEST['dateStart']))
{
	$dateStart = date('Y-m-d',strtotime('-7day'));
}
elseif ($_REQUEST['dateStart'] == 'ALL')
{
	$dateStart = SERVER_ONLINE_DATE;
}
else
{
	$dateStart = trim(SS($_REQUEST['dateStart']));
}


if (! isset($_REQUEST['dateEnd']))
	$dateEnd = strftime("%Y-%m-%d", time());
elseif ($_REQUEST['dateStart'] == 'ALL')
{
	$dateEnd = strftime("%Y-%m-%d", time());
}
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

$dateStartStamp = strtotime($dateStart . ' 0:0:0');
$dateEndStamp = strtotime($dateEnd . ' 23:59:59');
$dateStartStamp = $dateStartStamp ? $dateStartStamp : strtotime('-7day');
$dateEndStamp = $dateEndStamp ? $dateEndStamp : time();

$dateStartStr = strftime("%Y-%m-%d", $dateStartStamp);
$dateEndStr = strftime("%Y-%m-%d", $dateEndStamp);

$dateStrPrev = strftime("%Y-%m-%d", $dateStartStamp - 86400);
$dateStrToday = strftime("%Y-%m-%d");
$dateStrNext = strftime("%Y-%m-%d", $dateStartStamp + 86400);

$brandid  = (int)$_REQUEST['brand_id'];
$seriesid = (int)$_REQUEST['series_id'];
$min_price = (int)$_REQUEST['min_price'];
$max_price = (int)$_REQUEST['max_price'];
$q = SS($_REQUEST['q']);
$search_sort_1 = SS($_REQUEST['sort_1']);
$search_sort_2 = SS($_REQUEST['sort_2']);
$pageno = getUrlParam('page');

if (empty($search_sort_1))		$search_sort_1 = "mtime desc";
if (empty($search_sort_2))		$search_sort_2 = "id desc";

$search_sort .= $search_sort_1 . ", ". $search_sort_2;
$where = '1';
$where .="  AND `mtime`>={$dateStartStamp} AND `mtime`<={$dateEndStamp}";


//要显示的内容
$count_result = 0;
$keywordlist = getList($tablename, $where, $pageno, $search_sort, LIST_PER_PAGE_RECORDS, $count_result);
$pagelist = getPages($pageno, $count_result);

$msg = empty($msg) ?  '' : implode('<br />' , $msg);
if (empty($Log)) {
	$displayFix = 'display:none;' ;//默认隐藏补单的表单 
	$Log['PayTime'] = date('Y-m-d H:i:s');
	$Log['IP'] = $_SERVER['REMOTE_ADDR'];
}else {
	$displayFix = '';
}

//排序的
$smarty->assign("search_sort_1", $search_sort_1);
$smarty->assign("search_sort_2", $search_sort_2);
$smarty->assign("search_keyword", $q);
$smarty->assign("search_brandid", $brandid);
$smarty->assign("search_seriesid", $seriesid);

$smarty->assign("record_count", $count_result);
$smarty->assign("keywordlist", $keywordlist);
$smarty->assign("page_list", $pagelist);
$smarty->assign("page_count", ceil($count_result/LIST_PER_PAGE_RECORDS));
$smarty->assign('sortoption', $sortlistopgion);

$smarty->assign("dateStart", $dateStartStr);
$smarty->assign("dateEnd", $dateEndStr);

$smarty->assign("dateStrPrev", $dateStrPrev);
$smarty->assign("dateStrNext", $dateStrNext);
$smarty->assign("dateStrToday", $dateStrToday);

$smarty->assign("Log", $Log);
$smarty->assign("msg", $msg);
$smarty->assign("ok", $ok);
$smarty->assign("displayFix", $displayFix);


$smarty->display("module/pay/pay_status_history.tpl");
exit;
