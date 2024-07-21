<?
define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
if(!defined('SEC_PER_DAY')){
	define('SEC_PER_DAY',60*60*24);
}

////////////////////////////////////////////////
//运行脚本示例如下
//php ./fix_money_stat.php 2011-02-01 2011-03-10 



//1.提供添加两个col的脚本
//2.提供两个新col的数值的写入程序
//3.添加以往的此两个col的数值
//4.页面显示
//添加的8个fields分别为 

//cur_bind_gold_added
//cur_unbind_gold_added
//cur_bind_gold_consume
//cur_unbind_gold_consume

//cur_bind_silver_added
//cur_unbind_silver_added
//cur_bind_silver_consume
//cur_unbind_silver_consume


if (strlen($argv[1]) > 1 && strlen($argv[2]) > 1){
	updateColumnValue($argv[1],$argv[2]);
	echo "success fix data between $argv[1] and $argv[2]";
}
	


/**
 * 包含from当天晚上要跑的和to当天晚上要跑的数据
 */
function updateColumnValue($fromDate,$toDate){
	$from = strtotime($fromDate);
	$to = strtotime($toDate);
	if($from  < 100000000 || $to < 100000000 || $from >= $to){
		die("invalid date input");	
	}
	for($itr = $from;$itr < $to+1;$itr += SEC_PER_DAY){
		//get itr of the $itr day
		$dataOfEachday = getAssoDataOfTime($itr);
		$year = date('Y',$itr);
		$month = date('m',$itr);
		$day  = date('d',$itr);
		
		foreach($dataOfEachday as $key=>$eachKind){
			foreach($eachKind as $eachLevel){
				$level = $eachLevel['level'];
				$num = $eachLevel['num'];				
				//key represent 'cur_bind_gold_added'//etc  of the 8 added columns
				$where = "where year = '$year'  and month= '$month' and day = '$day' and user_level= '$level'";
				$sql = "update t_stat_money_consume set  $key = $num ".$where ;
				GQuery($sql);  														
			}
		}
			
	}
}




//绑定/不绑定,元宝/银两,新增/消耗,总共八种2**3
function getAssoDataOfTime($stamp){
	require_once('../class/log_gold_class.php');
	require_once('../class/log_silver_class.php');
	$yes_time = $stamp - SEC_PER_DAY;
	$cur_gold = LogGoldClass::getCirculationGoldTypes();
	$cur_silver = LogSilverClass::getCirculationSilverTypes();
	
	$cur_gold = ' and mtype in ('.implode(',', $cur_gold).')';
	$cur_silver = ' and mtype in ('.implode(',', $cur_silver).')';

	$silverTbl = getSilverTableName($stamp);
		
	$ary = array(
		//colName,tableName,colCompare,mTypeRange,tag
		array('gold_bind','t_log_use_gold','tbl.gold_bind < 0',$cur_gold,'cur_bind_gold_added'),
		array('gold_unbind','t_log_use_gold','tbl.gold_unbind < 0',$cur_gold,'cur_unbind_gold_added'),
		array('gold_bind','t_log_use_gold','tbl.gold_bind > 0',$cur_gold,'cur_bind_gold_consume'),
		array('gold_unbind','t_log_use_gold','tbl.gold_unbind > 0',$cur_gold,'cur_unbind_gold_consume'),
	
		array('silver_bind',$silverTbl,'tbl.silver_bind < 0',$cur_silver,'cur_bind_silver_added'),
		array('silver_unbind',$silverTbl,'tbl.silver_unbind < 0',$cur_silver,'cur_unbind_silver_added'),
		array('silver_bind',$silverTbl,'tbl.silver_bind > 0',$cur_silver,'cur_bind_silver_consume'),
		array('silver_unbind',$silverTbl,'tbl.silver_unbind > 0',$cur_silver,'cur_unbind_silver_consume'),
		
	);
	$result = array();
	foreach($ary as $item){
		$sqlTemplate = "select attr.level,sum( tbl.{$item[0]} ) as num from {$item[1]} tbl,db_role_attr_p attr 
				where tbl.user_id = attr.role_id " .
				"and mtime >= $yes_time and mtime <= $stamp and {$item[2]} {$item[3]}  group by level";
		
		$temp = GFetchRowSet($sqlTemplate);
		//每日所有级别汇总
		$add = 0;
		foreach($temp as $it){
			$add +=  $it['num'];			
		}
		$temp[] = array('level'=>-1,'num'=>$add);

		$result[$item[4]] = $temp;		
	}
	
	//result 结构
	//cur_bind_gold_added  -->  (level,num)*level
	//...
	//
	return $result;
}


//返回当日零时的timestamp
function getOClockOfDay($str){
	return strtotime(date('Y-m-d',strtotime($str)));
}

//分月表
function  getSilverTableName($mtime){
	//选择昨天所在的表
	$suffix = date("_Y_m",$mtime-24*60*60);
	return 'tzr_logs.t_log_use_silver'.$suffix;
}
