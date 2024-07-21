<?php
/*
 * Author: odinxu, MSN: odinxu@hotmail.com
 * 2008-9-6
 *
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;

$auth->assertModuleAccess(__FILE__);





/**
 * select * from t_log_login
 */


if ( !isset($_REQUEST['dateStart']))
	$dateStart = strftime ("%Y-%m-%d", time() );
else
	$dateStart  = trim(SS($_REQUEST['dateStart']));

if ( !isset($_REQUEST['dateEnd']))
	$dateEnd = strftime ("%Y-%m-%d", time());
else
	$dateEnd = trim(SS($_REQUEST['dateEnd']));

$dateStartStamp = strtotime($dateStart . ' 0:0:0') or $dateStartStamp = GetTime_Today0();
$dateEndStamp   = strtotime($dateEnd . ' 23:59:59') or $dateEndStamp = time();

$dateStartStr = strftime ("%Y-%m-%d", $dateStartStamp);
$dateEndStr   = strftime ("%Y-%m-%d", $dateEndStamp);


$data = getLoginCntOfEachSpan($dateStartStamp, $dateEndStamp);
	

$sum = 0;
foreach ($data as $item) {
	$sum += $item['value'];
}


$smarty->assign("search_keyword1", $dateStartStr);
$smarty->assign("search_keyword2", $dateEndStr);

$smarty->assign("keywordlist", $data);
$smarty->assign("sum", $sum);


$smarty->display("module/online/login_data_stat.tpl");
exit;
//////////////////////////////////////////////////////////////


function getLoginCntOfEachSpan($startTime,$endTime){
	$totalStatResult = array();
	$arr = array(1,2,3,4,5,6,8,10,15,20,25,30,50,80,100);
	for($idx = 0 ; $idx < count($arr) ;$idx++) {
		$min = $arr[$idx];
		if (isset($arr[$idx+1])) {
			$max = $arr[$idx+1];
			$sql = "select count(alias_tbl.role_id) as cnt from (
					select count(*) as num,role_id from t_log_login 
					where log_time > $startTime 
					and log_time < $endTime 
					group by role_id having count(*) >= $min
					and count(*) < $max
				) as alias_tbl";

		}else {
			$max = 'MAX';
			$sql = "select count(alias_tbl.role_id) as cnt from (
					select count(*) as num,role_id from t_log_login 
					where log_time > $startTime 
					and log_time < $endTime 
					group by role_id having count(*) >= $min
				) as alias_tbl";		
			}
		$num = GFetchRowOne($sql);
		$totalStatResult[] = array(
			'prompt'=>"[ $min, $max )",
			'value'=> intval($num['cnt'])
			);					
	}
	return $totalStatResult;
}




/*
function getLoginDataView($startTime, $endTime)
{
	$db = getDbConnWrite();

	$sqlFR     = 'SELECT FOUND_ROWS() as c';
	$sqlSELECT = "SELECT SQL_CALC_FOUND_ROWS DISTINCT userid, count( id ) AS c FROM `tlog_login` ";
	$sqlWHERE  = " WHERE log_time>={$startTime} AND log_time<={$endTime} ";
	$sqlGROUP  = " GROUP BY userid ";

	$arr = array(1,2,3,4,5,6,8,10,15,20,25,30,50,80,100);
	$result = array();
	for($i=0;$i<count($arr);$i++)
	{
		$sqlHAVING = "HAVING c >= " . $arr[$i];
		if (isset($arr[$i+1]))
			$sqlHAVING .= ' AND c < ' . $arr[$i+1];

		$sql = $sqlSELECT . $sqlWHERE . $sqlGROUP . $sqlHAVING;

		//echo $sql . CRLF;

		$db->sql_query($sql);

		$db->sql_query($sqlFR);
		$row = $db->sql_fetchrow();

		//new dBug($row['c']);

		$area = '[' . $arr[$i] . ' , ';
		if (isset($arr[$i+1]))
			$area .= $arr[$i+1] . ')';
		else
			$area .= 'MAX)';

		$result[] = array($area, intval($row['c']));

	}

	return $result;
}

*/