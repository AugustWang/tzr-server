<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth;
$auth->assertModuleAccess(__FILE__);


$action = trim($_GET['action']);
if ($action=='search') {
	$role = UserClass::getUser($_POST['role_name'],$_POST['account_name'],$_POST['role_id']);
	$bind = 1;
}

if ($action == 'do') {
	$bind = $_POST['bind'] ? 1 : 0;
	$bindTip = $bind ? '绑定的' : '不绑定的';
	$type = trim($_GET['type']);
	$role = $_POST['role'];
	$role_id = $role['role_id'];
	if (!$role_id) {
		$err[] = "请先搜索出要赠送的玩家" ;
	}
	$reason = trim ( $_POST ['reason'] );
	/*if (! validChinese ( $reason )) {
		$err[] = "赠送原因必须是纯中文" ;
	}*/	
	if ( 0== mb_strlen ( $reason )) {
		 $err[] = "请填写赠送原因" ;
	}
	$reason = base64_encode( base64_encode($reason) );
	if ($type == 'silver') {
		$number = intval ( $_POST ['ding'] )*100*100 + intval ( $_POST ['liang'] )*100 + intval ( $_POST ['wen'] );
		$wen = $number;
		$ding = intval($wen/10000) ; //10000文 = 1锭
		$wen -=  $ding * 10000; 
		$liang = intval( $wen/100 ); //100文 = 1两
		$wen -=  $liang * 100;
	}else {
		$number = intval ( $_POST ['number'] );
	}
	//添加日志
	$loger = new AdminLogClass();
	if (empty($err)) {
		if ($type == 'gold') {
			//赠送元宝
			$result = getJson(ERLANG_WEB_URL . "/pay/send_gold/"
								."?reason={$reason}&role_id={$role_id}&"
								."number={$number}&bind={$bind}");
								
			if ($result['result'] == 'ok') {
				$msg = "成功赠送 {$number}个 {$bindTip} 元宝";
				$err[] = $msg;
				$loger->Log( AdminLogClass::TYPE_SEND_GOLD, $msg.'赠送原因：'.$_POST ['reason'], $number,'', $role['role_id'], $role['role_name']);
			} else {
				$err[] = "元宝赠送失败";
			}
		} else if ($type == 'item') {
			//赠送金砖
			$err[] = "功能尚未实现" ;
		} else if ($type == 'silver') {
			//赠送银两
			$result = getJson(ERLANG_WEB_URL . "/pay/send_silver/"
								."?reason={$reason}&role_id={$role_id}&"
								."number={$number}&bind={$bind}");
			if ($result['result'] == 'ok') {
				$msg = "成功赠送 {$ding}锭{$liang}两{$wen}文 {$bindTip} 银两";
				$err[] = $msg;
				$loger->Log( AdminLogClass::TYPE_SEND_SILVER , $msg, $number,'赠送原因：'.$_POST ['reason'], $role['role_id'], $role['role_name']);
			} else {
				$err[] = "银两赠送失败";
			}
		}
	}
}
if ( in_array($action,array('search','do')) && !intval($role['role_id']) ){ // 若已提交表单，且找不到玩家
	$err[] = '找不到此玩家';
}

$give_gold_reason = _getGiveGoldReason();                       
$give_jinzhuan_reason = _getGiveJinZhuanReason();               
$give_silver_reason = _getGiveSilverReason();                   

$data = array(
	'role'=>$role,
	'number'=>$number,
	'reason'=>$reason,
	'bind'=>$bind,
	'err' => empty($err) ? '' : implode('<br />',$err),
	'give_gold_reason'=>$give_gold_reason,             
 	'give_jinzhuan_reason'=>$give_jinzhuan_reason,     
 	'give_silver_reason'=>$give_silver_reason,         
);
$smarty->assign($data);
$smarty->display('module/pay/send_gold.html');

//////////////////////////////////////////////////
                                                                     
function _getGiveGoldReason(){                                       
        return array(                                                
                '1'=>'代理申请元宝',                                 
                '2'=>'内部申请元宝',                                 
                '3'=>'盗号的问题，补偿元宝',                         
                '4'=>'充值没有到账，补发元宝',                       
                '5'=>'帐号出现异常或BUG，跟元宝购买有关的补偿',      
                '6'=>'提交游戏建议，奖励元宝',                       
                '7'=>'提交游戏BUG，奖励元宝',                        
                '8'=>'配合GM测试，奖励元宝',                         
                '9'=>'测试需要元宝',                                 
        );                                                           
}                                                                    
function _getGiveJinZhuanReason(){                                   
        return array(                                                
                '1'=>'代理申请金砖',                                 
                '2'=>'内部申请金砖',                                 
                '3'=>'盗号的问题，补偿金砖',                         
                '4'=>'充值没有到账，补发金砖',                       
                '5'=>'帐号出现异常或BUG，跟金砖购买有关的补偿',      
                '6'=>'提交游戏建议，奖励金砖',                       
                '7'=>'提交游戏BUG，奖励金砖',                        
                '8'=>'配合GM测试，奖励金砖',                         
                '9'=>'测试需要金砖',                                 
        );                                                           
}                                                                    
function _getGiveSilverReason(){                                     
        return array(                                                
                '1'=>'代理申请银两',                                 
                '2'=>'内部申请银两',                                 
                '3'=>'盗号的问题，补偿银两',                         
                '4'=>'充值没有到账，补发银两',                       
                '5'=>'帐号出现异常或BUG，跟银两购买有关的补偿',      
                '6'=>'提交游戏建议，奖励银两',                       
                '7'=>'提交游戏BUG，奖励银两',                        
                '8'=>'配合GM测试，奖励银两',                         
                '9'=>'测试需要银两',                                 
        );             
}
?>                                              
