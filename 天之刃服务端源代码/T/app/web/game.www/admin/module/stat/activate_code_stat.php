<?php
/*
 * Author: 许昭鹏, MSN: xzp@live.com
 * 2009-06-23
 * 
 * 激活码使用情况统计
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;

$auth->assertModuleAccess(__FILE__);


$all = getActiveNumStat();
$all = array_reverse($all);

$smarty->assign("stat", $all['stat']);
$smarty->assign("all", $all);

$smarty->display("module/stat/activate_code_stat.tpl");

die;


function getActiveNumStat()
{
    $result = array();
    $sql = "SELECT COUNT(*) AS c FROM `". T_ACTIVATE_CODE. "` ";
    $row = GFetchRowOne($sql);
    if ((!isset($row['c'])) || ($row['c']<=0) )
    {
        $result['count'] = 0;
        return $result;
    }
    $result['count'] = $row['c'];
    
    $sql = "SELECT COUNT(*) AS c FROM `". T_ACTIVATE_CODE. "` WHERE `role_id`>0";
    $row = GFetchRowOne($sql);
    $result['used'] = $row['c'];

    $result['not_used'] = $result['count'] - $result['used'];
    
    
    $sql = "SELECT COUNT(*) AS c FROM `". T_ACTIVATE_CODE. "` WHERE `role_id`>0";
    
    $sqlSelect = "SELECT FROM_UNIXTIME( `mtime` , '%m' ) AS `month` , 
                    FROM_UNIXTIME( `mtime` , '%d' ) AS `day` , 
                    FROM_UNIXTIME( `mtime` , '%H' ) AS `hour` , 
                    count( `mtime` ) AS `c`  FROM `". T_ACTIVATE_CODE. "`
                    WHERE `role_id`>0
                    GROUP BY `month` , `day` , `hour`
                    WITH ROLLUP";
    $rs = GFetchRowSet($sqlSelect);
    
    $result['stat'] = $rs;
    
    return $result;
}

