<?php 
if (!defined('IN_ODINXU_SYSTEM')) {
	exit('hack attemp!');
}

//管理后台的ROOT用户名和密码
define(ROOT_USERNAME, "root");
define(ROOT_PASSWORD, "123456");

//把后台切换的配置$ADMIN_SYS_QUANTITY开服总量，ADMIN_FLAG_KEY通信密钥，
//ADMIN_USE_URL后台在使用的域名,ADMIN_LOGIN_TIMEOUT后台登陆超时时间.
//注意，如果是debug模式，此处的超时设置无效。

//注意:: 外服需要修改为下面一行的定义，显示多个区服的跳转!!
//$ADMIN_SYS_QUANTITY = array(1,2);
$ADMIN_SYS_QUANTITY = array();

define(ADMIN_FLAG_KEY, "testtestkey");
define(ADMIN_LOGIN_TIMEOUT,1800);
define(ADMIN_URL_PREFIX, "s");
define(ADMIN_USE_URL, "mccq.test.com");

// 绑定hosts后的访问入口地址
define(ADMIN_GATEWAY_URL, "http://s1.56799.net/admin/");