<?php 
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';


include_once SYSDIR_ADMIN.'/class/item_log_class.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
include_once SYSDIR_ADMIN.'/dict/gold_dic.php';
include_once SYSDIR_ADMIN.'/dict/item_list_dict.php';
global $GOLD_OPTION_LIST;
$cost_list = $GOLD_OPTION_LIST;
$option = $ITEM_LIST;

$itemclass = array(
	1=>'装备',
	2=>'宠物',
	3=>'VIP',
	4=>'时装座骑',
	5=>'经验',
	0=>'其他',
	);
$itemsonclass = array(
	1=>array(
		//0=>'0',
		1=>'一级灵石',
		2=>'二级灵石',
		3=>'五级灵石',
		4=>'强化石',
		5=>'打造材料',
		6=>'颜色材料',
		7=>'品质石',
		8=>'开孔',
		9=>'镶嵌',
		10=>'其他',	
		11=>'装备符',
	),
	2=>array(
		//0=>'0',
		1=>'宠物技能',
		2=>'宠物召唤符',
		3=>'宠物延寿',
		4=>'宠物洗灵',
		5=>'宠物提悟',
		6=>'宠物其他',
	),
	3=>array(
		//0=>'0',
		1=>'VIP',
	),
	4=>array(
		//0=>'0',
		1=>'时装',
		2=>'座骑',
	),
	5=>array(
		//0=>'0',
		1=>'经验',
	),
	0=>array(
		//0=>'0',
		1=>'常用道具',
		2=>'玫瑰花',
		3=>'药品',
		4=>'变身符',

	),
	
);	

	
$class = SS($_REQUEST['class']);

$date_start  = trim(SS($_REQUEST['dateStart']));
if (empty($date_start)){
	$date_start = date("Y-m-d",time() - 7*24*60*60);
	$dateStart = strftime("%Y-%m-%d",$date_start);
}
else {
    $dateStart = strftime("%Y-%m-%d",$date_start);
}

$date_end = trim(SS($_REQUEST['dateEnd']));
if(empty($date_end)){
	$date_end = date("Y-m-d",time());
	$dateEnd = strftime ("%Y-%m-%d", $date_end);
}else{
	$dateEnd = strftime("%Y-%m-%d",$date_end);
}

function get_cost_list($value){
	global $GOLD_OPTION_LIST;
	$cost_list = $GOLD_OPTION_LIST;
	$result = array ();
	foreach ($cost_list as $key=>$item){
		if($value==$item['big_type']){
			$result[] = $key; 
		}
	}
	return $result;
}

	$display = get_cost_list("$class");
if(!empty($datestart)&&!empty($dateend)){
$where = "where 1 ";
$where .= "and mtime between $dateStart and $dateEnd ";
} 
//按操作开始
$sql = "SELECT itemid,mtype,count(itemid) as count,(sum(gold_bind)+sum(gold_unbind)) as total,sum(gold_bind) as bind,sum(gold_unbind) as unbind,count(id) as times FROM `t_log_use_gold` ".$where." group by mtype,itemid";
$result = GFetchRowSet($sql);


$result_arr = array();
foreach ($result as $key=>$val){
	$result_arr[$val['mtype']] = $val;
}
//echo '<pre>';print_r($result_arr);echo '</pre>';
foreach ($result_arr as $key=>$value){
	if(in_array($key,$display)){
		$type = $value['mtype'];
		$big_type= $cost_list[$key]['big_type'];
		$small_type = $cost_list[$key]['small_type'];
		$value['big_type'] = $big_type;
		$value['small_type'] = $small_type;
		$value['class'] = $itemsonclass[$big_type][$small_type];
		$value['opt_name']= $cost_list[$type]['item_name'];
		$out_arr[] = $value; 
	}
}
//echo '<pre>';print_r($out_arr);echo '</pre>';
//按操作结束

//按分类开始
$class_sql = "SELECT itemid,mtype,count(itemid) as count,(sum(gold_bind)+sum(gold_unbind)) as total,sum(gold_bind) as bind,sum(gold_unbind) as unbind,count(id) as times FROM `t_log_use_gold` ".$where." group by itemid";
$class_result = GFetchRowSet($sql);

$class_arr = array();
foreach ($class_result as $key=>$val){
	$class_arr[$val['itemid']] = $val;
}

$class_output = array();
foreach ($class_arr as $key=>$value){
	if($option[$key]['big_type']==$class){	
		$small_type = $option[$key]['small_type'];
		$value['key'] = $small_type; 
		$value['big_type'] = $option[$key]['big_type'];
		$value['small_type'] = $option[$key]['small_type'];
		$value['class']= $itemsonclass[$option[$key]['big_type']][$small_type];	
		$value['item_name']= $option[$key]['item_name'];
		$class_output[] = $value; 
	}
}
//echo '<pre>';print_r($class_output);echo '</pre>';
foreach($class_output as $key=>$value ){
	$paixu[] = $value['key'];
	$fenlei[] = $value['class'];
}
//echo '<pre>';print_r($class_output);echo '</pre>';
array_multisort($paixu,$fenlei, $class_output);

//按分类结束
$smarty->assign('dateStart',$date_start);
$smarty->assign('dateEnd',$date_end);
$smarty->assign('class_output',$class_output);
$smarty->assign('class',$itemclass[$class]);
$smarty->assign('itemclass',$itemclass);
$smarty->assign('output',$out_arr);
$smarty->display("module/analysis/gold_cost_list.tpl");