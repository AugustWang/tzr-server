<?php

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
include SYSDIR_ADMIN . '/class/item_log_class.php';

$action = trim(SS($_REQUEST['action']));
if($action=="getdetail")
{
	$unique_id=trim(SS($_REQUEST['unique_id']));
	if(!empty($unique_id))
	{
		$sql = "SELECT * FROM `t_log_super_item` WHERE `super_unique_id` = {$unique_id}";
		$result = GFetchRowOne($sql);
		_error("siqiang". var_export($result,true));
		$str="";
		if(count($result)!=0)
		{
			$str.=($result['level']==null)? "": "物品等级：".$result['level'].",";
			$equip_level = floor($result['reinforce_result']/10);
			$equip_start = $result['reinforce_result']%10;
			$str.=($result['reinforce_result']==null)? "": "当前强化结果：".$equip_level."级".$equip_start."星,";
			$str.=($result['punch_num']==null)? "": "当前打孔个数：".$result['punch_num'].",";
			$str.=($result['stone_num']==null)? "": "当前镶嵌宝石个数：".$result['stone_num'].",";
			$str.=($result['signature']==null)? "": "装备签名：".$result['signature'].",";
			$str.=($result['refining_index']==null)? "": "精炼系数：".$result['refining_index'].",";
		}
		if(!empty($str))
		{
			$str = substr($str,0,strlen($str)-1);
		}
		echo $str;
	}
	else
	{
		echo "";
	}
}
else{
	$acname = trim(SS($_REQUEST['acname']));
	$nickname = trim(SS($_REQUEST['nickname']));

	$itemname = SS($_REQUEST['itemname']);
 $item_id = SS($_REQUEST['item_id']);
	if(!isset($item_id)){ $item_id = 0;}
	$date1 = SS($_REQUEST['date1']);
	$date2 = SS($_REQUEST['date2']);
	$objItemLog = new ItemLogClass();

	$arrDate = $objItemLog->formatTime($date1, $date2);
	$date1 = $arrDate['startDate'];
	$date2 = $arrDate['endDate'];
	$itemlist=AdminItemClass::getItemList();

	$actionTypes = ItemLogClass::$itemLogType;
	$checkActions = $_REQUEST['actions'] ? $_REQUEST['actions']  : array_keys($actionTypes);
	//echo '<pre>';print_r($checkActions);die();
	foreach ($checkActions as $key => $val) {
		$urlActions .= urlencode('actions['.$key.']').'='.$val.'&amp;';
	}
	$iteminfo = AdminItemClass::getItemHash(true,true);
	$bindTypeList = array(1=>'绑定',2=>'不绑定');

	$chkAll = true;
	$arrActionType = array();
	foreach ($actionTypes as $key => $val) {
		if (in_array($key,$checkActions) ) {
			$checked =  ' checked="checked" ' ;
		}else {
			$checked = '';
			$chkAll = false;
		}
		$arrActionType[] = array(
			'key' => $key,
			'text' => $val,
			'checked' => $checked,
		);
	}
	//echo '<pre>';print_r($arrActionType);die();
	#========start test ======
	//$nickname = '测试50';//测试
	#========end test ======
	if ($nickname)
		$userid = UserClass::getUseridByRoleName($nickname);
	elseif ($acname)
	$userid = UserClass::getUseridByAccountName($acname);

	$pageno = empty($_POST) ? intval($_REQUEST['page']) : 1 ;
	if ($pageno <= 0)
		$pageno = 1;

	if (SS($_REQUEST['date1']) && SS($_REQUEST['date1'])) {
		$itemPerPage = LIST_PER_PAGE_RECORDS;
		$actions = $chkAll ?  '' : $checkActions;

		$keywordlist = $objItemLog->getItemLogManage($userid,$date1,$date2,$item_id,$actions,$pageno,$count_result,$itemPerPage);
		foreach ($keywordlist as &$row) {
			$row['item_name'] = $iteminfo[$row['itemid']];
			$row['action_desc'] = $actionTypes[$row['action']];
			$row['color_name'] = $dictColor[$row['color']];
			$row['fineness_name'] = $dictQualityType[$row['fineness']];
			$row['bind_desc'] = $bindTypeList[$row['bind_type']];
		}
		$pagelist	= getPages($pageno, $count_result);
	}


	//排序的
	//$sortlistopgion = getSortTypeListOption();

	$smarty->assign("date1",$date1);
	$smarty->assign("date2",$date2);
	$smarty->assign("search_keyword1", $acname);
	$smarty->assign("search_keyword2", $nickname);
	$smarty->assign("iteminfo",$iteminfo);
	$smarty->assign("item_id",$item_id);
	$smarty->assign("record_count", $count_result);
	$smarty->assign("keywordlist", $keywordlist);
	$smarty->assign("page_list", $pagelist);
	$smarty->assign("page_count", ceil($count_result / LIST_PER_PAGE_RECORDS));
	//$smarty->assign('errMsg', $errMsg);
	$smarty->assign("arrActionType", $arrActionType );
	$smarty->assign("urlActions", $urlActions );
	$smarty->assign("chkAll", $chkAll );
	$smarty->assign("itemname",$itemname);
	$smarty->assign("itemlist",$itemlist);
	$smarty->display("module/gamer/item_log_manage.tpl");
}
exit;
//////////////////////////////////////////////////////////////

function getSortTypeListOption() {
	return array (
		"id asc" => 'ID↑',
		"id desc" => 'ID↓',
		"start_time asc" => '使用时间↑',
		"start_time desc" => '使用时间↓',
		"itemid asc" => '道具↑',
		"itemid desc" => '道具↓',

	);
}
