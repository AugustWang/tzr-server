<?php
/**
 * 系统全局配置项
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

$action = SS($_REQUEST['ac']);

if ($action === 'modify')
{
	$sql = "SELECT * FROM `t_config` ORDER BY `readonly`,`ctype` DESC, `ckey`";
	$data = GFetchRowSet($sql);
	$arr = array();
	foreach($data as $vv)
	{
		$arr[ $vv['ckey'] ] = $vv;
	}

	$input = $_REQUEST;
	unset($input['save']);
	unset($input['submit']);
	unset($input['ac']);
	unset($input['session']);

	//如果 magic_quotes_gpc = On，那么去掉转义
	//如果　magic_quotes_gpc = Off，那么不用去转义了
	if (get_magic_quotes_gpc()) {
		foreach($input as $k=>$v)
		{
			$input[$k] = stripslashes($v);
		}
	}

	$newVal = array();
	foreach($arr as $kk =>$vv) {
		if ($vv['readonly']) continue; //数据库表中存在这个配置项KEY，但它是只读的，则跳过

		$ctype = $vv['ctype'];

		if ($ctype == 'boolean') {
			if ($input[$kk]) $value = 'true'; else $value = 'false';
		} else if ($ctype == 'int') {
			$value = intval($input[$kk]);
		} else if ($ctype == 'string' || $ctype == 'text') {
			$value = (string)$input[$kk];
		} else if ($ctype == 'float') {
			$value = (float)$input[$kk];
		}
		if ($value != $vv['cvalue'] || $s != '')
			$newVal[$kk] = $value;
	}

	if (count($newVal)>0)
	{
		$str = '';
		#更新非混服config数据库
		if($s == ''){
			foreach($newVal as $kk => $vv)
			{
				$f = array();
				$f['ckey'] = $kk;
				$f['cvalue'] = mysql_escape_string($vv);
				$sql = makeUpdateSqlFromArray($f, 't_config', 'ckey');
				GQuery($sql);
				$str .= $kk . ', ';
			}
			echo "<font color=green>成功更新" . count($newVal) . "个配置项: {$str}</font><br/>";
		}
		// 让config修改立即生效
		$conf_key = 'MCCQ_CONFIG_CACHE_KEY';
		global $cache;
		$cache->delete($conf_key);
	}
}

$sql = "SELECT * FROM `t_config` ORDER BY `readonly`,`ctype` DESC, `ckey`";
$data = GFetchRowSet($sql);
global $CONFIG_PARAMS;
$smarty->assign('params', $CONFIG_PARAMS);
$smarty->assign('data', $data);
$smarty->assign('msg', $msg);
$smarty->display("module/setting/config_setting.tpl");

exit;
