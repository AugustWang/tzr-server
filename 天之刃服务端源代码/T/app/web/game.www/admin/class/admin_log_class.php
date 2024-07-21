<?php
/*
 * Author: odinxu, MSN: odinxu@hotmail.com
 * 2008-9-8
 *
 */


if ( ! defined('ADMIN_CLASS_ADMIN_LOG_CLASS_PHP_FILE') )
{
    define('ADMIN_CLASS_ADMIN_LOG_CLASS_PHP_FILE', 1);

//用户登录验证，  同时，在这里也引用全站通用的配置和函数，包括数据库类等
include_once SYSDIR_ADMIN . '/class/admin_auth.php';
include_once SYSDIR_CLASS."/db.class.php";

global $ADMIN_LOG_TYPE;

$ADMIN_LOG_TYPE = array(
 0 => '显示全部',
 
 1001 => '封禁帐号',
 1002 => '解封帐号',
 1003 => '封禁IP',
 1004 => '解封IP',
 1005 => '踢玩家下线',
 1006 => '玩家禁言',
 1007 => '玩家解除禁言',
 1008=>  '踢摊位下线',
 1009=>  '送回新手村',
 1010 => '重置精力值',
 1011 => '技能返还经验',
 1012 => '设置防沉迷',
 1013 => '清理个人拉镖状态',
 
 2001 => '赠送道具',
 2002 => '赠送银两',
 2003 => '赠送元宝',
 2004 => '充值补单',
 2005 => '批量发道具',
 
 3001 => '消息广播',
 3002 => '给玩家发信',
 3003 => '批量发信',
 
 4001 => '直接登录玩家帐号',
 4002 => '模拟平台登录帐号',
 4003 => '直接注册GM角色',
  
 
 9001 => '登录系统',
 9002 => '修改密码',
 9003 => '新设后台用户',
 9004 => '修改后台用户',
 9005 => '修改后台用户密码',
 9006 => '新增道具权限组',
 9007 => '修改道具权限组',
 9008 => '新建后台权限组',
 9009 => '修改后台权限组',
 9010 => '删除后台权限组',
 9011 => '同步系统公告',
 9012 => '登录公告设置',
 9013 => '设置连续登录天数',
 9014 => '开启国运',
 9015 => '开启国探',
 9016 => '清理拉镖状态',
 9017 => '同步镖车与人的位置',
 9018 => '清理道具摆摊异常',
 9019 => '清除交易状态',
);

//loadBaseCache('building');
//loadBaseCache('tech');
//loadBaseCache('items');

class AdminLogClass
{
	const TYPE_ALL		= 0;		//显示全部
	
	const TYPE_BAN_USER		= 1001;		//封禁帐号
	const TYPE_UNBAN_USER	= 1002;	//解封帐号
	const TYPE_BAN_IP		= 1003;		//封禁IP
	const TYPE_UNBAN_IP		= 1004;		//解封IP
	const TYPE_KICK_USER	= 1005;	//踢玩家下线
	const TYPE_BAN_CHAT		= 1006;		//玩家禁言
	const TYPE_UNBAN_CHAT		= 1007;		//玩家解除禁言
	const TYPE_KICK_STALL	=1008; 		//踢摆摊
	const TYPE_SEND_RETURN_PEACE_VILLAGE	=1009; 		//送回新手村
	const TYPE_RESET_ENERGY		= 1010;		//重置精力值
	const TYPE_SKILL_RETURN_EXP = 1011;		// 技能返还经验
	const TYPE_PASS_FCM = 1012;				// 设置防沉迷
	const TYPE_CLEAR_PERSON_YBC = 1013;				// 清理个人拉镖状态
	
	const TYPE_SEND_GOODS		= 2001;		//赠送道具
	const TYPE_SEND_SILVER		= 2002;		//赠送银两
	const TYPE_SEND_GOLD		= 2003;		//赠送元宝
	const TYPE_DO_ORDERS		= 2004;		//充值补单
	const TYPE_MSG_SEND_BATCH_GOODS	= 2005;		//批量发道具
	
	const TYPE_MSG_BROADCAST	= 3001;		//消息广播
	const TYPE_MSG_SENDEMAIL	= 3002;		//给玩家发信
	const TYPE_MSG_SEND_BATCH_EMAIL	= 3003;		//批量发信
	
	const TYPE_DIRECT_LOGIN_USER		= 4001;		//直接登录玩家帐号
	const TYPE_DIRECT_LOGIN_PLATFORM	= 4002;		//模拟平台登录帐号
	const TYPE_CREATE_GM_ROLE			= 4003;		//直接注册GM角色
 
	
	const TYPE_SYS_LOGIN			= 9001;			//登录系统
	const TYPE_SYS_SET_PASSWORD		= 9002;		//修改自己密码
	const TYPE_SYS_CREATE_ADMIN		= 9003;		//新设后台用户
	const TYPE_SYS_MODIFY_ADMIN_GROUPID		= 9004;		//修改用户所属组
	const TYPE_SYS_MODIFY_ADMIN_PASSWORD		= 9005;		//修改后台用户密码
	const TYPE_SYS_CREATE_ITEM_GOOP				= 9006;		//新增道具权限组
	const TYPE_SYS_MODIFY_ITEM_GOOP				= 9007;		//修改道具权限组
	const TYPE_SYS_CREATE_ADMIN_GROUP		= 9008;		//新建用户组
	const TYPE_SYS_MODIFY_ADMIN_GROUP		= 9009;		//修改用户组
	const TYPE_SYS_DELETE_ADMIN_GROUP		= 9010;		//删除用户组
	
	const TYPE_SYN_SYSTEM_NOTICE			= 9011; 	//同步系统公告
	const TYPE_SET_SYSTEM_NOTICE			= 9012;		//设置系统公告
	const TYPE_SET_CONLOGIN					= 9013;		//设置连续登录天数
	
	const TYPE_SET_FACTION_YBC = 9014 ; // 开启国运
	const TYPE_SET_GUOTAN = 9015 ; // 开启国探
	const TYPE_CLEAR_YBC_STATE = 9016 ; // 清理拉镖状态
	const TYPE_SYN_YBC_POS = 9017;// 同步镖车与人的位置
        const TYPE_CLEAR_ITEM_STALL_STATE = 9018; // 清理道具摆摊状态异常
        const TYPE_CLEAR_EXCHANGE_STATE = 9019; // 清理交易状态
        
	var $userid;
	var $username;

    var $key;

	function __construct()
 	{
 		global $auth;
		$this->userid    = $auth->userid();
		$this->username  = $auth->username();
 		//assert(is_int($ADMIN->userid) && $ADMIN->userid > 0);
 	}

	function __destruct()
	{
	}

	//使用金币
	// $type 的取值根据 $ADMIN_LOG_TYPE 数组
	// $detail 与 $type 匹配，如果使用赠送道具，则$detail为道具的ID
	// $number 为具体的数量，比如赠送金币的数量
	// $desc 为中文的详细描述，如“赠送道具”，“赠送金币”
	// $user_id, $user_name为被操作对象
	public function Log($type, $detail, $number, $desc, $user_id, $user_name)
	{
		$f['admin_id']   = $this->userid;
		$f['admin_name'] = $this->username;
		$f['admin_ip']   = GetIP();

		$f['user_id']    = $user_id;
		$f['user_name']  = $user_name;

		$f['mtime']    = time();
		$f['mtype']    = $type;
		$f['mdetail']  = $detail;
		$f['number']   = $number;
		if (!empty($desc))
		    $f['desc']     = $desc;
		else {
		    global $ADMIN_LOG_TYPE;
		    $f['desc']     = $ADMIN_LOG_TYPE[$type];
		}

		$sql = makeInsertSqlFromArray($f, 't_log_admin');

		GQuery($sql);
	}

	//历史记录
	public function getLogs($start = 0, $end = 0, $admin_name = '', $type = 0)
	{
		global $_DCACHE;
		$sql = "SELECT * FROM `t_log_admin`".
			" WHERE 1 ";
		if ($admin_name)
			$sql .= " AND `admin_name`='{$admin_name}'";
		if ($start)
			$sql .= " AND `mtime` >= {$start}";
		if ($end)
			$sql .= " AND `mtime` <= {$end}";
		if ($type>0)
			$sql .= " AND mtype='{$type}'";

		$sql .= " ORDER BY `mtime` DESC";
		$rs = GFetchRowSet($sql);

		if(!is_array($rs))
			$rs = array();

		//var_dump($sql);

		for($i = 0; $i < count($rs); $i++)
		{
			if($rs[$i]['mtime'])
				$rs[$i]['time_str'] = strftime('%D %T', $rs[$i]['mtime']);
			 
			$mtype = $rs[$i]['mtype'];
			$str = '';
			if($rs[$i]['mdetail'])
			{
				if($mtype == 5)
				{
					$res = extractData($rs[$i]['mdetail']);
					if(intval($res['W']))
						$str .= '木: ' .intval($res['W']);
					if(intval($res['M']))
						$str .= '  铁: ' .intval($res['M']);
					if(intval($res['F']))
						$str .= '  粮: ' .intval($res['F']);
				}
				elseif($mtype == 2)
				{
					$tid = $rs[$i]['mdetail'];
					$tname = $_DCACHE['tech'][$tid]['name'];
					$str .= $tname;

				}
				elseif($mtype == 1)
				{
					$bid = $rs[$i]['mdetail'];
					$bname = $_DCACHE['building'][$bid]['name'];
					$str .= $bname;
				}
				elseif($mtype == 3)
				{
					$sid = $rs[$i]['mdetail'];
					$num = $rs[$i]['number'];
					$sname = $_DCACHE['soldier'][$sid]['name'];
					//$str .= $sname . ' ' . $num . '个';
				}
				elseif($mtype == 4)
				{
					$iid = $rs[$i]['mdetail'];
					$num = $rs[$i]['number'];
					$iname = $_DCACHE['item'][$iid]['name'];
					//$str .= $iname . ' ' . $num . '个';
				}
			}
			if($mtype == 6)
			{
				$num = $rs[$i]['number'];
				if($rs[$i]['desc']=='赠送元宝')
				{
					$str .= '赠送'.$num.' 元宝';
				}
				elseif($rs[$i]['desc']=='赠送金砖')
				{
					$str .= '赠送'.$num.' 金砖';
				}
				//else $str .= $num.' 元宝';
			}
			elseif($mtype == 92)
			{
				$admin_level = $rs[$i]['number'];
				$pos = strpos($rs[$i]['mdetail'],'权限组');
				if($pos === false)
				{
					$str .= '级别 '.$admin_level;
				}
			}
			$rs[$i]['mdetail_str'] = $str;
		}

		return $rs;
	}

	/*
	 * 取得有过滤条件的数据
	 */
	public function getGlvLogs($start = 0, $end = 0, $admin_name = '', $gulvxt, $op_type, $type = 0)
	{
		global $_DCACHE;
		$sql = "SELECT * FROM `t_log_admin`".
			" WHERE 1 ";
		if ($admin_name)
			$sql .= " AND `admin_name`='{$admin_name}'";
		if ($gulvxt)
			$sql .= " AND `mtype` <> '{$gulvxt}'";
		if ($op_type != '0')
			$sql .= " AND `mtype`= '{$op_type}'";
		if ($start)
			$sql .= " AND `mtime` >= {$start}";
		if ($end)
			$sql .= " AND `mtime` <= {$end}";
		if ($type>0)
			$sql .= " AND mtype='{$type}'";


		$sql .= " ORDER BY `mtime` DESC";
		$rs = GFetchRowSet($sql);

		if(!is_array($rs))
			$rs = array();

		//var_dump($sql);

		for($i = 0; $i < count($rs); $i++)
		{
			if($rs[$i]['mtime'])
				$rs[$i]['time_str'] = strftime('%D %T', $rs[$i]['mtime']);
		 
			$mtype = $rs[$i]['mtype'];
			$str = '';
			if($rs[$i]['mdetail'])
			{
				if($mtype == 5)
				{
					$res = extractData($rs[$i]['mdetail']);
					if(intval($res['W']))
						$str .= '木: ' .intval($res['W']);
					if(intval($res['M']))
						$str .= '  铁: ' .intval($res['M']);
					if(intval($res['F']))
						$str .= '  粮: ' .intval($res['F']);
				}
				elseif($mtype == 2)
				{
					$tid = $rs[$i]['mdetail'];
					$tname = $_DCACHE['tech'][$tid]['name'];
					$str .= $tname;

				}
				elseif($mtype == 1)
				{
					$bid = $rs[$i]['mdetail'];
					$bname = $_DCACHE['building'][$bid]['name'];
					$str .= $bname;
				}
				elseif($mtype == 3)
				{
					$sid = $rs[$i]['mdetail'];
					$num = $rs[$i]['number'];
					$sname = $_DCACHE['soldier'][$sid]['name'];
					//$str .= $sname . ' ' . $num . '个';
				}
				elseif($mtype == 4)
				{
					$iid = $rs[$i]['mdetail'];
					$num = $rs[$i]['number'];
					$iname = $_DCACHE['item'][$iid]['name'];
					//$str .= $iname . ' ' . $num . '个';
				}
			}
			if($mtype == 6)
			{
				$num = $rs[$i]['number'];
				if($rs[$i]['desc']=='赠送元宝')
				{
					$str .= '赠送'.$num.' 元宝';
				}
				elseif($rs[$i]['desc']=='赠送金砖')
				{
					$str .= '赠送'.$num.' 金砖';
				}
				//else $str .= $num.' 元宝';
			}
			elseif($mtype == 92)
			{
				$admin_level = $rs[$i]['number'];
				$pos = strpos($rs[$i]['mdetail'],'权限组');
				if($pos === false)
				{
					$str .= '级别 '.$admin_level;
				}
			}
			$rs[$i]['mdetail_str'] = $str;
		}

		return $rs;
	}

	/**
	 * 记录管理员批量赠送道具
	 *
	 * @param string $detail
	 */
	public function logBatchSendItem($detail)
	{
	    $this->Log(9, '', 0, $detail);
	}
}

}