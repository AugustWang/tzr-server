<?php
/**
 * 客户端每隔一段时间自动ping，防止session过期
 */
session_start();
if (!$_SESSION['account_name'] || $_SESSION['timestamp'] < 0) {
	
	exit('timeout');
}
// 需要手工保存sesion一次，因为我们的服务器sesion是存放在memcache中的
// 默认两个小时失效，如果没有写行为，则session两个小时候在memcache中失效
$_SESSION['last_op_time'] = time();
echo 'ok';