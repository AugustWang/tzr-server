<?php
$curPwd = getcwd();
$appRoot = dirname($curPwd).'/';
chdir($appRoot);
$file = "hrl/server_map.xml";
if (!file_exists($file))
{
    print "文件{$appRoot}{$file}不存在";
    exit(1);
}
print "开始分析文件:{$appRoot}{$file} ... \r\n";
$xml = simplexml_load_file($file);

$mmArray = array();
$mmDefineArray = array();
$mmDefineArray2 = array();

$packages = $xml->package;
foreach($packages as $v)
{
    $modules = $v->module;
    foreach($modules as $m)
    {
        $a = $m->attributes();
        $name = (string)$a['name'];
        $id = intval($a['id']);
        $nameUp = strtoupper($name);
        $nameLower = strtolower($name);
        $mmArray[$nameLower] = $id;
        $mmDefineArray[$nameUp] = $id;
        $methods = $m->method;
        foreach($methods as $me)
        {
        	$mm = $me->attributes();
        	$nameM = (string)$mm['name'];
        	$idM = intval($mm['id']);
        	$nameMUP = strtoupper($nameM);
        	$nameMLower = strtolower($nameM);
        	$mmArray[$nameMLower] = $idM;
        	$mmDefineArray[$nameMUP] = $idM;
			$mmDefineArray2[$nameUp][] = $nameMUP;
        }
    }
}

$mmOutput = '[';
foreach($mmArray as $k=>$v)
{
    $mmOutput .= "{".$v.", ".$k."},\r\n";
}
$mmOutput = trim($mmOutput, ",\r\n");
$mmOutput .= "\r\n].";


$mmFileName = "config/mm_map.config";
@unlink($mmFileName);
file_put_contents($mmFileName, $mmOutput);

print "生成{$appRoot}{$mmFileName}成功 \r\n";

$mmDefineOutput = '';
foreach($mmDefineArray as $k=>$v)
{
    $mmDefineOutput .= "-define($k, $v).\r\n";
}
$mmDefineFileName = "hrl/mm_define.hrl";
@unlink($mmDefineFileName);
file_put_contents($mmDefineFileName, $mmDefineOutput);

print "生成{$appRoot}{$mmDefineFileName}成功\r\n";

$mmOutput = '-define(MM_PARSE_LIST, [';
foreach($mmArray as $k=>$v)
{
    $mmOutput .= "{".$v.", ".$k."},\r\n";
}
$mmOutput = trim($mmOutput, ",\r\n");
$mmOutput .= "\r\n]).";


$mmParseFileName = "hrl/mm_parse_list.hrl";
@unlink($mmParseFileName);
file_put_contents($mmParseFileName, $mmOutput);

$as3Code = <<<EOT
package com.net
{
	public class SocketCommand
	{	


EOT;
foreach($mmDefineArray2 as $module => $methodList){
	$as3Code .= "\n		//{$module}\n";
	foreach($methodList as $method){
		$as3Code .= '		public static const '.$method.':String = "'.$method.'";'."\n";
	}
}

$as3Code .= <<<EOT
		public function SocketCommand()
		{
			
		}
	}
}
EOT;
$as3CodeFile = "as3/SocketCommand.as";
@unlink($as3CodeFile);
file_put_contents($as3CodeFile, $as3Code);
print "生成{$appRoot}{$as3CodeFile}成功\r\n";
print "生成{$appRoot}{$mmParseFileName}成功 \r\n";

