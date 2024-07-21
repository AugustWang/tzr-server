<?php
/**
 * 天之刃当前在线人数
 * @date 2010.11.26
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.ip.limit.info.php";
include_once "../config/config.php";
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";

if ($_GET['data']){
        echo getMostOnline();
}else{
        echo getOnline();
}
#获取当天最高在线
function getMostOnline(){
        $theday = $_GET['data'];
        $str = explode("-",$theday);
        $sql = "SELECT online FROM t_log_online WHERE year='{$str[0]}' AND month='{$str[1]}' AND day='{$str[2]}' ORDER BY online DESC limit 1";
        $rs = GFetchRowSet($sql);
        echo $rs[0]['online'];
}


