<?php
if (!defined('MING2_WEB_ADMIN_FLAG')) {
	exit ('hack attemp');
}

if (!defined("LIST_PER_PAGE_RECORDS"))
	define("LIST_PER_PAGE_RECORDS", 20);
if (!defined("LIST_SHOW_PREV_NEXT_PAGES"))
	define("LIST_SHOW_PREV_NEXT_PAGES", 7); //First Prev 1 2 3 4 5 6 7 8 9 10... Next Last

include_once SYSDIR_ADMIN."/class/sql_select_class.php";
include_once SYSDIR_ADMIN."/class/sql_func_helper_class.php";
include_once SYSDIR_ADMIN."/include/db_functions.php";
include_once SYSDIR_ADMIN."/include/db_defines.php";

function getRequest($key,$default = 0){
 	$ret = $_POST[$key] or $ret = $_GET[$key] or $ret = $default;
 	return $ret;
}

/**
 * 根据记录总数和每页记录数获得分页数
 *
 * @param int $counts
 * @param int $rsPerPage
 * @return int
 */
function getNumsOfPage($counts, $rsPerPage, $max = 0)
{
    $tmp = (($counts % $rsPerPage) == 0) ? ($counts / $rsPerPage) : (floor($counts / $rsPerPage) + 1);   
    if ($max > 0)
    {
        if ($tmp > $max)
        {
            $tmp = $max; 
        }
    }
    return intval($tmp);
}

/**
 * 验证用户名是否合法
 * @param $username
 * 
 * @return true | $errorMsg
 */
function validUsername($username) {
	$username = trim($username);
	if ($username == '') {
		return '用户名不能为空';
	}
	if (preg_match("/^[\x{4e00}-\x{9fa5}0-9a-zA-Z_]+$/u", $username) == 0) {
		return '用户名只能由英文、数字、中文以及下划线组成';
	}
	return true;
}

function validChinese($str) {
	$str = trim($str);
	if (preg_match("/^[\x{4e00}-\x{9fa5}]+$/u", $str) == 0) {
		return false;
	}
	return true;
}

/**
 * 验证密码是否合法
 * @param $password
 * 
 * @return true | $errorMsg
 */
function validPassword($password) {
	$username = trim($password);
	if ($username == '') {
		return '密码不能为空';
	}
	if (preg_match("/^[0-9a-zA-Z_]+$/u", $password) == 0) {
		return '密码只能由英文、数字以及下划线组成';
	}
	return true;
}

/**
 * 访问Service，但不关注返回值
 * @param $url
 */
function getNothing($url) {
	@ file_get_contents($url);
}

/**
 * 通过返回指定URL的erlang web服务获取JSON
 * @param $url
 */
function getJson($url) {
	global $smarty;
	$result = @ file_get_contents($url);
	if ($result) {
		return json_decode($result, true);
	}
	$smarty->assign(array (
		'errorMsg' => 'erlang web尚未启动或者访问出错:' . $url
	));
	$smarty->display("error.html");
	exit ();
}

function errorExit($msg) {
	global $smarty;
	$smarty->assign(array (
		'errorMsg' => $msg
	));
	$smarty->display("error.html");
	exit ();
}

function succExit($msg, $url = '') {
	if (!$url) {
		$url = $_SERVER['HTTP_REFERER'];
	}
	global $smarty;
	$smarty->assign(array (
		'info' => $msg,
		'url' => $url
	));
	$smarty->display("succ.html");
	exit ();
}

function infoExit($msg, $url = '') {
	if (!$url) {
		$url = $_SERVER['HTTP_REFERER'];
	}
	global $smarty;
	$smarty->assign(array (
		'info' => $msg,
		'url' => $url
	));
	$smarty->display("succ.html");
	exit ();
}


/**
 * SQL的参数值的安全过滤
 * 所有SQL语句的参数，都必须用这个函数处理一下。目的：防SQL注入攻击!!
 * @param $name
 */
function SS($name) {
	$name = trim($name);
	return mysql_real_escape_string($name);
}

/**
 * 获取URL参数值
 * @param $name
 */
function getUrlParam($name = 'pid') {
	$v = intval($_REQUEST[$name]);
	$v = ($v < 1) ? 1 : $v;
	return $v;
}


///日期的常用操作方法
/**
 * 返回当前天0时0分0秒的时间
 * @param $outstring	是否返回字符串类型，默认为false
 * 			如果$outstring为true则返回该时间的字符串形式，否则为时间戳
 */
function GetTime_Today0($outstring = false){
	$str_today0 = strftime ("%Y-%m-%d", time());
	$result = strtotime ($str_today0);
	if ($outstring)
		return strftime ("%Y-%m-%d %H:%M:%S", $result );
	else
		return $result;
}

function GetTimeString($srcTimeStamp){
	return strftime ("%Y-%m-%d %H:%M:%S", $srcTimeStamp );
}

function GetDayString($srcTimeStamp)	{
	return strftime ("%Y-%m-%d", $srcTimeStamp );
}

function GetTodayString()	{
	return strftime ("%Y-%m-%d");
}

function GetCurTimeString()	{
	return strftime ("%Y-%m-%d %H:%M:%S");
}
	
	
function GetIP(){
	if(!empty($_SERVER["HTTP_CLIENT_IP"])) $cip = $_SERVER["HTTP_CLIENT_IP"];
	else if(!empty($_SERVER["HTTP_X_FORWARDED_FOR"])) $cip = $_SERVER["HTTP_X_FORWARDED_FOR"];
	else if(!empty($_SERVER["REMOTE_ADDR"])) $cip = $_SERVER["REMOTE_ADDR"];
	else $cip = "";
	return $cip;
}

/**
 * curl方式 post数据
 *
 * @param mix $data
 * @param string $url 全路径,如: http://127.0.0.1:8000/test
 */
function curlPost($url,$params)
{
	if (!trim($params)) {
		return false;
	}
	$ch=curl_init();  
	curl_setopt($ch,CURLOPT_URL,$url);
	curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);  
	curl_setopt($ch,CURLOPT_POST,1);
	curl_setopt($ch,CURLOPT_POSTFIELDS,$params);  
	$result = curl_exec($ch);
	curl_close($ch);
	return $result;
}

function getWebJson($urlPath)
{
	global $smarty, $erlangWebHost;
	$result = @ file_get_contents(rtrim(ERLANG_WEB_URL, '/').$urlPath);
	if ($result) {
		return json_decode($result, true);
	}
}

function getServerVersion()
{
	$content = @file_get_contents("/data/tzr/server/version_server.txt");
	if (!$content) {
		die("服务端版本号文件丢失");
	}
	return trim($content);
}

function getClientVersion()
{
	$content = @file_get_contents("/data/tzr/server/version_client.txt");
	if (!$content) {
		die("客户端版本号文件丢失");
	}
	return trim($content);
}

/**
 * 对系统配置项执行宏定义
 * 加载存放在数据库t_config表里的游戏配置项
 */
function define_SystemConfigFromDB($_REPLACE) {
	global $cache;
	$conf_key = 'MCCQ_CONFIG_CACHE_KEY';
	$data = $cache->fetch($conf_key);
	
	if (!isset($data[0]))
	{
		global $db;
		$sql = "SELECT * FROM `t_config`";
		$data = GFetchRowSet($sql);
		if (is_array($data)) {
			//prepare for preg_replace
			$_p = array_keys($_REPLACE);
			$_r = array();
			foreach($_p as $i => $p) {
				$_p[$i] = '/<'.$p.'>/';
				$_r[$i] = $_REPLACE[$p];
			}
			ksort($_p);
			ksort($_r);
			//preg_replace: putting in all parameterized values
			foreach($data as $i => $vv) {
				$kk = $vv['ckey'];
				$value = transformURL4FlashClient($vv['cvalue']);
				if(($value = preg_replace($_p, $_r, $value)) !== NULL) {
					$vv['cvalue'] = $value;
					$data[$i] = $vv;
				}
			}
		}
		$cache->store($conf_key, $data);
	}
	if (is_array($data)) {
		foreach($data as $vv) {
			$kk = $vv['ckey'];
			if (defined($kk)) {
				continue;
			}
			$ctype = $vv['ctype'];
			if ($ctype == 'boolean'){
				define($kk, ($vv['cvalue'] == 'true') );
			}
			else if ($ctype == 'int'){
				define($kk, (int)$vv['cvalue']);
			}
			else if ($ctype == 'string'){
				define($kk, (string)$vv['cvalue']);
			}
			else if ($ctype == 'text'){
				define($kk, (string)$vv['cvalue']);
			}
			else if ($ctype == 'float'){
				define($kk, (float)$vv['cvalue']);
			}
		}
	}
	//没有定义数据，可能是缓存失败了，数据库读取配置项也失败了。
	if ( (!defined("WEB_STATIC")) || (!defined("PAY_URL")) ){
		die('INIT CONFIG FAIL');
	}
}
/**
 * 银两单位转换（文->锭、两、文）
 *
 * @param integer $wen
 * @return string
 */
function silverUnitConvert($wen)
{
	$ding = intval($wen/10000) ; //10000文 = 1锭
	$wen -=  $ding * 10000; 
	$liang = intval( $wen/100 ); //100文 = 1两
	$wen -=  $liang * 100;
	$str = $ding ? $ding.'锭' : '';
	$str .= $liang ? $liang.'两' : '';
	$str .= $wen ? $wen.'文' : '';
	return !$ding && !$liang && !$wen ? '0' : $str;
}

/**
 * 
 * 为flash客户端做url预处理
 * 将&改为|
 * @param string $url
 * @return string $url
 */
function transformURL4FlashClient($url) {
	return str_replace('&', '|', $url);
}


/**
 * 生成平台跳转ticket
 * @param $accountName 账号名称 
 * @param $timestamp 时间戳
 * @param $agentID 代理商ID
 * @param $serverID 服务器ID
 * @param $fcmFlag 防沉迷标志
 */
function gene_login_ticket($accountName, $timestamp, $agentID, $serverID, $fcmFlag)
{
	global $API_SECURITY_TICKEY_LOGIN;
	return md5($API_SECURITY_TICKEY_LOGIN.$accountName.$timestamp.$agentID.$serverID.$fcmFlag);
}

/*
 * 将字符串数据拆分
 *
 */
function extractData($str, $level = 1)
{
	$extr = ',';
	$extr2 = ':';
	if (empty($str))
		return null;

	$arr = explode($extr, $str);
	if (sizeof($arr)<=0)
		return null;

	$result = null;
	if ($level == 1)
	{
		//  "F:1000,W:800"  拆分成数组 F=1000; W=800;
		for($i=0;$i<count($arr);$i++)
		{
			$r = explode($extr2, $arr[$i]);
			$result[$r[0]] = $r[1];
		}
	}
	else if ($level == 2)
	{
		//  "B:2:1,T:3:3"  拆分成数组
		for($i=0;$i<count($arr);$i++)
		{
			$r = explode($extr2, $arr[$i]);
			$result[$i]['k'] = $r[0];
			$result[$i]['v1'] = $r[1];
			$result[$i]['v2'] = $r[2];
		}
	}
	else if ($level == 3)
	{
		//  "B:2:1:4,T:3:3:5"  拆分成数组
		for($i=0;$i<count($arr);$i++)
		{
			$r = explode($extr2, $arr[$i]);
			$result[$i]['k'] = $r[0];
			$result[$i]['v1'] = $r[1];
			$result[$i]['v2'] = $r[2];
			$result[$i]['v3'] = $r[3];
		}
	}
	return $result;
}



/*
 * 将数组，组合合并为字符串格式
 */
function combineData($arr, $level = 1, $key = null)
{
	if (!is_array($arr))
		return '';

	if ($level == 1)
	{
		$str = '';
		foreach($arr as $k=>$v)
			$str .= "{$k}:{$v},";
		$str = trim($str, ',');
		return $str;
	}

	if ($level == 2)
	{
		if (empty($key))
			return false;

		$str = '';
		foreach($arr as $k=>$v)
			if ($v>0 && $k>0)
				$str .= "{$key}:{$k}:{$v},";

		$str = trim($str, ',');
		return $str;
	}
}

function isPost() {
	return (strtolower($_SERVER['REQUEST_METHOD']) == 'post');
}

//重写缓存文件
function rewriteCacheFile()
{
	$tblBanRole = T_BAN_ROLE_LIST;
	$file = SYSDIR_ROOT.'cache/data/base_limit_account.php';
	$sqlBanList = " SELECT `account_name`, `end_time` FROM {$tblBanRole} WHERE `end_time` = 99999 or `end_time` >= ".time() . " ";
	$banList = GFetchRowSet($sqlBanList);
	
	$strFileContent = 
	"<?php\n\n//key值为account_name\n\n\$_DCACHE['limit_account'] = array(\n";
	foreach ($banList as &$ban) {
		$strFileContent .= "\t '{$ban['account_name']}' => array('end_time'=>{$ban['end_time']},),\n";
	}
	$strFileContent .=");";
	if (is_writable(dirname($file))) {
		file_put_contents($file,$strFileContent);
	}else {
		die('无权限写入'.$file);
	}
}

function validateUserName($str) {
	//首字符为字母, 数字或者汉字, 总长度限制, 汉字最多5个, 其他只能是字母或数字
	$str = trim ( $str );
	
	$re = '/^(?i)(?:[\x{4e00}-\x{9fa5}]?[A-Z0-9]*){2,' . MAX_CN_UNAME_LENGTH . '}$/u';
	
	if (preg_match ( $re, $str ))
		return mb_strlen ( $str, 'UTF-8' ) >= MIN_UNAME_LENGTH && mb_strlen ( $str, 'UTF-8' ) <= MAX_UNAME_LENGTH;
	else {
		return false;
	}
}


/** 
 * 检查某个账号是否已经创建了角色
 * @param string $accountName 
 * @return bool
 */
function chk_account_role($accountName) {
	global $cache;
	$result = $cache->fetch('ACCOUNT_HAS_ROLE_'.$accountName);
	if ($result) {
		$_SESSION['role_id'] = $result;
		return true;
	} else {
		$result = getWebJson("/account/has_role/?account={$accountName}");
		if ($result == NULL) {
			return false;
		} else  {
			if ($result['result'] === true) {
				$_SESSION['role_id'] = $result['role_id'];
				$cache->store('ACCOUNT_HAS_ROLE_'.$accountName, $result['role_id']);
				return true;
			} else if ($result['result'] === false) {
				return false;
			} else {
				return false;
			}
		}
		return true;
	}
}

/**
 * 获取角色的基本信息：现在只是返回map_id和level
 * @param $accountName
 */
function get_role_base_info($accountName) {
	$result = getWebJson("/account/get_role_base_info/?account={$accountName}");
	if ($result == NULL) {
		return false;
	} else  {
		if ($result['result'] === true) {
			return $result;
		} else {
			return false;
		}
	}
}

/**
 * 通知erlang账号已经通过防沉迷验证了
 * @param string $accountName
 */
function setAccountFCMPassed($accountName) {	
	$result = getWebJson("/account/pass_fcm/?account={$accountName}");
	if ($result == NULL) {
		return false;
	} else  {
		if ($result['result'] === 'ok') {
			return true;
		} else {
			return false;
		}
	}
	return true;
}


/**
 * 获得本账号下的所有信息
 * 需要的信息：
 * 	一条网关：域名|端口|key
 *  角色ID
 *  角色level
 *  角色MapID
 *  聊天IP
 *  聊天key
 *  聊天port
 * @param string $accountName
 */
function getAllInfoFromMochiweb($accountName, $roleID) {
	$result = getWebJson("/account/get_all/?account={$accountName}&role_id={$roleID}");
	if (!$result) {
		die("错误码100001，请稍等一会重试");
	} else if ($result['result'] == 'error') {
		die("错误码100002，请联系管理员");
	}
	$result['lines'] = $result['gateway_host'].",".$result['gateway_port'].",".$result['gateway_key'];
	return $result;
}


/**
 * 获取账号下的角色
 * @param string $accountName
 */
function get_account_role_id($accountName) {
	global $cache;
	$result = $cache->fetch("ACCOUNT_ROLE_ID_".$accountName);
	if ($result) {
		return $result;
	}
	$result = getWebJson("/account/get_role_id/?account={$accountName}");
	if ($result == NULL) {
		return false;
	} else if ($result['result'] == 'error') {
		return false;
	}
	$cache->store("ACCOUNT_ROLE_ID_".$accountName, $result['result']);
	return $result['result'];
}

//生成一个用于连接分线的验证key
function gene_auth_key($account, $role_id) {
	$result = getWebJson("/login/get_key/?account={$account}&role_id={$role_id}");
	if (!$result) {
		return '';
	} else if (isset($result['result'])) {
		return '';
	}
	return $result;
}

// 检查是否开放了平台进入游戏
function checkPlatformState() {
	global $smarty;
	if (file_exists("/data/tzr/web/platform.lock")) {
		//检查是否是从后台跳转过来的，如果是则不需要判断入口是否关闭
		if ($_SESSION['from_admin'] == true) {
			// ignore
		} else {
			header('content-type:text/html;charset=utf-8');
	  		header("refresh:5;url=".OFFICIAL_WEBSITE);
	  		$smarty -> assign('msg', file_get_contents("/data/tzr/web/platform.lock").'<br />请稍后访问...5秒后自动跳转至官网');
	  		$smarty -> assign('link', OFFICIAL_WEBSITE);
	  		$smarty -> display('error.html');
	  		exit;
		}
	}
}

// 检查是否开放了后台进入游戏
function checkGameFromAdminState() {
	global $smarty;
	if (file_exists("/data/tzr/web/allgame.lock")) {
		header ( 'content-type:text/html;charset=utf-8' );
		header ( "refresh:5;url=" . OFFICIAL_WEBSITE );
		$smarty->assign ( 'msg', file_get_contents ( "/data/tzr/web/allgame.lock" ) . '<br />请稍后访问...5秒后自动跳转至官网' );
		$smarty->assign ( 'link', OFFICIAL_WEBSITE );
		$smarty->display ( 'error.html' );
		exit ();
	}
}

//获取一个80端口的网关让玩家连接
//返回 array('host' => host, 'port' => port, 'result' => 'succ');
function get80Line() {
	$result = getWebJson("/server/get_80_line");
	if (!$result) {
		return null;
	} else if ($result['result'] == 'failed') {
		return null;
	}
	return $result;
}


function getKey() {
	$result = getWebJson('/server/get_key');
	if (!$result) {
		return null;
	} else if ($result['result'] == 'failed') {
		return null;
	}
	return $result;
}

// 获取一个分线
function get_line() {
	$result = getWebJson("/login/get_one_line/");
	if ($result == NULL) {
		return false;
	} else if ($result['result'] == 'failed') {
		return false;
	}
	return array('ip' => $result['ip'], 'port' => $result['port']);
}

//获取创建页的默认国家，也可以直接查询数据库来获取
function get_default_faction() {
	$result = getWebJson("/login/get_default_faction/");
	if ($result == NULL) {
		return false;
	} 
	return $result['result'];
}

/**
 * 测试mochiweb服务是否正常开启了
 */
function testMochiwebIsOk() {
	$result = getWebJson("/server/is_ok/");
	if ($result == NULL) {
		return false;
	}
	return true;
}

/**
 * 是否在测试模式
 */
function isDebugMode() {
	$file = "/data/tzr/server/setting/common.config";
	if (!file_exists($file)) {
		echo '文件/data/tzr/server/setting/common.config不存在';
		exit();
	}
	$fileContent = file($file);
	$debugMode = false;
	foreach ($fileContent as $v) {
		if (mb_strpos($v, 'is_debug', 0, 'utf8') !== false) {
			if (mb_strpos($v, 'true', 0, 'utf8') !== false) {
				$debugMode = true;
			}
		}
	}
	return $debugMode;
}

/**
 * 获得当前在线玩家数量
 */
function getOnline() {
	global $cache;
	$online = unpack("N", ($cache->fetch('online')));
	return $online[1];
}

function increaseQueue() {
	global $cache;
	if (!$cache->fetch("online_queue")) {
		$cache->store("online_queue", 0, 30);
		$cache->store("online_queue_timeline", time());
	} else {
		$onlineQueueTimeline = $cache->fetch("online_queue_timeline");
		//10秒之后刷掉排队人数
		if (time() - $onlineQueueTimeline > 10) {
			$cache->store("online_queue", 0, 30);
			$cache->store("online_queue_timeline", time());
		}
	}
	$cache->increase("online_queue");
}

function decreaseQueue() {
	global $cache;
	if (!$cache->fetch("online_queue")) {
		$cache->store("online_queue", 0, 30);
		$cache->store("online_queue_timeline", time());
	} else {
		$onlineQueueTimeline = $cache->fetch("online_queue_timeline");
		//10秒之后刷掉排队人数
		if (time() - $onlineQueueTimeline > 10) {
			$cache->store("online_queue", 0, 30);
			$cache->store("online_queue_timeline", time());
		}
	}
	$cache->decrease("online_queue");
}

function getQueue() {
	global $cache;
	return (int)$cache->fetch("online_queue");
}


/***************************************************************************      
Usage Example   : 
echo CvIp('218.56.198.104');
//返回 山东省济南市 网通ADSL
//如果参数为空则自动获取ip
***************************************************************************/

function CvIp($ip='')
{
        if(empty($ip)) $ip = _Cv_Get_Ip();
        if(!preg_match('#^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$#', $ip)) { 
        	return false; 
        }
        if($fd = @fopen(dirname(__FILE__).'/QQWry.Dat', 'rb')){
                $ip        = explode('.', $ip);
                $ipNum     = $ip[0]*16777216 + $ip[1]*65536 + $ip[2]*256 + $ip[3];
                $DataBegin = fread($fd, 4);
                $DataEnd   = fread($fd, 4);
                $ipbegin   = implode('', unpack('L', $DataBegin));

                if($ipbegin < 0) $ipbegin += pow(2, 32);
                $ipend = implode('', unpack('L', $DataEnd));
                if($ipend < 0) $ipend += pow(2, 32);
                $ipAllNum = ($ipend - $ipbegin) / 7 + 1;
                $BeginNum = 0;
                $EndNum = $ipAllNum;

                while($ip1num > $ipNum || $ip2num < $ipNum)
                {
                        $Middle= intval(($EndNum + $BeginNum) / 2);

                        fseek($fd, $ipbegin + 7 * $Middle);
                        $ipData1 = fread($fd, 4);
                        if(strlen($ipData1) < 4) {
                                fclose($fd);
                                return 'System Error';
                        }

                        $ip1num = implode('', unpack('L', $ipData1));
                        if($ip1num < 0) $ip1num += pow(2, 32);

                        if($ip1num > $ipNum) {
                                $EndNum = $Middle;
                                continue;
                        }

                        $DataSeek = fread($fd, 3);
                        if(strlen($DataSeek) < 3) {
                                fclose($fd);
                                return 'System Error';
                        }

                        $DataSeek = implode('', unpack('L', $DataSeek.chr(0)));
                        fseek($fd, $DataSeek);
                        $ipData2 = fread($fd, 4);
                        if(strlen($ipData2) < 4) {
                                fclose($fd);
                                return 'System Error';
                        }

                        $ip2num = implode('', unpack('L', $ipData2));
                        if($ip2num < 0) $ip2num += pow(2, 32);
                        if($ip2num < $ipNum) {
                                if($Middle == $BeginNum) {
                                        fclose($fd);
                                        return 'Unknown';
                                }
                                $BeginNum = $Middle;
                        }
                }

                $ipFlag = fread($fd, 1);
                if($ipFlag == chr(1))
                {
                        $ipSeek = fread($fd, 3);
                        if(strlen($ipSeek) < 3) {
                                fclose($fd);
                                return 'System Error';
                        }

                        $ipSeek = implode('', unpack('L', $ipSeek.chr(0)));
                        fseek($fd, $ipSeek);
                        $ipFlag = fread($fd, 1);
                }

                if($ipFlag == chr(2)) {
                        $AddrSeek = fread($fd, 3);
                        if(strlen($AddrSeek) < 3) {
                                fclose($fd);
                                return 'System Error';
                        }
                        $ipFlag = fread($fd, 1);
                        if($ipFlag == chr(2)) {
                                $AddrSeek2 = fread($fd, 3);
                                if(strlen($AddrSeek2) < 3) {
                                        fclose($fd);
                                        return 'System Error';
                                }
                                $AddrSeek2 = implode('', unpack('L', $AddrSeek2.chr(0)));
                                fseek($fd, $AddrSeek2);
                        } else {
                                fseek($fd, -1, SEEK_CUR);
                        }

                        while(($char = fread($fd, 1)) != chr(0))
                                $ipAddr2 .= $char;

                        $AddrSeek = implode('', unpack('L', $AddrSeek.chr(0)));
                        fseek($fd, $AddrSeek);

                        while(($char = fread($fd, 1)) != chr(0))
                                $ipAddr1 .= $char;
                } else {
                        fseek($fd, -1, SEEK_CUR);
                        while(($char = fread($fd, 1)) != chr(0))
                                $ipAddr1 .= $char;

                        $ipFlag = fread($fd, 1);
                        if($ipFlag == chr(2)) {
                                $AddrSeek2 = fread($fd, 3);
                                if(strlen($AddrSeek2) < 3) {
                                        fclose($fd);
                                        return 'System Error';
                                }
                                $AddrSeek2 = implode('', unpack('L', $AddrSeek2.chr(0)));
                                fseek($fd, $AddrSeek2);
                        } else {
                                fseek($fd, -1, SEEK_CUR);
                        }
                        while(($char = fread($fd, 1)) != chr(0))
                                $ipAddr2 .= $char;
                }
                fclose($fd);

                if(preg_match('/http/i', $ipAddr2)) {
                        $ipAddr2 = '';
                }

                $ipaddr = "$ipAddr1 $ipAddr2";
                $ipaddr = preg_replace('/CZ88\.NET/is', '', $ipaddr);
                $ipaddr = preg_replace('/^\s*/is', '', $ipaddr);
                $ipaddr = preg_replace('/\s*$/is', '', $ipaddr);
                if(preg_match('/http/i', $ipaddr) || $ipaddr == '') {
                        $ipaddr = 'Unknown';
                }

                return $ipaddr;
        }
}

function _Cv_Get_Ip()
{
        $_IpArray = array($_SERVER['HTTP_X_FORWARDED_FOR'], $_SERVER['HTTP_CLIENT_IP'], $_SERVER['REMOTE_ADDR'], getenv('REMOTE_ADDR'));
        rsort($_IpArray);
        reset($_IpArray);
        return $_IpArray[0];
}


function bug(&$params,$die=false){
	echo "<pre>";
	var_export($params);
	echo "</pre>";
	$die and die();
}


function renderPageIndicator($linker='',$curPage=1,$totalLenth=1,$perLength=1,$otherQueryAry='',$page=''){
	$count = ceil($totalLenth/$perLength);
	$idx = 1;
	$query = array();
	foreach ($otherQueryAry as $k=>$v){
		$query[] = "$k=$v";
	}
	$query = implode('&', $query);
	
	
	$pager = "<span class='pagination'> &nbsp;&nbsp;[<a href='{$linker}?{$query}&{$page}=1'>首页</a>]&nbsp;&nbsp;";
	while($idx < $count+1){
		if ($curPage == $idx){
			$pager .= "&nbsp;<a color='red'>$idx</a>&nbsp;";
		}else{
			$pager .= "&nbsp;[<a href='$linker?$query&$page=$idx'>$idx</a>]&nbsp;";
		}
	//	$pager .= "&nbsp;&nbsp;&nbsp;&nbsp;";
		$idx++;
	}
	$pager .= "&nbsp;&nbsp;[<a href='{$linker}?{$query}&{$page}=$count'>末页</a>]&nbsp;&nbsp;</span>";
	return $pager;
}


/**
 * 设置最大显示高度,给定数组和数值,返回改数组,其中basePix为高度表示
 * e.g generatePixHeightOfEachElement(array(array('weight'=>5,'text'=>'text'),array('weight'=>10,'text'=>'text')),200,'weight');
 * 返回索引为height
 */
function generatePixHeightOfEachElement(&$ary,$basePix,$index=fasle){
	if ($index){
		$max = 0;
		foreach($ary as $item){
			$max = max($max,$item[$index]);
		}
		foreach ($ary as &$item){
			$item['height'] = intval($basePix*$item[$index]/$max);
		}
		return $ary;
		
	}else{
		$max = max($ary);
		foreach ($ary as &$item){
			$num = $item;
			$item = array();
			$item['height'] = intval($num*$basePix/$max);
			$item['num'] = $num; 
		}
		return $ary;
	}
} 


/**
	 * 输出测试信息
	 * 最低 级别
	 */
	function _test($mixdata, $filename = null, $trace = false) {
		$level = 6;
		$header = "TEST REPORT";
		debug_ouput($mixdata, $filename, $level, $header, $trace);
	}
	/**
	 * 输出测试信息
	 * 调试 级别
	 */
	function _debug($mixdata, $filename = null, $trace = false) {
		$level = 5;
		$header = "DEBUG REPORT";
		debug_ouput($mixdata, $filename, $level, $header, $trace);
	}
	/**
	 * 输出测试信息
	 * 程序信息 级别
	 */
	function _info($mixdata, $filename = null, $trace = false) {
		$level = 4;
		$header = "INFO REPORT";
		debug_ouput($mixdata, $filename, $level, $header, $trace);
	}
	/**
	 * 输出测试信息
	 * 警告 级别
	 */
	function _warning($mixdata, $filename = null, $trace = true) {
		$level = 3;
		$header = "WARNING REPORT";
		debug_ouput($mixdata, $filename, $level, $header, $trace);
	}
	/**
	 * 输出测试信息
	 * 错误 级别
	 */
	function _error($mixdata, $filename = null, $trace = true) {
		$level = 2;
		$header = "ERROR REPORT";
		debug_ouput($mixdata, $filename, $level, $header, $trace);
	}
	/**
	 * 输出测试信息
	 * 严重错误 级别
	 */
	function _critical($mixdata, $filename=null, $trace = true) {
		$level = 1;
		$header = "CRITICAL ERROR REPORT";
		debug_ouput($mixdata, $filename, $level, $header, $trace);
	}
	/**
	 * 输出测试信息
	 * 调试 级别
	 */
	function debug($mixdata, $filename = null, $trace = false) {
		
		_debug($mixdata, $filename, $trace);
	}
	/**
	 * 输出一个指定级别的DEBUG日志信息
	 */
	function debug_ouput($mixed, $filename, $level, $header, $trace = true) {
		
		if (!defined("MING2_DEBUG"))  //不写测试信息
			return;
		if (intval(MING2_DEBUG) < $level)	//级别高则优先级低
			return;

			
		if (!$filename) {
			if(!defined("SYSDIR_LOG"))
				$filename = "/data/logs/www_debug.log";
			else
				$filename = SYSDIR_LOG . "/www_debug.log";
		}
		

		if (is_string($mixed))
			$text = $mixed;
		else
			$text = var_export($mixed, true);

		$trace_list = "";
		if($trace) {
			$_t = debug_backtrace();
			$trace_list = "-- TRACE : \r\n";
			if(DEBUG_FULL_BACKTRACE === true) {
				$trace_list .= var_export($_t, true);
			} else {
				foreach($_t as $_line) {
					$trace_list .= "-- " . $_line['file'] . "[" . $_line['line'] . "] : " .  $_line['function'] . "()" . "\r\n";
				}
			}
		}

		$text = "\r\n=". $header . "==== " . strftime ("[%Y-%m-%d %H:%M:%S] "). time() . " ===\r\n<" . getmypid() . "> : " . $text . "\r\n" . $trace_list;

		$h = fopen($filename ,'a');
		if (!$h) throw new exception('Could not open logfile:'.$filename);

		// exclusive lock, will get released when the file is closed
		if ( ! flock($h,LOCK_EX) )
			return false;

		if (fwrite($h,$text)===false) {
			throw new exception('Could not write to logfile:'.$filename);
		}
		flock($h, LOCK_UN);

		fclose($h);
	}
	
	
/*
 * 将秒数，转换成中文表达方法，比如： 2分14秒，  3小时5分56秒
 */
function ConvertSecondToChinese($time)
{
	if ($time<=60)
		return $time.'秒';
	else if ($time<=3600)
		return floor($time/60).'分'. ($time % 60) . '秒';
	else if ($time<=86400)
		return floor($time/3600).'时'. floor(($time % 3600)/60). '分'. ($time % 60) . '秒';
	else
		return floor($time/86400).'天'. floor(($time % 86400)/3600). '时'. floor(($time % 3600)/60). '分'. ($time % 60) . '秒';
}


function getIpAddr($ip) {
        global $iplocation;
        if(!$iplocation) {
        	$iplocation = new IpLocation(SYSDIR_INCLUDE.'/QQWry.Dat');
        }
        $location = $iplocation->getlocation($ip);
        $addr = $location['country'] . $location['area'];
        return $addr; 
}


function get_real_ip(){  //获取客户IP地址
	$ip=false;
	if(!empty($_SERVER["HTTP_CLIENT_IP"])){
		$ip = $_SERVER["HTTP_CLIENT_IP"];
	}
	if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
		$ips = explode (", ", $_SERVER['HTTP_X_FORWARDED_FOR']);
		if ($ip){ 
			array_unshift($ips, $ip); $ip = FALSE; 
		}
			for ($i = 0; $i < count($ips); $i++) {
				if (!eregi ("^(10|172.16|192.168).", $ips[$i])) {
					$ip = $ips[$i];
					break;
				}
			}
	}
	return ($ip ? $ip : $_SERVER['REMOTE_ADDR']);
}

//1.电信,2.教育网,3.联通,4。其他
function get_user_isp($ip) {
	$ip = get_real_ip();
	$arr = GetIPaddr($ip);
	$true_arr = iconv("gb2312","utf-8",$arr);
	if (strpos($true_arr, '电信通') !== false) {
		return 0;
	} else if (strpos($true_arr, '电信') !== false) {
		return 1;
	} else if (strpos($true_arr, '联通') !== false) {
		return 3;
	} else if (strpos($true_arr, '教育网') !== false) {
		return 2;
	} else if (strpos($true_arr, '长城') !== false) {
		return 5;
	} else if (strpos($true_arr, '移动') !== false) {
		return 6;
	} else if (strpos($true_arr, '铁通') !== false) {
		return 7;
	} else {
		return 4;
	}
}


/**
 * 是否指定小时 11-12-16 12:08:08 true
 * @param $timeStr
 */
function ifHourSpecified($timeStr){
	if(strpos($timeStr, ':') === FALSE){
		return false;
	}
	return true;
}

/**
 * 
 * 最为通用的时间转换,开始时间为0点,默认为今日0点,结束时间为24点,指定了小时的话则为所指定的具体时间
 * @param unknown_type $startStr
 * @param unknown_type $endStr
 */
function sanitizeTimeSpan($startStr,$endStr=0){
	$start = strtotime($startStr) or $start = GetTime_Today0();
	if(ifHourSpecified($endStr)){
		$end = strtotime($endStr);
	}else{
		$end = strtotime($endStr) or $end = GetTime_Today0();
		$end+=24*60*60-1;
	}
	return array($start,$end);
}



/**
 * 
 * return true if weekend
 * @param $stamp
 */
function judgeIfWeekend($stamp){
	$noOfWeek = date('w',$stamp);
	return $noOfWeek < 1; 
}

/**
 * 生成一个随机的角色名
 * @param $sex
 */
function gene_unique_name($sex) {
	global $db;
	$i = 10;
	while ($i) {
		$i--;
		$name = get_name($sex);
		$result = GFetchRowOne("select 1 from t_role_create_after where role_name = '$name'");
		if (count($result) > 0 ) {
			// 继续
		} else {
			return $name;
		}
	}
	return null;
}

function get_name($sex) {
	global $FIRST_NAME, $SEND_MAN_NAME_1, $SEND_MAN_NAME_2, $SEND_WOMEN_NAME_1, $SEND_WOMEN_NAME_2;
	$randomKey = array_rand($FIRST_NAME, 1);
	$firstName = $FIRST_NAME[$randomKey];
	if ($sex == 1) {
		return $firstName.$SEND_MAN_NAME_1[array_rand($SEND_MAN_NAME_1, 1)] . $SEND_MAN_NAME_2[array_rand($SEND_MAN_NAME_2, 1)];
	} else {
		return $firstName.$SEND_WOMEN_NAME_1[array_rand($SEND_WOMEN_NAME_1, 1)] . $SEND_WOMEN_NAME_2[array_rand($SEND_WOMEN_NAME_2, 1)];
	}
}


/**
 * usage:	
 * select count(role_id),(mtime+timeDiff())/86400 as day from group by day
 * 为了避免
 * @throws exception
 */
function timeDiff(){
	return  -strtotime('1970-01-01 00:00:00');
}


/**
 * 主要用于生成按钮上的今天,前一天天,下一天所对应的Y-m-d
 * @param $base (Y-m-d) default:today
 * @param $shiftDay(-1,昨天,1,下一天)
 * @usage timeShift(-1) timeShift(1,'2011-12-16'),timeShift()
 */
function timeShift($shiftDay=0,$base=0){
	if ($base == 0){
		$base = GetTime_Today0()+2;
	}else{
		$base = strtotime($base);
	}
	 $stamp = $base+$shiftDay*24*60*60;
	 return date('Y-m-d',$stamp);
}

function getToGameURL()
{
	if (AGENT_NAME == '4399') {
		// http://web.4399.com/stat/togame.php?target=mccq&server_id=S1
		$toGameUrl = TO_GAME_URL . "?target=" . GAME_NAME . "&server_id=" . SERVER_NAME;
	} else if (AGENT_NAME == '91wan') {
		// http://www.2918.com/index.php?act=gamelogin&game_id=7&server_id=1
		$toGameUrl = TO_GAME_URL . "&server_id=" . SERVER_NAME;
	} else if (AGENT_NAME == '2918') {
		// http://www.2918.com/index.php?act=gamelogin&game_id=7&server_id=1
		$toGameUrl = TO_GAME_URL . "&server_id=" . SERVER_NAME;
	} else {
		$toGameUrl = TO_GAME_URL . "?target=" . GAME_NAME . "&server_id=" . SERVER_NAME;
	}
	return $toGameUrl;
}


//======================start    充值相关接口函数====================
//======================liuwei   2011-6-29==========================
/**
 * 根据不同的代理，返回用户充值的链接
 * @param $roleName
 */
function getPayUrl($account_name,$true_arr){
	global $smarty;
	if (AGENT_NAME == "360") {    //360接口为qid=360用户id  加上 server_id=游戏分区
		$flag = 1;
		global $API_SECURITY_TICKET_PAY;
		$sign = md5($account_name.SERVER_NAME.$flag.$API_SECURITY_TICKET_PAY);
		$payUrl = str_replace(array('ACCNAME', 'SERVER_ID','SIGN'), array( $account_name, SERVER_NAME, $sign), PAY_URL);
		$payUrl2 = str_replace('|', '&', $payUrl);
	}else {
    	$payUrl = str_replace(array('GAME_NAME', 'SERVER_NAME', 'ACCNAME', 'SERVER_ID'), array(GAME_NAME, SERVER_NAME, $account_name, SERVER_ID), PAY_URL);
		$payUrl2 = str_replace('|', '&', $payUrl);
	}
	//是否屏蔽北京的IP：充值链接为空
	if (BAN_BEIJIN) {
        if(preg_match("/北京/",$true_arr2) || preg_match("/未知/",$true_arr)){
                $smarty->assign('payAPIUrl', '');
                $smarty->assign('payUrl2', '');
        } else {
                $smarty->assign('payAPIUrl', $payUrl);
                $smarty->assign('payUrl2', $payUrl2);
        }
	} else {
        $smarty->assign('payAPIUrl', $payUrl);
        $smarty->assign('payUrl2', $payUrl2);
}
}

function log_die($logid, $msg ,$check='false') {
		updatePayApiLog($logid, $check);// 充值详细日志	
		die($msg);	
}

function writePayApiLog($detail, $payto_user, $desc='') {
	global $db;
	$ins_ID = 0;
	try{
		$f['detail'] = SS($detail);
		$f['payto_user'] = SS($payto_user);
		$f['user_ip'] = GetPayIP();
		$f['desc'] = SS($desc);
		$f['mtime'] = time();
		$sql = makeInsertSqlFromArray($f, 't_log_pay_request');
		$db->query($sql);
		$ins_ID = $db->insertID();
	}
	catch(Exception $e){
		$ins_ID = 0;
	}
	
	return $ins_ID;
}

function updatePayApiLog($insertid  , $value) {
	global $db;
	if(intval($insertid) > 0){
		try{
			$f = array();
			$f['id'] = intval($insertid);
			$f['desc'] = SS($value);
			$sql = makeUpdateSqlFromArray($f, 't_log_pay_request','id');
			$db->query($sql);
		}
		catch(Exception $e){
		}
	}
}

function GetPayIP(){
	if(!empty($_SERVER["HTTP_CLIENT_IP"])) $cip = $_SERVER["HTTP_CLIENT_IP"];
	else if(!empty($_SERVER["HTTP_X_FORWARDED_FOR"])) $cip = $_SERVER["HTTP_X_FORWARDED_FOR"];
	else if(!empty($_SERVER["REMOTE_ADDR"])) $cip = $_SERVER["REMOTE_ADDR"];
	else $cip = "";
	return $cip;
}

/**
 * -- 充值请求详细日志表：
 *
CREATE TABLE `t_log_pay_request` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `payto_user` varchar(100) NOT NULL default '' COMMENT '充值用户名',
  `user_ip` varchar(30) NOT NULL default '' COMMENT '玩家IP',
  `detail` varchar(500) NOT NULL default '' COMMENT '参数内容',
  `desc` varchar(300) NOT NULL default '' COMMENT '备注',
  `mtime` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `payto_user` (`payto_user`),
  KEY `user_ip` (`user_ip`),
  KEY `desc` (`desc`),
  KEY `mtime` (`mtime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='充值请求详细日志表';
 */
//======================end    充值相关接口函数====================