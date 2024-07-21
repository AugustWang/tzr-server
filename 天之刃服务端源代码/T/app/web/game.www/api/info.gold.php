<?php
/**
 * 天之刃后台发放元宝记录获取接口
 * @date 2011.1.21
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.ip.limit.info.php";
include_once "../config/config.php";
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";

//使用Slave数据库
useSlaveDB();

$date   = SS($_REQUEST['date']);
$key    = SS($_REQUEST['key']);
$tstamp = SS($_REQUEST['tstamp']);

//验证密钥是否正确
$_s = md5($tstamp . $API_SECURITY_TICKET_INFO);
if($_s !== $key) {
        die('405');
}

$sql = "
        SELECT 
        LOGS.admin_name,ROLES.account_name AS user_account,LOGS.user_name,
        LOGS.mtime,LOGS.number
        FROM `t_log_admin` AS LOGS 
        INNER JOIN `db_role_base_p` AS ROLES
        ON ROLES.role_id = LOGS.user_id
        WHERE LOGS.mtype = 2003
        AND DATE_FORMAT( FROM_UNIXTIME( LOGS.mtime ) , '%Y-%m-%d %H:%i:%s' ) 
        BETWEEN '{$date} 00:00:00'
        AND '{$date} 23:59:59'
        ";

$data = $db->fetchAll($sql);

echo serialize($data);