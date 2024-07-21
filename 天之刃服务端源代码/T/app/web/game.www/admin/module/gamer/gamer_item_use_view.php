<?php

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
global $auth,$smarty;


$auth->assertModuleAccess(__FILE__);
include SYSDIR_ADMIN . '/class/user_class.php';
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
			if(!empty($result['stones']))
			{
				_error("siqiang1". var_export($result['stones'],true));
				$stones=json_decode($result['stones']);
				_error("siqiang2". var_export($stones,true));
				$str.="镶嵌石头：";
				foreach($stones as $k=>$v)
				{
					$stoneinfo = AdminItemClass::getItemByTypeid($v);
					$str.=$stoneinfo['item_name'].",";
				}
				//AdminItemClass::getItemByTypeid($typeid) 
			} 
			
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
	
	$search_sort_1 = SS($_REQUEST['sort_1']) ? SS($_REQUEST['sort_1']) : 'start_time desc';
	$search_sort_2 = SS($_REQUEST['sort_2']);
	
	$itemname=SS($_REQUEST['itemname']);
	$item_id = SS($_REQUEST['item_id']);
	if(!isset($_REQUEST['item_id'])) $item_id = '0';
	if($itemname=="") $item_id = '0';
	$startDate = $_REQUEST['date1'];
	$endDate = $_REQUEST['date2'];
	$objItemLog = new ItemLogClass();
	$arrDate = $objItemLog->formatTime($startDate, $endDate);
	$date1 = $arrDate['startDate'];
	$date2 = $arrDate['endDate'];
	$start_time = $arrDate['start_time'];
	$end_time = $arrDate['end_time'];
	$tableSuffix = $arrDate['suffix'];
	
	$itemlist=AdminItemClass::getItemList();  
	$iteminfo = AdminItemClass::getItemHash(true,true);
	$bindTypeList = array(1=>'绑定',2=>'不绑定');
	
	#========start test ======
	//$nickname = '测试50';//测试
	#========end test ======
	if ($acname || $nickname) {
		if ($nickname)
			$userid = UserClass::getUseridByRoleName($nickname);
		elseif ($acname)
		$userid = UserClass::getUseridByAccountName($acname);
		
		//处理混服
		/*if(MIX_SYSTEM_OPEN){
		 $username =$ADMIN->username;
		 //测试改名
		  //$username ="IS_" . $username;
		   $users =new UserClass($userid);
		   $userinfo = $users->getUserInfo();
		   $AccountName = $userinfo['AccountName'];
		   foreach($MIX_SERVICE_CONFIG as $k => $v){
		   $pad = $k . '_';
		   if(!(strpos(strtolower($username), strtolower($pad)) === false)){
		   if(strpos(strtolower($AccountName), strtolower($pad)) === false){
		   die('搜索失败!');
		   }
		   }
		   break;
		   }
		   }*/
		
		$pageno = intval($_REQUEST['page']);
		if ($pageno <= 0)
			$pageno = 1;
		
		if (empty ($search_sort_1))
			$search_sort_1 = 'start_time desc';
		if (empty ($search_sort_2))
			$search_sort_2 = 'id desc';
		$orderby = $search_sort_1.' , '.$search_sort_2;
		
		if(!$userid){
			//modified by wangtao
			$smarty->assign("word", "该玩家不存在");
			$smarty->display("module/gamer/gamer_item_use_view.tpl");
			exit();
		}
		
		
		$itemPerPage = LIST_PER_PAGE_RECORDS;
		$keywordlist = $objItemLog->getItemLog($userid,$item_id,$start_time,$end_time,$tableSuffix,$orderby,$pageno,$count_result,$itemPerPage);
		$itemList = AdminItemClass::getItemHash();
		$actionType = ItemLogClass::$itemLogType;
		foreach ($keywordlist as &$row) {
			$row['item_name'] = $iteminfo[$row['itemid']];
			$row['action_desc'] = $actionType[$row['action']];
			$row['color_name'] = $dictColor[$row['color']];
			$row['fineness_name'] = $dictQualityType[$row['fineness']];
			$row['bind_desc'] = $bindTypeList[$row['bind_type']];
		}
		$pagelist	= getPages($pageno, $count_result);
	}
	//$iteminfo = AdminItemClass::getItemHash(true,true);
	
	//排序的
	$sortlistopgion = getSortTypeListOption();
	
	
	$smarty->assign("date1",$date1);
	$smarty->assign("date2",$date2);
	$smarty->assign("search_sort_1", $search_sort_1);
	$smarty->assign("search_sort_2", $search_sort_2);
	$smarty->assign("search_keyword1", $acname);
	$smarty->assign("search_keyword2", $nickname);
	//$smarty->assign("iteminfo",$iteminfo);
	$smarty->assign("item_id",$item_id);
	$smarty->assign("record_count", $count_result);
	$smarty->assign("keywordlist", $keywordlist);
	$smarty->assign("page_list", $pagelist);
	$smarty->assign("page_count", ceil($count_result / LIST_PER_PAGE_RECORDS));
	$smarty->assign("itemlist",$itemlist);
	$smarty->assign("itemname",$itemname);
	$smarty->assign('sortoption', $sortlistopgion);
	
	$smarty->display("module/gamer/gamer_item_use_view.tpl");
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
