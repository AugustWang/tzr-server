<?php

/*
 * Author: wuzesen
 * 获取地图列表
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;


$rsData = array();

$sql = "SELECT  `map_id`, `map_name` FROM `t_map_list` ";
$rsData = GFetchRowSet($sql);

$smarty->assign('rsData', $rsData);
$smarty->display("module/system/list_map.tpl");
 


exit;
