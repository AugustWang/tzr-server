<?php
/*
 * created by yangyuqun@mingchao.com
 */
include_once '../../class/api/broadcast_copy_api.class.php';
$dataPost = $_POST;
if(!empty($dataPost)){
	$result = BroadcastCopyApi::getMsg($dataPost);	
	echo $result;
}
