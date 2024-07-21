<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN."/class/broadcast.class.php";
include_once('../../../config/config_servers.php');
include_once SYSDIR_ADMIN.'/class/api/broadcast_copy_api.class.php';
global $smarty;


$action = trim($_GET['action']);
if(empty($action)){
	$action='list';
}
$broadcastClass = new BroadcastClass();
if ($action == 'list') {
	$result = $broadcastClass -> listBroadcast();
	$url_list = $SERVERS_LIST;
	$cur_sid = SERVER_ID;
	$smarty->assign('url_list', $url_list);
	$smarty->assign ( array ('dataResultSet' => $result ));
	$smarty->assign ('cur_sid', $cur_sid);
	$smarty->display ( "module/chat/broadcast_message_list.html" );
	
} else if ($action == 'add') {
	$broadcastVo = $broadcastClass -> addBroadcast();
	$smarty->assign('broadcastVo', $broadcastVo);
	$smarty->assign('action', $action);
	$smarty->display ( "module/chat/broadcast_message_edit.html" );
	
} else if ($action == 'edit') {
	$id = trim($_GET['id']);
	$result = $broadcastClass -> editBroadcast($id,"id");
	$resultCode = $result["ResultCode"];
	$resultDesc = $result["ResultDesc"];
	$broadcastVo = $result["ResultData"];
	$smarty->assign('broadcastVo', $broadcastVo);
	$smarty->assign('action', $action);
	$smarty->assign('ResultCode', $ResultCode);
	$smarty->assign('ResultDesc', $ResultDesc);
	$smarty->display ( "module/chat/broadcast_message_edit.html" );
	
} else if ($action == 'show') {
	$id = trim($_GET['id']);
	$result = $broadcastClass -> showBroadcast($id,"id");
	$resultCode = $result["ResultCode"];
	$resultDesc = $result["ResultDesc"];
	$broadcastVo = $result["ResultData"];
	$smarty->assign('broadcastVo', $broadcastVo);
	$smarty->assign('action', $action);
	$smarty->assign('ResultCode', $ResultCode);
	$smarty->assign('ResultDesc', $ResultDesc);
	$smarty->display ( "module/chat/broadcast_message_edit.html" );
	
} else if($action == 'del'){
	$ids = trim($_GET['ids']);                          
	$result = $broadcastClass -> delBroadcast($ids,"id");
	$resultCode = $result["ResultCode"];
	$resultDesc = $result["ResultDesc"];
	$resultData = $result["ResultData"];
	$smarty->assign (array('dataResultSet' => $resultData));
	$smarty->assign('ResultCode', $ResultCode);
	$smarty->assign('ResultDesc', $ResultDesc);
	$smarty->display ( "module/chat/broadcast_message_list.html" );
	
}else if($action == 'copy'){
	$server_ids = trim($_GET['server_ids']);
	$msg_ids = trim($_GET['msg_ids']);
	$server_ids = explode(',',$server_ids);
	$msg_ids = explode(',',$msg_ids);
	foreach($msg_ids as $k=> $v)
	{
		$broadcastDetail = $broadcastClass -> showBroadcast($v,"id");
		$broadcastVo = $broadcastDetail["ResultData"];
		$broadcastVo['content']=base64_encode($broadcastVo['content']);
		foreach($server_ids as $key => $val)
		{
			$JSONresult = BroadcastCopyApi::sendMsg($broadcastVo,$SERVERS_LIST[$val]);
			$ARRresult = json_decode($JSONresult,true);
			$sendResult[$val][$v] =$ARRresult['result'];
		}
	}
	$smarty->assign('msg_ids',$msg_ids);
	$smarty->assign('sendResult', $sendResult);	
	$smarty->display ( "module/chat/broadcast_message_result.html" );

}else if($action == 'save'){
	$id = trim($_GET['id']);
	$foreign_id = trim($_GET['foreign_id']);
	$type = trim($_GET['type']);
	$send_strategy = trim($_GET['send_strategy']);
	$start_date = trim($_GET['start_date']);
	$end_date = trim($_GET['end_date']);
	$start_time = trim($_GET['start_time']);
	$end_time = trim($_GET['end_time']);
	$interval = trim($_GET['interval']);
	$content = urlencode(base64_encode(stripslashes(trim($_GET['content']))));
	$result = $broadcastClass -> saveBroadcast($id,$foreign_id,$type,$send_strategy,$start_date,
		$end_date,$start_time,$end_time,$interval,$content);
	$resultCode = $result["ResultCode"];
	$resultDesc = $result["ResultDesc"];
	$broadcastVo = $result["ResultData"];
	$smarty->assign('ResultCode', $ResultCode);
	$smarty->assign('ResultDesc', $ResultDesc);
	$smarty->assign('action', $action);
	$smarty->assign('broadcastVo', $broadcastVo);
	$smarty->display ( "module/chat/broadcast_message_edit.html" );
}
else{
	$result = $broadcastClass -> listBroadcast();
	$smarty->assign (array('dataResultSet' => $result));
	$smarty->display ( "module/chat/broadcast_message_list.html" );
}

