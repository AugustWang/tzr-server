<?php
header('Content-Type:text/html;charset=utf-8');

/**
* 定义数组
*/ 
$nodeList = array('mgeel', 'mgeed', 'mgeeb', 'mgeem', 'mgeew', 'mgeeg', 'mgeec', 'mgeeweb', 'mgees', 'manager');
$ebinRoot = array(
				'mgeel' => '/data/tzr/server/ebin/login',
				'mgeed' => '/data/tzr/server/ebin/db',
				'mgeeb' => '/data/tzr/server/ebin/behavior',
				'mgeem' => '/data/tzr/server/ebin/map',
				'mgeew' => '/data/tzr/server/ebin/world',
				'mgeeg' => '/data/tzr/server/ebin/gateway',
				'mgeec' => '/data/tzr/server/ebin/chat',
				'mgeeweb' => '/data/tzr/server/ebin/mgeeweb',
				'mgees' => '/data/tzr/server/ebin/security',
				'manager' => '/data/tzr/server/ebin/manager',
);

$configFile = '/data/tzr/server/setting/common.config';
$templateConfigFile = '/data/tzr/server/setting/common.config';
if(!file_exists($configFile)) {
	echo "文件/data/tzr/server/setting/common.config不存在，请检查";
	// 设置退出状态
	exit(1);
}

//$regPattern = "/{[\S\r\n\t ]*?}\./i";
//调用erlang来分析
$array = null;
$fileContent = file_get_contents($configFile);
//preg_match_all($regPattern, $fileContent, $array);

$gatewayConfigString = null;
$mapConfigString = null;

//$result = $array[0];

//最简单的过滤方式，简单粗暴但是管用，无需正则
$result = explode("}.", $fileContent);

foreach($result as $k=>$v) {
	// 过滤掉所有erlang注释
	$str = preg_replace("/%%[^\n\r]+/", "", $v);
	// 过滤掉所有空格换行
	$str = str_replace(array("\n", "\r", "\t", " "), "", $str);
	if (empty($str))
		$result[$k] = $str;
	else
		$result[$k] = $str . "}.";   //把因为explode函数而去掉的后缀重新加回。
}

foreach($result as $v) {
	if (strpos($v, "{gateway,") === 0) {
		$gatewayConfigString = $v;
	}
	if (strpos($v, "{map,") === 0) {
		$mapConfigString = $v;
	}
	if (strpos($v, "{master_host,") === 0) {
		$masterConfigString = $v;
	}
}
// "{gateway,[{"192.168.4.211","192.168.4.211",[443,8080]}]}."
//var_dump($result);
if (!$gatewayConfigString) {
	echo "网关配置有误，请检查";
	exit(2);
}
// "{map,[{"192.168.4.211",4}]}."
if (!$mapConfigString) {
	echo "地图配置有误，请检查";
	exit(3);
}

// "{master_host,"192.168.4.211"}."
if (!$masterConfigString) {
	echo "主节点配置有误，请检查";
	exit(3);
}

// -1 状态表示显示帮助
if ($argc < 2) {
	showHelp();
	exit(-1);
}

// 第二个参数是目标节点
$targetNode = strtolower($argv[2]);

// 第三个参数是指定服务器IP
$serverIpAddr = strtolower($argv[3]);

// 第一个参数是命令名称
$command = strtolower($argv[1]);

if (!in_array($targetNode, $nodeList)) {
	if (strpos($targetNode, "mgeeg_") === 0
		|| strpos($targetNode, "map_slave") === 0) {
		
	}else{
		echo '提示：节点名写错了，目前支持的有:\'mgeem,mgeew,mgeed,mgeec,mgeeg_443\'等'."\n";
		exit();
	}
}

$masterHost = getMasterHost();
if ($command == 'get_debug_command') {
	if ($targetNode == 'map') {
		echo make_debug_command($targetNode, $masterHost, getMapMasterHost(), getNodeEbinPath($targetNode), getCookie());
	} else if ( $serverIpAddr != '' && $serverIpAddr != null) {
		if( strpos($targetNode,"mgeeg") === 0 || strpos($targetNode,"map_slave") === 0  ){
			echo make_debug_command($targetNode, $serverIpAddr,$serverIpAddr, getNodeEbinPath($targetNode), getCookie());	
		}else{
			echo make_debug_command($targetNode, $masterHost, $masterHost, getNodeEbinPath($targetNode), getCookie());	
		}
	} else {
		echo make_debug_command($targetNode, $masterHost, $masterHost, getNodeEbinPath($targetNode), getCookie());
	}
} else if ($command == 'get_live_command') {
	if ($targetNode == 'mgeem') {
		echo make_map_live_command($targetNode, $masterHost, getMapMasterHost(), getNodeEbinPath($targetNode), getCookie());
	} else if ($targetNode == 'mgeeg') {
		echo make_live_command($targetNode."_".getGatewayMasterPort(), $masterHost, getGatewayMasterHost(), getNodeEbinPath($targetNode), getCookie());
	} else if ($targetNode == 'mgeeweb') {
		echo make_live_command($targetNode, $masterHost, $masterHost, getNodeEbinPath($targetNode), getCookie()). " -pa /data/tzr/server/ebin/chat/mod/ -pa /data/tzr/server/ebin/mochiweb/ -pa /data/tzr/server/ebin/chat ";
	} else {
		echo make_live_command($targetNode, $masterHost, $masterHost, getNodeEbinPath($targetNode), getCookie());
	}
} else if ($command == 'get_start_command') {
	if ($targetNode == 'mgeem') {
		echo make_map_start_command($targetNode, $targetNode, $masterHost, getMapMasterHost(), getNodeEbinPath($targetNode), getCookie());
	} else if ($targetNode == 'mgeeg') {
		echo "/data/tzr/server/mgectl manager start_gateway";
	} else if ($targetNode == 'mgeeweb') {
		echo make_start_command($targetNode."_".$masterHost, $targetNode, $masterHost, $masterHost, getNodeEbinPath($targetNode), getCookie()). " -pa /data/tzr/server/ebin/chat/mod/ -pa /data/tzr/server/ebin/mochiweb/ -pa /data/tzr/server/ebin/chat ";
	} else {
		echo make_start_command($targetNode, $targetNode, $masterHost, $masterHost, getNodeEbinPath($targetNode), getCookie());
	}
} else if ($command == 'get_stop_command') {
	$cookie = getCookie();
	if ($targetNode == 'mgeem') {
		echo make_stop_command($targetNode, $targetNode, $masterHost, getMapMasterHost(), getNodeEbinPath($targetNode), getCookie());
	} else if ($targetNode == 'mgeeg') {
		$command = "/usr/local/bin/erl -name ctl-{$targetNode}@{$masterHost} -setcookie {$cookie} -s mgeeg_ctl -noinput -hidden ";
		foreach(getNodeEbinPath($targetNode) as $v) {
			$command .= " -pa {$v}";
		}
		echo $command. " -extra {$targetNode}_".getGatewayMasterPort()."@{$masterHost} stop_all";
	} else if ($targetNode == 'manager') {
		$command = "/usr/local/bin/erl -name ctl-{$targetNode}@{$masterHost} -setcookie {$cookie} -s manager_ctl -noinput -hidden ";
		foreach(getNodeEbinPath($targetNode) as $v) {
			$command .= " -pa {$v}";
		}
		echo $command. " -extra {$targetNode}"."@{$masterHost} stop_all";
	} else {
		echo make_stop_command($targetNode, $targetNode, $masterHost, $masterHost, getNodeEbinPath($targetNode), getCookie());
	}
} else if ($command == 'backup') {
	$cookie = getCookie();
	$command = "/usr/local/bin/erl -name {$targetNode}_backup@{$masterHost} -noinput -detached -setcookie {$cookie} -hidden -smp disable ";
	$ebinArr = getNodeEbinPath($targetNode);
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	echo $command. " -s mgeed_ctl -extra {$targetNode}@{$masterHost} backup" ;
} else if ($command == 'start_gateway_distribution') {
	//  用于在A机分布式方式的启动网关，生成的命令行是不完整的，其他部分由shell组装，为什么这么干？ 仅仅因为方便
	$cookie = getCookie();
	$taskset = $argv[3];
	$host = $argv[4];
	$domain = $argv[5];
	$port = $argv[6];
	$dump = $argv[7];
	$ebinArr = getNodeEbinPath($targetNode);
	$command = "taskset -c {$taskset} /usr/local/bin/erl -name {$targetNode}_{$port}@{$host} +K true -smp disable  -env ERL_MAX_ETS_TABLES 500000  +P 250000 +h 10240 -detached -setcookie {$cookie} -noinput -s {$targetNode} -master_node manager@{$masterHost}  -env ERL_CRASH_DUMP {$dump}  -env ERL_MAX_PORTS 25000 ";
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	$command .= " -host {$domain} -port {$port} -pa /data/tzr/server/ebin/proto/ -pa /data/tzr/server/ebin/mochiweb/";
	echo $command;
} else if ($command == 'stop_gateway') {
	$cookie = getCookie();
	$command = "/usr/local/bin/erl -name {$targetNode}_stop_gateway@{$masterHost} -noinput -detached -setcookie {$cookie} -hidden -smp disable ";
	$ebinArr = getNodeEbinPath($targetNode);
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	echo $command. " -s manager_ctl -extra {$targetNode}@{$masterHost} stop_gateway";
} else if ($command == 'reload_config') {
	$configFile = $argv[3];
	$cookie = getCookie();
	$command = "/usr/local/bin/erl -name {$targetNode}_reload_config_{$configFile}@{$masterHost} -noinput -detached -setcookie {$cookie} -hidden -smp disable ";
	$ebinArr = getNodeEbinPath($targetNode);
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	echo $command. " -s manager_ctl -extra {$targetNode}@{$masterHost} reload_config {$configFile}" ;
} else if ($command == 'start_gateway') {
	$configFile = $argv[3];
	$cookie = getCookie();
	$command = "/usr/local/bin/erl -name {$targetNode}_start_gateway@{$masterHost} -noinput -detached -setcookie {$cookie} -hidden -smp disable ";
	$ebinArr = getNodeEbinPath($targetNode);
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	echo $command. " -s manager_ctl -extra {$targetNode}@{$masterHost} start_gateway" ;
} else if ($command == 'hot_update') {
	$configFile = $argv[3];
	$cookie = getCookie();
	$command = "/usr/local/bin/erl -name {$targetNode}_hot_update@{$masterHost} -noinput -detached -setcookie {$cookie} -hidden -smp disable ";
	$ebinArr = getNodeEbinPath($targetNode);
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	echo $command. " -s manager_ctl -extra {$targetNode}@{$masterHost} hot_update {$configFile}" ;
} else if ($command == 'mnesia_update') {
	$module = $argv[3];
	$method = $argv[4];
	$cookie = getCookie();
	$command = "/usr/local/bin/erl -name {$targetNode}_hot_update_{$module}_{$method}@{$masterHost} -noinput -setcookie {$cookie} -hidden -smp disable ";
	$ebinArr = getNodeEbinPath($targetNode);
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	echo $command. " -s mgeed_ctl -extra {$targetNode}@{$masterHost} mnesia_update {$module} {$method}" ;
}

echo "\n";
exit(0);


function getCookie()
{
	return "123456";
}

function getGatewayMasterHost()
{
	// "{gateway,[{"192.168.4.211","192.168.4.211",[443,8080]}]}."
	global $gatewayConfigString;
	// 正则匹配出第一个IP地址
	$p = "/((25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(25[0-5]|2[0-4]\d|1?\d?\d)/";
	$rtn = array();
	preg_match($p, $gatewayConfigString, $rtn);
	return $rtn[0];
}

function getGatewayMasterPort()
{
	// "{gateway,[{"192.168.4.211","192.168.4.211",[443,8080]}]}."
	global $gatewayConfigString;
	// 正则匹配出第一个IP地址
	$p = "/\[[\d,]+\]/";
	$rtn = array();
	preg_match($p, $gatewayConfigString, $rtn);
	preg_match("/[\d]+/", $rtn[0], $result);
	return $result[0];
}

/**
* 地图的主节点IP
*/
function getMapMasterHost()
{
	//"{map,[{"192.168.4.211",4}]}."
	global $mapConfigString;
	// 正则匹配出第一个IP地址
	$p = "/((25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(25[0-5]|2[0-4]\d|1?\d?\d)/";
	$rtn = array();
	preg_match($p, $mapConfigString, $rtn);
	return $rtn[0];
}

/**
* 生成DEBUG命令行
*/
function make_debug_command($targetNodeName, $masterHost, $nodeHost, $ebinArr, $cookie)
{
	$command = "/usr/local/bin/erl -name {$targetNodeName}_debug@{$masterHost} -setcookie {$cookie} -hidden -smp disable -remsh {$targetNodeName}@{$nodeHost}";
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	$command .= " -pa /data/tzr/server/ebin/update/";
	return $command;
}

/**
* 生成stop命令行
* 通过对应的*_ctl模块来停止
*/
function make_stop_command($targetNodeName, $startModule, $masterHost, $nodeHost, $ebinArr, $cookie)
{
	$command = "/usr/local/bin/erl -name ctl-{$targetNodeName}@{$masterHost} -setcookie {$cookie} -s {$startModule}_ctl -noinput -hidden -smp disable ";
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	return $command." -extra {$targetNodeName}@{$nodeHost} stop ";
}

/**
* 生成start命令行
*/
function make_start_command($targetNodeName, $startModule, $masterHost, $nodeHost, $ebinArr, $cookie)
{
	$command = "/usr/local/bin/erl -name {$targetNodeName}@{$masterHost} -detached -setcookie {$cookie} -noinput  -env ERL_MAX_ETS_TABLES 500000  +P 250000 +K true +h 10240 -smp disable -s {$startModule} -master_node manager@{$masterHost} ";
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	return $command;
}

/**
* 生成map start命令行
*/
function make_map_start_command($targetNodeName, $startModule, $masterHost, $nodeHost, $ebinArr, $cookie)
{
	$command = "/usr/local/bin/erl -name {$targetNodeName}@{$masterHost} -detached -setcookie {$cookie} -noinput  -env ERL_MAX_ETS_TABLES 500000  +P 250000 +h 10240 +K true -smp disable -slave_num 2 -master_host $masterHost -s mgeem_distribution do_start_master_independency -master_node manager@{$masterHost} ";
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	$command .= " -pa /data/tzr/server/ebin/gateway/ -pa /data/tzr/server/ebin/proto/";
	return $command;
}

/**
* 生成live命令行
*/
function make_live_command($targetNodeName, $masterHost, $nodeHost, $ebinArr, $cookie)
{
	$command = "/usr/local/bin/erl -name {$targetNodeName}@{$nodeHost} -setcookie {$cookie} -env ERL_MAX_ETS_TABLES 500000  +K true +P 250000 +h 10240 -smp disable -s $targetNodeName -master_node manager@{$masterHost} ";
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	return $command;
}

/**
* 生成map live命令行
*/
function make_map_live_command($targetNodeName, $masterHost, $nodeHost, $ebinArr, $cookie)
{
	$command = "/usr/local/bin/erl -name {$targetNodeName}@{$nodeHost} -setcookie {$cookie} -env ERL_MAX_ETS_TABLES 500000  +P 250000 +h 10240 -smp disable -slave_num 0 +K true -master_host $masterHost -s mgeem_distribution do_start_master_independency -master_node manager@{$masterHost} ";
	foreach($ebinArr as $v) {
		$command .= " -pa {$v}";
	}
	return $command;
}

// php host_info.php get_debug_command map
// php host_info.php get_start_command map
// php host_info.php get_live_command map

/**
* 获得节点的ebin目录
*/
function getNodeEbinPath($node) 
{
	global $ebinRoot;
	$root = $ebinRoot[$node];
	$baseEbinDirArray = getSubDir("/data/tzr/server/ebin/common");
	$dirArr = getSubDir($root);
	$arrTmp = array_merge($baseEbinDirArray, $dirArr);
	$arrTmp[] = "/data/tzr/server/ebin";
	$arrTmp[] = "/data/tzr/server/ebin/proto";
	$arrTmp[] = "/data/tzr/server/ebin/library";
	$arrTmp[] = "/data/tzr/server/ebin/config";
	if ($node == 'erlang_web') {
		$arrTmp[] = "/data/tzr/server/ebin/mochiweb";
	}
	return array_unique($arrTmp);
}

function getSubDir($root) 
{
	$arr=array($root); 
	if($dir_handle = opendir($root)){
        // 这里必须严格比较，因为返回的文件名可能是“0”   
        while(($file=readdir($dir_handle))!==false)   
        {   
			$tmp = realpath($root.'/'.$file);    
            if($file === '.' || $file === '..' || !is_dir($tmp)) {   
               continue;   
            }   
            $retArr = getSubDir($tmp);   
			$arr[] = $tmp;
            if(!empty($retArr))   
            {   
                $arr = array_merge($arr, $retArr);   
            }     
        }   
        closedir($dir_handle);
    }
	return array_unique($arr);
}

/**
* 获取主节点内网IP
*/
function getMasterHost() 
{
	global $masterConfigString;
	return str_replace(array('{master_host,"', '"}.'), "", $masterConfigString);
} 

/**
* 显示帮助
*/
function showHelp() 
{
	echo '语法：php host_info.php 命令 节点名称'."\n";
	echo '例如 php host_info.php get_debug_command login'."\n";
	echo "\n";
}
