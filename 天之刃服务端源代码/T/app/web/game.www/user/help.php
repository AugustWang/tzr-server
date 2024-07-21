<?php
session_start();
define('IN_ODINXU_SYSTEM', true);
include_once "../config/config.php";
include_once SYSDIR_ROOT."/config/config.key.php";
include_once SYSDIR_INCLUDE."/global.php";
header("content-type:text/html; charset=utf-8");
header( "Pragma: public" );
header( "Expires: 0" ); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
$fileContent = "[{000214A0-0000-0000-C000-000000000046}]\r\nProp3=19,2\r\n[InternetShortcut]\r\nURL=".OFFICIAL_WEBSITE."\r\nIDList=\r\n";
$saveFileSize = strlen($fileContent);
Header("Accept-Length: ".$saveFileSize);
Header("Content-Disposition: attachment; filename=" . iconv("UTF-8","GB2312//TRANSLIT", urlencode(AGENT_NAME . "天之刃.url")));
// 输出文件内容
echo $fileContent;
exit;
