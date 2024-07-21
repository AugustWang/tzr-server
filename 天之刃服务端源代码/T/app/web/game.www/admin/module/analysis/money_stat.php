<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$arrGoldLevel=array(
	'0—0',
	'1—10',
	'11—100',
	'101—500',
	'501—1000',
	'1001—5000',
	'5001—∞',
);

$arrSilverLevel=array(
	'[0—0]'=>array(0,0),
	'[1文—100两)'=>array(1,100*100),
	'[1锭—10锭)'=>array(100*100,10*100*100),
	'[10锭—100锭)'=>array(10*100*100,100*100*100),
	'[100锭—500锭)'=>array(100*100*100,500*100*100),
	'[500锭—∞)'=>array(500*100*100,'∞'),
);
$arrSumType = array('全部','绑定','不绑定');
$sumType = empty($_POST) ? 2 : intval($_POST['sumType']) ; //默认统计不绑定的 

$tblRoleAttr = T_DB_ROLE_ATTR_P;

$arrGold=array();
$allGold=0;
$allGoldRole = 0;
foreach ($arrGoldLevel as &$goldLevel) {
	$level=explode('—',$goldLevel);
	
	if (0==$sumType) {
		$strSum = ' SUM(`gold`)+SUM(`gold_bind`) ';
		$sqlGoldField = ' `gold`+`gold_bind` ';
	}elseif (1==$sumType){
		$strSum = ' SUM(`gold_bind`) ';
		$sqlGoldField = ' `gold_bind` ';
	}else {
		$strSum = ' SUM(`gold`) ';
		$sqlGoldField = ' `gold` ';
	}
	if (0==$level[0] && 0==$level[1]) {
		$sqlGoldWhere = " {$sqlGoldField} =0 ";
	}elseif('∞'==$level[1]) {
		$sqlGoldWhere = " {$sqlGoldField} >={$level[0]}  ";
	}else {
		$sqlGoldWhere = " {$sqlGoldField} >={$level[0]} AND {$sqlGoldField} <= {$level[1]} ";
	}
	$sqlGold = " SELECT COUNT(`role_id`) AS `total_role`, {$strSum} AS `total_gold` FROM {$tblRoleAttr} WHERE {$sqlGoldWhere} ";
	$rsGold = GFetchRowOne($sqlGold);
	$rsGold['gold_level'] = $goldLevel;
	$rsGold['total_gold'] = intval($rsGold['total_gold']);
	$rsGold['total_role'] = intval($rsGold['total_role']);
	$allGold += $rsGold['total_gold'];
	$allGoldRole += $rsGold['total_role'];
	array_push($arrGold,$rsGold);
}

$arrSilver=array();
$allSilver=0;
$allSilverRole = 0;
foreach ($arrSilverLevel as $silverLevel=>&$level) {
	$strSum = "";
	if (0==$sumType) {
		$strSum = ' SUM(`silver`)+SUM(`silver_bind`) ';
		$sqlSilverField = ' `silver`+`silver_bind` ';
	}elseif (1==$sumType){
		$strSum = ' SUM(`silver_bind`) ';
		$sqlSilverField = ' `silver_bind` ';
	}else {
		$strSum = ' SUM(`silver`) ';
		$sqlSilverField = ' `silver` ';
	}
	
	if (0==$level[0] && 0==$level[1]) {
		$sqlSilverWhere = " {$sqlSilverField}=0  ";
	}elseif('∞'==$level[1]) {
		$sqlSilverWhere = " {$sqlSilverField} >={$level[0]}  ";
	}else {
		$sqlSilverWhere = " {$sqlSilverField}  >={$level[0]} AND {$sqlSilverField} < {$level[1]} ";
	}
	$sqlSilver = " SELECT COUNT(`role_id`) AS `total_role`, {$strSum} AS `total_silver` FROM {$tblRoleAttr} WHERE {$sqlSilverWhere} ";
	$rsSilver = GFetchRowOne($sqlSilver);
	$rsSilver['silver_level'] = $silverLevel;
	$rsSilver['total_silver_str'] = silverUnitConvert(intval($rsSilver['total_silver']));
	$rsSilver['total_silver'] = intval($rsSilver['total_silver']);
	$rsSilver['total_silver_str'] = silverUnitConvert($rsSilver['total_silver']);
	$rsSilver['total_role'] = intval($rsSilver['total_role']);
	$allSilver += $rsSilver['total_silver'];
	$allSilverRole += $rsSilver['total_role'];
	array_push($arrSilver,$rsSilver);
	$arrSql[] = $sqlSilver;
}

foreach ($arrGold as &$row) {
	$row['avg'] = $row['total_role'] > 0 ? round($row['total_gold']/$row['total_role'],1) : 0;
	$row['gold_rate'] = $allGoldRole > 0 ? round($row['total_gold']*100/$allGold,2) : 0;
	$row['role_rate'] = $allGoldRole > 0 ? round($row['total_role']*100/$allGoldRole,2) : 0;
}
foreach ($arrSilver as &$row) {
	$row['avg'] = $row['total_role'] > 0 ? round($row['total_silver']/$row['total_role'],0) : 0;
	$row['avg_str'] = silverUnitConvert($row['avg']);
	$row['silver_rate'] = $allSilverRole > 0 ? round($row['total_silver']*100/$allSilver,2) : 0;
	$row['role_rate'] = $allSilverRole > 0 ? round($row['total_role']*100/$allSilverRole,2) : 0;
}
$allGoldAvg = $allGoldRole > 0 ? round($allGold/$allGoldRole,1) : 0 ;
$allSilverAvg = $allSilverRole > 0 ?round($allSilver/$allSilverRole,0) : 0 ;
$allSilverAvgStr = silverUnitConvert($allSilverAvg);
$allSilverStr = silverUnitConvert($allSilver);

$data = array(
	'arrSumType'=>$arrSumType,
	'sumType'=>$sumType,
	
	'arrGold' =>$arrGold,
	'allGold'=>$allGold,
	'allGoldRole' => $allGoldRole,
	'allGoldAvg'=>$allGoldAvg,
	
	'arrSilver' =>$arrSilver,
	'allSilver'=>$allSilver,
	'allSilverStr'=>$allSilverStr,
	'allSilverRole'=>$allSilverRole,
	'allSilverAvg' => $allSilverAvg,
	'allSilverAvgStr' => $allSilverAvgStr,
);
$smarty->assign($data);
$smarty->display("module/analysis/money_stat.tpl");
