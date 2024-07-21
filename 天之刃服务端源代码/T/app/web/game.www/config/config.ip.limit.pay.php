<?php
/**
 * 限制访问的IP
 */

if (!defined('IN_ODINXU_SYSTEM')) {
	exit('hack attemp!');
}
$API_ALLOW_IP = array('182.119.204.175');

if (! empty ( $_SERVER ["HTTP_CLIENT_IP"] )) {
	$cip = $_SERVER ["HTTP_CLIENT_IP"];
} else {
	if (! empty ( $_SERVER ["HTTP_X_FORWARDED_FOR"] )) {
		$cip = $_SERVER ["HTTP_X_FORWARDED_FOR"];
	} else {
		if (! empty ( $_SERVER ["REMOTE_ADDR"] )) {
			$cip = $_SERVER ["REMOTE_ADDR"];
		} else {
			$cip = "";
		}
	}
} 
	

if(!in_array($cip, $API_ALLOW_IP)) {
	//exit("Not Allow!");
}
	