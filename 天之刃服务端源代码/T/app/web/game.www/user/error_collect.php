<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";

global $db, $smarty;
if (isPost()) {
	// 记录前端发送过来的错误日志
	$role_id=$_SESSION['role_id'];
        if ($role_id > 0) {
                $sql = "select level, role_name from db_role_attr_p where role_id = '$role_id'";
                $row = GFetchRowOne($sql);
                _error($row);
                $level = $row['level'];
                $rolename = $row['role_name'];
        } else {
                $level = 0;
        }
        _error($_POST);
        // 记录前端发送过来的错误日志
        $error_id = intval(trim($_POST['error_id']));
        $error = SS(trim($_POST['error']));
        $arr = array('error_id'=>$error_id, 'level' => $level, 'error' => $error, 'dateline' => time(),
                        'role_id' => $role_id, 'role_name' => "$rolename",
                        'type' => SS(trim($_POST['type'])),'level' => $level, 
                        'module'=> SS(trim($_POST['module'])), 'method' => SS(trim($_POST['method'])));
        $sql = makeInsertSqlFromArray($arr, 't_log_error_collect');
        GQuery($sql);
} else {
	$action = trim($_GET['action']);
	if ($action == 'see') {
		$pageno = getUrlParam('page');
		$result = getList('t_log_error_collect', null, $pageno, 'id desc', LIST_PER_PAGE_RECORDS, $count_result);
		$pagelist = getPages($pageno, $count_result);
		$smarty->assign('result', $result);
		$smarty->assign("page_list", $pagelist);
		$smarty->assign("page_count", ceil($count_result/LIST_PER_PAGE_RECORDS));
		$smarty->display('error_collect.html');
	}
}