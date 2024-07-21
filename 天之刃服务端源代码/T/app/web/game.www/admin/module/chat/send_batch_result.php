<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);
include_once SYSDIR_ADMIN . "/include/dict.php";

$sqlSendResult = "SELECT id,all_count,fail_count,log_time,title,letter_type,time_spend FROM t_send_batch_result ORDER BY log_time DESC;";
	$sendResult = GFetchRowSet($sqlSendResult);
	if(count($sendResult)>0)
	{
		foreach($sendResult as $key => $sr)
		{
			
			if (0==$sr['fail_count']&&0!=$sr['all_count'])
				$sr['result']="全部成功";
			else if($sr['fail_count']<$sr['all_count'])
				$sr['result']="部分成功";
			else
				$sr['result']="全部失败";
			
			$sr['log_time']=date("Y-m-d H:i:s",$sr['log_time']);
			
			$sendResult[$key]=$sr;
		}
	}
	
	$data = array('sendResult'=>$sendResult);
	$smarty->assign($data);
	$smarty->display( 'module/chat/send_batch_result.tpl' );
?>