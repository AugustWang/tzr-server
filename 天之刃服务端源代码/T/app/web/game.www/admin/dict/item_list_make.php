<?php
/*
 * created by yangyuqun
 * copyright http://www.mingchao.com
 */
define('IN_ODINXU_SYSTEM', true);
include_once "../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
include_once SYSDIR_ADMIN.'/class/admin_item_class.php';
global $ITEM_LIST;

	$sql = "SELECT  `typeid`, `item_name` FROM `t_item_list` ";
	
	$rs = GFetchRowSet($sql);

	
//function update_item_list($rs){
@$fp = fopen(SYSDIR_ADMIN."/dict/item_list_dict.php","w"); 
if(!$fp){ 
	echo "system error"; 
	exit(); 
}else { 
	$fileData = '<?php'."\n $";  
	$fileData = $fileData."ITEM_LIST= array ("."\n";
	$litem_list = 'item_list';
	foreach($rs as $list){
		$fileData = $fileData."\t".$list['typeid']."=>'".$list['item_name']."',\n";
	}
	$fileData = $fileData.")\n"."?>"; 
$update = fwrite($fp,$fileData);
if($update){echo "更新成功,请拷贝admin/dict/item_list_dict.php文件到所需要的目录";} 
fclose($fp);
} 
//}

?>