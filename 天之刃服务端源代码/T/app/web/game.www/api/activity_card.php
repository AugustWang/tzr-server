<?php
/**
 * 天之刃获取新手卡接口
 * @author liuwei
 * @date 2011.6.23
 * @lastmodified 2011.6.23
 */

define('IN_ODINXU_SYSTEM', true);

include_once "../config/config.ip.limit.pay.php";
include("../config/config.php");
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";

define('ACTIVE_NUM_LENGTH'     , 12);

$qid     = SS($_REQUEST['qid']); 
$server_id    = SS($_REQUEST['server_id']);        		//游戏分区
$card_type = SS($_REQUEST['card_type']);
$mtime = time(); 

if(empty($card_type)) {
	$card_type = 11;
}

$action = SS($_REQUEST['action']);
if($action == 'chk'){
	$sign = SS($_REQUEST['sign']);
	$chkcode = SS($_REQUEST['chkcode']);
	$chk_sign = md5($chkcode.$API_SECURITY_TICKET_INFO);
	if($chk_sign==$sign){
		$sql="SELECT `role_id` as cnt FROM t_activate_code WHERE code = '{$chkcode}'";
		$result = GFetchRowOne($sql);
		if (($result['cnt']) < 1) {
			$msg = "未兑换";
		}else{
			$msg = "已兑换";
		}
		die($msg);
	}else{
		die("Key验证出错");
	}
}



if(AGENT_NAME != "360") {
	$sign = SS($_REQUEST['sign']);
	$total = SS($_REQUEST['total']);
	if( strtolower($sign) != strtolower(md5($qid.$server_id.$card_type.$API_SECURITY_TICKET_INFO))) {
		die("wrong ticket");
	}else{	
		if(empty($total)||$total==1){
			$code = md5($server_id . $qid  . $card_type. time() . $API_SECURITY_TICKET_INFO);
			$code = substr($code,0, ACTIVE_NUM_LENGTH ) . $card_type;
			$result = check($code,$card_type,$mtime);	
			if($result){
				echo $code.'<br>';
				//echo $code."\n";
			}
		}else{
			for($i=1;$i<=$total;$i++){
				$code = md5($server_id . $qid  .$i.time(). $card_type . $API_SECURITY_TICKET_INFO);
				$code = substr($code,0, ACTIVE_NUM_LENGTH ) . $card_type;
				$result = check($code,$card_type,$mtime);	
				if($result){
					echo $code.'<br>';
				//	echo $code;
				//	echo "\n";
				}	
			}
		}
	}
	
}else{ //360不验证
	$code = md5($server_id . $qid  . $card_type . "360::activity::card::gfkdsg6548&5j$");
	$code = substr($code,0, ACTIVE_NUM_LENGTH ) . $card_type;	
	$result = check($code,$card_type,$mtime);	
	if($result){
		echo $code;
	}
	
}


function check($code,$card_type,$mtime){
	$sql="SELECT `role_id` FROM t_activate_code WHERE code = '{$code}'";
	$result = GFetchRowOne($sql);
	if (count($result) < 1) {
		$sqlInsert = "INSERT INTO `t_activate_code` (`code`, `publish_id`, `publish_time`) VALUES ('{$code}','{$card_type}','{$mtime}')";
		$res = GQuery($sqlInsert);
	}else{
		$res = false;
	}
	return $res;
}

