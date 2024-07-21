<?php


/*
 * Created on Oct 26, 2010
 *
 * 在线用户列表类
 */
class OnlineUserClass {
	
	public static function getOnlineList() {
		$now = time();
		$sql = "SELECT `role_id`, `role_name`, `account_name`, " .
				" ($now -`login_time`) as real_online_time, `faction_id`, `login_ip`, `line`" .
				" FROM `". T_USER_ONLINE ."` order by real_online_time desc ";
		$rs = GFetchRowSet($sql);
		return $rs;
	}
}
?>
