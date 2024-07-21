<?php
/**
 * 天之刃360代理充值接口
 * @author liuwei
 * @date 2011.6.23
 * @lastmodified 2011.6.23
 */

define('IN_ODINXU_SYSTEM', true);

include_once "../config/config.ip.limit.pay.php";
include("../config/config.php");
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_INCLUDE."/functions.php";

$order_id    = SS($_REQUEST['order_id']);         			//订单号
$qid     = intval($_REQUEST['qid']);       					//360用户ID
$order_amount   = intval($_REQUEST['order_amount']);      //充值金额，人民币
$server_id    = $_REQUEST['server_id'];        				//游戏分区
$sign      = SS($_REQUEST['sign']);							//签名

$pay_gold = $order_amount * 10;								//360没有充值元宝的参数，所以都是充值的钱*10
$pay_time = time();											//360没有给充值时间

// 充值详细日志，只要请求了这个接口，都会有一个记录，存储在：tlog_pay_request  2010-07-07
$log_detail = "PayNum=" . $order_id . ";PayToUser=" . $qid .
                ";PayMoney=" . $order_amount . ";PayGold=" . $pay_gold .
                  ";PayTime=" . $pay_time . ";ticket=" . $sign;
$logid = writePayApiLog($log_detail, $qid);//记录日志

if(empty($order_id) || $qid <= 0 || empty($pay_gold) 
	|| $pay_gold < 0 || empty($sign)) {
		log_die($logid, 'param error.');// 充值详细日志
} else {
	$serverID2 = strtoupper($server_id);
	$token = md5($qid . $order_amount . $order_id . $serverID2 . $API_SECURITY_TICKET_PAY);
	
	if($token != $sign) {
		log_die($logid, 'ticket error.');
	}
}

$year = date('Y', $pay_time);
$month = date('m', $pay_time);
$day = date('d', $pay_time);
$hour = date('H', $pay_time);

//充值的具体逻辑由游戏服完成，返回 array('result' => $result);

$url = "/api/pay/?order_id={$order_id}&ac_name={$qid}"
		."&pay_gold={$pay_gold}&pay_time={$pay_time}&pay_money={$order_amount}&year={$year}"
		."&month={$month}&day={$day}&hour={$hour}";
$result = getWebJson($url);

if ($result == NULL) {
	log_die($logid, '0');
} else {
	if ($result['result'] == 'ok') {
		log_die($logid, '1','true');
	}elseif ($result['result'] == 'used') {
		log_die($logid, '2','true');
	}
	 else {
		log_die($logid, '0');
	}
}

exit;

