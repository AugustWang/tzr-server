<?php
/**
 * 战斗结果测试辅助工具
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php"; 
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth,$smarty;
$auth->assertModuleAccess(__FILE__);

$action = SS(trim($_POST['action']));
$role_a = array();
$role_b = array();
$role_a = init_role_parameter('a');
$role_b = init_role_parameter('b');
$fight_times=0;
$fight_result = array();
$a_win=0;
$b_win=0;
if($action=='fight')
{
	
	$role_a = get_role_parameter('a');
	$role_b = get_role_parameter('b');
	$fight_times = intval($_POST['fight_times']);
	$first_hand =intval($_POST['first_hand']);
	if($fight_times>0)
	{
		$fight_result = do_fight($role_a,$role_b,$fight_times,$first_hand);
		for($i=0;$i<$fight_times;$i++){
			if($fight_result[$i]['winner']=='a'){
				$a_win++;
			}else{
				$b_win++;
			}
		}
	}
}


$smarty->assign('role_a',$role_a);
$smarty->assign('role_b',$role_b);
$smarty->assign('a_win',$a_win);
$smarty->assign('b_win',$b_win);
$smarty->assign('fight_times',$fight_times);
$smarty->assign('fight_result',$fight_result);
$smarty->display("module/test/test_fight.tpl");

/////////////////////////////////////////////////////////////////////////

function init_role_parameter($role_key)
{
	$role = array();
	$role['name'] = $role_key;
	$role['max_attack'] = 10;   //攻击
	$role['min_attack'] = 10;   //攻击
	$role['defence'] = 1;   //防御
	$role['hp'] = 20;
	$role['hit_target'] = 5000;
	$role['dodge'] = 5000;
	$role['double'] = 5000;
	$role['ignore_defence'] = 5000;
	$role['reduce_harm'] = 5000;
	$role['lucky'] = 5000;
	$role['attack_speed'] = 5000;
	return $role;

}

function get_role_parameter($role_key)
{
	$role = array();
	$max_attack=  intval($_POST[$role_key.'_max_attack']);
	$min_attack=  intval($_POST[$role_key.'_min_attack']);
	$defence=  intval($_POST[$role_key.'_defence']);
	$hp=  intval($_POST[$role_key.'_hp']);
	$hit_target=  intval($_POST[$role_key.'_hit_target']);
	$dodge=  intval($_POST[$role_key.'_dodge']);
	$double=  intval($_POST[$role_key.'_double']);
	$ignore_defence=  intval($_POST[$role_key.'_ignore_defence']);
	$reduce_harm=  intval($_POST[$role_key.'_reduce_harm']);
	$lucky=  intval($_POST[$role_key.'_lucky']);
	$attack_speed=  intval($_POST[$role_key.'_attack_speed']);
	
	$role['name'] = $role_key;
	$role['max_attack'] = $max_attack >1?$max_attack:1;
	//最小攻击小于等于最大攻击
	$role['min_attack'] = $min_attack >1?$min_attack:1;
	$role['min_attack'] = $role['max_attack']>=$role['min_attack']?$role['min_attack']:$role['max_attack'];
	$role['defence'] = $defence >1?$defence:1;
	$role['hp'] = $hp >1?$hp:1;
	$role['hit_target'] = $hit_target >1?$hit_target:1;
	//限制闪避值
	$role['dodge'] = $dodge >0?$dodge:0;
	$role['dodge'] = $role['dodge']>10000?10000:$role['dodge'];
	$role['double'] = $double >0?$double:0;
	$role['ignore_defence'] = $ignore_defence >0?$ignore_defence:0;
	//限制伤害减免
	$role['reduce_harm'] = $reduce_harm >0?$reduce_harm:0;
	$role['reduce_harm'] = $role['reduce_harm']>9999?9999:$role['reduce_harm'];
	$role['lucky'] = $lucky >0?$lucky:0;
	$role['attack_speed'] = $attack_speed >1?$attack_speed:1;
	//计算攻击时间间隔
	$attack_space_time = round(1360/($role['attack_speed']/1000));
	$role['attack_space_time'] = $attack_space_time<500?500:$attack_space_time;
	//攻击花费的时间
	$role['spend_times']=0;
	return $role;
}

function do_fight($role_a,$role_b,$fight_times,$first_hand)
{
	$fight_result=array();
	for($i=0;$i<$fight_times;$i++){
		if($first_hand==2){
			$_first_hand=rand(0,1);
		}
		$fight_result[] = round_fight($role_a,$role_b,$_first_hand);
	}
	return $fight_result;
}	
//一次战斗
function round_fight($role_a,$role_b,$first_hand)
{
	$fight_role='b'; //记录攻击的人是谁
	$round_record = array();
	if($first_hand==0){
		$round_record[] = one_fight($role_a,$role_b);
		$fight_role='a';
	}else{
		$round_record[] = one_fight($role_b,$role_a);
		$fight_role='b';
	}
	while($role_a['hp']>0 and $role_b['hp']>0){
		if($role_a['spend_times']>$role_b['spend_times']){
			$round_record[] = one_fight($role_b,$role_a);
			$fight_role = 'b';
		}else if($role_a['spend_times']<$role_b['spend_times']){
			$round_record[] = one_fight($role_a,$role_b);
			$fight_role = 'a';
		}else if($role_a['spend_times']==$role_b['spend_times']){
			if($fight_role =='a'){
				$round_record[] = one_fight($role_b,$role_a);
				$fight_role = 'b';
			}else if($fight_role =='b'){
				$round_record[] = one_fight($role_a,$role_b);
				$fight_role = 'a';
			}
		}
	}
	$result['winner']='';
	if($role_a['hp']>0){	
		$result['winner']='a';
	}else if($role_a['hp']>0){
		$result['winner']='b';
	}
	$result['record']=$round_record;
	return $result;
}

//一次攻击
//计算攻击力
//1.命中计算
//2.幸运值计算
//3.重击计算
//4.破甲计算
//5.伤害减免计算
function one_fight(&$role_a,&$role_b){
	$result=$role_a['name']."对".$role_b['name']."发起攻击，";
	//命中计算
	$A = rand(1,10000);
	$B = max(100,$role_b['dodge']-$role_b['hit_target']);
	
	if($A>$B){//闪避失败
		//幸运计算
		$lucky_value =rand(1,100)+$role_a['lucky'];
		//攻击力计算
		if($lucky_value>100){
			$attack_value=$role_a['max_attack'];
		}else if($lucky_value<1){
			$attack_value=$role_a['min_attack'];
		}else{
			$attack_value=rand($role_a['min_attack'],$role_b['max_attack']);
		}
		//重击计算
		$A = rand(1,10000);
		if($A<$role_a['double']){
			$result.=$role_a['name']."触发了暴击，";
			$attack_value=2*$attack_value;
		}
		//破甲计算
		$A = rand(1,10000);
		if($A<$role_a['ignore_defence']){//破甲成功
			$result.=$role_a['name']."破甲成功，";
			$attack_value = ($attack_value-$role_b['defence'])+$attack_value*rand(5,7)/100;	
		}else{//破甲失败
			$attack_value = $attack_value*($attack_value/$role_b['defence'])*rand(5,7)/100;
		}
		//伤害减免计算
		$reduce_harm_value = $role_b['reduce_harm']/10000;
		$attack_value = ceil((1-$role_b['reduce_harm']/10000)*$attack_value);
		
		$attack_value = $attack_value>$role_b['hp']?$role_b['hp']:$attack_value;
		$role_b['hp']=$role_b['hp']-$attack_value;
		$result.=$role_b['name']."掉了".$attack_value."点血量!";
	}
	else{//闪避成功
		$result.=$role_b['name']."闪避成功。";	
	}
	$role_a['spend_times']+=$role_a['attack_space_time'];
	return $result;
}

