<?php
define('GAME_NAME', 'tzr');
define('AGENT_ID', 1);
define('AGENT_NAME', 'mc');
define('SERVER_ID', 1);
define('SERVER_NAME', 'S1');

//设定开服日期
define('SERVER_ONLINE_DATE', '2011-06-28');

//设定DEBUG日志级别
define('MING2_DEBUG',2);
define('SYSDIR_LOG',"/data/logs/");


//t_config 配置中的参数值
//参数名 => 值
global $CONFIG_PARAMS;
$CONFIG_PARAMS = array();

$CONFIG_PARAMS['GAME_NAME'] = GAME_NAME;
$CONFIG_PARAMS['AGENT_ID'] = AGENT_ID;
$CONFIG_PARAMS['AGENT_NAME'] = AGENT_NAME;
$CONFIG_PARAMS['SERVER_ID'] = SERVER_ID;
$CONFIG_PARAMS['SERVER_NAME'] = SERVER_NAME;
$CONFIG_PARAMS['ACCNAME'] = '账号名';
