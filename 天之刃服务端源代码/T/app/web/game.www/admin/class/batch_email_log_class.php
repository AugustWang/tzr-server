<?php

class BatchEmailLog {
	 const TYPE_EMAIL_BY_ROLE_NAME_NO_GOODS = 1;  //无附件按角色名发送的邮件
	 const TYPE_EMAIL_BY_ROLE_NAME_WITH_GOODS = 2;  //有附件按角色名发送的邮件
	 const TYPE_EMAIL_BY_CONDITION_NO_GOODS = 3;  //无附件按条件发送的邮件
	 const TYPE_EMAIL_BY_CONDITION_WITH_GOODS = 4;  //有附件按条件发送的邮件
	 
	 private $table=T_LOG_BATCH_EMAIL;
	 
	 public function insert($type,$role_names='',$conditions='',$email_content,$good_info,$email_title)
	 {
	 	$type = intval($type);
	 	$role_names = SS($role_names);
	 	$conditions = SS($conditions);
	 	$email_content = SS($email_content);
	 	$good_info = SS($good_info);
	 	$create_time = time();
	 	$update_time = time();
	 	global $auth;
		$admin_name = $auth->username();
	 	$sql = " insert into {$this->table} (`type`,`role_names`,`conditions`,`create_time`,`update_time`,`email_content`,`good_info`,`admin_name`,`email_title`)
	 			values({$type},'{$role_names}','{$conditions}',{$create_time},{$update_time},'{$email_content}','{$good_info}','{$admin_name}','{$email_title}'); ";
	 	$result = GQuery($sql);
	 	return $result;
	 }
	 
	 public function getEmail()
	 {
	 	$type = intval($type);
	 	$sql = " select * from {$this->table} ORDER BY create_time desc ";
	 	return GFetchRowSet($sql);
	 }
}
