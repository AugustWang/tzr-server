<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/batch_email_log_class.php';
$action = trim($_GET['action']);
$action = $action ? $action : 'byRoleName';

$arrSex = array(0=>'不限', 1=>'男',2=>'女');
$arrFaction = array(0 => '不限',1=>'云州',2=>'沧州',3=>'幽州');
$ONE_TIME_SEND_MAX = 300; //一次发多少个玩家。（用于按条件发信）
if ('byRoleName' == $action) {
	if (!empty($_POST)) {
		$role_names = explode('，',$_POST['role_names']);
		$email_content = stripslashes($_POST['email_content']) ;
		$email_title = stripslashes($_POST['email_title']) ;
		
		$arrRoleName = array();
		if (empty($role_names)) {
			$errMsg[] = '角色名为空！'; 
		}else {
			foreach ($role_names as $roleName) {
				$roleName = SS($roleName);
				if ($roleName) {
					array_push($arrRoleName,"'{$roleName}'");
				}
			}
		}
		if (!empty($arrRoleName)) {
			$table = T_DB_ROLE_BASE_P;
			$strRoleNames = implode(',',$arrRoleName);
			$sql = " select role_id,role_name from {$table} WHERE role_name in ({$strRoleNames}) ";
			$roles = GFetchRowSet($sql);
			$strLogRoleNames = '';
			foreach ($roles as &$row) {
				$strRoleIds .=$row['role_id'].',';
				$strLogRoleNames .=$row['role_name'].'，';
			}
			$strRoleIds = trim($strRoleIds,',');
			$strLogRoleNames = trim($strLogRoleNames,'，');
			if (!$strRoleIds) {
				$errMsg[] = '查不到对应的玩家';
			}
		}
		if (!$email_title) {
			$errMsg[] = '请输入信件标题！';
		}
		if (!$email_content) {
			$errMsg[] = '请输入信件内容！';
		}
		if (is_int(strpos($email_content,'~')))
		{
			$errMsg[] = '信件内容不能包含符号‘~’';
		}
	
		if (empty($errMsg)) {
			$result = doSend($strRoleIds,$email_content,$email_title);
			if ('ok'==$result['result']) {
				$errByRoleName =  '信件已经成功发出';
				$obj = new BatchEmailLog();
				$obj->insert(BatchEmailLog::TYPE_EMAIL_BY_CONDITION_NO_GOODS ,$strLogRoleNames,$jsonCondition,$email_content,'',$email_title);
				$loger = new AdminLogClass();
				$loger->Log( AdminLogClass::TYPE_MSG_SEND_BATCH_EMAIL ,'批量发信', '','', '', '');
			}else{
				$errByRoleName =  '信件发送失败';
			}
		}else {
			$errByRoleName = implode('<br />',$errMsg);
		}
	}
	$data = array(
		'errByRoleName' => $errByRoleName,
		'strRoleNames' => $_POST['role_names'],
		'email_content' => $email_content,
	);
	$smarty->assign($data);
	$smarty->display ( 'module/chat/send_email_batch_by_role_name.tpl' );
	exit();
}elseif ('byCondition' == $action){
	$displayStartLevel='none';
	$displayEndLevel='none';
	if (!empty($_POST)) {
		$email_content =  stripslashes($_POST['email_content']) ;
		$email_title =  stripslashes($_POST['email_title']) ;
		if (""==$email_title) {
			$errMsg[]= '信件标题不能为空!';
		}
		if (""==$email_content) {
			$errMsg[]= '信件内容不能为空!';
		}
		if (is_int(strpos($email_content,'~')))
		{
			$errMsg[] = '信件内容不能包含符号‘~’';
		}
		if(!empty($errMsg)){
			$err = implode('<br />',$errMsg);
		}else {
			$postData = formatCondition();
//			echo '<pre>';print_r($postData);echo '</pre>';die();

			$data = $postData;
			$result=doSendByCondition($data,$email_content, $email_title);
			$ok = $result['result'];
			if($result['result']=='error')
			{
				$ok = '信件发送全部失败！';
			}

			//保存进历史记录：
			$jsonCondition = json_encode($data);
			$obj = new BatchEmailLog();
			$obj->insert(BatchEmailLog::TYPE_EMAIL_BY_CONDITION_NO_GOODS ,'',$jsonCondition,$email_content,'',$email_title);
			$loger = new AdminLogClass();
			$loger->Log( AdminLogClass::TYPE_MSG_SEND_BATCH_EMAIL ,'批量发信', '','', '', '');
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
	
	
	$data['email_title'] = $email_title;
	$data['email_content'] = $email_content;
	$data['arrCompare'] = $arrCompare;
	$data['arrStatus'] = array(0=>'不限',1=>'在线');
	$data['arrSex'] = $arrSex;
	$data['arrFaction'] = $arrFaction;
	$data['displayStartLevel'] = 'between'==$data['selectedCompare'] ? '' : 'none';
	$data['displayEndLevel']= !isset($data['selectedCompare']) || '0'==$data['selectedCompare'] ? 'none' : '';
	
	$data['err']=$err;
	$data['ok']=$ok;
	
	$smarty->assign($data);
	$smarty->display ( 'module/chat/send_email_batch_by_condition.tpl' );
	exit();
}elseif ('receiverCnt'==$action) {
	$data = formatCondition();
	$rsCnt = GFetchRowOne($data['sqlCnt']);
	echo intval($rsCnt['cnt']);
}elseif ('history'==$action){
	$obj = new BatchEmailLog();
	$rs = $obj->getEmail();
//	echo '<pre>';print_r($rs);die();
	$rsEmail = array();
	foreach ($rs as &$row) {
		$row['create_time'] = date('Y-m-d H:i:s',$row['create_time']);
		if (BatchEmailLog::TYPE_EMAIL_BY_CONDITION_NO_GOODS == $row['type']){
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
			$row['email_content'] = preg_replace('/size="([^"]*)"/i','style="font-size:${1}px;"',$row['email_content']); //把字体大小换成px。
			array_push($rsEmail,$row);
		}elseif(BatchEmailLog::TYPE_EMAIL_BY_ROLE_NAME_NO_GOODS == $row['type']  ) {
			$row['conditions'] = '无限制条件';
			$row['email_content'] = preg_replace('/size="([^"]*)"/i','style="font-size:${1}px;"',$row['email_content']); //把字体大小换成px。
			array_push($rsEmail,$row);
		}
	}
//	echo '<pre>';print_r($rsEmail);echo '</pre>';
	$data = array('rsEmail'=>$rsEmail);
	$smarty->assign($data);
	$smarty->display ( 'module/chat/send_email_batch_history.tpl' );
}

exit();

/////////////////////////
function formatCondition(){
	$tableRa = T_DB_ROLE_ATTR_P;
	$tableRb = T_DB_ROLE_BASE_P;
	$tableRe = T_DB_ROLE_EXT_P;
	
	$selectedStatus = intval($_POST['selectedStatus']);
	$strUserOnline = $selectedStatus ? ",t_user_online uo " : "" ;
	$strWhereOnline = $selectedStatus ? " AND uo.role_id=ra.role_id " : "" ;
	$sqlRs = " select rb.role_id,rb.role_name from {$tableRb} rb, {$tableRa} ra, {$tableRe} re {$strUserOnline} WHERE rb.role_id=ra.role_id AND rb.role_id=re.role_id {$strWhereOnline}";
	$sqlCnt = " select count(rb.role_id) as cnt from {$tableRb} rb, {$tableRa} ra, {$tableRe} re {$strUserOnline} WHERE rb.role_id=ra.role_id AND rb.role_id=re.role_id {$strWhereOnline} ";
	
	$selectedCompare = SS(trim($_POST['selectedCompare']));
	$days = intval($_POST['days']);
	$days = $days >0 && $days <= 14 ? $days : 14; 
	$selectedSex = intval(trim($_POST['selectedSex']));
	$selectedFaction = intval(trim($_POST['selectedFaction']));
	$family_name = trim($_POST['family_name']);
	$startLevel = intval(trim($_POST['startLevel']));
	$endLevel = intval(trim($_POST['endLevel']));
	$where = '';
	$lastLoginTime = time() - $days * 24 * 3600 ;
	$where.=" AND re.last_login_time > {$lastLoginTime} ";
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
	return array(
		'selectedCompare'=>$selectedCompare,
		'selectedStatus'=>$selectedStatus,
		'days'=>$days,
		'last_stamp'=>$lastLoginTime,
		'selectedSex' => $selectedSex,
		'selectedFaction'=>$selectedFaction,
		'family_name'=>$family_name,
		'startLevel'=>$startLevel,
		'endLevel'=>$endLevel,
		'sqlRs'=>$sqlRs,
		'sqlCnt'=>$sqlCnt
	);
}


function doSend($strRoleIds,$email_content,$email_title)
{
	$email_content = base64_encode(base64_encode($email_content)); //发信前先把信件内容进行 双重base64加密 否则有些特殊字符发不了。
	$email_title = base64_encode(base64_encode($email_title));
	$url =ERLANG_WEB_URL . "/email/send_email_batch" ;
	$params = "role_list={$strRoleIds}&email_content={$email_content}&email_title={$email_title}";
	$data = curlPost($url, $params);
	return json_decode($data,true);
}


function doSendByCondition($data,$email_content, $email_title)
{
	$email_content = base64_encode(base64_encode($email_content));
	$email_title = base64_encode(base64_encode($email_title));
	$url =ERLANG_WEB_URL . "/email/send_email_batch" ;
	$params = "email_title={$email_title}" .
			"&email_content={$email_content}" .
			"&status={$data['selectedStatus']}".
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