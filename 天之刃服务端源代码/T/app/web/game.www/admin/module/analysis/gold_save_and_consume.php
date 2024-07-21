<?php
/*
* Author: 许昭鹏, MSN: xzp@live.com
* 2009-11-27
*
*/
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

//消除 IDE警告
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

$level_type = trim(SS($_REQUEST['level_type']));
if (empty($level_type))
	$level_type = 'not';

$date1 = trim(SS($_REQUEST['date1']));
$date2 = trim(SS($_REQUEST['date2']));



if (! isset($_REQUEST['date1']))
{
	$start_day = GetTime_Today0() - 7*86400;
	$dateStart = strftime("%Y-%m-%d",$start_day);
	//$date1 = strftime("%Y-%m", time()) . '-01';
}	
else
	$date1 = trim(SS($_REQUEST['date1']));

if (! isset($_REQUEST['date2']))
	$date2 = strftime("%Y-%m-%d", time());
else
	$date2 = trim(SS($_REQUEST['date2']));

$date1Stamp = strtotime($date1 . ' 0:0:0');
$date2Stamp = strtotime($date2 . ' 23:59:59');
$date1Stamp = $date1Stamp ? $date1Stamp : strtotime(date('Y-m-d',strtotime('-7day')));
$date2Stamp = $date2Stamp ? $date2Stamp : time();

//默认应该显示多少天的数据(从哪一天开始，一直到今天)
if (! isset($_REQUEST['date1']))
{
	while ($date2Stamp + 1 - $date1Stamp < 86400 * 8)
		$date1Stamp -= 86400;

	$server_open_stamp = strtotime(SERVER_ONLINE_DATE . ' 0:0:0');
	if ($server_open_stamp > $date1Stamp)
		$date1Stamp = $server_open_stamp;

	$date1 = GetDayString($date1Stamp);
}


$level = $_POST['level'] or $level = -1 ;
list($datalist,$max)= getLevelDataToRender($date1Stamp, $date2Stamp,$level);
$typelistopgion  = getTypeListOption();


$smarty->assign('level',$level);
$smarty->assign("typeoption", $typelistopgion);
$smarty->assign("date1", $date1);
$smarty->assign("date2", $date2);
$smarty->assign('levels',renderDropDownBox());
$smarty->assign('level',$level);
$smarty->assign("level_type", $level_type);

$smarty->assign("level_type_name", $datalist['name'][$level_type]);
//$smarty->assign("level_summary", $datalist['summary'][$level_type]);

$smarty->assign("datalist", $datalist);
$smarty->assign('max',$max);
$smarty->display("module/analysis/gold_save_and_consume.tpl");
exit();

function getTypeListOption()
{
	return array(
			"not"  => '不显示分等级明细',
			"consume_unbind_gold" => '元宝消耗量',
			"save_unbind_gold"  => '元宝留存量',
			"new_unbind_gold" => '元宝新增量',
		);
}
//week 
function getLevelDataToRender($start,$end,$lv=-1){
	$sql = "SELECT * from t_stat_money_consume where mtime >= $start and mtime <= $end and user_level = $lv order by mtime";
	$result = GFetchRowSet($sql);
	
	$max = array();	
	foreach ($result as &$item) {
		$item['save_bind_gold'] = abs($item['save_bind_gold']);
		$item['save_unbind_gold'] = abs($item['save_unbind_gold']);
		$item['save_bind_silver'] = abs($item['save_bind_silver']);
		$item['save_unbind_silver'] = abs($item['save_unbind_silver']);
		$item['consume_unbind_gold'] = abs($item['consume_unbind_gold']);
		$item['consume_bind_gold'] = abs($item['consume_bind_gold']);
		$item['consume_bind_silver'] = abs($item['consume_bind_silver']);
		$item['consume_unbind_silver'] = abs($item['consume_unbind_silver']);
		$item['new_bind_gold'] = abs($item['new_bind_gold']);
		$item['new_unbind_gold'] = abs($item['new_unbind_gold']);
		$item['new_bind_silver'] = abs($item['new_bind_silver']);
		$item['new_unbind_silver'] = abs($item['new_unbind_silver']);

		$labelAry = array(
		 	"cur_bind_gold_added",
			"cur_unbind_gold_added",
			"cur_bind_gold_consume",
			"cur_unbind_gold_consume",
			"cur_bind_silver_added",
			"cur_unbind_silver_added",
			"cur_bind_silver_consume",
			"cur_unbind_silver_consume"
		 );
		 foreach ($labelAry as $label){		 	
		 	$item[$label] = abs($item[$label]);		 	
		 }
		 
		 
	 	$item['cur_silver_added'] = $item['cur_bind_silver_added'] + $item['cur_unbind_silver_added'];
		$item['cur_gold_added'] =  $item['cur_bind_gold_added'] + $item['cur_unbind_gold_added'];
		$item['cur_silver_consume'] = $item['cur_bind_silver_consume'] + $item['cur_unbind_silver_consume'];
		$item['cur_gold_consume'] = $item['cur_bind_gold_consume'] + $item['cur_unbind_gold_consume'];
	
		
		$item['new_silver'] = abs($item['new_unbind_silver'])+ abs($item['new_bind_silver']);
		$item['consume_silver'] = abs($item['consume_unbind_silver'])+ abs($item['consume_bind_silver']);
		$item['save_silver'] = abs($item['save_bind_silver'])+ abs($item['save_unbind_silver']);
		
		
		$item['new_gold'] = abs($item['new_unbind_gold'])+ abs($item['new_bind_gold']);
		$item['consume_gold'] = abs($item['consume_unbind_gold'])+ abs($item['consume_bind_gold']);
		$item['save_gold'] = abs($item['save_bind_gold'])+ abs($item['save_unbind_gold']);
		
		
		
		
		//below generate max array;
		$indexArys = array('save_bind_gold','save_unbind_gold','save_bind_silver','save_unbind_silver','consume_unbind_gold',
		'consume_bind_gold','consume_bind_silver','consume_unbind_silver','new_bind_gold','new_unbind_gold','new_bind_silver',
		'new_unbind_silver','new_silver','consume_silver','save_silver','new_gold','consume_gold','save_gold',
			 "cur_bind_gold_added",
			"cur_unbind_gold_added",
			"cur_bind_gold_consume",
			"cur_unbind_gold_consume",
			"cur_bind_silver_added",
			"cur_unbind_silver_added",
			"cur_bind_silver_consume",
			"cur_unbind_silver_consume",
			'cur_gold_added',
			'cur_gold_consume'								
		);
		
		foreach ($indexArys as $idx){
			if (!isset($max[$idx])){
				$max[$idx] = 0;
			}
			$max[$idx] = max($item[$idx],$max[$idx]);
		}
		
		$item['mtime'] = $item['mtime'] - 60*60*24;
		$item['month'] = date('m',$item['mtime']);
		$item['day'] = date('d',$item['mtime']);
		$item['week'] = date('w',$item['mtime']);
	}
	
	
	//因为smarty页面不好用于计算,所以这里直接除以120px,便于输出长度
	foreach ($max as &$item){
		$item = $item/120;
	}
	return array($result,$max);
}


function renderDropDownBox() {
	$ary = array();
	$ary[-1]  = "全部级";
	for ($start=1; $start < 161; $start++) { 
		$ary[$start]  = $start.'级' ;		
	}
	return $ary;
}





