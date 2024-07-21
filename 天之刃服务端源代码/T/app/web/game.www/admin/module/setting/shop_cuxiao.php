<?php
/**
 * 商店促销信息控制后台
 * @author QingliangCn
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
global $auth, $smarty;
$auth->assertModuleAccess(__FILE__);

include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
$itemClass = new AdminItemClass();

$action = trim($_POST['action']);
if ($action == 'set') {
	// 更新促销商品信息
	$key = trim($_POST['key']);
	$num = intval($_POST['num']);
	$price = intval($_POST['price']);
	setShopCuxiaoItem($key, $num, $price);
}

$shaoCuxiaoItem = getShopCuxiaoItem();
foreach ($shaoCuxiaoItem as $k=>$v) {
	$itemID = array_pop(explode("_", $v['key']));
	$item = $itemClass->getItemByTypeid($itemID);
	$shaoCuxiaoItem[$k]['name'] = $item['item_name'];
	$shaoCuxiaoItem[$k]['id'] = $itemID;
	$shaoCuxiaoItem[$k]['real_price'] = $v['price']['currency'][0]['amount'];
}


$smarty->assign('shopCuxiaoItemList', $shaoCuxiaoItem);
$smarty->display('module/setting/shop_cuxiao.html');

/**
 * 设置某个促销商品的详细信息
 * @param string $key
 * @param int $num
 * @param int $price
 */
function setShopCuxiaoItem($key, $num, $price) {
	getWebJson('/shop/set_cuxiao_item/?key='.$key."&num=".$num."&price=".$price);
}

/**
 * 获取促销商品列表 
 */
function getShopCuxiaoItem() {
	$result = getWebJson('/shop/get_cuxiao_item_list');
	if ($result == null) {
		return null;
	} else {
		return $result['list'];
	}
}