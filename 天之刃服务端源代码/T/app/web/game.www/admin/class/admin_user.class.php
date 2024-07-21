<?php
if(!defined('MING2_WEB_ADMIN_FLAG')) {
	exit('hack attemp');
}
class AdminUserClass
{
	/**
	 * 
	 * 枚举所有的管理员
	 * @return array [uid=>['uid','username','comment','groupid','groupname','last_login_time'],...]
	 */
	public static function enum()
	{
		global $db;
		$sql = "SELECT `uid`,`username`,`comment`,`groupid`,`last_login_time` FROM `".T_ADMIN_USER."`";
		$rows = $db->fetchAll($sql);
		$groups = AdminGroupClass::enum();
		$enum = array();
		foreach($rows as $row) {
			if($gname = $groups[intval($row['groupid'])]['name'])
				$row['groupname'] = $gname;
			$enum[intval($row['uid'])] = $row;
		}
		return $enum;
	}
	
	/**
	 * 
	 * 新管理员
	 * @param string $name
	 * @param string $comment
	 */
	public static function create($name, $password, $comment)
	{
		global $db;
		$data = array();
		$data['username'] = ($name);
		$data['passwd'] = strtolower(md5($password));
		$data['comment'] = ($comment);
		$sql = makeInsertSqlFromArray($data, T_ADMIN_USER);
		$db->query($sql);
		$uid = fetchLatestIDWithData($data, T_ADMIN_USER, 'uid');
		return $uid;
	}
	
	/**
	 * 
	 * 改变组
	 * @param int $userid
	 * @param int $groupid
	 */
	public static function changeGroup($userid, $groupid)
	{
		global $db;
		$data = array();
		$data['uid'] = intval($userid);
		$data['groupid'] = intval($groupid);
		$sql = makeUpdateSqlFromArray($data, T_ADMIN_USER, 'uid');
		return $db->query($sql);
	}
	
	/**
	 * 
	 * 修改
	 * @param string $password
	 * @param int $groupid
	 * @param string $comment
	 */
	public static function update($userid, $password, $groupid, $comment)
	{
		global $db;
		$data = array();
		$data['uid'] = intval($userid);
		if($password !== null) $data['passwd'] = strtolower($password);
		if($groupid !== null) $data['groupid'] = intval($groupid);
		if($comment !== null) $data['comment'] = ($comment);
		if(count($data) <= 1)
			return true;
		$sql = makeUpdateSqlFromArray($data, T_ADMIN_USER, 'uid');
		return $db->query($sql);
	}
}