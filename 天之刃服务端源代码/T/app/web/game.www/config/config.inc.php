<?php
define('DB_MING2_GAME','tzr_game');
define('DB_MING2_LOGS','tzr_logs');
define('DB_MING2_SLAVE','tzr_game_slave');
/////////////////////////////////////////////
//主数据库用于游戏持久化
global $dbConfig_game;
$dbConfig_game = array(
	'user' => 'tzr_game',
	'passwd' => 'T5BvbN8t8KSrMKuP',
	'host' => 'localhost',
	'dbname' => DB_MING2_GAME,
);

/////////////////////////////////////////////
//Slave机用于隔离来自平台的数据压力
global $dbConfig_slave;
$dbConfig_slave = array(
	'user' => 'tzr_game',
	'passwd' => 'T5BvbN8t8KSrMKuP',
	'host' => 'localhost',
	'dbname' => DB_MING2_SLAVE,
);