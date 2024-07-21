<?php
/**
 * 天之刃360代理充值明细查询接口
 * @author caisiqiang
 * @date 2011.6.23
 * @lastmodified 2011.6.23
 */

define('IN_ODINXU_SYSTEM', true);

include_once "../config/config.ip.limit.pay.php";
include("../config/config.php");
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";

$begin_time   = $_REQUEST['begin_time'];       	//起始时间
$end_time   = $_REQUEST['end_time'];      		//结束时间
$server_id    = $_REQUEST['server_id'];        		//游戏分区
$sign      = SS($_REQUEST['sign']);	
						//签名
global $API_SECURITY_TICKET_PAY;

$serverID2 = strtoupper($server_id);
$token = md5($serverID2 . $begin_time  . $end_time . $API_SECURITY_TICKET_PAY);

if($token != $sign) {
	die("ticket error");
}

$payDetailSql="SELECT account_name,order_id,pay_money,pay_time,'{$server_id}' as server_id " .
		"FROM db_pay_log_p ";
		"WHERE pay_time > {$begin_time} AND pay_time<{$end_time} ";
$payDetailList = GFetchRowSet($payDetailSql);


$xml = getXml($payDetailList);
echo $xml;

/////////////////////////////////////////////////////
function getXml($array)
	{
	$xml.='<?xml version="1.0" encoding="utf-8"?>';
	$xml.="<data>";
	foreach($array as $key=>$val) {
		$xml.="<order_record>";
		$xml.="<qid>".$val['account_name']."</qid>";
		$xml.="<order_id>".$val['order_id']."</order_id>";
		$xml.="<order_amount >".$val['pay_money']."</order_amount >";
		$xml.="<finish_time>".$val['pay_time']."</finish_time>";
		$xml.="<server_id>".$val['server_id']."</server_id>";
		$xml.="</order_record>";
	}
	$xml.="</data>";
	return $xml;
}
