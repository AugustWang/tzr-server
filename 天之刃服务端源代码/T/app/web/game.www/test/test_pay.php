<?php
define('IN_ODINXU_SYSTEM', true);

include_once "../config/config.ip.limit.pay.php";
include("../config/config.php");
include_once '../config/config.key.php';
include_once SYSDIR_INCLUDE."/global.php";

$action = trim($_POST['action']);
if ($action == 'do') {
	$accountName = trim($_POST['account_name']);
	$money = floatval($_POST['money']);
	$payNum = rand(100000, 999999999);
	$payGold = $money * 10;
	$payTime = time();
	$ticket = md5($API_SECURITY_TICKET_PAY . $payNum . $accountName . $money . $payGold . $payTime);
	$result = file_get_contents(WEB_SITEURL."/api/pay.php?PayNum={$payNum}"
									."&PayToUser={$accountName}&PayMoney={$money}"
									."&PayGold={$payGold}&PayTime={$payTime}&ticket={$ticket}");
	if ($result == 'param error.') {
		echo "参数错误";
	} else if ($result == 'ticket error.') {
		echo "密匙错误";
	} else if ($result == 'true') {
		echo "充值成功";
	} else if ($result == 'failed') {
		echo "充值失败";
	}
} else {
?>
<html>
<head></head>
<body>
<form action="" method="post">
	<input type="hidden" name="action" value="do" />
	账号名: <input type="text" name="account_name" value="" /><br>
	人民币: <input type="text" name="money" value="" /><br>
	<input type="submit" value="充值" /> <br>
</form>
</body>
</html>
<?php 	
}