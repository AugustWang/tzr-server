<?php
/*
 * Author: dqj
 * 2010-1-27
 *
 */
define('IN_ODINXU_SYSTEM', true);
include "../../../config/config.php";
include SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
$goldTypes = array('全部','元宝','绑定元宝');
$type = intval($_REQUEST['goldType']); 
if (!empty($_POST)) {
	$page = 1;
}else {
	$page = intval($_GET['page']);
}
$page = $page < 1 ? 1 : $page; 
$itemPerPage = 100; //每页显示多少条记录
$offset = ($page-1) * $itemPerPage ;
$tblRa = T_DB_ROLE_ATTR_P;
$tblRb = T_DB_ROLE_BASE_P;
if (1==$type) {
	$sql = " SELECT attr.role_id ,attr.role_name, base.account_name, attr.gold AS golds
			 FROM {$tblRa} attr, {$tblRb} base 
			 WHERE attr.gold > 100 AND attr.role_id=base.role_id  ORDER BY golds DESC 
			 LIMIT {$offset} , {$itemPerPage} ";
	$sqlCnt = " SELECT count(`role_id`) as `cnt` FROM {$tblRa} WHERE `gold` > 100 ";
}elseif (2==$type){
	$sql = " SELECT attr.role_id ,attr.role_name, base.account_name, attr.gold_bind AS golds
			 FROM {$tblRa} attr, {$tblRb} base 
			 WHERE attr.gold_bind > 100 AND attr.role_id=base.role_id  ORDER BY golds DESC 
			 LIMIT {$offset} , {$itemPerPage}  ";
	$sqlCnt = " SELECT count(`role_id`) as `cnt` FROM {$tblRa} WHERE `gold_bind` > 100 ";
}else {
	$sql = " SELECT attr.role_id ,attr.role_name, base.account_name, attr.gold as unbind_gold, attr.gold_bind as bind_gold, (attr.gold+attr.gold_bind) AS golds
			 FROM {$tblRa} attr, {$tblRb} base 
			 WHERE (attr.gold+attr.gold_bind) > 100 AND attr.role_id=base.role_id ORDER BY golds DESC 
			 LIMIT {$offset} , {$itemPerPage}  ";
	$sqlCnt = " SELECT count(`role_id`) as `cnt` FROM {$tblRa} WHERE (`gold`+`gold_bind`) > 100 ";
}
$rs = GFetchRowSet($sql);
$rsCnt = GFetchRowOne($sqlCnt);
$rowCnt = intval($rsCnt['cnt']);
$pagelist	= getPages($page, $rowCnt, $itemPerPage);
//debug($rs);

$smarty->assign("rs",$rs);
$smarty->assign("offset",$offset);
$smarty->assign("goldTypes",$goldTypes);
$smarty->assign("goldType",$type);
$smarty->assign("page_list",$pagelist);

$smarty->display("module/pay/gold_remain_list.tpl");

?>