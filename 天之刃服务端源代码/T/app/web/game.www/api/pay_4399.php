<?php
/**
 * 天之刃充值接口
 * @author QingliangCn <qing.liang.cn@gmail.com>
 * @date 2010.10.28
 * @lastmodified 2010.10.28
 */

define('IN_ODINXU_SYSTEM', true);

include_once "../config/config.ip.limit.pay.php";
include("../config/config.php");
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_INCLUDE."/functions.php";


$p = SS($_REQUEST['p']);
$params = explode("|",$p);

$order_id  = SS($params[0]);                    //订单号
$ac_name   = urldecode($params[1]);              //充值的平台帐号
$pay_money = floatval($params[2]);
$pay_gold  = intval($params[3]);                 //充值元宝
$pay_time  = intval($params[4]);                  //充值时间
$ticket    = SS($params[5]);
// 待定..


//$order_id    = SS($_REQUEST['PayNum']);           //订单号
//$ac_name     = SS($_REQUEST['PayToUser']);       //充值的平台帐号
//$pay_money   = floatval($_REQUEST['PayMoney']);     //充值金额，人民币
//$pay_gold    = intval($_REQUEST['PayGold']);        //充值元宝
//$pay_time    = intval($_REQUEST['PayTime']);        //充值时间
//$ticket      = SS($_REQUEST['ticket']);

// 充值详细日志，只要请求了这个接口，都会有一个记录，存储在：tlog_pay_request  2010-07-07
$log_detail = "PayNum=" . $order_id . ";PayToUser=" . $ac_name .
                ";PayMoney=" . $pay_money . ";PayGold=" . $pay_gold .
                  ";PayTime=" . $pay_time . ";ticket=" . $ticket;
$logid = writePayApiLog($log_detail, $ac_name);//记录日志

if(empty($order_id) || empty($ac_name) || empty($pay_gold) 
	|| $pay_gold < 0 || empty($pay_time) || empty($ticket)) {
		//log_die($logid, 'param error.');// 充值详细日志
		log_die($logid,'-1');
} else {
	// 解决：部分代理传的时间戳为“毫秒”（充值接口要求是：秒） 或 参数异常的问题
	// 限制充值时间，必须是：2009-01-01 至 2037-12-31之间的充值，或 2009-01-01 至 当前时间的充值，才作为正常充值。
	// 1230739200 => 2009-01-01, 2145801600 => 2037-12-31
	if($pay_time < 1230739200 || ($pay_time > time()+300 && $pay_time > 2145801600)){
		log_die($logid, '-1');// 充值详细日志
	}
	$token = md5($order_id . $ac_name . $pay_money . $pay_gold . $pay_time.$API_SECURITY_TICKET_PAY);
	//echo $token;
	if($token != $ticket) {
		log_die($logid, '-2');
	}
}


$year = date('Y', $pay_time);
$month = date('m', $pay_time);
$day = date('d', $pay_time);
$hour = date('H', $pay_time);

//充值的具体逻辑由游戏服完成，返回 array('result' => $result);

$url = "/api/pay/?order_id={$order_id}&ac_name={$ac_name}"
		."&pay_gold={$pay_gold}&pay_time={$pay_time}&pay_money={$pay_money}&year={$year}"
		."&month={$month}&day={$day}&hour={$hour}";
$result = getWebJson($url);
if ($result == NULL) {
	log_die($logid, '-4');
} else {
	if ($result['result'] == 'ok') {
		log_die($logid, '1','true');
	} else if($result['result'] == 'used')  {
		log_die($logid, '2','true');
	} else if($result['result'] == 'not_found') {
		log_die($logid, '-3');
	} else {
		log_die($logid, '-4');
	}
}

exit;



