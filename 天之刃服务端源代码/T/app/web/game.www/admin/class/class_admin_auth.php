<?php

if ( !defined('IN_ODINXU_SYSTEM') )
{
	die("Hacking attempt");
}

if ( ! defined('ADMIN_AUTH_CLASS_DEFINE') )
{
	define('ADMIN_AUTH_CLASS_DEFINE', TRUE);


class AdminAuth
{
	public $username = '';
	public $userlevel = '0';
	public $userid = 0;
	public $power = array();
	public $itempower = '0';
	public $itemPowerArr = array();

	function AdminAuth()
	{
		$this->username = '';
		$this->userlevel = '0';
		$this->userid = 0;
		$this->power = array();
		$this->itempower = '0';
		$this->itemPowerArr = array();
		 
	}

	function CleanAuthInfo()
	{
		$_SESSION['admin_user'] = '';
		$_SESSION['admin_level'] = '';
		$_SESSION['admin_id'] = '';
		$_SESSION['admin_power'] = array();
		$_SESSION['itempower'] = '';
		$_SESSION['itemPowerArr'] = array();

		$this->username = '';
		$this->userlevel = '0';
		$this->userid = 0;
		$this->power = array();
		$this->itempower = '0';
		$this->itemPowerArr = array();
	}

	function Check($name, $pwd)
	{ 
		
	} 

	function HadLogined()
	{
		return true;
	} 
 
 

	/*
	 * 是否有该指定的权限
	 */
	public function checkPowerId($power_id)
	{
	    return true;
	}


	/*
	 * 检查当前用户，是否有某个脚本文件的访问权限。
	 */
	public function checkPhpScriptPower($php_script_filename, $if_false_then_die = true)
	{
		return true;
	}

}

}

?>
