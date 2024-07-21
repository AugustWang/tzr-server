<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);
define('LOG_DIR', '/data/logs');


$line = intval($_REQUEST['line']) or $line = 30;
$file = $_GET['file'];



if ($file && is_file(LOG_DIR.DIRECTORY_SEPARATOR.$file)){
	$content = getFileContent($file, $line);
	$smarty->assign(array(
		'content'=>$content,
		'file'=>$file
	));
}else{
	$ary = list_file();
	$smarty->assign('ary',$ary);	
}

$smarty->assign('line',$line);
$smarty->display('module/system/admin_error_log_view.tpl');



function getFileContent($file,$line){
	$file =  LOG_DIR.DIRECTORY_SEPARATOR.$file;
	$content = getCommandOutput("tail -$line $file");
	return $content;
}


function list_file(){
	$dir = LOG_DIR;	
	$content = getCommandOutput("ls  -1t $dir |grep 'ming2.*log' ");
	$ary = explode("\n",$content);
	return $ary;
}



/**
 * 获取命令输出
 * @param unknown_type $cmd
 */
function getCommandOutput($cmd){
	ob_start();
	passthru("$cmd");
	$content_grabbed=ob_get_contents();
	ob_end_clean();
	return $content_grabbed;

}