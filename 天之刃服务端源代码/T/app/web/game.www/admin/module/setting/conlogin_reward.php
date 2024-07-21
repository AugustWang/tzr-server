<?php
/**
 * 连续登录奖励 
 * @author QingliangCn
 * @create_time	2011/2/21
 */

define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
$itemClass = new AdminItemClass();
$smarty->assign('itemlists', $itemClass->getItemList());

$job = trim($_REQUEST['job']);
$action = trim($_REQUEST['action']);

if ($job == 'type') {
	//操作列表
	if ($action == 'add') {
		$title = trim($_POST['title']);
		if ($title == '') {
			errorExit("标题不能为空");
		}
		if (mb_strlen($title, 'utf8') > 18) {
			errorExit("标题长度不能超过18个字符");
		}
		$sql = "SELECT id FROM `t_conlogin_reward_category` WHERE title = '{$title}'";
		if (count(GFetchRowOne($sql)) > 0) {
			errorExit("标题重复");
		}
		$beginDay = intval($_POST['begin_day']);
		$endDay = intval($_POST['end_day']);
		if ($beginDay < 1) {
			errorExit("开始天数必须大于0");
		}
		if ($endDay < $beginDay) {
			errorExit("结束天数不能小于开始天数");
		}
		$arr = array('begin_day' => $beginDay, 'end_day'=>$endDay, 'title'=>$title);
		GQuery(makeInsertSqlFromArray($arr, 't_conlogin_reward_category'));
		
		$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE 1";
		$result = GFetchRowSet($sql);
		$smarty->assign('awardlist', $result);
		$smarty->display("module/setting/conlogin_reward.html");
	} else if ($action == 'edit') {
		$flag = trim($_POST['flag']);
		$aid = intval(trim($_REQUEST['aid']));
		if ($flag == 'do') {
			$title = trim($_POST['title']);
			if ($title == '') {
				errorExit("标题不能为空");
			}
			if (mb_strlen($title, 'utf8') > 18) {
				errorExit("标题长度不能超过18个字符");
			}
			$beginDay = intval($_POST['begin_day']);
			$endDay = intval($_POST['end_day']);
			if ($beginDay < 1) {
				errorExit("开始天数必须大于0");
			}
			if ($endDay < $beginDay) {
				errorExit("结束天数不能小于开始天数");
			}
			$arr = array('id' => $aid, 'begin_day' => $beginDay, 'end_day'=>$endDay, 'title'=>$title);
			GQuery(makeUpdateSqlFromArray($arr, 't_conlogin_reward_category'));
			$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE `id` = $aid";
			$result = GFetchRowOne($sql);
			$smarty->assign('listtype', $result);
			$smarty->assign('aid', $aid);
			$smarty->assign('itemListsType', getRewardsByID($aid));
			$smarty->display("module/setting/edit_conlogin_reward.html");
		} else {
			$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE `id` = $aid";
			$result = GFetchRowOne($sql);
			$smarty->assign('listtype', $result);
			$smarty->assign('aid', $aid);
			$smarty->assign('itemListsType', getRewardsByID($aid));
			$smarty->display("module/setting/edit_conlogin_reward.html");
		}
	} else if ($action == 'del') {
		$aid = intval($_REQUEST['aid']);
		$sql = "DELETE FROM `t_conlogin_reward_category` WHERE id = {$aid}";
		GQuery($sql);
		$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE 1";
		$result = GFetchRowSet($sql);
		$smarty->assign('awardlist', $result);
		$smarty->display("module/setting/conlogin_reward.html");
	} else if ($action == 'export') {
		$file = "/tmp/conlogin_reward.config";
		if (gene_config_file($file)) {
			header("content-type:text/html; charset=utf-8");
			header( "Pragma: public" );
			header( "Expires: 0" ); 
			Header("Content-type: application/octet-stream");
			Header("Accept-Ranges: bytes");
			Header("Accept-Length: ".filesize($file));
			Header("Content-Disposition: attachment; filename=conlogin_reward.config");
			echo file_get_contents($file);
			exit();
		} else {
			errorExit("尚无数据");
		}
	} else {
		$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE 1";
		$result = GFetchRowSet($sql);
		$smarty->assign('awardlist', $result);
		$smarty->assign('itemListsType', getRewardsByID($aid));
		$smarty->display("module/setting/conlogin_reward.html");
	}
} else if ($job == 'itemDetail') {
	if ($action == 'add') {
		$aid = intval(trim($_POST['aid']));
		$itemID = intval(trim($_POST['typeid']));
		$itemInfo = $itemClass->getItemByTypeid($itemID);
		if (!$itemInfo) {
			errorExit("道具不存在");
		}
		$num = intval(trim($_POST['num']));
		if ($num < 1) {
			errorExit("道具数量必须大于0");
		}
		$bind = intval(trim($_POST['bind'])) ? 1 : 0;
		$gold = intval(trim($_POST['gold']));
		if ($gold < 0) {
			errorExit("元宝不能为负数");
		}
		$silver = intval(trim($_POST['silver']));
		if ($silver < 0) {
			errorExit("银两不能为负数");
		}
		$minLevel = intval(trim($_POST['minlv']));
		if ($minLevel < 1) {
			errorExit("最小等级必须大于0");
		}
		$maxLevel = intval(trim($_POST['maxlv']));
		if ($maxLevel < $minLevel) {
			errorExit("最大等级必须大于最小等级");
		}
		$loopDay = intval(trim($_POST['loop_day']));
		if ($loopDay < 1) {
			$loopDay = 1;
		}
		$vipLevel = intval(trim($_POST['vipLevel']));
		$needPayed = intval(trim($_POST['hasPayed'])) ? 1 : 0;
		$arr = array(
					'category_id' => $aid,
					'type' => $itemInfo['type'],
					'type_id' => $itemID,
					'min_level' => $minLevel,
					'max_level' => $maxLevel,
					'need_payed' => $needPayed,
					'num' => $num,
					'silver' => $silver,
					'gold' => $gold,
					'bind' => $bind,
					'loop_day' => $loopDay,
					'item_name' => $itemInfo['item_name'],
					'need_vip_level' => $vipLevel,
		);
		GQuery(makeInsertSqlFromArray($arr, 't_conlogin_reward'));
		$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE `id` = $aid";
		$result = GFetchRowOne($sql);
		$smarty->assign('listtype', $result);
		$smarty->assign('aid', $aid);
		$smarty->assign('itemListsType', getRewardsByID($aid));
		$smarty->display("module/setting/edit_conlogin_reward.html");
	} else if ($action == 'del') {
		$id = intval($_REQUEST['id']);
		$aid = intval($_REQUEST['aid']);
		$sql = "DELETE FROM `t_conlogin_reward` WHERE id = {$id}";
		GQuery($sql);
		$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE `id` = $aid";
		$result = GFetchRowOne($sql);
		$smarty->assign('listtype', $result);
		$smarty->assign('id', $id);
		$smarty->assign('aid', $aid);
		$smarty->assign('itemListsType', getRewardsByID($aid));
		$smarty->display("module/setting/edit_conlogin_reward.html");
	} else if ($action == 'edit') {
		$flag = trim($_REQUEST['flag']);
		$id = intval($_REQUEST['id']);
		$aid = intval($_REQUEST['aid']);
		if ($flag == 'do') {
			$id = intval(trim($_POST['id']));
			$itemID = intval(trim($_POST['typeid']));
			$itemInfo = $itemClass->getItemByTypeid($itemID);
			if (!$itemInfo) {
				errorExit("道具不存在");
			}
			$num = intval(trim($_POST['num']));
			if ($num < 1) {
				errorExit("道具数量必须大于0");
			}
			$bind = intval(trim($_POST['bind'])) ? 1 : 0;
			$gold = intval(trim($_POST['gold']));
			if ($gold < 0) {
				errorExit("元宝不能为负数");
			}
			$silver = intval(trim($_POST['silver']));
			if ($silver < 0) {
				errorExit("银两不能为负数");
			}
			$minLevel = intval(trim($_POST['minlv']));
			if ($minLevel < 1) {
				errorExit("最小等级必须大于0");
			}
			$maxLevel = intval(trim($_POST['maxlv']));
			if ($maxLevel < $minLevel) {
				errorExit("最大等级必须大于最小等级");
			}
			$loopDay = intval(trim($_POST['loop_day']));
			if ($loopDay < 1) {
				$loopDay = 1;
			}
			$needPayed = intval(trim($_POST['hasPayed'])) ? 1 : 0;
			$vipLevel = intval(trim($_POST['vipLevel']));
			$arr = array(
						'id' => $id,
						'category_id' => $aid,
						'type' => $itemInfo['type'],
						'type_id' => $itemID,
						'min_level' => $minLevel,
						'max_level' => $maxLevel,
						'need_payed' => $needPayed,
						'num' => $num,
						'silver' => $silver,
						'gold' => $gold,
						'bind' => $bind,
						'loop_day' => $loopDay,
						'item_name' => $itemInfo['item_name'],
						'need_vip_level' => $vipLevel,
						
			);
			GQuery(makeUpdateSqlFromArray($arr, 't_conlogin_reward'));
			
			$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE `id` = $aid";
			$result = GFetchRowOne($sql);
			$smarty->assign('listtype', $result);
			$smarty->assign('id', $id);
			$smarty->assign('aid', $aid);
			$smarty->assign('itemListsType', getRewardsByID($aid));
			$smarty->display("module/setting/edit_conlogin_reward.html");
			exit();
		}
		
		$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE `id` = $aid";
		$result = GFetchRowOne($sql);
		$smarty->assign('listtype', $result);
		
		$sql = "SELECT * FROM `t_conlogin_reward` WHERE id = {$id}";
		$result = GFetchRowOne($sql);
		$smarty->assign('item', $result);
		$smarty->assign('id', $id);
		$smarty->assign('aid', $aid);
		$smarty->display("module/setting/edit_conlogin_reward_item.html");
	}
} else {
	$sql = "SELECT * FROM `t_conlogin_reward_category` WHERE 1";
	$result = GFetchRowSet($sql);
	$smarty->assign('awardlist', $result);
	$smarty->display("module/setting/conlogin_reward.html");
}

/**
 * 根据ID显示某个配置下的所有奖励
 * @param int $id
 */
function getRewardsByID($id) {
	$sql = "SELECT * FROM `t_conlogin_reward` WHERE category_id = $id";
	return GFetchRowSet($sql);
}

/**
 * 生成连续登录奖励的配置文件
 * @param string $file
 */
function gene_config_file($file) {
	$sql = "SELECT *, a.id as aid  FROM `t_conlogin_reward` a, t_conlogin_reward_category as b WHERE a.category_id = b.id";
	$result = GFetchRowSet($sql);
	if (!$result) {
		return false;
	}
	$txt = "";
	foreach ($result as $v) {
		$beginDay = $v['begin_day'];
		$endDay = $v['end_day'];
		$minLevel = $v['min_level'];
		$maxLevel = $v['max_level'];
		$num = $v['num'];
		$itemType = $v['type'];
		$itemID = $v['type_id'];
		$bind = $v['bind'] ? 'true' : 'false';
		$silver = $v['silver'];
		$gold = $v['gold'];
		$needPay = $v['need_payed'] ? 'true' : 'false';
		$loopDay = $v['loop_day'];
		$vipLevel = $v['need_vip_level'];
		$txt .= "{r_conlogin_reward, {$v['aid']}, {$minLevel}, {$maxLevel}, {$beginDay}, {$endDay}, {$num}, {$itemType}, {$itemID}, {$bind}"
					. ", {$silver}, {$gold}, {$needPay}, {$loopDay}, {$vipLevel}". "}.\r";
	}
	file_put_contents($file, $txt);
	return true;
}