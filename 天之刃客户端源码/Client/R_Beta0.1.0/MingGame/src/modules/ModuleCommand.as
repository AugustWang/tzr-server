package modules {

	public class ModuleCommand {

		public static const START_UP_SCENE:String="START_UP_SCENE";
		public static const ENTER_GAME:String="ENTER_GAME";
		public static const ROLE_MOVE_TO:String="ROLE_MOVE_TO"; //走路消息
		public static const INIT_CONNECT:String="INIT_CONNECT";
		public static const CONNECTED:String="CONNECT";
		public static const CONNECTED_FAILURE:String="CONNECTED_FAILURE";
		public static const START_LOGIN:String="START_LOGIN";
		public static const LOGIN_COMPLETE:String="LOGIN_COMPLETE";
		public static const START_AUTH:String="START_AUTH";
		public static const ON_SMALL_MAP_COMPLETE:String="ON_SMALL_MAP_COMPLETE";
		public static const CLEAR_MAP_PATH:String="CLEAR_MAP_PATH";

		public static const GOODS_CHANGED:String="GOODS_CHANGED";
		public static const RESET_SKILL:String="RESET_SKILL";
		public static const REMOVE_SKILL_ITEM:String="REMOVE_SKILL_ITEM";
		public static const SOCIETY_FLICK:String="SOCIETY_FLICK";
		public static const STOP_SOCIETY_FLICK:String="STOP_SOCIETY_FLICK";
		public static const FRIEND_FLICK:String="FRIEND_FLICK";
		public static const FRIEND_STOP_FLICK:String="FRIEND_STOP_FLICK";
		public static const CLOTHING_NAME_CHANGED:String="CLOTHING_NAME_CHANGED";
		public static const SHOW_HP_TIP:String="SHOW_HP_TIP";
		public static const ROLE_LEVEL_UP:String="ROLE_LEVEL_UP";
		public static const ROLE_DEAD_ALIVE:String="ROLE_DEAD_ALIVE";

		public static const CREATE_FAMILY:String="CREATE_FAMILY"; //创建门派
		public static const JOIN_FAMILY:String="JOIN_FAMILY";
		public static const LEAVE_FAMILY:String="LEAVE_FAMILY";
		public static const CHANGE_FAMILY:String="CHANGE_FAMILY";
		public static const FAMILYINFO_INIT:String="FAMILYINFO_INIT"; //初始化门派数据
		public static const INVITE_JOIN_FAMILY:String="INVITE_JOIN_FAMILY"; //邀请加入门派
		public static const FAMILY_CHANGED:String="FAMILY_CHANGED";
		public static const CHANGE_FAMILY_VIEW:String="CHANGE_FAMILY_VIEW"; //改变门派视图
		public static const START_TEAM:String="START_TEAM";
		public static const APPLY_TEAM:String="APPLY_TEAM"; //申请组队
		public static const LEVEL_TEAM:String="LEVEL_TEAM"; //退队
		public static const JOIN_TEAM:String="JION_TEAM"; //加入队伍，从无队变有队
		public static const PACKAGE_MONEY_CHANGE:String="PACKAGE_MONEY_CHANGE";
		public static const PACKAGE_UPDATE_GOODS:String="PACKAGE_UPDATE_GOODS";
		public static const FAMILY_COLLECT_PRIZE:String="FAMILY_COLLECT_PRIZE"; //门派采集领取奖励面板

		public static const FAMILY_CAR_FINISH:String="FAMILY_CAR_FINISH";
		public static const SIMPLE_FAMILY_CAR:String="SIMPLE_FAMILY_CAR";
		public static const QUALITY_FAMILY_CAR:String="QUALITY_FAMILY_CAR";
		public static const FAMILY_CAR_TO_CONVENE:String="FAMILY_CAR_TO_CONVENE";
		public static const FAMILY_CAR_HELP:String="FAMILY_CAR_HELP";

		public static const CONLOGIN_OPEN_PANEL:String="CONLOGIN_OPEN_PANEL"; // 显示连续登录窗口
		public static const TEAM_VIEW:String="TEAM_VIEW"; //组队:面板初始化
		public static const UPDATE_FIVE:String="UPDATE_FIVE"; // 组队:更新五行属性
		public static const ROLE2_FIVE_ELE_ATTR:String="ROLE2_FIVE_ELE_ATTR";
		public static const OPEN_SYSTEM_WINDOW:String="OPEN_SYSTEM_WINDOW"; //打开系统窗口
		public static const OPEN_SMALL_SCENE:String="OPEN_SMALL_SCENE"; //
		public static const OPEN_AUTOKILL_MONSTER:String="OPEN_AUTOKILL_MONSTER"; //开启自动技能
		public static const START_FLIGHT:String="START_FLIGHT"; //开启战斗
		public static const CONFIG_CHANGED:String="CONFIG_CHANGED"; //配置改变
		public static const MAP_ENTER:String="MAP_ENTER"; // 进入地图（会有多次，如跨地图、传送）
		public static const OPEN_FRIEND_LIST:String="OPEN_FRIEND_LIST"; //打开好友列表面板
		public static const GET_FRIEND_ENERMY:String="GET_FRIEND_ENERMY"; //获取好友仇人数据
		public static const SET_FRIEND_ENERMY:String="SET_FRIEND_ENERMY"; //仇人数据
		public static const SEND_FRIEND_PRIVATE:String="SEND_FRIEND_PRIVATE"; // 窗口聊天消息发送 
		public static const SEND_FRIEND_PRIVATE_RETURN:String="SEND_FRIEND_PRIVATE_RETURN"; //发送好友私聊
		public static const ADD_FRIEND:String="ADD_FRIEND"; //添加好友
		public static const ADD_BLACK:String="ADD_BLACK"; //添加黑名单
		public static const OPEN_FRIEND_PRIVATE:String="OPEN_FRIEND_PRIVATE"; //打开私聊窗口
		public static const FRIENDS_GROUP_INIT:String="FRIENDS_GROUP_INIT"; //群组初始化
		public static const INIT_GROUP_MEMBERS:String="INIT_GROUP_MEMBERS"; //初始化群组成员
		public static const GROUP_MEMBER_EXIT:String="GROUP_MEMBER_EXIT"; //退出群组
		public static const GROUP_MEMBER_ONOFFLINE:String="GROUP_MEMBER_ONOFFLINE"; //群组成员上下线
		public static const GROUP_MEMBER_JOIN:String="GROUP_MEMBER_JOIN"; //群组成员加入
		public static const GROUP_MESSAGE:String="GROUP_MESSAGE"; //群消息
		public static const JOIN_GROUP_CHANNEL:String="JOIN_GROUP_CHANNEL"; //加入群聊天频道
		public static const EXIT_GROUP_CHANNEL:String="EXIT_GROUP_CHANNEL"; //退出群聊天频道
		public static const UPDATE_TEAMGROUP:String="UPDATE_TEAMGROUP"; //更新组队群
		public static const OPEN_OFFLINE_PANEL:String="OPEN_OFFLINE_PANEL"; //打开离线请求面板
		public static const OPEN_FAMILY_RQUEST_PANEL:String="OPEN_FAMILY_RQUEST_PANEL"; //打开门派请求面板
		public static const OPEN_FORGESHOP_WINDOW:String="OPEN_FORGESHOP_WINDOW"; //打开铁匠铺
		// 训练营相关
		public static const TRAINING_PROGRESS:String="TRAINING_PROGRESS";


		public static const OPEN_TRAIN:String="OPEN_TRAIN";
		public static const TRAINING_STATE:String="TRAINING_STATE";
		public static const TRAINING_START:String="TRAINING_START";
		public static const TRAINING_END:String="TRAINING_END";

		public static const CHANGE_MAP:String="CHANGE_MAP"; //切换地图事件
		public static const CHANGE_MAP_ROLE_READY:String="CHANGE_MAP_ROLE_READY"; //切换地图后并且自己已经初始化
		public static const CANCLE:String="CANCLE";
		public static const YBC_POS:String="YBC_POS";
		public static const YBC_CLEAR:String="YBC_CLEAR";
		public static const DRAW_MY_PATH:String="DRAW_MY_PATH";

		public static const PET_LIST_CHANGED:String="PET_LIST_CHANGED";
		public static const SHOW_HIDE_PET_STATE:String="SHOW_HIDE_PET_STATE";
		public static const BATTLE_PET_CHANGE:String="BATTLE_PET_CHANGE"; //出战或召回时触发
		public static const OPEN_OR_CLOSE_PET_MAIN:String="OPEN_OR_CLOSE_PET_MAIN";
		public static const OPEN_PET_SKILL:String="OPEN_PET_SKILL";
		public static const OPEN_PET_LIFE:String="OPEN_PET_LIFE";
		public static const OPEN_PET_SAVVY:String="OPEN_PET_SAVVY";
		public static const OPEN_PET_FEED:String="OPEN_PET_FEED";
		public static const GET_PET_GROW_INFO:String="GET_PET_GROW_INFO";
		public static const OPEN_FAMILY_YBC_PEANL:String="OPEN_FAMILY_YBC_PEANL";

		public static const PET_STORE:String="PET_STORE";
		public static const OFFICE_CHANGED:String="OFFICE_CHANGED"; //官职信息改变
		public static const OPEN_PACK_PANEL:String="OPEN_PACK_PANEL"; //打开背包窗口
		public static const BUY_ADD_ITEM:String="BUY_ADD_ITEM"; //购买物品项
		public static const MOUNT_UP_FAR_RUN:String="MOUNT_UP_FAR_RUN";
		public static const LETTER_GET_ACCESSORY:String="LETTER_GET_ACCESSORY"; //接受来自信件的物品
		public static const PICK_UP_GOODS:String="PICK_UP_GOODS"; //拾取物品
		public static const OPEN_SALE_PANEL:String="OPEN_SALE_PANEL"; //打开交易面板
		public static const DEAL_ITEM_CHANGE:String="DEAL_ITEM_CHANGE"; //交易物品项改变
		public static const DEAL_CHECK_DISTANCE:String="DEAL_CHECK_DISTANCE";
		public static const GOODS_INIT:String="GOODS_INIT"; //背包数据初始化
		public static const MP_HP_CHANGED:String="MP_HP_CHANGED"; //角色，MP,HP改变
		public static const USEGOODS_ENABLE:String="USEGOODS_ENABLE"; //锁定使用物品
		public static const OPEN_LETTER_LIST:String="OPEN_LETTER_LIST"; //打开信件
		public static const OPEN_WRITE_LETTER:String="OPEN_WRITE_LETTER"; //打开写信界面
		// 本地添加聊天界面上显示的内容。 
		public static const CHAT_APPEND_MSG:String="CHAT_APPEND_MSG";

		//******************聊天部分//
		public static const PRI_CHAT:String="PRI_CHAT"; //私聊
		public static const HORN_USE_GOODS:String="HORN_USE_GOODS"; // 使用小喇叭道具发送喇叭
		public static const STOREROOM:String="STOREROOM"; //打开仓库
		//钱庄部分
		public static const BANK:String="BANK"; //打开钱庄
		//--------------------- 角色部分开始 --------------------- //
		public static const EXP_CHAGNGE:String="EXP_CHAGNGE";
		public static const ROLE_ARR_CHANGE:String="ROLE_ARR_CHANGE";
		public static const ROLE_REMAIN_POINT_CHANGE:String="ROLE_REMAIN_POINT_CHANGE";
		//--------------------- 角色部分结束 --------------------- //

		//--------------------- 交易开始 --------------------------- //
		public static const RUN_TO_DEAL:String="RUN_TO_DEAL";
		public static const OPEN_STALL_PANEL:String="OPEN_STALL_PANEL";
		public static const OPEN_STALL:String="OPEN_STALL"; //场景的 open stall
		public static const SELETED_STALL:String="SELETED_STALL";
		public static const SKILL_CLOSE_DEAL:String="SKILL_CLOSE_DEAL";
		public static const EXCHANGE_NPC_DEAL:String="EXCHANGE_NPC_DEAL"; //兑换
		public static const DEAL_STALL_START:String="DEAL_STALL_START"; //开始摆摊
		public static const DEAL_STALL_END:String="DEAL_STALL_END"; //结束摆摊
		public static const DEAL_STALL_WALK_TO:String="DEAL_STALL_WALK_TO"; //摆摊XXX
		//--------------------- 交易结束 --------------------------- //
		//--------------------- 坐骑开始 --------------------------- //
		public static const MOUNT_UPGRADE_CLEAN:String="MOUNT_UPGRADE_CLEAN"; //清除坐骑蒙板
		public static const MOUNT_TOKEN_CHANHE:String="MOUNT_TOKEN_CHANHE"; //坐骑提速令牌
		public static const MOUNT_UPGRADE_UPDATA:String="MOUNT_UPGRADE_UPDATA"; //坐骑提速返回
		public static const MOUNT_RENEWAL:String="MOUNT_RENEWAL"; //坐骑续期
		//--------------------- 坐骑结束 --------------------------- //
		//--------------------- GM开始 --------------------------- //
		public static const GM_OPEN_SENDVIEW:String="GM_OPEN_SENDVIEW"; //GM面板打开
		public static const GM_COMPLAINT:String="GM_COMPLAINT"; //GM返回
		//--------------------- GM结束 --------------------------- //
		//--------------------- NearRole开始 --------------------------- //
		//师徒副本
		public static var USE_EDUCATE_FB_MEMBER_ITEM:String="USE_EDUCATE_FB_MEMBER_ITEM"; //使用队长令牌
		public static var USE_EDUCATE_FB_LEADER_ITEM:String="USE_EDUCATE_FB_LEADER_ITEM"; //使用队员令牌
		public static var MORAL_VALUE_CHANGED:String="MORAL_VALUE_CHANGED"; //师德值改变
		public static var EDUCATE_FILTER_STUDENTS:String="EDUCATE_FILTER_STUDENTS";
		public static var EDUCATE_SWORN_MENTORING:String="EDUCATE_SWORN_MENTORING";
		public static var EDUCATE_FILTER_TEACHER:String="EDUCATE_FILTER_TEACHER";
		public static var EDUCATE_DROPOUT:String="EDUCATE_DROPOUT";
		public static var EDUCATE_EXPEL:String="EDUCATE_EXPEL";
		public static var EDUCATE_UPGRADE:String="EDUCATE_UPGRADE";
		public static var EDUCATE_MORAL_VALUE_TO_EXP:String="EDUCATE_MORAL_VALUE_TO_EXP";
		public static var EDUCATE_MORAL_VALUE_TO_PK:String="EDUCATE_MORAL_VALUE_TO_PK";
		public static var EDUCATE_INTRODUCE:String="EDUCATE_INTRODUCE";
		//// flower 模块
		public static const OPEN_FLOWER_VIEW:String="OPEN_FLOWER_VIEW";
		public static const USE_FLOWER_GOODS:String="USE_FLOWER_GOODS";

		public static const SHOW_SELECTED_ONE:String="SHOW_SELECTED_ONE";
		public static const BUY_GOODS:String="BUY_GOODS"; //购买物品
		public static const ROLE_OPEN_MY_DETAIL:String="ROLE_OPEN_MY_DETAIL";
		public static const OPEN_OR_CLOSE_MY_DETAIL:String="OPEN_OR_CLOSE_MY_DETAIL"; //打开角色面板
		public static const ONEP_SKILL_TREE:String="ONEP_SKILL_TREE"; //打开技能面板
		public static const OPEN_STOVE_WINDOW:String="OPEN_STOVE_WINDOW"; //打开天公炉
		public static const NEAR_ROLES:String="NEAR_ROLES"; //更新附近玩家列表
		public static const FOLLOW:String="FOLLOW"; // 跟谁
		public static const OPEN_OTHER_DETAIL:String="OPEN_OTHER_DETAIL";
		public static const UPDATE_BLOOD:String="UPDATE_BLOOD";
		public static const ROLE_CHANGE_ATTACK_MODE:String="ROLE_CHANGE_ATTACK_MODE";
		public static const EQUIP_CHANGED:String="EQUIP_CHANGED";
		public static const ROLE_CHANGE_SEX:String="ROLE_CHANGE_SEX";
		public static const ROLE_UPDATE_SEX:String="ROLE_UPDATE_SEX";
		public static const ROLE_CHANGE_HAIR:String="ROLE_CHANGE_HAIR";
		public static const ROLE_PKPOINT_CHANGE:String="ROLE_PKPOINT_CHANGE";
		public static const ROLE_MONUT_PERIOD_CHANGE:String="ROLE_MONUT_PERIOD_CHANGE";

		//// 广播模块 
		public static const BROADCAST:String="BROADCAST";
		public static const BROADCAST_SELF:String="BROADCAST_SELF";
		public static const TIPS:String="TIPS";
		public static const MAP_BROTHER_KILLED:String="MAP_BROTHER_KILLED";
		public static const YBC_NOTIFY_POS:String="YBC_NOTIFY_POS";
		public static const BROADCAST_SHOW:String="BROADCAST_SHOW";


		//商店模块
		public static const OPEN_SHOP_PANEL:String="OPEN_SHOP_PANEL"; //打开商店
//		public static const OPEN_NPC_SHOP:String="OPEN_NPC_SHOP"; //打开NPC商店
		public static const SHOP_OPEN_NPC_SHOP:String="SHOP_OPEN_NPC_SHOP"; //打开NPC商店
		public static const SHOP_OPEN_PET_SHOP:String="SHOP_OPEN_PET_SHOP"; //打开宠物商店
		public static const SHOP_BUY_GOODS:String="SHOP_BUY_GOODS"; //购买物品
		//装备模块
		public static const EQUIP_UNLOAD:String="EQUIP_UNLOAD"; //玩家缷下装备
		public static const EQUIP_ENDURACE_CHANGED:String="EQUIP_ENDURACE_CHANGED"; //装备耐久发生变化
		public static const EQUIP_CHECK_ENDURANCE:String="EQUIP_CHECK_ENDURANCE";
		//技能
		public static const SKILL_LEARN_FROM_BOOK:String="LEARN_FROM_BOOK"; //技能书使用学习技能
		public static const UPDATE_PET_GROW:String="UPDATE_PET_GROW"; //更新技能面板的训宠界面
		//刺探模块
		public static const SPY_FACTION:String="SPY_FACTION"; //
		public static const OPEN_CONTRIBUTE_PANEL:String="OPEN_CONTRIBUTE_PANEL"; //打开贡献面板
		public static const OPEN_PET_SHOP:String="OPEN_PET_SHOP";
		public static const ACTION_RUN_TO_DEAL:String="ACTION_RUN_TO_DEAL";
		public static const GET_POINTS:String="GET_POINTS";
		public static const MOVE_TO:String="MOVE_TO";

		public static const TO_LV_UP:String="TO_LV_UP";
		public static const OPEN_FAMILY:String="OPEN_FAMILY";
		public static const OPEN_ACTIVE:String="OPEN_ACTIVE";
		//大明宝藏副本
		public static const COUNTRY_TREASURE_ENTER:String="ENTER_COUNTRY_TREASURE"; //进入大明宝藏副本
		public static const COUNTRY_TREASURE_QUIT:String="QUIT_COUNTRY_TREASURE"; //退出大明宝藏副本
		public static const OPEN_RIDER_VIEW:String="OPEN_RIDER_VIEW";
		public static const LEVEL_GIFT_TIME_GIFT_LIST:String="LEVEL_GIFT_TIME_GIFT_LIST";

		public static const JAIL_OUT:String="JAIL_OUT";
		public static const JAIL_DONATE:String="JAIL_DONATE";
		public static const JAIL_OUT_FORCE:String="JAIL_OUT_FORCE";

		//采集模块
		public static const COLLECT_STOP:String="COLLECT_STOP"; //停止采集
		public static const REMOVE_COLLECTION:String="REMOVE_COLLECTION"; //采集物消失
		public static const UPDATE_COLLECTION:String="UPDATE_COLLECTION"; //采集物重生
		//抢国王
		public static const ROB_KING_SIGN_UP:String="ROB_KING_SIGN_UP";
		public static const ENTER_KING_ROOM:String="ENTER_KING_ROOM";
		public static const ROB_KING_ONCLICK_THRONE:String="ROB_KING_ONCLICK_THRONE";
		public static const ROB_KING_HOLD_SEAT:String="ROB_KING_HOLD_SEAT";
		public static const ROB_KING_HOLDING:String="ROB_KING_HOLDING";
		public static const ROB_KING_BREAK:String="ROB_KING_BREAK";
		public static const ROB_KING_END:String="public static const";
		//一键换装
		public static const CLOTHING_ID:String="CLOTHING_ID";

		public static const PRESENT_PRESENT_GET:String="PRESENT_PRESENT_GET";


		//国战
		public static const OPEN_FACTION_PANEL:String="OPEN_FACTION_PANEL";
		//场景
		public static const REQUEST_CHANG_MAP:String="REQUEST_CHANG_MAP"; //其他模块请求场景
		public static const REQUEST_JUMP_POS:String="REQUEST_JUMP_POS"; //其他模块请求场景
		public static const NEAR_TALK_RECEIVE:String="NEAR_TALK_RECEIVE"; //附近聊天
		public static const LOCK_WALK:String="LOCK_WALK";
		public static const ACTION_DO_SKILL:String="ACTION_DO_SKILL";
		public static const FAMILY_ENTER:String="FAMILY_ENTER";
		public static const GOTO_BROTHER_KILLED:String="GOTO_BROTHER_KILLED";
		public static const QUIT_ENEMY_CAMP:String="QUIT_ENEMY_CAMP"; //退出讨伐敌营
		public static const OPEN_NPC_PANNEL:String="CLICK_NPC";
		public static const GOTO_COUNTRY_MAP:String="GOTO_COUNTRY_MAP";
		public static const I_AM_RELIVE:String="I_AM_RELIVE";
		public static const ADD_SIGN_ON_MAP:String="ADD_SIGN_ON_MAP";
		public static const CLEAR_SIGN_ON_MAP:String="CLEAR_SIGN_ON_MAP";
		public static const SIT_DOWN:String="SIT_DOWN";
		public static const AUTO_HIT_MONSTER:String="AUTO_HIT_MONSTER";
		public static const SCENE_SHOW_SIGN:String="SCENE_SHOW_SIGN";
		public static const SCENE_CLEAR_SIGN:String="SCENE_CLEAR_SIGN";
		//小地图
		public static const OPEN_PAY_HANDLER:String="OPEN_PAY_HANDLER"; //打开重置页面
		public static const FLASH_SOMETHING:String="FLASH_SOMETHING"; //闪烁
		public static const STOP_FLASH_SOMETHING:String="STOP_FLASH_SOMETHING"; //闪烁
		// VIP
		public static const VIP_PANEL:String="VIP_PANEL"; // 打开VIP面板
		public static const VIP_REMOTE_DEPOT:String="VIP_REMOTE_DEPOT"; //开通VIP远程仓库

		//任务
		public static const OPEN_MISSION_PANNEL:String='OPEN_MISSION_PANNEL'; //打开任务面板
		public static const MISSION_LIST_UPDATE:String='MISSION_LIST_UPDATE'; //任务列表更新
		public static const MISSION_DO:String='MISSION_DO'; //执行任务
		public static const MISSION_CANCEL:String='MISSION_CANCEL'; //取消任务
		public static const MISSION_SHOW_FOLLOW_VIEW:String='MISSION_SHOW_FOLLOW_VIEW'; //显示任务追踪面板
		public static const MISSION_HIDE_FOLLOW_VIEW:String='MISSION_HIDE_FOLLOW_VIEW'; //隐藏任务追踪面板
		public static const MISSION_CHANGE_FOLLOW_VIEW:String='MISSION_CHANGE_FOLLOW_VIEW'; //隐藏/显示任务追踪面板
		public static const MISSION_REQUEST_LIST_AUTO_MISSION:String='MISSION_REQUEST_LIST_AUTO_MISSION';//请求委托任务列表


		//NPC
		public static const NPC_CLICK_MISSION_LINK:String='NPC_CLICK_MISSION_LINK';

		//BGP重连
		public static const BGP_GATEWAY_CONNECT:String='BGP_GATEWAY_CONNECT';
		public static const BGP_STANDBY_RECONNECT_GATEWAY:String='BGP_STANDBY_RECONNECT_GATEWAY'; //通过BGP连接gateway


		// 个人副本
		public static const PERSONAL_FB_LIST:String="PERSONAL_FB_LIST";
		public static const PERSONAL_FB_ROLE_DEAD:String="PERSONAL_FB_ROLE_DEAD";
		public static const PERSONAL_FB_QUIT:String="PERSONAL_FB_QUIT";
		public static const PERSONAL_FB_NEXT_LEVEL:String="PERSONAL_FB_NEXT_LEVEL";

		// 英雄副本
		public static const HERO_FB_ROLE_DEAD:String="HERO_FB_ROLE_DEAD";

		// 任务副本
		public static const MISSION_FB_ROLE_DEAD:String="MISSION_FB_ROLE_DEAD";

		/**
		 * 任务更新守边视图的vo
		 */
		public static const MISSION_UPDATE_SHOU_BIAN_TIME_VIEW_VO:String='MISSION_UPDATE_SHOU_BIAN_TIME_VIEW_VO';
		/**
		 * 任务移除守边视图
		 */
		public static const MISSION_REMOVE_SHOU_BIAN_TIME_VIEW:String='MISSION_REMOVE_SHOU_BIAN_VIEW';
		/**
		 * 守边任务状态切换
		 */
		public static const MISSION_SHOU_BIAN_STATUS_CHANGE:String='MISSION_SHOU_BIAN_STATUS_CHANGE';


		//resize
		public static const STAGE_RESIZE:String="STAGE_RESIZE";
		public static const HIDE_ROLES:String = "HIDE_ROLES";

		//车夫链接被点击
		public static const NPC_DRIVER_LINK_CLICK:String='NPC_DRIVER_CLICK';
		//点击领取道具奖励
		public static const GIFT_ITEM_AWARD:String="GIFT_ITEM_AWARD"; //领取道具奖励
		public static const GIFT_ITEM_TIP_SHOW:String="GIFT_ITEM_TIP_SHOW"; //领取道具奖励提示
		public static const GIFT_ITEM_TIP_CLOSE:String="GIFT_ITEM_TIP_CLOSE"; //关闭领取道具奖励提示

		//自动任务 玩家选择了
		public static const MISSION_AUTO_SELECTED:String='mission_auto_selected';
		// 自动任务 玩家取消了选择
		public static const MISSION_AUTO_UN_SELECTED:String='mission_auto_un_selected';
		//自动任务 发起自动任务
		public static const MISSION_AUTO_DO:String='MISSION_AUTO_DO';


		public static const OPEN_PACK_PANEL_WHEN_NOT_POP_UP:String="OPEN_PACK_PANEL_WHEN_NOT_POP_UP"; //打开背包窗口 如果窗口没有打开的花

		public static const MISSION_NEW_PLAYER_PET_TASK:String="MISSION_NEW_PLAYER_PET_TASK"; //新手任务出战宠物

		//打开创奇目标面板
		public static const OPEN_GOAL_PANEL:String="OPEN_GOAL_PANEL";

		public static const HIDE_GUIDE_TIP:String="HIDE_GUIDE_TIP";
		public static const HIDE_MISSION_NPC_PANEL:String="HIDE_MISSION_NPC_PANEL";
		public static const SHOW_MISSION_NPC_PANEL:String="SHOW_MISSION_NPC_PANEL";

		//传奇目标指令
		public static const OPEN_TRAIN_PET:String="OPEN_TRAIN_PET";
		public static const OPEN_CAREER_SKILL_PANEL:String="OPEN_CAREER_SKILL_PANEL";
		public static const OPEN_EDUCATE_VIEW:String="OPEN_EDUCATE_VIEW";
		public static const OPEN_PET_APTITUDE:String="OPEN_PET_APTITUDE";
		public static const OPEN_ROLE_ATTR_PANEL:String="OPEN_ROLE_ATTR_PANEL";

		public static const OPEN_EQUIP_PUNCH:String="OPEN_EQUIP_PUNCH";
		public static const OPEN_EQUIP_EXALT:String="OPEN_EQUIP_EXALT";
		public static const OPEN_EQUIP_BIND:String="OPEN_EQUIP_BIND";
		public static const OPEN_EQUIP_UPGRADE:String="OPEN_EQUIP_UPGRADE";
		public static const OPEN_EQUIP_BOX:String="OPEN_EQUIP_BOX";
		public static const OPEN_EQUIP_COMPOSE:String="OPEN_EQUIP_COMPOSE";
		public static const OPEN_EQUIP_REFINE:String = "OPEN_EQUIP_REFINE";
		//
		public static const GOAL_START_FLICK:String="GOAL_START_FLICK";
		public static const SHOW_HIT_MONSTER_GUIDE:String = "SHOW_HIT_MONSTER_GUIDE";
		
		//网络延时指令
		public static const NET_PING_VALUE:String = "NET_PING_VALUE";
		
		//打开队伍窗口
		public static const OPEN_TEAM_PANEL:String = "OPEN_TEAM_PANEL";
		//改变拾取模式
		public static const CHANGE_PICK_MODE:String = "CHANGE_PICK_MODE";
		public static const OPEN_PRESTIGE_PANEL:String = "OPEN_PRESTIGE_PANEL";
		
		public static const PRESTIGE_CHANGED:String = "PRESTIGE_CHANGED";
		public static const HEART_BEAT:String = "HEART_BEAT";
		public static const ACT_FOLLOW_LIST_CHANGED:String = "ACT_FOLLOW_LIST_CHANGED";
		public static const MP_AUTOUSE_CHANGE:String = "MP_AUTOUSE_CHANGE";
		public static const HP_AUTOUSE_CHANGE:String = "HP_AUTOUSE_CHANGE";	
		public static const SYSTEM_CONFIG_INIT:String = "SYSTEM_CONFIG_INIT";
		public static const OPEN_MY_SHOP:String = "OPEN_MY_SHOP";
		public static const BUYBACK_CHANGED:String = "BUYBACK_CHANGED";
		public static const RUSH_GOODS_UPDATE:String = "RUSH_GOODS_UPDATE";
		public static const OPEN_BOSSGROUP_PANEL:String = "OPEN_BOSSGROUP_PANEL";
		public static const OPEN_ACHIEVEMENT_PANEL:String = "OPEN_ACHIEVEMENT_PANEL";
		
		public static const TEAM_AUTO_APPLY_CHANGE:String = "TEAM_AUTO_APPLY_CHANGE";
		
		public static const SYSTEM_CONFIG_AUTO_TEAM_CHANGE:String = "SYSTEM_CONFIG_AUTO_TEAM_CHANGE";
		
		public static const PET_CURRENT_INFO_CHANGE:String="PET_CURRENT_INFO_CHANGE";
		public static const PET_INFO_UPDATE:String="PET_INFO_UPDATE";
		public static const PET_SKILLS_UPDATE:String="PET_SKILLS_UPDATE";
		public static const PET_TRAINING_INFO_UPDATE:String="PET_TRAINING_INFO_UPDATE";
		public function ModuleCommand() {
		}
	}
}