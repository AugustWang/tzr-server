<?php
/**
 * @desc 称号管理
 * @author linruirong@mingchao.com
 * 
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$action = $_REQUEST['action'];
$table1 = T_DB_NORMAL_TITLE_P;
$table2 = T_DB_ROLE_BASE_P;
$role = $_REQUEST['role'];
if (!empty($role)) {
	$role['role_id'] = intval($role['role_id']);
	$role['role_name'] = SS($role['role_name']);
	$role['account_name'] = SS($role['account_name']);
}

if ("searchUser" == $action) {
	$role = UserClass::getUser($role['role_name'],$role['account_name'],$role['role_id']);
	if (empty($role)) {
		$errMsg[] = '查不到玩家"'.$_REQUEST['role_name'].'"';
	}
	$showInChatChk = ' checked="checked" ';
	$showInSenceChk = ' checked="checked" ';
}elseif ('set' == $action) {
	$errMsg = array();
	$data = formateData($role['role_id'],$errMsg);
	if (empty($errMsg)) {
		$setRs = doSet($data);
		$send_letter = intval($_REQUEST['send_letter']);
		$content = trim($_REQUEST['letter_content'],'<br>') ;
		if ($send_letter && $content) {
			doSendEmail($role['role_id'],base64_encode(base64_encode($content)));
		}
//		echo $setRs;
	}
}elseif ('del'== $action ) {
	$title_id = intval($_REQUEST['id']);
	$role['role_id'] = intval($_REQUEST['role_id']);
	$delRs = doDel($title_id,$role['role_id']);
//	echo $delRs;
}/*elseif ('update' == $action){
	$id = intval($_REQUEST['id']);
	$sqlUpdate = " SELECT nt.*,rb.role_name, rb.account_name FROM {$table1} nt, {$table2} rb WHERE nt.id={$id} AND rb.role_id=nt.role_id ";
	$result = GFetchRowOne($sqlUpdate);
	$role = array(
		'role_id' => $result['role_id'],
		'role_name' => $result['role_name'],
		'account_name' => $result['account_name'],
	);
	$title = $result['name'];
	$color = $result['color'];
	$showInChatChk = $result['show_in_chat'] ? ' checked="checked" ' : '';
	$showInSenceChk = $result['show_in_sence'] ? ' checked="checked" ' : '';
	$end_time = $result['timeout_time'] ? date('Y-m-d H:i:s',$result['timeout_time']) : '';
}*/
$err = empty($errMsg) ? '' : implode('<br />',$errMsg);
$arrTitles = array(
	1=>'皇帝称号',
	2=>'国王称号',
	3=>'师傅称号',
	4=>'婚姻称号',
	5=>'门派称号',
	6=>'等级称号',
	7=>'自定义称号',
	100=>'锦衣卫',
	110=>'丞相',
	120=>'大将军',
	104001=>'恶人榜称号',
	101001=>'等级榜称号',
	105001=>'功勋榜称号'
);
$type = SS($_REQUEST['type']) ? SS($_REQUEST['type']) : 7 ; //默认只取自定义的

$where='';
if ( intval($role['role_id']) ) {
	$where = " and rb.role_id={$role['role_id']} ";
}elseif ($role['role_name']){
	$where = " and BINARY rb.role_name='{$role['role_name']}' ";
}
$sql = " SELECT nt.*,rb.role_name FROM {$table1} nt, {$table2} rb WHERE nt.type={$type} AND rb.role_id=nt.role_id {$where} ";

$allGamerTitles =  GFetchRowSet($sql);
if (is_array($allGamerTitles)) {
	foreach ($allGamerTitles as &$row) {
		$row['auto_timeout'] = $row['auto_timeout'] ? '是' : '否';
		$row['timeout_time'] = $row['timeout_time'] > 0 ? date('Y-m-d H:i:s',$row['timeout_time']) : '';
		$row['show_in_chat'] = $row['show_in_chat'] ? '是' : '否';
		$row['show_in_sence'] = $row['show_in_sence'] ? '是' : '否';
	}
}

if (!empty($role)) {
	foreach ($role as $key => $val) {
		$urlListSuffix .= urlencode('role['.$key.']').'='.$val.'&amp;';
	}
}
$data = array(
	'allGamerTitles' => $allGamerTitles,
	'role' => $role,
	'title' => $title,
	'color' => $color,
	'showInChatChk' => $showInChatChk,
	'showInSenceChk' => $showInSenceChk,
	'end_time' => $end_time,
	'err' => $err,
	'urlListSuffix'=>$urlListSuffix,
);

$smarty->assign($data);
$smarty->display('module/gamer/gamer_title.tpl');
exit();
//////////////
function formateData($role_id,&$errMsg)
{
	$data['role_id'] = $role_id;
	$data['title'] = SS($_REQUEST['title']);
	$data['color'] = SS(trim($_REQUEST['color'],'#'));
	$data['start_time'] = intval(strtotime($_REQUEST['start_time']));
	$data['end_time'] = intval(strtotime($_REQUEST['end_time']));
	$data['show_in_chat'] = intval($_REQUEST['show_in_chat']) ? 'true' : 'false';
	$data['show_in_sence'] = intval($_REQUEST['show_in_sence']) ? 'true' : 'false';;
	$data['auto_timeout'] = $data['end_time'] ? 'true' : 'false';
	$data['timeout_time'] = $data['end_time']; //暂时只用结束时间，即一给玩家加上自定义称号，就立即生效
	
	if (!$role_id) {
		$errMsg[] = '没有此玩家！';
	}
	if (!$data['title']) {
		$errMsg[] = '称号不能为空！';
	}
	if (!$data['color']) {
		$errMsg[] ='颜色值不能为空！';
	}
	return $data;
}

function doSet($data)
{
	foreach ($data as $key => $val) {
		$params .= "{$key}={$val}&";
	}
	$params = trim($params,'&');
	$url = ERLANG_WEB_URL.'/gamer_title/add_title';
	$result = curlPost($url,$params);
	return $result;
}

function doDel($title_id, $role_id)
{
	$params = "title_id={$title_id}&role_id={$role_id}";
	$url = ERLANG_WEB_URL.'/gamer_title/remove_title';
	$result = curlPost($url,$params);
	return $result;
}

function doSendEmail($role_id, $content)
{
	$url = ERLANG_WEB_URL . "/email/send_email" ;
	$params = 'role_id='.$role_id.'&content='.$content;
	$data = curlPost($url, $params);
	return json_decode($data,true);
}