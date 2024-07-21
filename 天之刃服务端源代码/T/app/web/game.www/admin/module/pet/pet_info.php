<?php
/*
 * created by yangyuqun
 */
define('IN_ODINXU_SYSTEM', true);
define('LEN_PER_PAGE', 25);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN.'/dict/pet.php';
include_once SYSDIR_ADMIN.'/include/dict.php';



// 宠物操作日志类型
$pet_option_log = array(
	'9999'=>'全部',
	101=>'放生宠物',
	102=>'宠物洗灵',
	103=>'宠物提悟',
	104=>'宠物延寿',
	105=>'宠物学技能',
	106=>'宠物洗髓',
	107=>'宠物死亡',
	108=>'宠物增加技能栏',
	109=>'宠物遗忘技能',
	110=>'宠物遗忘技能',
	111=>'宠物领悟新的特技',
	112=>'宠物升级特技 ',
	113=>'宠物升级',
);
$search_sort_1 = SS($_REQUEST['sort_1']);
$search_sort_2 = SS($_REQUEST['sort_2']);


$search_sort_1 = getRequest('sort_1','id desc');
$search_sort_2 = getRequest('sort_2','reg_time desc');
$page = SS($_REQUEST['page']);
$curpage = $page;
$oldPage = $page;
$pageno = ($page == 0)?0:($page-1);
$pageStart = $pageno*LEN_PER_PAGE+1;




$pet_id = SS($_GET['pet_id']);
$rold_id = SS($_GET['role_id']);
$option = SS($_GET['option']);

$datestart = SS($_GET['dateStart']);
$dateend = SS($_GET['dateEnd']);
$start_time = strtotime(SS($_GET['dateStart']));
$end_time = strtotime(SS($_GET['dateEnd']));

if($option=='9999'){
	$option = '';
}
if (!$datestart || !$dateend ) {
	$dateend = date('Y-m-d',time());
	$datestart = date('Y-m-d',strtotime('-6day'));
}

if (!$start_time || !$end_time ) {
	$start_time = strtotime(date('Y-m-d',strtotime('-6day')));
	$end_time = strtotime(date('Y-m-d 23:59:59'));
}

$where = ' where 1';
$where = $where.(empty($pet_id)?"":" and pet_id = '$pet_id'");
$where = $where.(empty($role_id)?"":" and role_id = '$role_id'");
$where = $where.(empty($option)?"":" and action = '$option'");
$where = $where.' and mtime>='.$start_time.' and mtime <= '.$end_time;
$sql = "select * from t_log_pet_action ".$where." limit $pageStart,".LEN_PER_PAGE;
$pet_list = GFetchRowSet($sql);
$sql2 = "select count(1) as cnt from t_log_pet_action ".$where;
$page = GFetchRowOne($sql2);
$countResult = intval($page['cnt']);
$pagelist = getPages($pageno, $countResult);

$pet_info = array();
foreach($pet_list as $list){
	$list['time'] = date('Y-m-d h:i:s',$list['mtime']);
	array_push($pet_info,$list);
}
$smarty->assign('option',$option);
$smarty->assign('pet_id',$pet_id);
$smarty->assign('role_id',$rold_id);
$smarty->assign('pet_option_log',$pet_option_log);
$smarty->assign('start',$datestart);
$smarty->assign('end',$dateend);
$smarty->assign('pagelist',$pagelist);
$smarty->assign('pet_info',$pet_info);
$smarty->display("module/pet/pet_info.tpl");
exit();