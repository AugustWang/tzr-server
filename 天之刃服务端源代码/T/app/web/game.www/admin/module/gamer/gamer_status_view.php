<?php
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';

global $auth, $db, $smarty, $dictMapInfo, $dictWeaponType, $dictPkMode, $dictFaction, $dictBuffType;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN."/include/dict.php";
include_once SYSDIR_ADMIN."/dict/map_info.php";
include_once SYSDIR_ADMIN."/class/vip_class.php";
include_once SYSDIR_ADMIN."/class/admin_item_class.php";
include_once SYSDIR_ADMIN."/class/admin_family_class.php";
include_once SYSDIR_ADMIN."/dict/bufftype.php";

$role_id = intval( $_POST['uid'] );
if ($role_id < 1) {
    $role_id  = intval($_GET['uid']);
}   
$role_name = SS( $_POST['nickname'] );
$account_name = SS( $_POST['acname'] );
$action = trim($_POST['gamer_action']) ? trim($_POST['gamer_action']) : trim($_GET['gamer_action']);
$gamerUid = trim($_POST['gamer_uid']) ? trim($_POST['gamer_uid']) : trim($_GET['gamer_uid']);

if( $gamerUid ){
	$role_id = intval($gamerUid);
}
$isPost = intval( $_POST['isPost'] );
$where = '';
if ($role_id) {
	$where .= " AND role_id=".$role_id;
}else {
	$where.= $account_name ? " AND BINARY account_name='".$account_name."' ": '';
	$where.= $role_name ? " AND BINARY role_name='".$role_name."' ": '';
}
if (trim( $where )) {
	$sqlBase = " SELECT * FROM ".T_DB_ROLE_BASE_P." WHERE TRUE ".$where;
	$base = $db->fetchOne($sqlBase);
}else {
	$errMsg = '请输入查找条件!';
}

if ('sendReturnHome'==$action && $base['role_id']) {
	$result = getWebJson("/user?fun=kickReturnHome&arg={$base['role_id']}");
	if ('ok'==$result['result']) {
		$msg = '操作成功，玩家已经被送回新手村';
	}else {
		$msg = '操作成功，可能玩家已经下线';
	}
	$logger = new AdminLogClass();
	$logger->Log(AdminLogClass::TYPE_SEND_RETURN_PEACE_VILLAGE,'','','',$base['role_id'],$base['role_name']);
}else if ('tidyRoleGoods'==$action && $base['role_id']) {
	$result = getWebJson("/user?fun=tidyRoleGoods&arg={$base['role_id']}");
	if ('ok'==$result['result']) {
		$msg = '操作成功，玩家的背包数据已经被重新整理';
	}else {
		$msg = '操作失败，可能操作超时';
	}
	$logger = new AdminLogClass();
	$logger->Log(AdminLogClass::TYPE_SEND_RETURN_PEACE_VILLAGE,'','','',$base['role_id'],$base['role_name']);
}else if ('updateRoleMission'==$action && $base['role_id']) {
	$result = getWebJson("/user?fun=updateRoleMission&arg={$base['role_id']}");
	if ('ok'==$result['result']) {
		$msg = '操作成功，玩家的任务数据已经更新到前端';
	}else {
		$msg = '操作失败，可能操作超时';
	}
	$logger = new AdminLogClass();
	$logger->Log(AdminLogClass::TYPE_SEND_RETURN_PEACE_VILLAGE,'','','',$base['role_id'],$base['role_name']);	
}else if ('kick'==$action && $base['role_id']) {
	$result = getWebJson("/online?method=kick&roleid={$base['role_id']}");
	if ('ok'==$result['result']) {
		$msg = '玩家已经被踢下线，但要5分钟后才能改变状态';
	}else {
		$msg = '踢下线失败，可能玩家已经下线';
	}
	$logger = new AdminLogClass();
	$logger->Log(AdminLogClass::TYPE_KICK_USER,'','','',$base['role_id'],$base['role_name']);
} else if ('kickStall'==$action && $base['role_id']) {
	$result = getJson(ERLANG_WEB_URL."/account/kick_stall/{$base['role_id']}");
	$msg = $result['result'];
	if ('ok'==$result['result']) {
		$msg = '踢摊位下线成功';
	}else {
		$msg = '踢摊位下线失败，可能玩家已经撤摊';
	}
	
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_KICK_STALL,'','','',$base['role_id'],$base['role_name']);
} else if ($action == 'setConlogin' && $base['role_id']) {
	$day = intval($_REQUEST['day']);
	if ($day < 1) {
		$day = 1;
	}
	$result = getWebJson("/role/set_conlogin/?day={$day}&role_id={$base['role_id']}");
	if ($result['result'] == 'ok') {
		$msg = "设置连续登录天数成功，已设置为{$day}天";
	} else {
		$msg = "设置连续登录天数失败";
	}
	$smarty->assign('day', $day);
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_SET_CONLOGIN, $msg ,'','',$base['role_id'],$base['role_name']);
}else if($action == 'setActivePoint' && $base['role_id']){
	$ap = intval($_REQUEST['ap']);
	if ($ap < 1) {
		$ap = 1;
	}
	$result = getWebJson("/role/set_activepoint/?ap={$ap}&role_id={$base['role_id']}");
	if ($result['result'] == 'ok') {
		$msg = "设置玩家活跃度成功，已设置为{$ap}";
	} else {
		echo $result['result'];
		$msg = "设置玩家活跃度失败";
	}
	$smarty->assign('ap', $ap);
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_SET_CONLOGIN, $msg ,'','',$base['role_id'],$base['role_name']);	
} else if ($action == 'resetEnergy' && $base['role_id']) {
	$result = getJson(ERLANG_WEB_URL."/account/reset_energy/{$base['role_id']}");
	$msg = $result['result'];
	if ('ok' == $result['result']) {
		$msg = '重置精力值成功';
	} else {
		$msg = '重置精力值失败，角色不存在或已下线';
	}
	
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_RESET_ENERGY, '', '', '', $base['role_id'], $base['role_name']);
} else if ($action == 'skillReturnExp' && $base['role_id']) {
	$result = getJson(ERLANG_WEB_URL."/account/skill_return_exp/{$base['role_id']}");
	$msg = $result['result'];
	if ('ok' == $result['result']) {
		$msg = '技能返还经验成功';
	} else {
		$msg = '技能返还经验失败，角色不存在或已下线';
	}
	
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_SKILL_RETURN_EXP, '', '', '', $base['role_id'], $base['role_name']);
} else if($action == 'passFcm' && $base['role_id']) {
	$result = getJson(ERLANG_WEB_URL."/account/pass_fcm/?account={$base['account_name']}");
	$msg = $result['result'];
	if ('ok' == $result['result']) {
		$msg = '设置玩家通过防沉迷成功';
	} else {
		$msg = '设置玩家通过防沉迷失败，请联系开发';
	}
	
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_PASS_FCM, '', '', '', $base['role_id'], $base['role_name']);
} else if ($action == 'clearPersonYbc') {
	$result = getJson(ERLANG_WEB_URL."/role/clear_person_ybc/?role_id={$base['role_id']}");
	$msg = $result['result'];
	if ('ok' == $result['result']) {
		$msg = '清理玩家个人拉镖成功';
	} else {
		$msg = '清理玩家个人拉镖失败，请联系开发';
	}
	
	$loger = new AdminLogClass();
	$loger->Log(AdminLogClass::TYPE_CLEAR_PERSON_YBC, '', '', '', $base['role_id'], $base['role_name']);
} else if ($action == 'clearItemStallState') {
        $result = getJson(ERLANG_WEB_URL."/role/clear_item_stall_state/?role_id={$base['role_id']}");
        if ('ok' == $result['result']) {
                $msg = '清理道具摆摊状态异常成功';
        } else {
                $msg = '清理道具摆摊状态异常失败，请联系开发';
        }

        $loger = new AdminLogClass();
        $loger->Log(AdminLogClass::TYPE_CLEAR_ITEM_STALL_STATE, '', '', '', $base['role_id'], $base['role_name']);
} else if ($action == 'clearExchangeState') {
        $result = getJson(ERLANG_WEB_URL."/role/clear_exchange_state/?role_id={$base['role_id']}");
        if ('ok' == $result['result']) {
                $msg = '清理交易状态异常成功';
        } else {
                $msg = '清理交易状态异常失败，请联系开发';
        }

        $loger = new AdminLogClass();
        $loger->Log(AdminLogClass::TYPE_CLEAR_EXCHANGE_STATE, '', '', '', $base['role_id'], $base['role_name']);
}

if ($base['role_id']) {
	$strFcm = '';
	$sqlFcm = " SELECT `passed` FROM `db_fcm_data_p` WHERE `account`='{$account_name}' ";
	$rsFcm = GFetchRowOne($sqlFcm);
	$strFcm = 1==$rsFcm['passed'] ? '通过' : '未通过';
	$specialState =  getUserSpecialState($base['role_id']);	
	$sqlAttr = ' SELECT * FROM '.T_DB_ROLE_ATTR_P.' WHERE role_id='.$base['role_id'];
	$attr = $db->fetchOne($sqlAttr); 
	$lastLoginIP = GFetchRowOne("SELECT login_ip FROM t_log_login WHERE role_id = ".$base['role_id']);
	$attr['last_login_ip'] = $lastLoginIP['login_ip'];
	$sqlExt = ' SELECT * FROM '.T_DB_ROLE_EXT_P.' WHERE role_id='.$base['role_id'];
	$ext = $db->fetchOne($sqlExt);
	$sqlSkill = " SELECT SUM(`cur_level`) as `cur_level` FROM db_role_skill_p WHERE `role_id`={$base['role_id']} ";
	//$rsSkill = GFetchRowOne($sqlSkill);
	//$cur_skill_point = intval($rsSkill['cur_level']);
	$skin = UserClass::getUserSkin($base['role_id']);
	$goods = UserClass::getBagGoods($base['role_id']);
	if (!empty($skin)) {
		$allItems = AdminItemClass::getItemHash();
		$skin['weapon_name'] = $allItems[$skin['weapon']];
		$skin['clothes_name'] = $allItems[$skin['clothes']];
		$skin['assis_weapon_name'] = $allItems[$skin['assis_weapon']];
	}
	$stallGood = UserClass::getStallGoods($base['role_id']);
	$equipsOn = UserClass::getUserEquips($base['role_id']); //穿在身上的装备
	
	$duplicateGoodsList = getDuplicateGoodsList($goods,$stallGood,$equipsOn);
	$pos = UserClass::getRolePos($base['role_id']); //玩家位置信息
	if (!empty($pos['map_id'])) {
		$pos['map_name'] = $dictMapInfo[$pos['map_id']];
	}
	$fight = UserClass::getRoleFight($base['role_id']); //玩家战斗信息

	if ($base['family_id'] && $base['family_name']) {
		$family = AdminFamilyClass::getFamilyByFamilyName($base['family_name']);
		if (is_array($family['members'])) {
			foreach ($family['members'] as &$members) {
				if ($members['role_id']==$base['role_id']) {
					$family_title = $members['title'];
					break;
				}
			}
		}
	}
	$roleBase = UserClass::getRoleBase($base['role_id']); 
	$buffs=$roleBase['buffs'];//玩家BUFF信息
	if (is_array($buffs)) {
		foreach ($buffs as &$buff) {
			$buff['buff_name'] = $dictBuffType[$buff['buff_id']];
			$buff['start_time'] = date('Y-m-d H:i:s',$buff['start_time']);
			$buff['end_time'] = date('Y-m-d H:i:s',$buff['end_time']);
		}
	}
	
	$equips = array();//装备
	$stones = array();//宝石
	$general = array();//普通物品
	formatGoods($goods, 'bag', $equips, $stones, $general);
	formatGoods($stallGood, 'stall', $equips, $stones, $general);
	formatGoods($equipsOn, 'body', $equips, $stones, $general);

	// ========= start ===处理在线情况相关数据===========//
	$dateOneDayAgo = date('Ymd',strtotime('-1day'));
	$dateSixDayAgo = date('Ymd',strtotime('-6day'));
	$sqlOnlineHistory = "SELECT * FROM t_log_daily_online WHERE `role_id`={$base['role_id']} AND `mdate` BETWEEN {$dateSixDayAgo} AND {$dateOneDayAgo} ORDER BY `mdate` DESC ";
	$rsOnlineHistory = GFetchRowSet($sqlOnlineHistory);
	$sqlStatOnline = " SELECT * FROM t_stat_user_online WHERE `user_id`={$base['role_id']} ";
	$rsStatOnline = GFetchRowOne($sqlStatOnline);	
	$sqlNowOnline = " SELECT role_id FROM t_user_online WHERE `role_id`={$base['role_id']} ";
	$rsNowOnline = GFetchRowOne($sqlNowOnline);
	$isNowOnline = $rsNowOnline['role_id'] ? 1 : -1;
	
	$online = array();
	if ($rsStatOnline) {
		$total_live_time = getTimeStr($rsStatOnline['total_live_time']);
		$user_status = $rsStatOnline['last_record_time'] >= date('Ymd',strtotime('-3day')) && $rsStatOnline['avg_online_time'] >= 60 ? '活跃玩家' : '流失玩家';		
		$online['total_live_time'] = $total_live_time;
		$online['avg_online_time'] = getTimeStr(intval($rsStatOnline['avg_online_time']/7));
		$online['user_status'] = $user_status;
	}
	if (!empty($online)) {
		for ($i=1; $i<= 6; $i++){
			$online["total_live_time_{$i}"] = '0分钟';
			$mdate = date('Ymd',strtotime("-{$i}day"));
			foreach ($rsOnlineHistory as $key => $history) {
				if ($mdate == $history['mdate']) {
					$online["total_live_time_{$i}"] = getTimeStr($history['online_time']);
					unset($rsOnlineHistory[$key]);
					break;
				}
			}
		}
	}
	// ========= end ===处理在线情况相关数据===========//
	
	// ========= start ===处理充值情况相关数据===========//	
	$sqlPay = " SELECT SUM(`pay_money`) AS `total_pay`, SUM(`pay_gold`) AS `total_gold` FROM  db_pay_log_p WHERE `role_id`={$base['role_id']} ";
	$pay = GFetchRowOne($sqlPay);
	$pay['total_pay'] = round($pay['total_pay'],1);
	$pay['total_gold'] = intval($pay['total_gold']);
	// ========= end ===处理充值情况相关数据===========//

}else {
	$errMsg = '找不到此玩家';
}
// vip
$isVip="否";
$vipLevel = "0";
if($base['role_id']){
	$vip=VipClass::getVipInfo($base['role_id']);
	if(!empty($vip)){
		if($vip['end_time']>time())
		$isVip = "是";
		else
		$isVip= "否（过期）";
		$vipLevel = $vip['vip_level'];
	}
}

if($base){
	$arrStatus = array(0=>'正常', 1=>'死亡', 2=>'战斗', 3=>'交易', 4=>'打坐', 5=>'摆摊', 6=>'训练', 7=>'采集');
	$base['sex'] = 1== $base['sex'] ? '男' : '女'; //性别：1男，2女
	$base['status'] = $arrStatus[$base['status']];
	$base['_faction_name'] = $dictFaction[$base['faction_id']];
	$base['weapon_type'] = $dictWeaponType[$base['weapon_type']];
	$base['pk_mode_name'] = $dictPkMode[$base['pk_mode']];
}

if ($attr) {
	$attr['silver'] = silverUnitConvert($attr['silver']);
	$attr['silver_bind'] = silverUnitConvert($attr['silver_bind']);
	$attr['show_cloth'] = $attr['show_cloth'] ? '是' : '否';
	$attr['unbund']     = $attr['unbund'] ? '是' : '否';
	$five_ele_attr = array(''=>'无',1=>'金',2=>'木',3=>'水',4=>'火',5=>'土');
	$attr['_five_ele_attr_name']  = $five_ele_attr[ $attr['five_ele_attr'] ];
}

$isFcmPassed = UserClass::isFcmPassed($account_name)== '1';

$data = array(
	'isVip'=> $isVip,
	'vipLevel'=>$vipLevel,
	'isPost'=>$isPost,
	'base'=>$base,
	'attr'=>$attr,
	'ext' =>$ext,
	'buffs'=>$buffs,
	'uid' =>$role_id,
	'acname'=>$account_name,
	'nickname'=>$role_name,
	'family_title'=>$family_title,
	'skin' =>$skin,
	'equips'=>$equips,
	'stones'=>$stones,
	'general'=>$general,
	'online'=>$online,
	'pay' => $pay,
	'pos'=>$pos,
	'fight'=>$fight,
	'cur_skill_point'=>$cur_skill_point,
	'msg'=>$msg,
	'isNowOnline'=>$isNowOnline,
	'isFcmPassed'=>$isFcmPassed,
	's'=>$specialState,
	'strFcm'=>$strFcm,
);


$smarty->assign($data);
$smarty->display('module/gamer/gamer_status_view.tpl');

exit();
///////////////////

/**
 * 获取重复的物品ID列表
 */
function getDuplicateGoodsList($goods,$stallGood,$equipsOn){
	$idList = array();
	if (is_array($goods)) {
		foreach ($goods as & $g) {
			array_push($idList,$g['id']);
		}
	}
	if (is_array($stallGood)) {
		foreach ($stallGood as & $g) {
			array_push($idList,$g['id']);
		}
	}
	if (is_array($equipsOn)) {
		foreach ($equipsOn as & $g) {
			array_push($idList,$g['id']);
		}
	}
}

/**
 * 格式化物品信息
 *
 * @param array $goods
 * @param string $from : bag=背包, body=身上的, stall=摆难区
 * @param array $equips
 * @param array $stones
 * @param array $general
 */
function formatGoods($goods, $from, &$equips, &$stones, &$general)
{
	global $dictBagidName, $dictQualityType , $dictColor;
	
	if (is_array($goods) && !empty($goods)) {
		foreach ($goods as &$good) {
			$good['bind'] = $good['bind'] ? '是' : '否'; 
			$good['_period'] = $good['start_time'] && $good['end_time'] ? date('Y-m-d H:i:s',intval($good['start_time'])).' -- '. date('Y-m-d H:i:s',intval($good['end_time'])) : '无限制';
			$good['_current_colour_name'] = $dictColor[$good['current_colour']];
			$good['_bagid_name'] = 'stall' == $from ? '摆摊区' : $dictBagidName[$good['bagid']] ;
			if (3==$good['type']) { //装备
				$good['name'] = $dictQualityType[$good['quality']] .'的'.$good['name'];
				$good['wearing'] = 0 == $good['bagposition'] ? '是':'否' ;
				$reinforce = $good['reinforce_result'];
				$good['reinforce_result'] = intval(substr($reinforce,0,1)).'级'.intval(substr($reinforce,1,1)).'星';
				$good['stone_num'] = intval($good['stone_num']);
				$good['punch_num'] = intval($good['punch_num']);
				$strStones = '';
				if (is_array($good['stones'])) {
					foreach ($good['stones'] as $stone) {
						$strStones .= $stone['name'].'<br />';
					}
				}
				$good['stones'] = $strStones;
				array_push($equips,$good);
			}elseif (2== $good['type'] && 0 == $good['embe_pos'] ){//宝石
				array_push($stones,$good);
			}elseif(1==$good['type']) {//普通物品
				array_push($general,$good);
			}
		}
	}	
}

function getTimeStr($minute)
{
	$hour = $minute >= 60 ? intval($minute/60) : 0;
	$minute = $minute%60;
	$str = $hour > 0 ? $hour.'小时' : '';
	$str .= $minute > 0 ? $minute.'分钟' : '';
	return $str ? $str : '0分钟';
}


function getUserSpecialState($roleId){
	$ary = getWebJson("/ybc/user_state/$roleId");
	if($ary['status'] == 'yes'){
		return normalizeAry($ary);
	}else{
		return $ary;	
	}
}

function  normalizeAry($ary){	
	$asso_ary = array(
		1=>'个人拉镖',
		3=>'组队拉镖',
		8=>'门派拉镖',
	);
	
	$co = array(
		0=>'否',
		1=>'是',
		'undefined'=>'否',
		'true'=>'是',
		'false'=>'否'
	);
	$ary['ybc'] = $asso_ary[$ary['ybc']] or $ary['ybc'] = '没有拉镖';
	$ary['stall_self'] = $co[$ary['stall_self']];
	$ary['stall_auto'] = $co[$ary['stall_auto']];
	$ary['fight'] = $co[$ary['fight']];
	$ary['sitdown'] = $co[$ary['sitdown']];
	$ary['normal'] = $co[$ary['normal']];
	$ary['exchange'] = $co[$ary['exchange']];
	$ary['trading'] = $co[$ary['trading']];
	return $ary;	
}

