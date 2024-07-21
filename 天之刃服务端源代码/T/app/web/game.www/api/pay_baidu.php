<?php
/**
 * 天之刃百度代理充值接口
 * @author liuwei
 * @date 2011.6.29
 * @lastmodified 2011.6.29
 */

define('IN_ODINXU_SYSTEM', true);

include_once "../config/config.ip.limit.pay.php";
include("../config/config.php");
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_INCLUDE."/functions.php";

	$apiKey = SS($_POST['api_key']);
	$accountName     = SS($_POST['user_id']); 
	$pay_time   = SS($_POST['timestamp']);   
	$serverID    = SS($_POST['server_id']);        		//游戏分区
	$order_id    = SS($_POST['order_id']);         			//玩家订单号
	$wanba_oid    = SS($_POST['wanba_oid']);         			//订单号
	$order_amount   = intval($_POST['amount']);      //充值金额，人民币
	$currency   = SS($_POST['currency']);      //币种
	$result   = SS($_POST['result']);      //支付结果，支付成功返回“1”，支付中返回“0”，支付失败返回“-1”
	$back_send   = SS($_POST['back_send']);      //后台通知（Y）、前台通知（N）
	$sign      = SS($_POST['sign']);							//签名
	$pay_gold = $order_amount * 10;								//360没有充值元宝的参数，所以都是充值的钱*10
	$timetick = strtotime($pay_time);
// 充值详细日志，只要请求了这个接口，都会有一个记录，存储在：tlog_pay_request  2010-07-07
$log_detail = "PayNum=" . $order_id . " " . $wanba_oid . ";PayToUser=" . $accountName .
                ";PayMoney=" . $order_amount . ";PayGold=" . $pay_gold .
                  ";PayTime=" . $timetick . ";ticket=" . $sign;
$logid = writePayApiLog($log_detail, $accountName);//记录日志

if(empty($order_id) || empty($accountName)|| empty($wanba_oid) || empty($pay_gold) 
	|| $pay_gold < 0 || empty($sign)) {
		log_die($logid, 'param error.');// 充值详细日志
} else {
	$ticketValid = md5($API_SECURITY_TICKET_PAY."amount".$order_amount."api_key".$apiKey."back_send".
	$back_send."currency".$currency."order_id".$order_id."result".$result."server_id".
	$serverID."timestamp".$pay_time."user_id".$accountName."wanba_oid".$wanba_oid);
	
	if (strtolower($sign) != strtolower($ticketValid)) {
		log_die($logid, 'sign error.');
	}
}



$year = date('Y', $timetick);
$month = date('m', $timetick);
$day = date('d', $timetick);
$hour = date('H', $timetick);

//充值的具体逻辑由游戏服完成，返回 array('result' => $result);
//百度的订单号特殊处理，用_ext_链接起来
$url = "/api/pay/?order_id={$order_id}_ext_{$wanba_oid}&ac_name={$accountName}"
		."&pay_gold={$pay_gold}&pay_time={$timetick}&pay_money={$order_amount}&year={$year}"
		."&month={$month}&day={$day}&hour={$hour}";
		
$result = getWebJson($url);

if ($result == NULL) {
	log_die($logid, '00');
} 
else {
	if ($result['result'] == 'ok') {
		log_die($logid, '<!--recv=ok-->','true');
	}elseif ($result['result'] == 'used') {
		log_die($logid, '<!--recv=ok-->','true');
	}
	 else {
		log_die($logid, $result['result']);
	}
}

exit;


