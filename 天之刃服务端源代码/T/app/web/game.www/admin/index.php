<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ADMIN."/include/global.php";
global $smarty;

$smarty->display("index.html");

