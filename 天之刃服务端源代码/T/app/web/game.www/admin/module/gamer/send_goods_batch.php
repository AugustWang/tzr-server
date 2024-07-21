<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN . "/include/dict.php";
include_once SYSDIR_ADMIN.'/class/batch_email_log_class.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
//设置页面访问的超时时间
set_time_limit(120);

$action = trim($_GET['action']);
$action = $action ? $action : 'byRoleName';

$arrSex = array(0=>'不限', 1=>'男',2=>'女');
$arrFaction = array(0 => '不限',1=>'云州',2=>'沧州',3=>'幽州');
$ONE_TIME_SEND_MAX = 500;//一次发多少个玩家。（用于按条件发送）
$start_time=0;
$end_time=0;



if ('byRoleName' == $action) {
	
	if (!empty($_POST)) {
		$bind = $_POST ['bind'] ? 1 : 0;
		$typeid = intval ( $_POST ['typeid'] );
		$color = intval($_POST['color']);
		$quality = intval($_POST['quality']);
		$number = intval ( $_POST ['number'] );
		$email_title = stripslashes(trim($_POST['email_title'])) ;
		if (!$email_title) {
			$errMsg[] = '请输入信件标题！';
		}
		
		$start_time = $_POST['start_time'];
		$end_time = $_POST['end_time'];
		if($start_time!=0)$start_time = strtotime($start_time);
        if($end_time!=0)$end_time =strtotime($end_time);
		
		
		if ($typeid) {
			$items = AdminItemClass::getItemByTypeid($typeid);
			if ($items) {
				$type = $items['type'];
				$itemName = $items['item_name'];
			}else{
				$err[] =  "无ID为{$typeid}的物品！" ;
			}
		}else {
			$err[] =  "请输入物品ID！" ;
		}
		
		$role_names = explode('，',$_POST['role_names']);
		$email_content = stripslashes( $_POST['email_content']);
		$arrRoleName = array();
		if (empty($role_names)) {
			$err[] = '角色名为空！'; 
		}else {
			foreach ($role_names as $roleName) {
				$roleName = SS($roleName);
				if ($roleName) {
					array_push($arrRoleName,"'{$roleName}'");
				}
			}
		}
		if($start>$end)
		{
		$err[] = "结束时间不小于起始时间！";
		}
		if (!empty($arrRoleName)) {
			$table = T_DB_ROLE_BASE_P;
			$strRoleNames = implode(',',$arrRoleName);
			$sql = " select role_id,role_name from {$table} WHERE role_name in ({$strRoleNames}) ";
			$roles = GFetchRowSet($sql);
			$strLogRoleNames = '';
			foreach ($roles as &$row) {
				$strRoleIds.=$row['role_id'].',';
				$strLogRoleNames .= $row['role_name'].'，';
			}
			$strRoleIds = trim($strRoleIds,',');
			$strLogRoleNames = trim($strLogRoleNames,'，');
			if (!$strRoleIds) {
				$err[] = '查不到对应的玩家';
			}
		}else{
			$err[] = '角色名为空！'; 
		}
		if (!$email_content) {
			$err[] = '请输入信件内容！';
		}
		if (is_int(strpos($email_content,'~')))
		{
			$err[] = '信件内容不能包含符号‘~’';
		}
		
		
		if (empty($err)) {
			$result = doSend($strRoleIds,$email_content, $email_title, $type, $bind, $typeid, $color, $quality, $number,$start_time,$end_time );
			
				$jsonCondition = json_encode($data);
				$arrGoodsInfo = array(
					'type'    => $type   ,
					'bind'    => $bind ,
					'typeid'  => $typeid ,
					'item_name'=>$itemName,
					'color'   => $color,
					'quality' => $quality ,
					'number'  => $number,
					'start_time' => $start_time,
					'end_time' => $end_time,
				);
				$jsonGoodsInfo = json_encode($arrGoodsInfo);
				$obj = new BatchEmailLog();
				$obj->insert(BatchEmailLog::TYPE_EMAIL_BY_ROLE_NAME_WITH_GOODS ,$strLogRoleNames,$jsonCondition,$email_content,$jsonGoodsInfo, $email_title);
				$loger = new AdminLogClass();
				$detail = "批量道具：{$dictColor[$arrGoodsInfo['color']]}{$dictQualityType[$arrGoodsInfo['quality']]}的【{$arrGoodsInfo['item_name']}】";
				$loger->Log( AdminLogClass::TYPE_MSG_SEND_BATCH_GOODS ,$detail, $arrGoodsInfo['number'],'','' , '');
				$errByRoleName =  '发送成功!';
				$number = 0 ; //发送成功后数量清零，以免不小心多点了一次“发送”按钮时，重复发送了。
			
				$errByRoleName = $result['result'];
			
		}else {
			$errByRoleName = '错误：'.implode('<br />',$err);
		}
	}else{
		$bind = 1; //默认为绑定
	}
	$data = array(
		'errByRoleName' => $errByRoleName,
		'strRoleNames' => $_POST['role_names'],
		'email_content' => $email_content,
		'dictColor' => $dictColor,
		'dictQualityType' => $dictQualityType,
		'bind'=>$bind,
		'typeid'=>$typeid,
		'color'=>$color,
		'quality'=>$quality,
		'number'=>$number,
		'start_time' =>$start_time,
		'end_time' => $end_time,
	);
//	echo '<pre>';print_r($data);
	$smarty->assign($data);
	$smarty->display ( 'module/gamer/send_goods_batch_by_role_name.tpl' );
	exit();
}elseif ('byAll' == $action){
	$err = array();
	if (!empty($_POST)) {
		$email_content = stripslashes($_POST['email_content'] );
		if (!$email_content) {
			$err[]= '信件内容不能为空!';
		}
		if (is_int(strpos($email_content,'~')))
		{
			$err[] = '信件内容不能包含符号‘~’';
		}
		$email_title = stripslashes(trim($_POST['email_title'])) ;
		if (!$email_title) {
			$errMsg[] = '请输入信件标题！';
		}
		$postData = formatCondition($err);
		if(!empty($err)){
			$err = implode('<br />',$err);
		}else {
			unset($postData['sqlRs'],$postData['sqlCnt']);
			$data = $postData;
			
			$result = doSend("all",$email_content, $email_title, $data['type'], $data['bind'], $data['typeid'], $data['color'], $data['quality'], $data['number'], $data['start_time'], $data['end_time']);
			$ok = $result['result'];
			if($result['result']=='error')
			{
				$ok = '信件发送全部失败！';
			}
						
			//保存进历史记录：
			$jsonCondition = json_encode($data);
			$arrGoodsInfo = array(
				'type'    => $data['type']   ,
				'bind'    => $data['bind'] ,
				'typeid'  => $data['typeid'] ,
				'item_name'=>$data['item_name'] ,
				'color'   => $data['color'] ,
				'quality' => $data['quality'] ,
				'number'  => $data['number'],
				'start_time' => $data['start_time'], 
				'end_time' => $data['end_time'],
			);
			$jsonGoodsInfo = json_encode($arrGoodsInfo);
			$obj = new BatchEmailLog();
			$obj->insert(BatchEmailLog::TYPE_EMAIL_BY_CONDITION_WITH_GOODS ,"14天登录过的全部玩家",$jsonCondition,$email_content,$jsonGoodsInfo, $email_title);
			$loger = new AdminLogClass();
			$detail = "批量道具：{$dictColor[$arrGoodsInfo['color']]}{$dictQualityType[$arrGoodsInfo['quality']]}的【{$arrGoodsInfo['item_name']}】";
			$loger->Log( AdminLogClass::TYPE_MSG_SEND_BATCH_GOODS ,$detail, $arrGoodsInfo['number'],'','' , '');
			$data['number'] = 0; //发送成功后数量清零，以免不小心多点了一次“发送”按钮时，重复发送了。
		}
	}
	
	$arrCompare = array(
		0 => '不限',
		'>' => '等级 ＞ x',
		'>=' => '等级 ≥ x',
		'=' => '等级 ＝ x',
		'<' => '等级 ＜ x',
		'<=' => '等级 ≤ x',
		'between' => 'y ≤ 等级 ≤ x',
	);
	
	$data['email_content'] = $email_content;
	$data['arrCompare'] = $arrCompare;
	$data['arrSex'] = $arrSex;
	$data['arrFaction'] = $arrFaction;
	$data['displayStartLevel'] = 'between'==$data['selectedCompare'] ? '' : 'none';
	$data['displayEndLevel']= !isset($data['selectedCompare']) || '0'==$data['selectedCompare'] ? 'none' : '';
	$data['dictColor'] = $dictColor;
	$data['dictQualityType'] = $dictQualityType;
	$data['err']=$err;
	$data['ok']=$ok;
//	echo '<pre>';print_r($data);echo '</pre>';
	$smarty->assign($data);
	$smarty->display ( 'module/gamer/send_goods_batch_by_all.tpl' );
	exit();
}elseif ('byCondition' == $action){
	$displayStartLevel='none';
	$displayEndLevel='none';
	$err = array();
	if (!empty($_POST)) {
		$email_content = stripslashes($_POST['email_content'] );
		if (!$email_content) {
			$err[]= '信件内容不能为空!';
		}
		if (is_int(strpos($email_content,'~')))
		{
			$err[] = '信件内容不能包含符号‘~’';
		}
		$email_title = stripslashes(trim($_POST['email_title'])) ;
		if (!$email_title) {
			$errMsg[] = '请输入信件标题！';
		}
		$postData = formatCondition($err);
		if(!empty($err)){
			$err = implode('<br />',$err);
		}else {
			unset($postData['sqlRs'],$postData['sqlCnt']);
			$data = $postData;
			$result=doSendByCondition($data,$email_content, $email_title);
			$ok = $result['result'];
			if($result['result']=='error')
			{
				$ok = '信件发送全部失败！';
			}
//			if (is_int($result['result'])){
//				$handletime = $result['result'];
//				$ok = '预计'.$handletime.'秒之后发送完毕！，结果请在“发送结果”中查看';	
//			}else{
//				_error("result=" . $result);
//				$ok = '信件发送全部失败！';
//			} 
			
			
			//保存进历史记录：
			$jsonCondition = json_encode($data);
			$arrGoodsInfo = array(
				'type'    => $data['type']   ,
				'bind'    => $data['bind'] ,
				'typeid'  => $data['typeid'] ,
				'item_name'=>$data['item_name'] ,
				'color'   => $data['color'] ,
				'quality' => $data['quality'] ,
				'number'  => $data['number'],
			);
			$jsonGoodsInfo = json_encode($arrGoodsInfo);
			$obj = new BatchEmailLog();
			$obj->insert(BatchEmailLog::TYPE_EMAIL_BY_CONDITION_WITH_GOODS ,"按条件筛选过的玩家",$jsonCondition,$email_content,$jsonGoodsInfo, $email_title);
			$loger = new AdminLogClass();
			$detail = "批量道具：{$dictColor[$arrGoodsInfo['color']]}{$dictQualityType[$arrGoodsInfo['quality']]}的【{$arrGoodsInfo['item_name']}】";
			$loger->Log( AdminLogClass::TYPE_MSG_SEND_BATCH_GOODS ,$detail, $arrGoodsInfo['number'],'','' , '');
			$data['number'] = 0; //发送成功后数量清零，以免不小心多点了一次“发送”按钮时，重复发送了。
		}
	}
	
	$arrCompare = array(
		0 => '不限',
		'>' => '等级 ＞ x',
		'>=' => '等级 ≥ x',
		'=' => '等级 ＝ x',
		'<' => '等级 ＜ x',
		'<=' => '等级 ≤ x',
		'between' => 'y ≤ 等级 ≤ x',
	);
	
	$data['email_content'] = $email_content;
	$data['arrCompare'] = $arrCompare;
	$data['arrSex'] = $arrSex;
	$data['arrFaction'] = $arrFaction;
	$data['displayStartLevel'] = 'between'==$data['selectedCompare'] ? '' : 'none';
	$data['displayEndLevel']= !isset($data['selectedCompare']) || '0'==$data['selectedCompare'] ? 'none' : '';
	$data['dictColor'] = $dictColor;
	$data['dictQualityType'] = $dictQualityType;
	$data['err']=$err;
	$data['ok']=$ok;
//	echo '<pre>';print_r($data);echo '</pre>';
	$smarty->assign($data);
	$smarty->display ( 'module/gamer/send_goods_batch_by_condition.tpl' );
	exit();
}elseif ('receiverCnt'==$action) {
	$data = formatCondition($err);
	$rsCnt = GFetchRowOne($data['sqlCnt']);
	echo intval($rsCnt['cnt']);
}elseif ('history'==$action){
	$obj = new BatchEmailLog();
	$rs = $obj->getEmail();
//	echo '<pre>';print_r($rs);die();
	$rsEmail = array();
	foreach ($rs as &$row) {
		$row['create_time'] = date('Y-m-d H:i:s',$row['create_time']);
		if (BatchEmailLog::TYPE_EMAIL_BY_CONDITION_WITH_GOODS == $row['type']){
			$condition = json_decode($row['conditions'],true);
			$str = '';
			if($condition['selectedCompare']){
				if ('between'==$condition['selectedCompare']) {
					$str .= "{$condition['startLevel']}  ≤ 等级 ≤ {$condition['endLevel']}; ";
				}else {
					$str .= " 等级 {$condition['selectedCompare']} {$condition['endLevel']}; ";
				}
			}
			if ($condition['selectedSex']) {
				$sex = $arrSex[$condition['selectedSex']];
				$str .= "性别：{$sex}; ";
			}
			if ($condition['selectedFaction']) {
				$faction = $arrFaction[$condition['selectedFaction']];
				$str .= "国家：{$faction}; ";
			}
			if ($condition['family_name']) {
				$str .= "门派：{$condition['family_name']}; ";
			}
			$row['conditions'] = $str ? $str : '无限制条件';
			$arrGoodInfo =  json_decode($row['good_info'],true);
			$goods_info = "{$dictColor[$arrGoodInfo['color']]}{$dictQualityType[$arrGoodInfo['quality']]}的【{$arrGoodInfo['item_name']}】×{$arrGoodInfo['number']}";
			$row['goods_info'] = $goods_info;
			$row['email_content'] = preg_replace('/size="([^"]*)"/i','style="font-size:${1}px;"',$row['email_content']); //把字体大小换成px。
			array_push($rsEmail,$row);
		}elseif(BatchEmailLog::TYPE_EMAIL_BY_ROLE_NAME_WITH_GOODS == $row['type']  ) {
			$row['conditions'] = '无限制条件';
			$arrGoodInfo =  json_decode($row['good_info'],true);
			$goods_info = "{$dictColor[$arrGoodInfo['color']]}{$dictQualityType[$arrGoodInfo['quality']]}的【{$arrGoodInfo['item_name']}】×{$arrGoodInfo['number']}";
			$row['goods_info'] = $goods_info;
			$row['email_content'] = preg_replace('/size="([^"]*)"/i','style="font-size:${1}px;"',$row['email_content']); //把字体大小换成px。
			array_push($rsEmail,$row);
		}
	}
//	echo '<pre>';print_r($rsEmail);echo '</pre>';
	$data = array('rsEmail'=>$rsEmail);
	$smarty->assign($data);
	$smarty->display ( 'module/gamer/send_goods_batch_history.tpl' );
}
exit();

/////////////////////////
function formatCondition(&$err){
	$tableRa = T_DB_ROLE_ATTR_P;
	$tableRb = T_DB_ROLE_BASE_P;
	$tableRe = T_DB_ROLE_EXT_P;
	$sqlRs = " select rb.role_id,rb.role_name from {$tableRb} rb, {$tableRa} ra,{$tableRe} re WHERE rb.role_id=ra.role_id AND re.role_id=rb.role_id ";
	$sqlCnt = " select count(rb.role_id) as cnt from {$tableRb} rb, {$tableRa} ra,{$tableRe} re WHERE rb.role_id=ra.role_id AND re.role_id=rb.role_id ";
	
	$selectedCompare = SS(trim($_POST['selectedCompare']));
	$selectedSex = intval(trim($_POST['selectedSex']));
	$selectedFaction = intval(trim($_POST['selectedFaction']));
	$family_name = trim($_POST['family_name']);
	$startLevel = intval(trim($_POST['startLevel']));
	$endLevel = intval(trim($_POST['endLevel']));
	$lastDays= intval(trim($_POST['lastDays']));
	$where = '';
	$lastStamp=0;
	if(!empty($lastDays))
	{
		if($lastDays>0)
		{ 
		$lastStamp=strtotime(date( "Y-m-d "))-($lastDays-1)*86400;
		$where=" and re.last_login_time>{$lastStamp} ";
		}
	}
	
	if ($selectedCompare) {
		if (in_array( $selectedCompare, array('>','=','<','>=','<=') )) {
			$where .= " and ra.level {$selectedCompare} {$endLevel} ";
		}elseif ('between' == $selectedCompare){
			$where .= " and ra.level between {$startLevel} and {$endLevel} ";
		}
	}
	if ($selectedSex) {
		$where .= " and rb.sex={$selectedSex} ";
	}
	if ($selectedFaction) {
		$where .= " and rb.faction_id={$selectedFaction} ";
	}
	if ($family_name) {
		$where .= " and rb.family_name='{$family_name}' ";
	}
	$sqlRs .= $where;
	$sqlCnt .= $where;
	
	$bind = $_POST ['bind'] ? 1 : 0;
	$typeid = intval ( $_POST ['typeid'] );
	$color = intval($_POST['color']);
	$quality = intval($_POST['quality']);
	$number = intval ( $_POST ['number'] );
	$start_time= $_POST['start_time'];
	$end_time = $_POST['end_time'];
	
		if($start_time!=0)$start_time = strtotime($start_time);
        if($end_time!=0)$end_time =strtotime($end_time);
	if ($typeid) {
		$items = AdminItemClass::getItemByTypeid($typeid);
		if ($items) {
			$type = $items['type'];
			$itemName = $items['item_name'];
		}else{
			$err[] =  "无ID为{$typeid}的物品！" ;
		}
	}else {
		$err[] =  "请输入物品ID！" ;
	}
	/*
	if( check_super_item($typeid) ){
		$err[] =  "您没有赠送超级道具的权限！" ;
	}else if( check_money_item($typeid) ){
		$err[] =  "您没有赠送货币道具的权限！" ;
	}*/
	
	if ($number <=0) {
		$err[] =  "数量必须为正数！" ;
	}
	if ($number > 50) {
		$err[] =   "最多赠送50个！" ;
	}
	//-define(TYPE_EQUIP, 3).
	if ($number > 1 && $type==3 ) {
		$err[] =   "装备一次只能赠送1件！" ;
	}
	
	return array(
		'selectedCompare'=>$selectedCompare,
		'selectedSex' => $selectedSex,
		'selectedFaction'=>$selectedFaction,
		'startLevel'=>$startLevel,
		'endLevel'=>$endLevel,
		'bind'=>$bind,
		'type'=>$type,
		'typeid'=>$typeid,
		'item_name'=>$itemName,
		'color'=>$color,
		'quality'=>$quality,
		'number'=>$number,
		'start_time'=>$start_time,
		'end_time'=>$end_time,
		'last_stamp'=>$lastStamp,
		'family_name'=>$family_name,
		'sqlRs'=>$sqlRs,
		'sqlCnt'=>$sqlCnt
	);
}


function doSend($strRoleIds,$email_content, $email_title, $type, $bind, $typeid, $color, $quality, $number ,$start, $end)
{
	$email_content = base64_encode(base64_encode($email_content));
	$email_title = base64_encode(base64_encode($email_title));
	$url =ERLANG_WEB_URL . "/send_goods_batch" ;
	$params = "title={$email_title}&role_list={$strRoleIds}&type={$type}&bind={$bind}&typeid={$typeid}&color={$color}&quality={$quality}&number={$number}&email_content={$email_content}&start_time={$start}&end_time={$end}";
	$data = curlPost($url, $params);
	_error("wuzesen,data=" . $data);
	return json_decode($data,true);
}

function doSendByCondition($data,$email_content, $email_title)
{
	$email_content = base64_encode(base64_encode($email_content));
	$email_title = base64_encode(base64_encode($email_title));
	$url =ERLANG_WEB_URL . "/send_goods_batch_by_condition" ;
	$params = "title={$email_title}" .
			"&type={$data['type']}" .
			"&bind={$data['bind']}" .
			"&typeid={$data['typeid']}" .
			"&color={$data['color']}" .
			"&quality={$data['quality']}" .
			"&number={$data['number']}" .
			"&email_content={$email_content}" .
			"&start_time={$data['start_time']}" .
			"&end_time={$data['end_time']}" .
			"&sex={$data['selectedSex']}" .
			"&faction={$data['selectedFaction']}" .
			"&start_level={$data['startLevel']}" .
			"&end_level={$data['endLevel']}" .
			"&family_name={$data['family_name']}" .
			"&selected_compare={$data[selectedCompare]}" .
			"&last_stamp={$data[last_stamp]}";
	$data = curlPost($url, $params);
	_error("wuzesen,data=" . $data);
	return json_decode($data,true);
}

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