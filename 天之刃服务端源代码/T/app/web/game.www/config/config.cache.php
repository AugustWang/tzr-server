<?php
/////////////////////////////////////////////
//主数据库用于游戏持久化
global $cacheConfig;
$cacheConfig = array(
	'use_config' => 'memcache' ,
	'memcache'   => array(
	//	'type'     => 'file',
		'type'     => 'memcache',
		'server'   => array(
			array('host' =>'localhost', 'port' => '11211', 'weight' => '10')
		  	),
		'ttl'      => 3600,
		'compress' => true,
		),
);
