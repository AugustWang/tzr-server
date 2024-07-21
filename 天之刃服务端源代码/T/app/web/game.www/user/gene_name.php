<?php
/**
 * 生成随机名字
 */

ob_start();
session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_INCLUDE."/global.php";
include_once SYSDIR_INCLUDE.'/name_data.php';

global $FIRST_NAME, $SECOND_NAME_MAN, $SECOND_NAME_WOMEN;

$sex = intval($_REQUEST['sex']);

$name =  gene_unique_name($sex);
if ($name == null) {
	echo 'error';
} else {
	echo 'ok#'.$name;
}
exit();
