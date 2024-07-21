<?php
/**
 * 创建角色页面
 * @author QingliangCn
 * @create_time 2010/12/17
 */

ob_start();
session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_INCLUDE."/mgc.php";
include_once SYSDIR_INCLUDE.'/name_data.php';

global $smarty, $FIRST_NAME, $SECOND_NAME_MAN, $SECOND_NAME_WOMEN;;

$action = $_REQUEST['action'];

if ($action == 'create') {
	//DEBUG模式下不检查
	if (!isDebugMode()) {
		if (chk_session() !== true) {
			echo 'error#hack_attemp';
			exit();
		}
		$accountName = $_SESSION['account_name'];
	}
	else 
	{
		if (empty($_SESSION['account_name'])) {
			$accountName = $_POST['account'];
		} else {
			$accountName = $_SESSION['account_name'];
		}
	}
	
	if ($accountName == '') {
		echo 'error#hack_attemp';
		exit();
	}
	
	//检查当前是否有角色进入游戏了
	if ($accountName != '' && $accountName != null && $_SESSION['role_id'] > 0) {
		$result = getAllInfoFromMochiweb( $accountName, $_SESSION['role_id'] );
		if ($result && $result['result'] == 'ok') {
			echo "succ#".$_SESSION['role_id']."|".$result['map_id']."|".$result['level']."|".$result['gateway_host']
				."|".$result['gateway_port']."|".$result['gateway_key'];
		} else {
			echo 'error#请刷新';
		}
		exit();
	}
	//检查当前账号是否已有角色了
	$tmpRoleID = get_account_role_id($accountName);
	if ($tmpRoleID !== false && $tmpRoleID > 0) {
		$result = getAllInfoFromMochiweb( $accountName, $tmpRoleID );
		if ($result && $result['result'] == 'ok') {
			echo "succ#".$_SESSION['role_id']."|".$result['map_id']."|".$result['level']."|".$result['gateway_host']
				."|".$result['gateway_port']."|".$result['gateway_key'];
		} else {
			echo 'error#请刷新';
		}
		exit();
	}
	$userName = trim(urldecode($_POST['username']));
	// 过滤用户名:非法字符和大小写转换
	if (validateUserName($userName) === false) {
		echo 'error#用户名只能由字母、数字以及汉字组成，长度必须在2-7个字符之间，';
		exit();
	}
	if (($rtn = filterMGZ($userName)) !== true) {
		echo 'error#包含非法字符:'.$rtn;
		exit();
	}
	// 验证过滤性别
	$sex = intval($_POST['sex']);
	if ($sex !== 1) {
		$sex = 2;
	}
	// 验证发型
	$hairType = intval($_POST['hair_type']);
	// 验证头像
	$head = intval($_POST['head']);
	// 验证国家
	$factionID = intval($_POST['faction_id']);
	if ($factionID > 3 || $factionID < 1) {
		echo 'error#请选择国家';
		exit();	
	}
	// 验证发型的颜色
	$hairColor = trim(urldecode($_POST['hair_color']));
	// 验证职业
	$category = intval($_POST['category']);
	if ($category < 1 || $category > 4) {
		echo 'error#请选择职业';
		exit();
	}
	
	logAfterCreateRole($accountName,$userName,$factionID);
	$result = createUser($accountName, $userName, $sex, $factionID, $head, $hairType, $hairColor, $category);
	if (is_int($result) && $result > 0) {
		echo "ok";
		$_SESSION['role_id'] = $result;
		//记录创角页数据
		$defaultSex = intval($_REQUEST['d_sex']);
		$changedSex = intval($_REQUEST['c_sex']) ? 1 : 0;
		$defaultCategory = intval($_REQUEST['d_category']);
		$changedCategory = intval($_REQUEST['c_category']) ? 1 : 0;
		$defaultFaction = intval($_REQUEST['d_faction']);
		$changedFaction = intval($_REQUEST['c_faction']) ? 1 : 0;
		$changedName = intval($_REQUEST['c_name']) ? 1 : 0;
		
		// 改变过性别的玩家最终选择的性别是不是和默认性别一样
		if ($changedSex) {
			if ($sex == $defaultSex) {
				$sexChangedSame = 0;
			} else {
				$sexChangedSame = 1;
			}
		} else {
			$sexChangedSame = 2;			
		}
		
		//职业是否改过
		if ($changedCategory) {
			if ($category == $defaultCategory) {
				$categoryChangedSame = 0;
			} else {
				$categoryChangedSame = 1;
			}
		} else {
			$categoryChangedSame = 2;
		}
		
		$arr = array(
					'account_name' => $accountName,
					"default_sex" => $defaultSex,
					"changed_sex" => $changedSex,
					'sex' => $sex,
					'sex_changed_same' => $sexChangedSame,
					'default_category' => $defaultCategory,
					'changed_category' => $changedCategory,
					'category_changed_same' =>  $categoryChangedSame,
					'category' => $category,
					'c_name' =>  $changedName,
		);
		GQuery(makeInsertSqlFromArray($arr, 't_log_create_user_changed'));
		exit();
	} else {
		logCreateRoleFailed($accountName, $result);
		echo "error#{$result}";
		exit();
	}
	exit();
} else {
	// log user enter
	
	//检查session是否过期
	if (time() - $_SESSION['last_op_time'] > 7200) {
		header("location:" . WEB_AUTH_URL);
		exit();
	}
	//检查session, 出错直接跳转到官网
	if (chk_session() !== true) {
		header("location:" . OFFICIAL_WEBSITE);
		exit();
	}
	//如果发现已有角色ID了，则直接跳转到游戏里面
	if (chk_account_role($_SESSION['account_name']) || ($_SESSION['account_name'] != '' && $_SESSION['role_id'] > 0)) {
		header("location:./main.php"); 
		exit();
	}
	// 测试用，可以选择任意的客户端版本号
	if ($_SESSION['test_cvs'] > 0 ) {
		$clientVersion = $_SESSION['test_cvs'];
	} else {
		$clientVersion = getClientVersion();
	}
	
	$serverVersion = getServerVersion();
	$clientRootURL = WEB_STATIC.$clientVersion;
	
	logBeforeCreateRole($_SESSION['account_name']);
		
	//弹出收藏夹处理
	if (isset ( $_COOKIE ['ming2_fav'] )) {
		if ($_COOKIE ['ming2_fav'] >= 2) {
			$favStr = '';
		} else {
			$favStr = ' onunload="bookmarkit()"';
			setcookie ( "ming2_fav", $_COOKIE ['ming2_fav'] + 1, time () + 99999999 );
		}
	} else {
		$favStr = ' onunload="bookmarkit()"';
		setcookie ( "ming2_fav", 1, time () + 99999999 );
	}
	//随机生成男女名字各一个
	$manName = gene_unique_name(1);
	$womenName = gene_unique_name(2);
	$smarty->assign('manName', $manName);
	$smarty->assign('womenName', $womenName);
	// 用于给客户端拼凑 ping.php 和 reconnect.php的url
	$smarty->assign('gameRoot', WEB_SITEURL."user/");
	$smarty->assign('sessionID',  session_id());
	$smarty->assign('faction',  get_default_faction());
	$smarty->assign('favStr', $favStr);
	$smarty->assign('serverVersion', $serverVersion);
	$smarty->assign('clientVersion', $clientVersion);
	//客户端地址
	$smarty->assign('clientRootUrl', $clientRootURL);
	// 登录、聊天和端口转发都设置在A机上
	$smarty->assign('OFFICIAL_WEBSITE', OFFICIAL_WEBSITE);
	$serverVersion = getServerVersion();
	$clientRootURL = WEB_STATIC.$clientVersion;
	$smarty->assign('WEB_RESOURCE_HOST', $clientRootURL);
	$smarty->assign('WEB_SITEURL', WEB_SITEURL);
	$smarty->assign('WEB_AUTH_URL', WEB_AUTH_URL);
	$smarty->assign('title', WEB_TITLE);
	// 根据后台配置来确定创建页的版本
	if (defined('CREATE_ROLE_VERSION')) {
		$createRoleSwfFile = "createRoleCQ".CREATE_ROLE_VERSION.".swf";
	} else {
		$createRoleSwfFile = "createRoleCQ1.swf";
	}
	$smarty->assign('createRoleSwfFile', $createRoleSwfFile);
	$smarty->display("create_user.html");
}

/**
 * 	载入该页面的时候的记录，##暂时没用##
 * @param $accountName
 */
function logBeforeCreateRole($accountName){
	$accountName = SS($accountName);
	$sql = "select 1 from t_role_create_before where account_name = '$accountName' limit 1";
	$result = GFetchRowSet($sql);
	if (count($result)>0){
		return null;
	}
	
	$mtime = time();
	$ary = array(
		'account_name'=>$accountName,
		'mtime'=>$mtime,
		'year'=>date('Y',$mtime),
		'month'=>date('m',$mtime),
		'day'=>date('d',$mtime)
	);
	$sql = makeInsertSqlFromArray($ary, 't_role_create_before');
	$result = GQuery($sql);
}

function logCreateRoleFailed($accountName, $result) {
	$sql = "insert into t_log_create_role_failed values (NULL, '$accountName', '$result')";
	GQuery($sql);
}

/**
 * 创建角色之后的记录,插入前检查检查已有记录
 * @param  $accountName
 */
function logAfterCreateRole($accountName,$roleName,$factionId){
	$accountName = SS($accountName);
	$checkSql = "select 1 from t_role_create_after where account_name = '$accountName' ";
	$result = GFetchRowSet($checkSql);
	if (count($result)>0){
		//已经创建过了,不需再创建
		return null;
	}
	
	$factionId = SS($factionId);
	$roleName = SS($roleName);
	$mtime = time();
	$ary = array(
		'account_name'=>$accountName,
		'role_name'=>$roleName,
		'faction_id'=>$factionId,
		'mtime'=>$mtime,
		'year'=>date('Y',$mtime),
		'month'=>date('m',$mtime),
		'day'=>date('d',$mtime)
	);
	$sql = makeInsertSqlFromArray($ary, 't_role_create_after');
	GQuery($sql);
}


/**
 * 检查session信息，由start.php页面设置
 */
function chk_session() {
	if ($_SESSION['account_name'] != '' && $_SESSION['account_name'] != NULL) {
		return true;
	}
	return false;	
}

/** 
 * 创建角色
 * @param string $accountName
 * @param string $userName
 * @param int $sex
 * @param int $factionID
 * @param int $head
 * @param int $hairType
 * @param int $hairColor
 */
function createUser($accountName, $userName, $sex, $factionID, $head, $hairType, $hairColor, $category) {
	$result = getWebJson("/account/create_role/?ac={$accountName}&uname={$userName}&sex={$sex}"
						."&fid={$factionID}&head={$head}&hair_type={$hairType}"
						. "&hair_color={$hairColor}&category={$category}");
	if ($result['result'] == 'ok') {
		return $result['role_id'];
	}
	return $result['result'];
}

/** 
 * 过滤敏感词
 * @param string $str
 */
function filterMGZ($str) {
	global $MGC;
	foreach ($MGC as $value) {
		if ($value != '') {
			if (mb_strpos($str, $value, 0, 'utf8') !== false) {
				return $value;
			}
		}
	}
	return true;
}


