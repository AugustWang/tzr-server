<?php
define('IN_ODINXU_SYSTEM', true);

/**
 * 用于显示任务列表
 */

$id = trim($_REQUEST['id']);
if( $id=='1' || $id=='2' || $id=='3' ){
	$file = '/data/miss_list_'. $id .'.txt';
}else{
	$id='1';
}
$factions = array('云州','沧州','幽州');
$file = '/data/miss_list_'. $id .'.txt';
$factionName = $factions[intval($id)-1];

if (file_exists($file)) {
    header("Content-Type:text/html;charset=utf-8"); 
    header('Expires: 0');
    ob_clean();
    flush();
    echo "<p><b>下面是【". $factionName ."】的25级前80个任务的列表</b></p>";
    echo "<p><u>任务ID, 名称, 经验, 绑定银子</u></p>";
    readfile($file);
    exit;
}
