<?php
/**
 * @author wangtao
 * 
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global_for_shell.php';
//$auth->assertModuleAccess(__FILE__);
/**
 * Done
 */
 
insert_new_record(tbl_convert());
$startExecTime = time();
echo basename(__FILE__) ."  start at :".date('Y-m-d H:i:s',$startExecTime);


function insert_new_record($allAry){
	$info = $allAry['plain'];
	$ary = $allAry['data'];

	
	$sqlHead = 	"INSERT INTO `t_stat_money_consume` (
	`id`, `mtime`, `year`, `month`, `day`, `user_level`, `save_bind_gold`, `consume_bind_gold`, 
	`new_bind_gold`, `save_unbind_gold`, `consume_unbind_gold`, `new_unbind_gold`, `save_bind_silver`, 
	`consume_bind_silver`, `new_bind_silver`, `save_unbind_silver`, `consume_unbind_silver`, `new_unbind_silver`,
	`cur_bind_gold_added`,
	`cur_unbind_gold_added`,
	`cur_bind_gold_consume`,
	`cur_unbind_gold_consume`,
	`cur_bind_silver_added`,
	`cur_unbind_silver_added`,
	`cur_bind_silver_consume`,
	`cur_unbind_silver_consume`
	) VALUES";
	
	$cnt = 0;
	$valueAry = array();
	foreach ($ary as $level => $item) {
		$cnt++;			
	
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
		
		//设置默认值
		foreach($labelAry as $label){
			if(!isset($item['cur'][$label])){
					$item['cur'][$label] = 0;
			}			
		}
		
		
		
		$valueAry[] = " 
			 (
			  NULL, $info[mtime], $info[year],
			  $info[month] , $info[day], $level,
			  {$item[bind_gold][save] }, 
			  {$item[bind_gold][consume]}, 
			  {$item[bind_gold][gain]},
			  {$item[unbind_gold][save]}, 
			  {$item[unbind_gold][consume]},
			  {$item[unbind_gold][gain]}, 
			  {$item[bind_silver][save]},
			  {$item[bind_silver][consume]},
			  {$item[bind_silver][gain]}, 
			  {$item[unbind_silver][save]},
			  {$item[unbind_silver][consume]},
			  {$item[unbind_silver][gain]},
			  {$item[cur][cur_bind_gold_added]},
			  {$item[cur][cur_unbind_gold_added]},
			  {$item[cur][cur_bind_gold_consume]},
			  {$item[cur][cur_unbind_gold_consume]},
			  {$item[cur][cur_bind_silver_added]},
			  {$item[cur][cur_unbind_silver_added]},
			  {$item[cur][cur_bind_silver_consume]},
			  {$item[cur][cur_unbind_silver_consume]}
			 )";
		if ($cnt % 30 == 29) {

			//excute insert every 10 values a time 
			$valueStr = implode(',',$valueAry);
			$sqlStr = $sqlHead.$valueStr;
			GQuery($sqlStr);
			$valueAry = array();
		}
	}
	//ensure last values are inserted 
	if (count($valueAry) > 0) {
		GQuery($sqlHead.implode(',',$valueAry));
	}
	
}

function tbl_convert(){
	$time = strtotime("today 00:00:00");
	$year = date('Y',$time);
	$month = date('m',$time);
	$day = date('d',$time);
	
	//levelOf 自动生成1，$max的级别的数据  [lv][12];circulation 的内容为8个数组,里面包含各个等级
	$levelOfEach  = getGoldStat($time);
	
	return array(
		'plain' =>array(
			'mtime' =>$time,
			'year'=>$year,
			'month'=>$month,
			'day'=>$day
		),
		'data'=>$levelOfEach,
	);
} 
 /*
function tbl_convert(){
	$time = time();
	$year = date('Y',$time);
	$month = date('m',$time);
	$day = date('d',$time);
	//级别
	$levels = range(1,5);
	$levels[] = -1; //统计序列,所有等级
	
	$levelOfEach = array();
	foreach ($levels as $lv) {
		$levelOfEach[$lv]['bind_gold'] = getBindGold($lv,$time);
		$levelOfEach[$lv]['unbind_gold'] = getUnBindGold($lv,$time);
		$levelOfEach[$lv]['bind_silver'] = getBindSilver($lv,$time);
		$levelOfEach[$lv]['unbind_silver'] = getUnbindSilver($lv,$time);
	}	
	
	return array(
		'plain'=>array(
			'mtime'=>$time,
			'year'=>$year,
			'month'=>$month,
			'day'=>$day
			),
		'data'=>$levelOfEach
			);
}

function getBindGold($lv,$time){
	return getCommon('t_log_use_gold','gold_bind',$lv,$time);
}

function getUnBindGold($lv,$time){
	return getCommon('t_log_use_gold','gold_unbind',$lv,$time);
}


function getBindSilver($lv,$time){
	return getCommon('t_log_use_silver','silver_bind',$lv,$time);
	
}

function getUnbindSilver($lv,$time){
	return getCommon('t_log_use_silver','silver_unbind',$lv,$time);
}
*/

//save consume new 
/*
function getCommon($tbl,$col,$lv,$time){
	//等级
	if ($lv != -1 ) {
		$level = " and attr.level  = $lv";
	}else {
		$level = '';
	}	
	
	$yesterday = $time - 24*60*60;
	$result = array();
	
	//save 剩余的
	$sql = "SELECT sum(tbl.`$col`) as save from `$tbl` tbl ,db_role_attr_p attr where tbl.mtime < $time and attr.role_id = tbl.user_id ".$level;
	$save = GFetchRowOne($sql);
	$result['save'] = $save['save'] or $result['save'] = 0;
	
	//consume 消耗的
	$sql = "SELECT sum(tbl.`$col`) as consume from `$tbl` tbl ,db_role_attr_p attr where attr.role_id = tbl.user_id and tbl.`$col` > 0 and tbl.mtime < $time and tbl.mtime > $yesterday ".$level;
	$consume = GFetchRowOne($sql);
	$result['consume'] = $consume['consume'] or $result['consume'] = 0;
	
	//new  获得的
	$sql = "SELECT sum(tbl.`$col`) as new from  `$tbl` tbl,db_role_attr_p attr where  attr.role_id = tbl.user_id and tbl.`$col`< 0 and tbl.mtime < $time and tbl.mtime > $yesterday ".$level;
	$new = GFetchRowOne($sql);
	$result['gain'] = $new['new'] or $result['gain'] = 0;
	
	return $result;
}




function getSuffixByYesterday($yesterday){
	$suffix = date('_Y_m',$yesterday);
	return  $suffix;
}

*/



function strip_null($value){
	return intval($value);
}

// gain<0 &&&&& consume>0

/**
 * 元宝统计,表中有level记录,需要(绑定,不绑定) * (剩余,消耗,获得)
 */
function getGoldStat($mtime){
	require_once('../class/log_silver_class.php');
	require_once('../class/log_gold_class.php');
	
	
	$yesterday = $mtime - 24*60*60;
	$result = array();
	$lastResult = array(); 
	

	$tableName = getSilverTableName($mtime);
	//1.所有不分等级的统计
	//gain bind gold 
	$sql = "select sum(gold_bind) as num from t_log_use_gold where mtime >= $yesterday and mtime <= $mtime and gold_bind <0 ";
	$gain = GFetchRowOne($sql);
	$lastResult[-1]['bind_gold']['gain'] = strip_null($gain['num']);  
	
	//consume bind gold
	$sql = "select sum(gold_bind) as num from t_log_use_gold where mtime >= $yesterday and mtime <= $mtime and gold_bind >0 ";
	$consume = GFetchRowOne($sql);
	$lastResult[-1]['bind_gold']['consume'] = strip_null($consume['num']);

	//save bind gold
	$sql = "select sum(gold_bind) as num from db_role_attr_p";
	$save = GFetchRowOne($sql);
	$lastResult[-1]['bind_gold']['save'] = strip_null($save['num']);
	
	//gain unbind gold 
	$sql = "select sum(gold_unbind) as num from t_log_use_gold where mtime >= $yesterday and mtime <= $mtime and gold_unbind <0 ";
	$gain = GFetchRowOne($sql);
	$lastResult[-1]['unbind_gold']['gain'] = strip_null($gain['num']);

	//consume unbind gold
	$sql = "select sum(gold_unbind) as num from t_log_use_gold where mtime >= $yesterday and mtime <= $mtime and gold_unbind >0 ";
	$consume = GFetchRowOne($sql);
	$lastResult[-1]['unbind_gold']['consume'] = strip_null($consume['num']);
	
	//save unbind gold
	$sql = "select sum(gold) as num from db_role_attr_p";
	$save = GFetchRowOne($sql);
	$lastResult[-1]['unbind_gold']['save'] = strip_null($save['num']);
	//	
	//-------------silver--------------------
	//(gain) bind silver
	$sql = "select sum(silver_bind) as num from $tableName where mtime >= $yesterday and mtime <= $mtime and silver_bind < 0";
	$gain = GFetchRowOne($sql);
	$lastResult[-1]['bind_silver']['gain'] = strip_null($gain['num']);
	
	$sql = "select sum(silver_bind) as num from $tableName where mtime >= $yesterday and mtime <= $mtime and silver_bind >0 ";
	$consume = GFetchRowOne($sql);
	$lastResult[-1]['bind_silver']['consume'] = strip_null($consume['num']);
	
	$sql = "select sum(silver_bind) as num from ".DB_MING2_GAME.".db_role_attr_p";
	$save = GFetchRowOne($sql);
	$lastResult[-1]['bind_silver']['save'] = strip_null($save['num']);
	
	//(gain) unbind silver
	$sql = "select sum(silver_unbind) as num from $tableName where mtime >= $yesterday and mtime <= $mtime and silver_unbind < 0";
	$gain = GFetchRowOne($sql);
	$lastResult[-1]['unbind_silver']['gain'] = strip_null($gain['num']);
	
	
	$sql = "select sum(silver_unbind) as num from $tableName where mtime >= $yesterday and mtime <= $mtime and silver_unbind > 0 ";
	$consume = GFetchRowOne($sql);
	$lastResult[-1]['unbind_silver']['consume'] = strip_null($consume['num']);
	
	$sql = "select sum(silver) as num from ".DB_MING2_GAME.".db_role_attr_p";
	$save = GFetchRowOne($sql);
	$lastResult[-1]['unbind_silver']['save'] = strip_null($save['num']);
	

	
	
	
	
	
	
	
	
	
	
	//===============分级别统计数据====================
	
	
	
	//消耗bind元宝
	$sql = "SELECT level ,SUM(gold_bind) AS num FROM t_log_use_gold WHERE gold_bind > 0 "
	."AND mtime >= $yesterday AND mtime <= $mtime GROUP BY level";
	
	//level,num
	$result['bind_consume'] = GFetchRowSet($sql);
	
	
	//消耗unbind元宝
	$sql = "SELECT level ,SUM(gold_unbind) AS num FROM t_log_use_gold WHERE gold_unbind > 0 "
	." AND mtime >= $yesterday AND mtime <= $mtime GROUP BY level";
	
	//level,num
	$result['unbind_consume'] = GFetchRowSet($sql);	
	
	
	//新增bind元宝
	$sql = "SELECT level ,SUM(gold_bind) AS num FROM t_log_use_gold WHERE gold_bind < 0 "
	."AND mtime >= $yesterday AND mtime <= $mtime GROUP BY level";
	
	//level,num
	$result['bind_gain'] = GFetchRowSet($sql);
	
	
	//新增unbind元宝
	$sql = "SELECT level ,SUM(gold_unbind) AS num FROM t_log_use_gold WHERE gold_unbind < 0 "
	." AND mtime >= $yesterday AND mtime <= $mtime GROUP BY level";	
	
	//level,num
	$result['unbind_gain'] = GFetchRowSet($sql);
	
	
	$sql = "SELECT level,SUM(gold) AS unbind,SUM(gold_bind) AS bind from db_role_attr_p attr,db_role_base_p base "
	."where attr.role_id = base.role_id group by level ";
	
	//level,g,gb
	$result['save'] = GFetchRowSet($sql);
	
	
	
	$silver = array();
	//算silver
	$sql = "SELECT level,sum(tbl.silver_bind) as num FROM ".$tableName." tbl ,db_role_attr_p attr where tbl.user_id = attr.role_id and mtime >= $yesterday and mtime <= $mtime and tbl.silver_bind > 0 group by level";
	$silver['bind_consume'] = GFetchRowSet($sql);
	
	//level,num
	$sql = "SELECT level,sum(tbl.silver_bind) as num FROM ".$tableName." tbl ,db_role_attr_p attr where tbl.user_id = attr.role_id and  mtime >= $yesterday and mtime <= $mtime and tbl.silver_bind < 0 group by level";
	$silver['bind_gain'] = GFetchRowSet($sql);
		
		
	$sql = "SELECT level,sum(tbl.silver_unbind) as num FROM ".$tableName." tbl ,db_role_attr_p attr where tbl.user_id = attr.role_id and mtime >= $yesterday and mtime <= $mtime and tbl.silver_unbind > 0 group by level";
	$silver['unbind_consume'] = GFetchRowSet($sql);	
			
			
	$sql = "SELECT level,sum(tbl.silver_unbind) as num FROM ".$tableName." tbl ,db_role_attr_p attr where tbl.user_id = attr.role_id and mtime >= $yesterday and mtime <= $mtime and tbl.silver_unbind < 0 group by level";
	$silver['unbind_gain'] = GFetchRowSet($sql);

	
	//save
	$sql = "SELECT level,sum(silver) as unbind,sum(silver_bind) as bind from db_role_attr_p attr,db_role_base_p base where attr.role_id = base.role_id group by level ";
	$silver['save'] = GFetchRowSet($sql);
	

	
	
	$sql = "SELECT max(level) as max_level from db_role_attr_p limit 1";
	$max_level = GFetchRowOne($sql);
	$max_level = $max_level['max_level'];
	
	
	
	

	
	//8种流通类型数据获取
	$cur_gold = LogGoldClass::getCirculationGoldTypes();
	$cur_silver = LogSilverClass::getCirculationSilverTypes();
	$cur_gold = ' and mtype in ('.implode(',', $cur_gold).')';
	$cur_silver = ' and mtype in ('.implode(',', $cur_silver).')';
	$silverTbl = getSilverTableName($mtime);
	$cirAry = array(
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
	
	$circulationAry = array();
	foreach($cirAry as $item){
		$sqlTemplate = "select attr.level,sum( tbl.{$item[0]} ) as num from {$item[1]} tbl,db_role_attr_p attr 
				where tbl.user_id = attr.role_id " .
				"and mtime >= $yesterday and mtime <= $mtime and {$item[2]} {$item[3]}  group by level";
		$circulationAry[$item[4]] = GFetchRowSet($sqlTemplate);
	}
	
	
	//分级别 0~max
	for ($lv = 0;$lv < $max_level+1;$lv++){
		$lastResult[$lv]['bind_gold'] = array(
			'save' => getSaveData($result['save'], $lv, true),
			'consume'=>getLevelOfData($result['bind_consume'], $lv),
			'gain'=>getLevelOfData($result['bind_gain'],$lv),
		);
		
		$lastResult[$lv]['unbind_gold'] = array(
			'save'=> getSaveData($result['save'], $lv, false),
			'consume'=> getLevelOfData($result['unbind_consume'], $lv),
			'gain'=> getLevelOfData($result['unbind_gain'],$lv )
		);

		$lastResult[$lv]['bind_silver'] = array(
			'save'=> getSaveData($silver['save'],$lv,true),
			'consume'=>getLevelOfData($silver['bind_consume'], $lv),
			'gain'=>getLevelOfData($silver['bind_gain'],$lv)
		);
		$lastResult[$lv]['unbind_silver'] = array(
			'save'=>getSaveData($silver['save'],$lv,false),
			'consume'=>getLevelOfData($silver['unbind_consume'],$lv),
			'gain'=>getLevelOfData($silver['unbind_gain'],$lv)
		); 
		
		//8种流通类型
		$lastResult[$lv]['cur'] = array(
			'cur_bind_gold_added'=>getCirLv($lv,'cur_bind_gold_added',$circulationAry),
			'cur_unbind_gold_added'=>getCirLv($lv,'cur_unbind_gold_added',$circulationAry),
			'cur_bind_gold_consume'=>getCirLv($lv,'cur_bind_gold_consume',$circulationAry),
			'cur_unbind_gold_consume'=>getCirLv($lv,'cur_unbind_gold_consume',$circulationAry),
			'cur_bind_silver_added'=>getCirLv($lv,'cur_bind_silver_added',$circulationAry),
			'cur_unbind_silver_added'=>getCirLv($lv,'cur_unbind_silver_added',$circulationAry),
			'cur_bind_silver_consume'=>getCirLv($lv,'cur_bind_silver_consume',$circulationAry),
			'cur_unbind_silver_consume'=>getCirLv($lv,'cur_unbind_silver_consume',$circulationAry)
		);
	}
		
	//8种流通类型的每日汇总
	$lastResult[-1]['cur'] = array(
			'cur_bind_gold_added'=>getCirLv(-1,'cur_bind_gold_added',$circulationAry),
			'cur_unbind_gold_added'=>getCirLv(-1,'cur_unbind_gold_added',$circulationAry),
			'cur_bind_gold_consume'=>getCirLv(-1,'cur_bind_gold_consume',$circulationAry),
			'cur_unbind_gold_consume'=>getCirLv(-1,'cur_unbind_gold_consume',$circulationAry),
			'cur_bind_silver_added'=>getCirLv(-1,'cur_bind_silver_added',$circulationAry),
			'cur_unbind_silver_added'=>getCirLv(-1,'cur_unbind_silver_added',$circulationAry),
			'cur_bind_silver_consume'=>getCirLv(-1,'cur_bind_silver_consume',$circulationAry),
			'cur_unbind_silver_consume'=>getCirLv(-1,'cur_unbind_silver_consume',$circulationAry)
	);
	
	
	return  $lastResult;
}


/**
 * 分等级整理
 * Enter description here ...
 * @param $lv
 * @param $label
 * @param $ary
 */
function getCirLv($lv,$label,$ary){
	if($lv == -1){
		$acc = 0;
		foreach($ary[$label] as $it){
			$acc += $it['num'];
		}
		//今日总共的
		return $acc;			
	}
	
	foreach($ary[$label] as  $item){
		if ($item['level'] == $lv){
			return $item['num'];
		}		
	}
	return 0;	
}






//t_log_use_silver_2010_12
function  getSilverTableName($mtime){
	//选择昨天所在的表
	$suffix = date("_Y_m",$mtime-24*60*60);
	return 'tzr_logs.t_log_use_silver'.$suffix;
}




// level bind unbind
function getSaveData($ary, $lv, $bind){
	foreach($ary as $item){
		if(intval($item['level']) == $lv){
			if ($bind){
				return intval($item['bind']);
			}else {
				return intval($item['unbind']);
			}
		}
	}
	return 0;
}



// level num 
function getLevelOfData($ary,$lv){
	foreach ($ary as $item){
		if (intval($item['level']) == $lv){
			return  intval($item['num']);
		}
	}
	return 0;
}

?>