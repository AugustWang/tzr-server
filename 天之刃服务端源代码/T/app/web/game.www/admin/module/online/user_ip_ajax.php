<?php
$qs = $_SERVER['QUERY_STRING'];
switch ($_GET['router']) {
	case 'ban':
		doBan();
		break;
	case 'online':
		doOnline();
		break;	
	default:
		break;
}

function doBan(){
	
	
}

$result  =  getJson(ERLANG_WEB_URL . "/ban?".$qs);
$result = json_decode($result);
if (substr($qs,'user') !== FALSE && substr($qs,'view') !== FALSE) {
	foreach ($result as &$item) {
		$item['rolename'] = getRolenameById($item['id']);
		$item['user_ip'] = getIpById($item['id']);
	}
}
echo json_encode($result);

function getRolenameById($rolename){
	$sql = "select role_name from db_role_attr_p where role_id = $rolename";
	$result = fetchRowOne($sql);
	return isset($result['role_name'])?$result['role_name']:"NULL";
}

function getIpById($id){
	$sql = "select last_login_ip from db_role_attr_p where role_id = $id";
	$ret = fetchRowOne($sql);
	return $ret['last_login_ip'] or NULL;		
}



?>