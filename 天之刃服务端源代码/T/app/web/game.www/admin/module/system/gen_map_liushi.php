<?php
/**
 * 生成地图流失率数据
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php"; 
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

if (isPost()) {
	$maps = SS(trim($_POST['maps']));
	$time_gap = SS(trim($_POST['time_gap']));
	$level = SS(trim($_POST['level']));
	if (!$maps) {
		errorExit("地图列表,不能为空");
	} 
	if ($time_gap !== '0' && !$time_gap) {
		errorExit("流失用户的最短时间,不能为空");
	}
	if (!$level) {
		errorExit("用户最大等级,不能为空");
	}
	
		
			$url =	ERLANG_WEB_URL . "/gen_map_goway" ;
			$params = "maps={$maps}&time_gap={$time_gap}&level={$level}";
			$ch=curl_init();  
			curl_setopt($ch,CURLOPT_URL,$url);
			curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);  
			curl_setopt($ch,CURLOPT_POST,1);
			curl_setopt($ch,CURLOPT_POSTFIELDS,$params);  
			
			$data = curl_exec($ch);
			$result = json_decode($data,true);

			if ('ok'==$result['result']) {
				$msg = '操作成功，已经导出数据到数据表t_map_liushi，请联系运维获取数据';
			}else {
				$msg = '操作失败，可能操作超时';
			}
			
			echo $msg;
			
}else{
	$smarty->display("module/system/gen_map_liushi.tpl");	
}



