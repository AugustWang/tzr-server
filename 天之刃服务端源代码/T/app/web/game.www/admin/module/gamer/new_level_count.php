<?php
/*
 * Created on 2011-6-14
 * @author:yangyuqun@mingchao.com
 * @copyright:http://www.mingchao.com
 */



define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/include/dict.php';
include_once SYSDIR_ADMIN.'/include/db_functions.php';

$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN."/class/vip_class.php";

$start = SS($_GET['start']);

$end = SS($_GET['end']);
$level_start = SS($_GET['level_start']);
$level_end = SS($_GET['level_end']);

if(empty($start)) $start = date('Y-m-d');
if(empty($end)) $end = date('Y-m-d');

$start_time = strtotime($start);
//$start_time = "1307501188";
$end_time = strtotime($end) + 24*60*60-1;


$where = " `log_time`>$start_time and `log_time` < $end_time ";
if(!empty($level_start)&&!empty($level_end)) {$where .= " and level >=$level_start and level <=$level_end" ;}

$sql = "SELECT count(1) as cur_total, level FROM `t_log_role_level` WHERE $where group by level ";
$total_sql = "SELECT count(1) as total FROM `db_role_base_p`";
$total = GFetchRowSet($total_sql);
$total = $total[0]['total'];
$tmp = mysql_query(" SELECT level FROM `t_log_role_level` WHERE $where2 ");
$result = GFetchRowSet($sql);
foreach($result as $row){
	$percent = $row['cur_total']*100/$total;
	$percent = number_format($percent, 2);
 	$outstring .= '<tr>'
					.'<td>'.$row['level'].'</td>'
					.'<td>'.$row['cur_total'].'</td>'
					.'<td>'.$total.'</td>'
					.'<td><table width="'.$percent.'%" bgcolor="red"><tr><td></td></tr></table>'.$percent.'%</td>'
					.'</tr>';

}
$smarty->assign('start',$start);
$smarty->assign('output',$outstring);
$smarty->assign('end',$end);
$smarty->display('module/gamer/new_level_count.tpl');
