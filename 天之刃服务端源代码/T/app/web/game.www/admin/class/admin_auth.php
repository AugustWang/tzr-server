<?php
if ( !defined('IN_ODINXU_SYSTEM') )
{
	die("Hacking attempt");
}

include_once dirname(__FILE__) . '/class_admin_auth.php';

//所有管理后面的页面，都必须 require_once 引用本页面 (admin_auth.php)
//进行用户登录检查，如果用户未登录，会自动跳回登录页面。
//用户名，等级，保存在全局变量 $ADMIN
$ADMIN = new AdminAuth();
if ( ! $ADMIN->HadLogined())
{
	MovePage(WEB_ADMINURL."login.php", false);
	
	exit;
}

if (!function_exists('error')){
    /**
     * 错误提示
     * @param string $msg
     */
    function error($msg)
    {
        global $smarty;
        $smarty->assign('msg', $msg);
        $smarty->display('admin/error.tpl');
        exit();
    }
    
    /**
     * 成功提示
     * @param string $msg
     */
    function msg($msg)
    {
        global $smarty;
        $smarty->assign('msg', $msg);
        $smarty->display('admin/msg.tpl');
        exit();
    }
}
