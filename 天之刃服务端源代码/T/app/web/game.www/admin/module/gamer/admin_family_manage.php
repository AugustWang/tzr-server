<?php

/*
 * Author: MarkyCai
 * 2011.01.13
 * 获取道具列表
 */


//TODO:需要增加用户的安全验证
define('IN_ODINXU_SYSTEM', true);
include_once "../../../config/config.php";
include_once SYSDIR_ADMIN.'/include/global.php';
$auth->assertModuleAccess(__FILE__);



//调用模块
include_once SYSDIR_ADMIN.'/class/admin_family_class.php';


$fname = trim(SS($_POST['fname']));
$fid = trim(SS($_POST['fid']));
$action = trim(SS($_POST['action']));
$owername = trim(SS($_POST['owername']));

$familyinfo=array();
$familyextinfo=array();
if($action='search' && ($fname != '' ||($fid !=''&&is_numeric($fid)))){//搜索
	$where = "where 1";
	if($fname!='')
		$where.= " AND family_name = '{$fname}' ";
	
	if($fid!='')
	{
		$where.= " AND family_id = {$fid}";
	}	
	
    $familyinfo = AdminFamilyClass::getFamilyInfo($fid,$fname);

	$createtime = AdminFamilyClass::getFamilyCreateTime($where);
	if(!$familyinfo['family_id'])
	{
		$errmsg='不存在该门派，请检查并重新输入。';	
	}
	else
	{
		$familyinfo['creator_time']=$createtime;
		//成员，长老，申请表，邀请表
		$familyinfo['members']=getElementList($familyinfo['members'],'role_name');
		$familyinfo['second_owners']=getElementList($familyinfo['second_owners'],'role_name');
		$familyinfo['request_list']=getElementList($familyinfo['request_list'],'role_name');
		$familyinfo['invite_list']=getElementList($familyinfo['invite_list'],'role_name');
		$familyextinfo = AdminFamilyClass::getFamilyExtInfo($familyinfo['family_id']);
	}
}
else
{
	$errmsg='搜索关键字错误';
}

if($action='change_owner' && $owername !='' )
{
        //更换掌门
}


$smarty->assign('fname',$fname);
$smarty->assign('fid',$fid);
$smarty->assign('familyinfo', $familyinfo);
$smarty->assign('familyextinfo',$familyextinfo);
$smarty->assign('errmsg',$errmsg);
$smarty->display("module/gamer/admin_family_manage.tpl");


exit;

//////////////////////////////////////////
function getElementList($arr,$column)
{
	if($arr)
	{
		foreach($arr as $k=>$v)
		{
			$list.=$v[$column].',';
		}
	}
	$list=rtrim($list,',');
	return $list;
}


?>

