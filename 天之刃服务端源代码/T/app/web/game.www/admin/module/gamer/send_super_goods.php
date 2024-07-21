<?php
/**
 * 赠送超级道具
 */
 
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
include_once SYSDIR_ADMIN . "/include/dict.php";

/**
 * 检查是否为超级道具 
 */
function check_super_item($itemTypeID){
	return $itemTypeID >= 10800001 and $itemTypeID< 10900000;
}

/**
 * 检查是否为货币道具 
 */
function check_money_item($itemTypeID){
	return $itemTypeID >= 10100007 and $itemTypeID<= 10100012;
}

$colorcode=array(
	1=>"#ffffff",
	2=>"#12cc95",
	3=>"#0d79ff",
	4=>"#fe00e9",
	5=>"#ff7e00",
	6=>"#FFD700",
);

$itemlist=AdminItemClass::getItemList(); 

$action = trim ( $_GET ['action'] );
if ('search'==$action) {
	$role = UserClass::getUser($_POST['role_name'],$_POST['account_name'],$_POST['role_id']);
	$bind = 1;
}

if ($action == 'do') {
	$role = $_POST ['role'] ;
	if (!$role['role_id']) {
		$err[] = "请先查找出玩家" ;
	}
	$bind = $_POST ['bind'] ? 1 : 0;
	$typeid = intval ( $_POST ['typeid'] );
	$color = intval($_POST['color']);
	$quality = intval($_POST['quality']);
	$number = intval ( $_POST ['number'] );
	$start_time = $_POST['start_time'];
	$end_time = $_POST['end_time'];

	if($start_time!=0)$start_time = strtotime($start_time);
    if($end_time!=0)$end_time =strtotime($end_time);

	if ($typeid) {
		$items = AdminItemClass::getItemByTypeid($typeid);
		if ($items) {
			$type = $items['type'];
			$itemName = $items['item_name'];
			$isOverlap = $items['is_overlap'];
		}else{
			$err[] =  "无ID为{$typeid}的物品！" ;
		}
	}else {
		$err[] =  "请输入物品ID！" ;
	}
	
//if( check_super_item($typeid) ){
//		$err[] =  "您没有赠送超级道具的权限！" ;
//	}else if( check_money_item($typeid) ){
//		$err[] =  "您没有赠送货币道具的权限！" ;
//	}
	if($start_time>$end_time)
	{
		$err[] = "结束时间不能小于起始时间！";
	}
	
	if ($number <=0) {
		$err[] =  "数量必须为正数！" ;
	}
	if ($number > 50) {
		$err[] =   "最多赠送50个！" ;
	}
	//-define(TYPE_EQUIP, 3).
	if($number >1 )
	{
		if($type==3)
		{
			$err[] =   "装备一次只能赠送1件！" ;
		}
		else if($isOverlap==2)
		{
			$err[] =   "此物品一次只能赠送1件！" ;
		}
	}
	
	if (empty($err)) {
		//======== start 通过附件发送道具==========
		//$mailMsg = $role['role_name'].'：<br>&nbsp;&nbsp;&nbsp; 您好！<br>&nbsp;&nbsp;&nbsp; 感谢您对我们的支持，系统赠送<font color=\"'.$colorcode[$color].'\">【'.$itemName.'】</font>×'.$number.'给您，请领取附件。';
		//$mailMsg = html_entity_decode( stripslashes( $mailMsg  ) );
		$url =ERLANG_WEB_URL . "/send_goods" ;
		$params = 'role_id='.$role['role_id'].'&role_name='.$role['role_name'];
		$params .= "&number={$number}&type={$type}&typeid={$typeid}&bind={$bind}&itemname=$itemName". 
			"&color={$color}&quality={$quality}".
			"&start_time={$start_time}&end_time={$end_time}";
		$data = curlPost($url, $params);
		$result = json_decode($data,true);
		
		//======== end 通过附件发送道具==========);
		if ($result ['result'] == 'ok') {
			
			$detail = "赠送 {$dictColor[$color]}{$dictQualityType[$quality]}的【{$itemName}】×{$number} 给【{$role['role_name']}】";
			$msg =  $detail.'成功' ;
			
			$typeid =''; //赠送成功后，清除数据，以防重复赠送
			$number = '';
			//添加日志
			$loger = new AdminLogClass();
			$loger->Log( AdminLogClass::TYPE_SEND_GOODS ,$detail, $number,'', $role['role_id'], $role['role_name']);
			unset($role['role_id']);
			unset($action);
		} else {
			$msg =  "物品{$typeid}[{$itemName}]赠送失败，可能背包空间不足或服务器运行出错";
		}
		$err[] =  $msg;
	}
}
if ( in_array($action,array('search','do')) && !intval($role['role_id']) ){ // 若已提交表单，且找不到玩家
	$err[] = '找不到此玩家';
}
$data = array(
	'pageTitle'=>"赠送超级道具",
	'role'=>$role,
	'dictColor' => $dictColor,
	'dictQualityType' => $dictQualityType,
	'bind'=>$bind,
	'typeid'=>$typeid,
	'color'=>$color,
	'quality'=>$quality,
	'number'=>$number,
	'err' => empty($err) ? '' : implode('<br />',$err),
	'itemlist'=>$itemlist,
);
$smarty->assign($data);
$smarty->display ( 'module/gamer/send_goods.tpl' );
