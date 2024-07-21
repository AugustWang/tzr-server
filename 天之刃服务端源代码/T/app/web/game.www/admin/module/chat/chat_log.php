<?php
/*
 * 查看聊天日志
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);

$day = intval($_REQUEST['day']);
if ($day == 0)
{
	$viewTime = time();
}
else
{
	$viewTime = $day;
}

$channel = SS($_REQUEST['channel']);
if (empty($channel))
	$channel = 'channel_world';

echo_header( array( 'channel'=> $channel,
					'curDay' => $viewTime,
					'today'  => time(),
					'prevDay'=> ($viewTime -86400),
					'nextDay'=> ($viewTime +86400),
					) );
					
readChatAndShow( $channel, GetDayString($viewTime) );

echo_ender();

exit;
					
function echo_header($param)
{
	$URL_SELF = $_SERVER['PHP_SELF'];
	
	$arr_channel = array('channel_world'=>'世界', 
					'channel_faction_1'=>'云州', 'channel_faction_2'=>'沧州', 'channel_faction_3'=>'幽州');
	$channel_name = $arr_channel[$param['channel']];
	$c_w = ($param['channel'] == 'channel_world')?"selected":"";
	$c_2 = ($param['channel'] == 'channel_faction_1')?"selected":"";
	$c_3 = ($param['channel'] == 'channel_faction_2')?"selected":"";
	$c_4 = ($param['channel'] == 'channel_faction_3')?"selected":"";
	$cur_day_str = GetDayString($param['curDay']);
	
	
echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=\"UTF-8\" />
<title>
	查看聊天历史记录
</title>
<body style='background-color:#B4E097;'>
<div>
	<form name=\"myform\" method=\"post\" action=\"{$URL_SELF}\">
	查看频道
<select name=\"channel\">
	<option value=\"channel_world\" {$c_w}>世界</option>
	<option value=\"channel_faction_1\" {$c_2}>云州</option>
	<option value=\"channel_faction_2\" {$c_3}>沧州</option>
	<option value=\"channel_faction_3\" {$c_4}>幽州</option>
</select>
<input type='hidden' name='day' value=\"{$param['curDay']}\" />
<input type='submit' class='button' name='submit' value='切换频道' />


&nbsp;&nbsp;&nbsp;&nbsp
<input type='button' class='button' name='datePrev' value='今天' onclick=\"javascript:location.href='{$URL_SELF}?day={$param['today']}&channel={$param['channel']}';\">
&nbsp;&nbsp;&nbsp;
<input type='button' class='button' name='datePrev' value='前一天' onclick=\"javascript:location.href='{$URL_SELF}?day={$param['prevDay']}&channel={$param['channel']}';\">
&nbsp;&nbsp;&nbsp;
<input type='button' class='button' name='dateNext' value='后一天' onclick=\"javascript:location.href='{$URL_SELF}?day={$param['nextDay']}&channel={$param['channel']}';\">
&nbsp;&nbsp;&nbsp;
	</form>

	<br>
	当前查看 {$channel_name} 频道  {$cur_day_str} 的聊天记录&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	
</div>
<hr>
<div>
";

}

function echo_ender()
{
	echo "</div>\n</body>\n</html>\n";
}

function readChatAndShow($channel , $viewDay){
	if (!defined('CHAT_LOGS_DIR'))
	{
		echo "LOG_DIR ERROR.";
		return false;
	}
	
	if (empty($channel))
		$channel = 'channel_world';
	
	
	#设置聊天日志目录
	$allCount = 0;
	$logDirName = CHAT_LOGS_DIR . $viewDay . "/" . $channel . "/";
	if (!file_exists($logDirName)){
		echo "NOT $channel $viewDay chat log.";
		return false;
	}else{
		$files = scandir_recursive($logDirName) ;
        natsort( $files );
        
		foreach ($files as $key => $value){
			$fileName = $logDirName . $value;
			$allCount = $allCount + show_file($fileName);
		}
	}
	
	
	
	
	echo "<br>\n玩家总共发言次数：$allCount<br><br>以上内容，不包括系统通知消息、道具展示消息。\n";
	
	return true;
}

function show_file($fileName){
	if (!file_exists($fileName))
	{
		echo "NOT $channel $viewDay chat log.";
		return false;
	}
	
	$count = 0;
	$handle = @fopen($fileName, "r");
	if ($handle) {
		while (!feof($handle)) {
			$buffer = fgets($handle, 8192);
			
			if (substr($buffer, 0, 1) !== '[')
				continue;
			
			$pos = strpos($buffer, '    ');
			if ($pos === false)
				continue;
				
			
			$data = substr($buffer, $pos + 3);
			//$data = (array)json_decode($body);
			if (empty( $data ))
				continue;
			
			echo substr($buffer, 0, $pos), 
			'&nbsp;&nbsp;&nbsp;',
			$data, "<br>\n";
			
			$count ++;
		}
		fclose($handle);
	}
	return $count;
}

function scandir_recursive($path, $recursive = false){
	if (!is_dir($path)) return 0;
	$list=array();
	$directory = @opendir("$path"); // @-no error display
	while ($file= @readdir($directory)){
		if( $recursive == false){
			if (($file<>".")&&($file<>"..")){
				$list[] = $file;
			}
			continue;
		}else{
			if (($file<>".")&&($file<>"..")){  
				$f=$path."/".$file;
				$f=preg_replace('/(\/){2,}/','/',$f); //replace double slashes
				if(is_file($f)) $list[]=$f;             
				if(is_dir($f))
					$list = array_merge($list ,scandir_recursive($f, $recursive));   //RECURSIVE CALL                               
			}
		}
	}
	@closedir($directory);  
	return $list ;
}
