%%%----------------------------------------------------------------------
%%% File    : global_lang.hrl
%%% Author  : odinxu
%%% Created : 2010-01-08
%%% Description: Language constant
%%%				多国语言支持，只需要修改这个文件就行。
%%%				程序中所有需要直接使用字符串（特别是中文）输出结果的，
%%%				务必得设置成这个文件里的常量。
%%%	
%%% 命名规定 :  1. 必须全部以 _LANG_ 开头
%%%			   2. 紧接着是 模块名
%%%			   3. 接着是操作名
%%%			   4. 最后是成功 OK， 失败 FAIL，跟着的是原因
%%%----------------------------------------------------------------------


%%----------------------  通用的     ----------------------
-define(_LANG_GAME_NAME,<<"天之刃">>).
-define(_LANG_PARAM_ERROR,<<"参数错误">>).
-define(_LANG_SYSTEM_ERROR, <<"系统错误">>).
-define(_LANG_BAG_ERROR, <<"背包错误">>).
-define(_LANG_FACTION_1, <<"云州">>).
-define(_LANG_FACTION_2, <<"沧州">>).
-define(_LANG_FACTION_3, <<"幽州">>).
-define(_LANG_COLOR_FACTION_1, <<"<font color=\"#00FF00\">云州</font>">>).
-define(_LANG_COLOR_FACTION_2, <<"<font color=\"#F600FF\">沧州</font>">>).
-define(_LANG_COLOR_FACTION_3, <<"<font color=\"#00CCFF\">幽州</font>">>).
-define(_LANG_FACTION_UNKNOW, <<"未知的国家">>).
-define(_LANG_UNIT_SILVER_1, "文").
-define(_LANG_UNIT_SILVER_2, "两").
-define(_LANG_UNIT_SILVER_3, "锭").
-define(_LANG_BIND_SILVER, "绑定银子").
-define(_LANG_SILVER, "银子").
-define(_LANG_GOLD_BIND, "绑定元宝").
-define(_LANG_GOLD, "元宝").
-define(_LANG_EXP, "经验").
-define(_LANG_TIMEOUT, "超时").
%%----------------------  登录系统  ----------------------

-define(_LANG_LOGIN_WRONG_PWD, <<"密码错误">>).
-define(_LANG_LOGIN_SYSTEM_ERROR, <<"系统错误">>).
-define(_LANG_LOGIN_FCM_LIMIT, <<"您今天在线超过3个小时，且离线时间不满足5小时，无法继续游戏。请尽快录入您的防沉迷资料">>).
-define(_LANG_LOGIN_TICKET_EXPIRED, <<"登录数据超时，请返平台重新登录">>).
-define(_LANG_LOGIN_WRONG_TICKET, <<"错误的登录数据，请返回平台重新登录">>).
-define(_LANG_LOGIN_ROLE_BAN,<<"您的角色已经被封禁,有疑问请联系GM">>).
-define(_LANG_LOGIN_IP_BAN,<<"你的IP段已经被封禁,有疑问请联系GM">>).
-define(_LANG_LOGIN_NOT_IMPLEMENT, <<"该登录方法尚未实现">>).

-define(_LANG_AUTH_KEY_WRONG_KEY, <<"错误的验证包">>).

%%---------------------  充值 --------------------------

-define(_LANG_PAY_ACCOUNT_NOT_FOUND, <<"玩家账号不存在">>).
-define(_LANG_PAY_DUPLICATED, <<"重复的订单号">>).
-define(_LANG_PAY_FIRST_TITLE, <<"充值送礼包">>).


%%---------------------  防沉迷  -------------------------
-define(_LANG_FCM_TIME_LIMIT, "请尽快更新您的防沉迷资料，未录入防沉迷资料的玩家，按照国家有关规定，游戏时间累计到达3小时将强制下线").
-define(_LANG_FCM_SYSTEM_ERROR_WHEN_REQUEST_PLATFORM, <<"请求平台验证防沉迷资料失败，请稍后重新尝试">>).

-define(_LANG_AUTH_WRONG_PACKET, <<"认证包错误，请刷新页面重新进入游戏">>).
%%----------------------  账号系统  ----------------------

-define(_LANG_ACCOUNT_NOT_EXISTS, 			<<"账号不存在">>).
-define(_LANG_ACCOUNT_NAME_EXISTS, 			<<"账号名已存在">>).
-define(_LANG_ACCOUNT_EMPTY, 				<<"账号名不能为空">>).
-define(_LANG_ACCOUNT_CREATE_FAILED,        <<"创建账号失败">>).
-define(_LANG_ACCOUNT_ALREADY_EXISTS_ROLE,  <<"该账号已经创建了角色">>).

%%----------------------  角色系统  ----------------------

-define(_LANG_ROLENAME_NOT_VALID_CHAR, <<"用户名只能由中文英文以及数字组成">>).
-define(_LANG_ROLE_MAX_COUNT_LIMIT, <<"创建角色数量已达系统限制">>).
-define(_LANG_ROLE_NAME_EXIST, <<"角色名已存在">>).
-define(_LANG_ROLE_NOT_EXISTS, <<"角色不存在">>).
-define(_LANG_ROLENAME_CANNT_EMPTY, <<"角色名不能为空">>).
-define(_LANG_NOT_VALID_SEX, <<"性别非法">>).
-define(_LANG_NOT_VALID_SKINID, <<"形象非法">>).
-define(_LANG_NOT_VALID_FACTION, <<"国家选择错误">>).
-define(_LANG_ROLENAME_BAN_WORDS, <<"字符串中包含敏感字">>).
-define(_LANG_TITLE_NOT_EXIST, <<"没有该称号">>).
-define(_LANG_ROLE_ID_IS_EXIST, <<"严重问题：角色数据出现异常！请马上联系GM！">>).
-define(_LANG_ROLE_ACCOUNT_TYPE_GUEST_NOT_OPEN, <<"游客模式的进入游戏功能维护中">>).

-define(_LANG_ROLE_STATE_ZAZEN_STRING, <<"正在打坐中">>).
-define(_LANG_ROLE_STATE_TRAINING_STRING, <<"正在训练中">>).
-define(_LANG_ROLE_STATE_DEAD_STRING, <<"死亡状态中">>).
-define(_LANG_ROLE_STATE_STALL_SELF_STRING, <<"正在亲自寄售中">>).
-define(_LANG_ROLE_STATE_STALL_AUTO_STRING, <<"正在自动寄售中">>).
-define(_LANG_ROLE_STATE_YBC_FAMILY_STRING, <<"正在门派拉镖中">>).
-define(_LANG_ROLE_STATE_NORMAL_STRING, <<"正常状态中">>).
-define(_LANG_ROLE_STATE_FIGHT_STRING, <<"正在战斗中">>).
-define(_LANG_ROLE_STATE_EXCHANGE_STRING, <<"正在交易中">>).
-define(_LANG_ROLE_STATE_COLLECT_STRING, <<"正在采集中">>).


%%----------------------  好友系统  ----------------------
-define(_LANG_FRIEND_REQUEST_SELF,        <<"不能邀请自己">>).
-define(_LANG_FRIEND_NO_REQUEST,          <<"没有收到邀请">>).
-define(_LANG_FRIEND_BLACK_ADDSELF,       <<"不能添加自己进黑名单">>).
-define(_LANG_FRIEND_NOT_IN_LIST,         <<"不在当前列表中">>).
-define(_LANG_FRIEND_TARGET_FULL,         <<"对方好友人数已达上限">>).
-define(_LANG_FRIEND_FRIEND_ALREADY,      <<"对方已经是你的好友">>).
-define(_LANG_FRIEND_IN_TARGET_BLACK,     <<"在对方黑名单中，不能发送邀请">>).
-define(_LANG_FRIEND_IN_TARGET_ENEMY,     <<"你是对方的仇人，不能发送邀请">>).
-define(_LANG_FRIEND_FRIEND_FULL,         <<"好友人数已达上限">>).
-define(_LANG_FRIEND_ROLE_NOT_EXIST,      <<"角色不存在">>).
-define(_LANG_FRIEND_TARGET_ENEMY,        <<"不能向仇人发送邀请，请先删除仇人后再邀请加为好友">>).
-define(_LANG_FRIEND_BLACK_ALREADY,       <<"对方已经在你的黑名单中">>).
-define(_LANG_FRIEND_ALREADY_ENEMY,       <<"对方已经你的仇人">>).
-define(_LANG_FRIEND_ENEMY_FRIEND,        <<"不能添加自己的好友为仇人">>).
-define(_LANG_FRIEND_REQUEST_ALREADY,     <<"已经在对方的请求列表之中">>).
-define(_LANG_FRIEND_NO_FRIEND,           <<"不是好友，不能查看对方的信息">>).
-define(_LANG_FRIEND_ENEMY_BAD_TYPE,      <<"不能添加角色以外的类型为仇人">>).
-define(_LANG_FRIEND_IN_ENEMY,            <<"对方在你的仇人列表中">>).
-define(_LANG_FRIEND_IN_BLACK,            <<"对方在你的黑名单中">>).
-define(_LANG_FRIEND_BLACK_SPEC_RELA,     <<"不能将有特殊关系的好友加入黑名单">>).
-define(_LANG_FRIEND_DEL_SPEC_RELA,       <<"不能删除有特殊关系的好友">>).
-define(_LANG_FRIEND_ENEMY_ADD_FRIEND,    <<"不能添加自己为仇人">>).
-define(_LANG_FRIEND_CONGRATULA_TIME_PASS, <<"好友已下线或再次升级，祝福失败">>).
-define(_LANG_FRIEND_CONGRATULA_EVER_CONGRATULA, <<"祝福无效，已经发送过祝福">>).
-define(_LANG_FRIEND_CONGRATULA_NOT_YOUR_FRIEND, <<"祝福失败，对方不是你的好友">>).
-define(_LANG_FRIEND_TARGET_REFUSE, <<"邀请已被对方拒绝">>).
-define(_LANG_FRIEND_KILL_FRIEND, <<"恶意杀死好友，扣除~w点好友度">>).
-define(_LANG_FRIEND_ONLINE_ACCEPT, <<"恭喜你与~s结为好友">>).
-define(_LANG_FRIEND_ONLINE_REFUSE, <<"~s拒绝了你的好友请求">>).
-define(_LANG_FRIEND_LETTER_TITLE, <<"好友系统的温馨提示">>).
-define(_LANG_FRIEND_LEVEL_CHANGE_MESSAGE,<<"恭喜你与[<font color=\"#ffff00\">~s</font>]结为\"<font color=\"#ff0000\">~s</font>\"，双方同屏组队时可同时提升物理攻击和法力攻击 <font color=\"#ff0000\">~s</font> 点">>).
-define(_LANG_FRIEND_BOTTLE_OP_TYPE, <<"查询经验瓶操作类型出错">>).
-define(_LANG_FRIEND_BOTTLE_EXP_NULL, <<"没有经验可领取">>).
-define(_LANG_FRIEND_BOTTLE_MIN_LEVEL, <<"角色等级达到32级才能领取经验">>).

%%----------------------  聊天系统  ----------------------

-define(_LANG_CHAT_TOO_FAST, <<"发言间隔时间小于3秒">>).
-define(_LANG_CHAT_AUTH_LOGIN_FAIL, <<"验证登录失败">>).
-define(_LANG_CHAT_ROLE_NOT_EXISTS, <<"玩家不存在">>).
-define(_LANG_CHAT_ROLE_NOT_ONLINE, <<"该玩家已经离线">>).
-define(_LANG_CHAT_ROLE_IN_BLACKLIST, <<"不能向黑名单玩家发送信息">>).
-define(_LANG_CHAT_GOODS_NOT_FOUND, <<"无法找到该物品">>).
-define(_LANG_CHAT_WORLDCHAT_NEED_MONEY, <<"您的银子不足，世界聊天需要至少2两银子">>).
-define(_LANG_CHAT_KING_BAN_BROADMSG, <<"<font color=\"#FFFF00\">[~s]</font>触怒了国王，被国王禁言~w分钟">>).
-define(_LANG_CHAT_KING_BAN_REASON, <<"被国王禁言">>).
-define(_LANG_CHAT_KING_BAN_COUNTS, <<"禁言失败，您今天禁言次数已满10次">>).
-define(_LANG_CHAT_KING_BAN_MSG, <<"你今天还有~b次禁言机会">>).
%%----------------------  战斗系统  ----------------------
-define(_LANG_FIGHT_NOT_IN_ATTACK_RANGE, 	<<"不在攻击范围内">>).
-define(_LANG_PK_MODE_NOT_EXIST,            <<"战斗模式不存在">>).
-define(_LANG_FIGHT_TARGET_CAN_NOT_EFFECT,  <<"作用目标无效">>).
-define(_LANG_FIGHT_CAN_NOT_USE_SKILL,      <<"无法使用该技能">>).
-define(_LANG_FIGHT_CANT_ATTACK,            <<"攻击无效，对方不满十级或在安全区内">>).
-define(_LANG_FIGHT_ATTACK_SPEED_ILLEGAL,   <<"攻击间隔没到，攻击无效">>).
-define(_LANG_FIGHT_ACTOR_DEAD, <<"死亡状态无法发起攻击">>).
-define(_LANG_FIGHT_ACTOR_PAPALYSIS, <<"麻痹状态不能使用技能">>).
-define(_LANG_FIGHT_ACTOR_SILENT, <<"震慑状态不能使用技能">>).
-define(_LANG_FIGHT_ACTOR_DIZZY, <<"晕眩状态不能使用技能">>).
-define(_LANG_FIGHT_ACTOR_UNBEAT, <<"无敌状态不能使用技能">>).
-define(_LANG_FIGHT_ILLEGAL_SKILL_INTERVAL, <<"攻击无效，技能冷却时间没到">>).
-define(_LANG_FIGHT_SKILL_CANT_ATTACK_TARGET, <<"该技能对目标无效">>).
-define(_LANG_FIGHT_ENEMY_PK_PEACE, <<"和平模式下不能攻击目标">>).
-define(_LANG_FIGHT_TARGET_TRAINING, <<"攻击无效，对方处于训练状态中">>).
-define(_LANG_FIGHT_IN_SAFE_AREA, <<"在安全区内不能发起攻击">>).
-define(_LANG_FIGHT_ENEMY_PK_TEAM, <<"组队模式下不能攻击队友">>).
-define(_LANG_FIGHT_FRIEND_PK_TEAM, <<"组队模式下不能对非队友使用该技能">>).
-define(_LANG_FIGHT_ATTACK_LESS_THAN_PROTECTED_LEVEL, <<"低于保护等级不能发起攻击">>).
-define(_LANG_FIGHT_TARGET_IN_SAFE_AREA, <<"攻击无效，对方在安全区内">>).
-define(_LANG_FIGHT_ENEMY_PK_FAMILY, <<"门派模式下不能对攻击本门派的成员">>).
-define(_LANG_FIGHT_FRIEND_PK_FAMILY, <<"门派模式下不能对不同门派的成员使用该技能">>).
-define(_LANG_FIGHT_ATTACKED_LESS_THAN_PROTECTED_LEVEL, <<"不能攻击低于保护等级的玩家及其宠物">>).
-define(_LANG_FIGHT_ENEMY_PK_FACTION, <<"国家模式下不能攻击本国玩家">>).
-define(_LANG_FIGHT_FRIEND_PK_FACTION, <<"国家模式下不能对外国玩家使用该技能">>).
-define(_LANG_FIGHT_ENEMY_PK_MASTER, <<"善恶模式下不能攻击非灰名或红名的玩家">>).
-define(_LANG_FIGHT_FRIEND_PK_MASTER, <<"善恶模式下不能对目标使用该技能">>).
-define(_LANG_FIGHT_SKILL_JUST_SELF, <<"攻击无效，该技能只能对自己释放">>).
-define(_LANG_FIGHT_SKILL_JUST_MONSTER, <<"攻击无效，该技能只能对怪物释放">>).
-define(_LANG_FIGHT_SKILL_JUST_PET, <<"攻击无效，该技能只能对宠物释放">>).
-define(_LANG_FIGHT_SKILL_JUST_YBC, <<"攻击无效，该技能只能对镖车释放">>).
-define(_LANG_FIGHT_SKILL_JUST_FRIEND, <<"攻击无效，该技能只能对盟友释放">>).
-define(_LANG_FIGHT_SKILL_JUST_ROLE, <<"攻击无效，该技能不能对怪物释放">>).
-define(_LANG_FIGHT_CHARGE_BARRIER_IN_FRONT, <<"前面有阻挡，不能使用冲锋技能">>).
-define(_LANG_FIGHT_CANT_RELIVE_ALIVE, <<"该技能只能作用于死亡的角色">>).
-define(_LANG_FIGHT_CANT_RELIVE_ACTOR, <<"该技能只能对角色释放">>).
-define(_LANG_FIGHT_TARGET_UNDEAD, <<"攻击无效，目标无敌">>).
-define(_LANG_FIGHT_NPC_FACTION, <<"国家模式下不能攻击本国NPC">>).
-define(_LANG_FIGHT_TARGET_STALL, <<"攻击无效，对方在寄售状态中">>).
-define(_LANG_FIGHT_ERROR_ACTOR_DEAD, <<"攻击失败，目标已死亡">>).
-define(_LANG_FIGHT_ERROR_ACTOR_CHANGE_SKIN, <<"不能对变身状态下的玩家进行攻击">>).
-define(_LANG_FIGHT_ACTOR_CHANGE_SKIN, <<"变身状态下无法进行战斗">>).
-define(_LANG_FIGHT_CANT_ATTACK_NPC_IN_WAROFFACTION, <<"国战期间不能攻击本国NPC">>).
-define(_LANG_FIGHT_CANT_ATTACK_OTHER_NPC_IN_WAROFFACTION, <<"国战期间不能攻击防守方的战斗NPC">>).
-define(_LANG_FIGHT_BONFIRE_INVINCIBLE, <<"对方喝醉了正被篝火沐浴,潜能爆发，状态无敌">>).
-define(_LANG_FIGHT_NPC_MASTER_MODE, <<"善恶模式下不能攻击NPC">>).


%%----------------------  组队系统  ----------------------
-define(_LANG_TEAM_NOT_IN,				<<"你不在队伍中">>).
-define(_LANG_TEAM_READ_ROLE_ATTR,		        <<"获取玩家属性异常，操作失败">>).
-define(_LANG_TEAM_AUTO_DISBAND,		        <<"队伍人数少于2人，自动解散队伍">>).
-define(_LANG_TEAM_LEADER_AUTHORITY,		<<"对不起，这个只有队长才能操作">>).
-define(_LANG_TEAM_NOT_EXIST,		        <<"队伍不存在，操作失败">>).
-define(_LANG_TEAM_PROCESS_EXCEPTION,		<<"系统出错，队伍自动解散">>).
-define(_LANG_TEAM_CREATE_FAIL,			<<"创建队伍失败">>).
-define(_LANG_TEAM_SYSTEM_BUSY,		<<"系统繁忙请重新操作">>).
-define(_LANG_TEAM_INVITE_FAIL,		<<"邀请失败">>).
-define(_LANG_TEAM_CREATE_FAIL_OFFLINE,		<<"创建队伍失败，创建时玩家突然不在线">>).
-define(_LANG_TEAM_INVITE_FAIL_OFFLINE,		<<"邀请失败，对方不在线">>).
-define(_LANG_TEAM_INVITE_FAIL_SELF,		<<"邀请失败，不能邀请自己">>).
-define(_LANG_TEAM_INVITE_FAIL_EXIST,		<<"邀请失败，对方有队伍了">>).
-define(_LANG_TEAM_INVITE_FAIL_IN_SAME_TEAM,		<<"邀请失败，对方已经在队伍了">>).
-define(_LANG_TEAM_INVITE_FAIL_COUNTRY,		<<"邀请失败，不同国家的玩家不能一起组队">>).
-define(_LANG_TEAM_INVITE_FAIL_INSERT_DATA,		<<"邀请失败，记录邀请数据时失败">>).
-define(_LANG_TEAM_INVITE_FAIL_MAX_LIMIT,		<<"邀请失败，当前队伍已经满员">>).
-define(_LANG_TEAM_INVITE_FAIL_REPEAT,		<<"邀请失败，你已经邀请，请不要重复邀请">>).
-define(_LANG_TEAM_ACCEPT_FAIL,	        <<"加入队伍失败">>).
-define(_LANG_TEAM_ACCEPT_FAIL_DO_DO,	        <<"加入队伍失败，操作过快">>).
-define(_LANG_TEAM_ACCEPT_FAIL_INVITED_OFFLINE,	        <<"加入队伍失败，邀请你加入队伍的玩家已经下线">>).
-define(_LANG_TEAM_ACCEPT_FAIL_NOT_INVITE,	        <<"加入队伍失败，对方队伍已解散">>).
-define(_LANG_TEAM_ACCEPT_FAIL_JOIN_TEAM,	        <<"加入队伍失败，对方已有队伍">>).
-define(_LANG_TEAM_ACCEPT_FAIL_DIFF_TEAM_ID,	        <<"加入队伍失败，队伍ID跟参数ID不一致">>).
-define(_LANG_TEAM_ACCEPT_REPEAT,			<<"加入队伍失败，你已经在队伍中">>).
-define(_LANG_TEAM_ACCEPT_FAIL_MAX_LIMIT,	        <<"加入队伍失败，该队伍人数已满">>).
-define(_LANG_TEAM_ACCEPT_FAIL_GET_TEAM_ID,	        <<"创建队伍失败，获取队伍Id异常">>).
-define(_LANG_TEAM_ACCEPT_FAIL_SYN_TEAM_ID,	        <<"加入队伍失败，同步队伍信息出错">>).
-define(_LANG_TEAM_REFUSE_FAIL_NOT_INVITE,	        <<"拒绝失败，对方没有邀请你加入">>).
-define(_LANG_TEAM_FOLLOW_FAIL_IS_LEADER,	        <<"跟随失败，队长不能自己跟随自己">>).
-define(_LANG_TEAM_FOLLOW_FAIL_REPEAT,		<<"请不需要重复设置跟随操作">>).
-define(_LANG_TEAM_FOLLOW_FAIL_NOT_VALID,		<<"设置跟随参数无效">>).
-define(_LANG_TEAM_FOLLOW_FAIL_TOO_FAR,		<<"跟随失败，跟队长距离太远">>).
-define(_LANG_TEAM_CHANGE_LEADER_FAIL_NOT_IN2,	<<"被转让的人不在队伍中">>).
-define(_LANG_TEAM_CHANGE_LEADER_FAIL_TO_SELF,	<<"不能转让给自己">>).
-define(_LANG_TEAM_CHANGE_LEADER_FAIL_TO_OFFLINE,	<<"转让失败，此队员此时掉线">>).
-define(_LANG_TEAM_KICK_FAIL_NOT_IN,		<<"踢人失败，对方不在队伍内">>).
-define(_LANG_TEAM_KICK_FAIL_SELF,			<<"踢人失败，不能踢自己">>).
-define(_LANG_TEAM_KICK_SUCC,			<<"你被请离队伍">>).
-define(_LANG_TEAM_LIST_FAIL_EXIST_TEAM_ID,		<<"获取队伍列表信息出错，队伍已经不存在">>).
-define(_LANG_TEAM_PICK_TYPE_NOT_VALID,		<<"队伍物品拾取模式无效">>).
-define(_LANG_TEAM_PICK_TYPE_REPEAT,		<<"不要重复设置队伍物品拾取模式">>).
-define(_LANG_TEAM_LEADER_DISBAND,		        <<"队长解散队伍">>).
-define(_LANG_TEAM_MEMBER_INVITE_PARAM,		<<"队员邀请玩家加入队伍失败">>).
-define(_LANG_TEAM_MEMBER_INVITE_REFUSE_L,		<<"您拒绝队员邀请玩家加入队伍">>).
-define(_LANG_TEAM_MEMBER_INVITE_REFUSE_M,		<<"队长拒绝您邀请玩家加入队伍">>).
-define(_LANG_TEAM_MEMBER_INVITE_ACCEPT_L,		<<"您同意队员邀请玩家加入队伍">>).
-define(_LANG_TEAM_MEMBER_INVITE_ACCEPT_M,		<<"队长同意您邀请玩家加入队伍">>).
-define(_LANG_TEAM_MEMBER_INVITE_TEAM,		<<"加入队伍失败，队伍已经解散">>).

-define(_LANG_TEAM_APPLY_SELF,		<<"不可以申请加入自己队伍">>).
-define(_LANG_TEAM_APPLY_ROLE_OFF_LINE,		<<"玩家不在线，申请加入队伍失败">>).
-define(_LANG_TEAM_APPLY_ROLE_ON_TEAM,		<<"对方没有在队伍中，申请加入队伍失败">>).
-define(_LANG_TEAM_APPLY_ROLE_IN_TEAM,		<<"你已经有队伍，不可申请入队">>).
-define(_LANG_TEAM_APPLY_ROLE_IN_SAME_TEAM,		<<"你已经加入本队伍，不可申请入队">>).
-define(_LANG_TEAM_APPLY_ROLE_ON_TEAM_ERROR,		<<"对方队伍已经解散，申请加入队伍失败">>).
-define(_LANG_TEAM_APPLY_ROLE_MAX_MEMBER,		<<"队伍已经满员，加入队失败">>).
-define(_LANG_TEAM_APPLY_NO_TEAM_LEADER,		<<"申请加入队伍失败">>).

-define(_LANG_TEAM_APPLY_TEAMLEADER_ON_TEAM,		<<"你已退出队伍，操作失败">>).
-define(_LANG_TEAM_APPLY_TEAMLEADER_TEAM_ERROR,		<<"队伍出错，操作失败">>).
-define(_LANG_TEAM_APPLY_TEAMLEADER_ROLE_OFF_LINE,		<<"申请入队玩家已经不在线">>).
-define(_LANG_TEAM_APPLY_TEAMLEADER_ROLE_IN_TEAM,		<<"玩家已经加入队伍了">>).
-define(_LANG_TEAM_APPLY_TEAMLEADER_REFUSE,		<<"队长拒绝你申请入队">>).
-define(_LANG_TEAM_APPLY_TEAMLEADER_NO_LEADER,		<<"你不是队长，操作失败">>).
-define(_LANG_TEAM_APPLY_ERROR,		<<"操作失败">>).
-define(_LANG_TEAM_APPLY_JOIN_ERROR,		<<"加入队伍失败">>).
-define(_LANG_TEAM_APPLY_FAIL_COUNTRY,		<<"申请失败，不同国家的玩家不能一起组队">>).
-define(_LANG_TEAM_MEMBER_ROLE_UP_LEVEL_BC,		<<"<font color=\"#58F1FF\">队友[~s]升到 ~s 级了</font>">>).

-define(_LANG_TEAM_QUERY_OP_TYPE_ERROR,<<"查询类型出错">>).
-define(_LANG_TEAM_QUERY_ERROR,<<"查询出错">>).  

-define(_LANG_TEAM_CREATE_ERROR,<<"创建队伍失败，请稍后重试">>). 
-define(_LANG_TEAM_CREATE_HAS_TEAM,<<"创建队伍失败，你已经加入队伍">>). 
-define(_LANG_TEAM_CREATE_DO_DO_DO,<<"创建队伍失败，操作过快">>).

%%----------------------  行走系统  ----------------------
-define(_LANG_WALK_CANNOT_PASS,				<<"该点不可行走">>).


%%----------------------  xx系统  ----------------------
    
    
%%----------------------  s2s系统  ----------------------
-define(_LANG_UNKNOW_REQURES, <<"未知请求">>).
-define(_LANG_KEY_TIME_LIMIT, <<"验证时间过期">>).
-define(_LANG_KEY_NOT_VALID, <<"Key非法">>).

%%----------------------  聊天频道 ----------------------
-define(_LANG_CHANNEL_WORLD, <<"世界">>).
-define(_LANG_CHANNEL_FACTION, <<"国家">>).
-define(_LANG_CHANNEL_TEAM, <<"组队">>).
-define(_LANG_CHANNEL_FAMILY, <<"门派">>).


-define(_LANG_SYSTEM_MAINTAIN, <<"系统维护，暂时无法登陆">>).
-define(_LANG_ROLE2_NOT_FOUND, <<"没有指定角色">>).
-define(_LANG_CHAT_NOT_IN_CHANNEL, <<"您没有在该频道中">>).
-define(_LANG_CHAT_ROLE_IS_BANNED, <<"您已经被禁言~w分钟">>).
%% 此处一定要使用~s
-define(_LANG_CHAT_ROLE_BANNED_ENDTIME, <<"您当前处于禁言状态，结束时间：~s">>).

-define(_LANG_FIGHT_TARGET_NOT_EXIST, <<"目标不存在">>).
-define(_LANG_FIGHT_NOT_IMPLEMENT, <<"尚未实现">>).
-define(_LANG_FIGHT_NO_TARGET, <<"指定位置无目标">>).
-define(_LANG_FIGHT_SAFE_NOT_ALLOW, <<"安全区不允许战斗">>).
-define(_LANG_FIGHT_AREA_CANNT_ATTACK, <<"该区域不可攻击">>).
-define(_LANG_FIGHT_SKILL_CANNT_TO_SELF, <<"该技能不能对自己释放">>).
-define(_LANG_FIGHT_NO_EFFECT, <<"无效攻击">>).
-define(_LANG_SKILL_NOT_EXIST, <<"技能不存在">>).
-define(_LANG_CHANNEL_NOT_EXISTS, <<"频道不存在，可能已被删除">>).
%%----------------------  角色系统  ----------------------

-define(_LANG_ROLE2_NO_ENOUGH_POINTS, <<"属性点不足">>).
-define(_LANG_NOT_ENOUGH_GOLD, <<"元宝不足">>).
-define(_LANG_NOT_ENOUGH_SILVER, <<"银子不足">>).
-define(_LANG_ROLE2_WRONG_STATUS, <<"当前模式下不能打坐">>).
-define(_LANG_ROLE2_FIVE_ELE_ATTR_PARAM, <<"参数出错，修改五行属性">>).
-define(_LANG_ROLE2_FIVE_ELE_ATTR_LEVEL, <<"角色级别不够，不能获取五行属性">>).
-define(_LANG_ROLE2_FIVE_ELE_ATTR_TYPE, <<"获取五行属性失败，参数出错">>).
-define(_LANG_ROLE2_FIVE_ELE_ATTR_FEE, <<"获取失败，已经有五行属性，不可以再次免费获取">>).
-define(_LANG_ROLE2_FIVE_ELE_ATTR_ERROR, <<"获取五行属性异常">>).
-define(_LANG_ROLE2_FIVE_ELE_ATTR_NOT_FEE, <<"操作失败，费用不足">>).
-define(_LANG_ROLE2_FIVE_ELE_ATTR_RE_GET, <<"不能重洗五属性，角色还没有五行属性">>).
-define(_LANG_ROLE2_RELIVE_TIME_LIMIT, <<"等待时间没到，不能进行原地复活">>).
-define(_LANG_ROLE2_LEVELUP_TRAINING, <<"训练状态下无法升级">>).
-define(_LANG_ROLE2_ADD_EXP_EXP_FULL, <<"<font color='#ff0000'>当前经验已储满，升级后才能获得经验</font>">>).
-define(_LANG_ROLE2_ADD_EXP_TRAINING_STATE, <<"训练状态下不能获得经验">>).
-define(_LANG_ROLE2_RELIVE_ILLEGAL_INTERVAL, <<"时间没到，不能采用这种复活方式">>).
-define(_LANG_ROLE2_RELIVE_BAD_TYPE, <<"不合法的复活类型">>).
-define(_LANG_ROLE2_RELIVE_NOT_DEAD, <<"复活失败，角色未处于死亡状态">>).
-define(_LANG_ROLE2_SEX_NOT_ENOUGH_GOLD, <<"你的元宝不足，不能变性。<a href='event:fillYB'><font color='#3be450'><u>快速充值</u></font></a>">>).
-define(_LANG_ROLE2_SEX_BROADCAST_MSG, <<"有人在王都—老太监处成功变性，开始了新的人生">>).
-define(_LANG_ROLE2_HAIR_NOT_ENOUGH_SILVER, <<"换发失败，没有足够的银子">>).
-define(_LANG_ROLE2_HAIR_BROADCAST_MSG_MALE, <<"[~s]在王都-艾美丽处成功换了新发型，变得更帅了">>).
-define(_LANG_ROLE2_HAIR_BROADCAST_MSG_FEMALE, <<"[~s]在王都-艾美丽处成功换了新发型，变得更靓了">>).
-define(_LANG_ROLE2_HEAD_BROADCAST_MSG_MALE, <<"[~s]在王都-艾美丽处成功换了新头像，变得更帅了">>).
-define(_LANG_ROLE2_HEAD_BROADCAST_MSG_FEMALE, <<"[~s]在王都-艾美丽处成功换了新头像，变得更靓了">>).
-define(_LANG_ROLE2_SEX_NOT_ENOUGH_BAG_SAPCE, <<"无法脱下~s，请保留背包空位">>).
-define(_LANG_ROLE2_EVENT_ID_NOT_EXIST, <<"不存在的事件类型">>).
-define(_LANG_ROLE2_EVENT_SYSTEM_ERROR, <<"设置事件失败：系统错误">>).
-define(_LANG_ROLE2_HEAD_SYSTEM_ERROR, <<"更换头像失败，系统错误">>).
-define(_LANG_ROLE2_HEAD_NOT_ENOUGH_SILVER, <<"更换头像失败，没有足够银子">>).
-define(_LANG_ROLE2_SHOW_EQUIP_RING_ERROR, <<"设置失败，系统错误">>).
-define(_LANG_ROLE2_REMOVE_SKIN_BUFF_ERROR, <<"移除变身状态失败，系统错误">>).
-define(_LANG_ROLE2_REMOVE_SKIN_BUFF_NOT_ENOUGH_SILVER, <<"移除变身状态失败，银子不足">>).
-define(_LANG_ROLE2_ADD_ENERGY_ILLEGAL_INPUT, <<"输入的元宝数量非法">>).
-define(_LANG_ROLE2_ADD_ENERGY_NOT_ENOUGH_GOLD, <<"兑换失败，元宝不足">>).
-define(_LANG_ROLE2_ADD_ENERGY_ENERGY_REMAIN_NOT_ENOUGH, <<"兑换失败，剩余的精力值不足">>).
-define(_LANG_ROLE2_ADD_ENERGY_SYSTEM_ERROR, <<"兑换失败，系统错误">>).
-define(_LANG_ROLE2_QUERY_FACTION_ONLINE_RANK_ERROR, <<"查询出错，请稍后重试">>).

%%------------------------商场系统------------------------

-define(_LANG_SHOP_ENOUGH_GOLD,              <<"您的元宝不足">>).
-define(_LANG_SHOP_BIND_GOLD_NOT_ENOUGH,     <<"您的绑定元宝不足">>).
-define(_LANG_SHOP_UNBIND_GOLD_NOT_ENOUGH,   <<"您的元宝不足">>).
-define(_LANG_SHOP_ENOUGH_SILVER,            <<"您的银子不足">>).
-define(_LANG_SHOP_BIND_SILVER_NOT_ENOUGH,   <<"您的绑定银子不足">>).
-define(_LANG_SHOP_UNBIND_SILVER_NOT_ENOUGH, <<"您的银子不足">>).
-define(_LANG_SHOP_ENOUGH_MONEY,     <<"您的金钱不够">>).
-define(_LANG_SHOP_NOT_THIS_GOODS,   <<"不好意思，没有这个商品">>).
-define(_LANG_LEVEL_NOT_ENOUGH,      <<"不好意思，您的等级不符合，不能购买此商品">> ).
-define(_LANG_SHOP_GOODS_BIND,       <<"物品绑定，不能出售">>).
-define(_LANG_SHOP_DOES_NOT_EXIST,   <<"商店不存在">>).
-define(_LANG_GOODS_NOT_IN_SHOP,     <<"商品不在商店！不能购买">>).
-define(_LANG_YOU_BAG_NOT_GOODS,     <<"您的背包中没有这个物品">>).
-define(_LANG_SHOP_GO_TO_HELL,       <<"见鬼啦">>).
-define(_LANG_SHOP_BAG_NOT_ENOUGH,   <<"背包空间不足，无法购买物品">>).
-define(_LANG_SHOP_NOT_SALE,         <<"此物品，不可出售">>).
-define(_LANG_SHOP_NUMBER_MUST_MORE_THAN_ZERO, <<"数量必须大于0">>).
-define(_LANG_SHOP_GOODS_CANT_SELL,  <<"不能出售该类型道具">>).
-define(_LANG_SHOP_BUY_ONLY_VIP, <<"只有VIP才能购买此物品">>).
-define(_LANG_SHOP_NUM_NOT_ENOUGH, <<"商品数量不足了">>).
-define(_LANG_SHOP_BUY_ITEM_NOT_TO, <<"商品销售时间没到">>).
-define(_LANG_SHOP_BUY_TIEM_PAS,    <<"商品销售时间已过">>).
-define(_LANG_SHOP_NOT_THIS_CU_XIAO_GOODS, <<"没有这个促销商品">>).
-define(_LANG_SHOP_CANNT_FIND_THIS_GOODS, <<"找不到指定的物品">>).
-define(_LANG_SHOP_CANNT_FIND_THIS_SHOP, <<"找不到指定的商店">>).

%%------------------------信件系统------------------------
-define(_LANG_LETTER_NOT_CAN_ACCEPT_GOODS,   <<"你不能领取物品">>).
-define(_LANG_LETTER_HAS_ACCEPT_GOODS,       <<"物品你已经领取过了">>).
-define(_LANG_LETTER_FAIL_ACCEPT_GOODS,      <<"物品领取失败">>).
-define(_LANG_LETTER_OPEN_FAIL,              <<"信件打开失败">>).
-define(_LANG_LETTER_DELETE_FAIL,            <<"信件删除失败">>).
-define(_LANG_LETTER_NOT_ACCEPT_GOODS,       <<"物品没提取,请提取">>).
-define(_LANG_LETTER_NO_MONEY,               <<"不好意思！你的钱不够">>).
-define(_LANG_LETTER_NOT_MEET_TERM,          <<"没有满足发送条件的接收者">>).
-define(_LANG_LETTER_SEND_SUCC,              <<"信件发送成功">>).
-define(_LANG_LETTER_REACH_THE_LIMIT,        <<"不好意思，你今天已经不能发信件了">>).
-define(_LANG_LETTER_DOES_NOT_EXIST,         <<"信件不存在">>).
-define(_LANG_LETTER_ROLE_NOT_FIND,          <<"没有找到相应的玩家">>).
-define(_LANG_LETTER_NOT_ACCEPT_OK,          <<"物品没有成功提取">>).
-define(_LANG_LETTER_NOT_DELETE_OK,          <<"信件没有全部删除">>).
-define(_LANG_LETTER_REFUSAL,               <<"退信，物品被退回">>).
-define(_LANG_LETTER_SEND_SELF,             <<"不能给自己发信件">>).
-define(_LANG_LETTER_SYSTEM_ERROR_WHEN_SEND_P2P_LETTER, <<"发送信件时发生系统错误">>).
-define(_LANG_LETTER_SYSTEM_ERROR_WHEN_ACCEPT_GOODS, <<"提取信件附件时发生系统错误">>).
-define(_LANG_LETTER_GOODS_MAY_ALREADY_ACCEPT, <<"附件可能已提取">>).
-define(_LANG_LETTER_SILVER_NOT_ENOUGH_WHEN_SEND_LETTER_WHEN_ACH, "您的银子不足10两，不能发送带附件的信件").

%%----------------------  技能系统  ----------------------

-define(_LANG_SKILL_HAVENT_LEARN, <<"升级技能之前需要先学习技能">>).
-define(_LANG_SKILL_POINT_NOT_ENOUGH, <<"剩余技能点数不足">>).
-define(_LANG_SKILL_LEVEL_LIMIT, <<"技能等级已满">>).
-define(_LANG_SKILL_ALREADY_LEARN, <<"你已经学会该技能">>).
-define(_LANG_SKILL_LEVEL_IS_MAXLEVEL, <<"该技能已经达到最高级">>).
-define(_LANG_SKILL_ITEM_NOT_EXIST, <<"缺少技能道具">>).
-define(_LANG_SKILL_REST_EXP_NOT_ENOUGH, <<"经验不足">>).
-define(_LANG_SKILL_REST_SILVER_NOT_ENOUGH, <<"银子不足">>).
-define(_LANG_SKILL_WARRIOR_SKILL_POINT_NOT_ENOUGH, <<"已学的战士技能点数不足">>).
-define(_LANG_SKILL_HUNTER_SKILL_POINT_NOT_ENOUGH, <<"已学的射手技能点数不足">>).
-define(_LANG_SKILL_RANGER_SKILL_POINT_NOT_ENOUGH, <<"已学的侠客技能点数不足">>).
-define(_LANG_SKILL_DOCTOR_SKILL_POINT_NOT_ENOUGH, <<"已学的医仙技能点数不足">>).
-define(_LANG_SKILL_PRE_SKILL_NOT_LREANED, <<"前置技能“~s”未达到 ~s级">>).
-define(_LANG_SKILL_ROLE_LEVEL_NOT_ENOUGH, <<"等级不够">>).
-define(_LANG_SKILL_ROLE_MP_NOT_ENOUGH, <<"法力不足">>).
-define(_LANG_SKILL_LEARN_NO_SKILL, <<"没有学习任何技能，不需要重置技能点">>).


-define(_LANG_TEAM_DISBAND, <<"队伍解散">>  ).
-define(_LANG_TEAM_ALREADY_IN_TEAM, <<"已经有队伍了">>).
-define(_LANG_TEAM_TEAM_NOT_EXIST, <<"队伍不存在">>).


%%----------------------  任务NPC系统  ----------------------
-define(_LANG_MISSION_DOING_YBC_CAN_NOT_TRANSFORM, <<"正在执行拉镖任务，无法使用传送卷">>).
-define(_LANG_MISSION_SB_TOO_EARLY, <<"还没到时间，再去边境转转吧">>).
-define(_LANG_MISSION_TAKE_CONDITION_LIMIT, <<"您还没有满足接受该任务的条件">>).
-define(_LANG_MISSION_NOT_EXISTS, <<"抱歉，没有找到该任务">>).
-define(_LANG_MISSION_NOT_TAKEN, <<"抱歉，您还没有接下该任务">>).
-define(_LANG_MISSION_TAKE_MISSION, "接受任务:").
-define(_LANG_MISSION_GET_AWARD, "获得奖励:<BR />").
-define(_LANG_MISSION_HAND_IN_LOW_CONDITION, <<"未满足接任务的条件">>).
-define(_LANG_MISSION_WAIT_OTHER_RANDOM, <<"抱歉，请先完成上一次随机转盘">>).
-define(_LANG_MISSION_DEL_MISSION_PROP_WARING, <<"您刚刚销毁了任务物品，销毁任务物品导致任务失败，系统直接为您取消该任务">>).
-define(_LANG_MISSION_GIVE_AWARD_FAILED, "发放奖励失败了:").
-define(_LANG_MISSION_CHOOSE_ONE_PROP, <<"请选择一种道具奖励">>).
-define(_LANG_MISSION_BAG_FULL, <<"<FONT COLOR='#FF0000'>您的背包已满，请整理背包后再继续执行任务</FONT>">>).
-define(_LANG_MISSION_YBC_NOT_NEARBY, <<"镖车不在附近，无法交任务">>).
-define(_LANG_MISSION_YBC_OWNER, "~s的镖车").
-define(_LANG_MISSION_YBC_BE_ATTACKING, <<"镖车被攻击了，速速救援啊">>).
-define(_LANG_MISSION_YBC_KILLED, <<"镖车挂掉了，任务失败">>).
-define(_LANG_MISSION_YBC_TIMEOUT, <<"已经超过交镖时间了，要走快点了">>).
-define(_LANG_MISSION_YBC_TIMEOUT_DEL, <<"超过系统时限，任务失败">>).
-define(_LANG_MISSION_YBC_CAN_NOT_CHANGE_TAKEN, <<"拉镖任务已经开始，不能使用换车令">>).
-define(_LANG_MISSION_YBC_HAS_TAKEN, <<"您当前还有拉镖任务没有完成，不能接新的拉镖任务">>).
-define(_LANG_MISSION_YBC_SILVER_NOT_ENOUGH, "您的银子不足，接拉镖任务需要 ~ts").
-define(_LANG_MISSION_YBC_SILVER_BIND_NOT_ENOUGH, "您的银子不足，接拉镖任务需要 ~ts").
-define(_LANG_MISSION_YBC_GOLD_NOT_ENOUGH, "您的元宝不足，接拉镖任务需要 ~ts").
-define(_LANG_MISSION_YBC_GOLD_BIND_NOT_ENOUGH, "您的元宝不足，接拉镖任务需要 ~ts").
-define(_LANG_MISSION_YBC_KILLED_NO_AWARD, "镖车被劫，没有奖励").
-define(_LANG_MISSION_YBC_AWARD_EXP, "经验:").
-define(_LANG_MISSION_YBC_COMPLETE, "完成拉镖任务，获得:<BR />").
-define(_LANG_MISSION_YBC_AWARD_BIND_SILVER, "绑定银子").
-define(_LANG_MISSION_YBC_AWARD_SILVER, "银子").
-define(_LANG_MISSION_YBC_GET_GOOD_COLOR, "哇！[~s]成功接到一辆 ~s 镖车，完成任务将获得超值奖励").
-define(_LANG_MISSION_YBC_TIMEOUT_DEL_NO_AWARD, "镖车超过系统时限，被删除，您得不到任何奖励").
-define(_LANG_MISSION_YBC_RETURN_DEPOSIT, "退回押金").
-define(_LANG_MISSION_YBC_TIMEOUT_NO_RETURN_DEPOSIT, "超过交镖时限，不退回押金").
-define(_LANG_MISSION_YBC_FAILED_NO_RETURN_DEPOSIT, "押镖任务失败，不退回押金").
-define(_LANG_MISSION_LISTENER_COMPLETE, <<"任务完成">>).
-define(_LANG_MISSION_FAIL_ANSWER_WRONG, <<"恭喜你答错了，请重新选择">>).
-define(_LANG_MISSION_CHOSE_AN_ANSWER, <<"恭喜你答错了，请重新选择">>).
-define(_LANG_MISSION_SB_TIMEOUT_NO_AWARD, <<"守边超时，没有奖励">>).
-define(_LANG_MISSION_AWARD_EXP, "经验:").
-define(_LANG_MISSION_YBC_HAS_GOT_THE_BEST_COLOR, "已经获得最佳颜色，不需要刷新").
-define(_LANG_MISSION_YBC_LEVEL_CAN_NOT_ATTACK, <<"该等级镖车不能攻击">>).
-define(_LANG_MISSION_YBC_CONSUME_SILVER, "接镖车任务，扣取银子").
-define(_LANG_MISSION_YBC_CONSUME_GOLD, "接镖车任务，扣取元宝").
-define(_LANG_MISSION_YBC_GAIN_SILVER, "完成镖车任务，获得银子").
-define(_LANG_MISSION_YBC_GAIN_GOLD, "完成镖车任务，获得元宝").
-define(_LANG_MISSION_GAIN_SILVER, "完成一般任务，获得银子").
-define(_LANG_MISSION_GAIN_GOLD, "完成一般任务，获得元宝").
-define(_LANG_MISSION_NOT_IN_DISTANCE, "您没有在任务NPC附近，不能做任务").
-define(_LANG_MISSION_PROP_NOT_ENOUGH, "<FONT COLOR='#FF0000'>你没有足够的任务道具，无法执行该任务</FONT>").
-define(_LANG_MISSION_SHOU_BIAN_WAN_CHENG, "<FONT COLOR='#ffcc00'>守卫国土任务已完成，赶紧向<a href='event:goto#~w,~w,~w'><u><FONT COLOR='#3DEA42'>边防大将军</FONT></u></a>汇报情况吧</FONT>").
-define(_LANG_MISSION_SB_GET_GOOD_THING, "[~s]成功完成4次守卫国土任务，在边防大将军-沐英那里挑选了一件【~s】").
-define(_LANG_MISSION_AUTO_GOLD_NOT_ENOUGH, "您的背包中没有足够的元宝支付委托任务所需费用").
-define(_LANG_MISSION_AUTO_CAN_NOT_CANCEL, "任务委托中，不能取消该任务").
-define(_LANG_MISSION_SHOU_BIAN_MUL_GONGXUN, "执行守边任务的[~s]杀死外国人获得双倍战功").
-define(_LANG_MISSION_EXCEPTION_RELOAD_DEFAULT, "<font color='#FFFF00'>该任务已过期，请查看新的可接任务</font>").
-define(_LANG_MISSION_EXCEPTION_RELOAD_DETAIL, "<font color='#FFFF00'>请 ~s 接任务 <b>~s</b></font>").
-define(_LANG_MISSION_AUTO_ACCEPT_BC_CENTER, <<"[~s]<a href='event:openMissionAuto' ><font color=\"#00FF00\"><u>委托</u></font></a>了~s任务，将轻松获得大量经验">>).
-define(_LANG_MISSION_AUTO_ACCEPT_BC_CHAT, <<"<font color='#C8EF1D'>~s<a href='event:openMissionAuto' ><font color=\"#00FF00\"><u>委托</u></font></a>了~s任务，将轻松获得大量经验</font>">>).
-define(_LANG_MISSION_AUTO_LETTER_TIP_HEAD, <<"自动完成：~s任务\n">>).
-define(_LANG_MISSION_AUTO_ATTR_REWARED_TIP1, <<"\n\n小提示：前~w次经验奖励随着次数而翻倍。">>).

%%------------------------物品模块------------------------------
-define(_LANG_GOODS_NO_TYPE,           <<"物品类型不存在">>).
-define(_LANG_GOODS_TIME_NOT_TO,       <<"时间没到，不能购买">>).
-define(_LANG_GOODS_BAG_NOT_ENOUGH, <<"背包空间不足">>).
-define(_LANG_GOODS_WARNING, <<"<FONT COLOR=\"#990000\"><B>亲爱的玩家，背包满了，为了能够继续做任务，请整理</B></FONT>">>).
-define(_LANG_GOODS_NOT_IN_BAG, <<"背包内找不到该物品">>).
-define(_LANG_GOODS_CAN_NOT_DIVIDE, <<"不能拆分">>).
-define(_LANG_GOODS_DEST_NOT_EMPTY, <<"目标位置不为空">>).
-define(_LANG_GOODS_POS_NOT_EXIST, <<"背包位置不存在">>).
-define(_LANG_GOODS_NUM_NOT_ENOUGH,<<"物品数量不足">>).
-define(_LANG_GOODS_USE_TIME_NOT_ARRIVE,<<"使用时间未到">>).
-define(_LANG_GOODS_USE_TIME_PASSED,<<"使用时间已过">>).
-define(_LANG_GOODS_SPLIT_FAIL,    <<"物品分离失败">>).
-define(_LANG_GOODS_SPLIT_NUM_SHORTAGE, <<"物品分离的个数不足">>).
-define(_LANG_BAG_ALREADY_USED,<<"背包位置已被使用">>).
-define(_LANG_ITEM_USE_ILLEGAL_NUM, <<"使用道具数量不合法">>).
-define(_LANG_ITEM_SEX_DO_NOT_MEET,<<"性别不符，不能使用这个道具">>).
-define(_LANG_ITEM_LEVEL_DO_NOT_MEET,<<"等级不符，不能使用这个道具">>).
-define(_LANG_ITEM_NO_EFFECT, <<"道具使用无效果">>).
-define(_LANG_ITEM_NO_THE_EFFECT, <<"道具没有这种效果">>).
-define(_LANG_ITEM_NO_TYPE_GOODS, <<"没有这种类型的物品">>).
-define(_LANG_ITEM_NO_TYPE_EQUIP, <<"没有这种类型的装备">>).
-define(_LANG_ITEM_NO_TYPE_ITEM, <<"没有这种类型的道具">>).
-define(_LANG_ITEM_NO_TYPE_STONE, <<"没有这种类型的宝石">>).
-define(_LANG_ITEM_NO_TYPE_MOUNT, <<"没有这种类型的坐骑">>).
-define(_LANG_ITEM_ROLE_DEAD, <<"死亡状态下不能使用物品">>).
-define(_LANG_ITEM_RANDOM_MOVE_FORBIDDEN, <<"本地图不能使用瞬移符">>).
-define(_LANG_ITEM_CAN_NOT_USE_WHEN_DOING_YBC_MISSION, <<"您正在做拉镖任务，无法使用该道具">>).
-define(_LANG_ITEM_USE_TOO_FAST, <<"使用失败，道具冷却时间未到">>).
-define(_LANG_ITEM_RESET_SKILL_OK, <<"重置技能点成功">>).
-define(_LANG_ITEM_ROLE_TRAINING, <<"训练状态下不能使用道具">>).
-define(_LANG_ITEM_ERROR_GOODS_IN_SHRINK, <<"扩展背包还有物品，取出失败">>).
-define(_LANG_ITEM_ERROR_SHRINK_BAGID, <<"不是合法的扩展背包，取出失败">>).
-define(_LANG_ITEM_ERROR_SHRINK_NOT_BAGID, <<"没有此扩展背包，取出失败">>).
-define(_LANG_ITEM_ERROR_SHRINK_BAG_ITEM_POS, <<"取出扩展背包放置位置不正确，取出失败">>).
-define(_LANG_ITEM_CANT_FIND_EFFECT_ITEM, <<"找不到作用道具">>).
-define(_LANG_ITEM_TRACE_ROLE_NOT_FOUND, <<"追踪失败，玩家不存在或对方已下线">>).
-define(_LANG_ITEM_TRACE_SYSTEM_ERROR, <<"追踪符使用出错">>).
-define(_LANG_ITEM_TRACE_GOODS_NOT_FOUND, <<"追踪符不存在">>).
-define(_LANG_ITEM_RETURN_HOME_IN_MISSION_FB, <<"任务副本内不能使用回城卷">>).

-define(_LANG_ITEM_SPECIAL_NOT_USE, <<"此道具无法使用">>).
-define(_LANG_ITEM_SPECIAL_NOT_FIND, <<"背包没有此物品，无法使用">>).
-define(_LANG_ITEM_SPECIAL_NOT_MISSION, <<"当前任务不可以使用此物品">>).
-define(_LANG_ITEM_SPECIAL_ERROR, <<"使用道具出错">>).
-define(_LANG_ITEM_SPECIAL_NOT_BAG_POS_ERROR, <<"你背包空间不足，使用失败">>).
-define(_LANG_ITEM_SPECIAL_USE_POS, <<"请到 ~s 的 [~s,~s] 附近使用此物品">>).
-define(_LANG_ITEM_SPECIAL_USE_DOING, <<"物品正在使用中，请不要走动">>).
-define(_LANG_ITEM_SPECIAL_USE_DOING_OTHER, <<"你正在使用其它物品，请稍后在使用">>).
-define(_LANG_ITEM_SPECIAL_USE_FAIL, <<"~s 被打断，请重新操作">>).
-define(_LANG_ITEM_SPECIAL_ROLE_STATE_DEAD, <<"死亡状态下，无法使用">>).
-define(_LANG_ITEM_SPECIAL_ROLE_STATE_FIGHT, <<"战斗状态下，无法使用">>).
-define(_LANG_ITEM_SPECIAL_ROLE_STATE_EXCHANGE,<<"交易状态下，无法使用">>).
-define(_LANG_ITEM_SPECIAL_ROLE_STATE_ZAZEN, <<"打坐状态下，无法使用">>).
-define(_LANG_ITEM_SPECIAL_ROLE_STATE_STALL, <<"寄售状态下，无法使用">>).
-define(_LANG_ITEM_SPECIAL_ROLE_STATE_TRAINING, <<"训练状态下，无法使用">>).
-define(_LANG_ITEM_SPECIAL_ROLE_STATE_COLLECT, <<"采集状态下，无法使用">>).

-define(_LANG_EQUIP_SEX_DO_NOT_MEET, <<"性别不符合，不能穿戴这件装备">>).
-define(_LANG_EQUIP_LEVEL_DO_NOT_MEET, <<"等级不够，不能穿戴">>).
-define(_LANG_EQUIP_WRONG_SLOTNUM , <<"该装备不能装备在这个位置">>).
-define(_LANG_EQUIP_IS_LOCKED, <<"【~s】处于锁定状态，无法装备">>).
-define(_LANG_EQUIP_NOT_IN_USE_TIME, <<"该装备不在使用时效时间内">>).
-define(_LANG_EQUIP_NOT_IN_BAG, <<"装备失败，背包内找不到该装备">>).
-define(_LANG_EQUIP_NOT_IN_BAG2, <<"装备失败，背包内找不到【~s】">>).
-define(_LANG_MOUNT_SEX_DO_NOT_MEET, <<"性别不符合，不能骑上这个坐骑">>).
-define(_LANG_MOUNT_LEVEL_DO_NOT_MEET, <<"等级不够，不能坐骑">>).
-define(_LANG_MOUNT_IS_LOCKED, <<"【~s】处于锁定状态，无法坐骑">>).
-define(_LANG_MOUNT_NOT_IN_BAG, <<"坐骑失败，背包内找不到该坐骑">>).
-define(_LANG_MOUNT_NOT_IN_BAG2, <<"坐骑失败，背包内找不到【~s】">>).
-define(_LANG_MOUNT_BAG_FULL, <<"背包已满，不能卸下坐骑">>).
-define(_LANG_MOUNT_CHANGECOLOR_NOT_MOUNTING, <<"必须装配坐骑，才能使用">>).
-define(_LANG_MOUNT_HIGHEST_SPEED, <<"已经获得最佳速度，无需使用坐骑提速牌">>).
-define(_LANG_MOUNT_SPEEDUP_COLOR_NOTFOUND,<<"背包中没有坐骑提速牌，可在随身商店购买获得">>).
-define(_LANG_MOUNT_USE_SPEEDUP_COLOR_BROADCAST, <<"哇！~s的<font color=\"#FFFF00\">[~s]</font> 将坐骑~s的速度提升到 ~s级别">>).
-define(_LANG_MOUNT_RENEWAL_PARAM_ERROR, <<"数据出错，坐骑续期操作失败">>).
-define(_LANG_MOUNT_RENEWAL_QUERY_TYPE_ID, <<"此坐骑不可以续期">>).
-define(_LANG_MOUNT_RENEWAL_NOT_GOODS,<<"此坐骑已经不存在，无法续期">>).
-define(_LANG_MOUNT_RENEWAL_NOT_EXPIRED, <<"坐骑是永久的不需要续期">>).
-define(_LANG_MOUNT_RENEWAL_SELECT_RENEWAL_TYPE, <<"请选择续期类型，再操作">>).
-define(_LANG_MOUNT_REDUCE_PKPOINT_SUCC, <<"使用【清心丸】成功，降低~s点PK值">>).


-define(_LANG_BAG_NOT_BAG,        <<"没找到背包">>).
-define(_LANG_BAG_TIEMOUT,        <<"背包使用时间已过期">> ).
-define(_LANG_EQUIP_BAG_FULL, <<"背包已满，不能脱下装备">>).
-define(_LANG_EQUIP_BAG_FULL2, <<"背包已满，不能卸下【~s】">>).
-define(_LANG_GOODS_SPLIT_ILLEGAL_NUM, <<"分离数量不合法">>).
-define(_LANG_EQUIP_FIX_NOT_ENOUGH_SILVER, <<"没有足够的银子修理">>).
-define(_LANG_EQUIP_FIX_NOT_EQUIP, <<"选中的物品不是装备">>).
-define(_LANG_EQUIP_FIX_ERROR, <<"选中的物品无法修理">>).
-define(_LANG_EQUIP_REACH_MAX_LIMIT, <<"最大耐久度已达最大值，不能再强化">>).
-define(_LANG_ITEM_EFFECT_CHANGE_YBC_OK, <<"使用换车令换车成功">>).
-define(_LANG_ITEM_REDUCE_PKPOINT_OK, <<"减PK值道具使用成功">>).
-define(_LANG_ITEM_PKPOINT_ZERO, <<"PK值为0，不需要使用【清心丸】">>).
-define(_LANG_ITEM_NO_FAMILY,<<"你没有门派,无法使用【门派令】">>).
-define(_LANG_ITEM_IN_10400,<<"讨伐敌营副本地图内,无法使用【门派令】">>).
-define(_LANG_ITEM_IN_10500,<<"大明宝藏地图内,无法使用【门派令】">>).
-define(_LANG_ITEM_IN_10600,<<"师徒副本地图内,无法使用【门派令】">>).
-define(_LANG_ITEM_IN_10700,<<"在监狱不能使用【门派令】">>).
-define(_LANG_ITEM_NOT_FAMILY_OWNER,<<"只有掌门才能使用【门派令】">>).
-define(_LANG_ITEM_NOT_VALID_DISTIONATION,<<"传送目标地点非法 ">>).
-define(_LANG_ITEM_COUNT_EXCEED,<<"使用失败，每日只能使用5次【门派令】">>).
-define(_LANG_ITEM_ATTR_POINT_NO_SET, <<"没有设置属性点，无需重置">>).
-define(_LANG_ITEM_NOT_CAN_USE, <<"该物品不能直接使用">>).
-define(_LANG_ITEM_ADD_HP_SYSTEM_ERROR, <<"增加血时发生系统错误">>).
-define(_LANG_ITEM_ADD_MP_SYSTEM_ERROR, <<"增加法力时发生系统错误">>).
-define(_LANG_ITEM_ADD_EXP_MULTIPLE_BUFF_SYSTEM_ERROR,<<"使用多倍经验符时发生系统错误">>).
-define(_LANG_ITEM_ADD_EXP_EXP_FULL, <<"累积经验已满，请升级后再使用经验药">>).
-define(_LANG_ITEM_USE_FIX_TOOL_SYSTEM_ERROR,<<"使用修理工具时发生系统错误">>).
-define(_LANG_ITEM_ADD_EXP_SYSTEM_ERROR, <<"使用经验药时发送系统错误">>).
-define(_LANG_ITEM_ADD_ATTR_POINT_SYSTEM_ERROR, <<"增加属性点时发生系统错误">>).
-define(_LANG_ITEM_ADD_SKILL_POINT_SYSTEM_ERROR, <<"增加技能点时发生系统错误">>).
-define(_LANG_ITEM_USE_GIFT_SYSTEM_ERROR,<<"使用礼包时发生系统错误">>).
-define(_LANG_ITEM_USE_BIG_HP_SYSTEM_ERROR,<<"使用大红药时发生系统错误">>).
-define(_LANG_ITEM_USE_BIG_MP_SYSTEM_ERROR,<<"使用大蓝药时发生系统错误">>).
-define(_LANG_ITEM_USE_REDUCE_PKPOINT_SYSMTE_ERROR,<<"使用清心丸时发生系统错误">>).
-define(_LANG_ITEM_USE_MONEY_SYSTEM_ERROR,<<"使用银票时发生系统错误">>).
-define(_LANG_ITEM_EFFECT_ADDEXP_OK,<<"使用经验药时发生系统错误">>).
-define(_LANG_ITEM_ADD_TRAINING_POINT_OK, <<"成功使用【训练牌】，训练点数+~w，可在太平村-张三丰进行离线挂机">>).
-define(_LANG_ITEM_GATHER_FACTIONIST_KING_LIMITED, <<"本次国战国王使用【国战征集令】的次数已经达到最大次数3次，无法再使用">>).
-define(_LANG_ITEM_GATHER_FACTIONIST_GENERAL_LIMITED, <<"本次国战大将军使用【国战征集令】的次数已经达到最大次数2次，无法再使用">>).
-define(_LANG_ITEM_GATHER_FACTIONIST_SUCC, <<"【国战征集令】使用成功">>).
-define(_LANG_ITEM_GATHER_FACTIONIST_NO_RIGHT, <<"只有国王或者大将军才可以使用【国战征集令】">>).
-define(_LANG_ITEM_GATHER_FACTIONIST_NOT_IN_WAR, <<"只有本国参与国战期间才能使用【国战征集令】">>).
-define(_LANG_ITEM_GAHTER_FACTIONIST_DEFEN_CANNT_USED_THIS_MAP, <<"防守方只能在本国普通地图使用【国战征集令】">>).
-define(_LANG_ITEM_GATHER_FACTIONIST_ATTACK_CANNT_USED_THIS_MAP, <<"攻击方只能在本国普通地图及防守方平江使用【国战征集令】">>).
-define(_LANG_ITEM_GATHER_FACTIONIST_ATTACK_CANNT_USED_THIS_MAP_JINGCHENG, <<"只有摧毁平江哨塔之后才能在敌国王都使用【国战征集令】">>).
-define(_LANG_ITEM_GAHTER_FACTIONIST_NOT_IN_WAR, <<"国战期间才能使用【国战征集令】">>).
-define(_LANG_ITEM_CHANGE_SKIN_ERROR_SPEC_STATE, <<"不可对~s状态下的玩家使用变身">>).
-define(_LANG_ITEM_CHANGE_SKIN_SUCC, <<"变身符使用成功">>).
-define(_LANG_ITEM_GET_NEW_PET_OK, <<"<font color='#FFFF00'>成功使用宠物召唤符，请按X查看<\font>">>).
-define(_LANG_ITEM_ROLE_CHANGE_SKIN, <<"变身状态下不能使用物品">>).
-define(_LANG_ITEM_MEMBER_GATHER_NOT_IN_WAROFFACTION, <<"非国战期间不能在敌国使用门派令">>).
-define(_LANG_ITEM_RETURN_HOME_IN_JAIL, <<"在监狱中无法使用回城卷">>).
-define(_LANG_ITEM_MEMBER_GATHER_IN_HERO_FB, <<"战役副本中无法使用门派令">>).
-define(_LANG_ITEM_MEMBER_GATHER_IN_MISSION_FB, <<"任务副本中无法使用门派令">>).
-define(_LANG_ITEM_MOVE_EXTAND_BAG_TIMES_UP,<<"现在不是使用扩展背包的有效时间">>).
-define(_LANG_ITEM_CHANGE_SKIN_NOTICE, <<"<font color='#FFFF00'>[~s]</font>对你使用了【~s】">>).
-define(_LANG_ITEM_USE_BIG_EXP_BCAST, <<"<font color='#FFFF00'>[~s]</font>偷尝了~s，获得了大量的经验，正痴痴的笑">>).

-define(_LANG_ITEM_USE_SHOU_CHONG_BCAST,<<"<font color='#FFFF00'>[~s]</font>使用了价值 1888 元宝的<a href='event:sclb'><u>~s</u></a>，获得了大量珍贵的道具">>).

-define(_LANG_ITEM_USE_WINE_OK,<<"你成功喝了一瓶~s">>).
-define(_LANG_ITEM_USE_WINE_TO_MAX,<<"你今天已经喝了5瓶酒了">>).





%%道具效果成功
-define(_LANG_ITEM_EFFECT_ADDHP_OK,  <<"道具使用增加生命值">>).
-define(_LANG_ITEM_EFFECT_ADDMP_OK,  <<"道具使用增加法力值">>).
-define(_LANG_ITEM_EFFECT_ADDSKILL_OK, <<"道具使用增加技能点">>).
-define(_LANG_ITEM_EFFECT_USED_BAG_OK, <<"使用扩展背包成功">>).
-define(_LANG_ITEM_EFFECT_NOT_EMPTY_BAG,<<"已经使用2个扩展背包了">>).
-define(_LANG_ITEM_EFFECT_USED_BAG_FAIL, <<"使用扩展背包失败">>).
-define(_LANG_ITEM_EFFECT_GIFT_BAG_NOT_POS, <<"背包位置不够，不能使用礼包">>).
-define(_LANG_ITEM_EFFECT_USED_GIFT_FAIL,   <<"打开礼包失败">>).
-define(_LANG_ITEM_EFFECT_USED_GIFT_OK,     "恭喜你获得:").
-define(_LANG_ITEM_RESET_ATTR_OK, <<"重置属性点成功">>).

-define(_LANG_DROPTHING_NOT_FOUND,<<"该物品不存在或已被拾取">>).
-define(_LANG_DROPTHING_PICK_PROTECEED,<<"物品拾取保护时间未到，您不能拾取">>).
-define(_LANG_DROPTHING_TOO_FAR_AWAY,<<"距离太远，不能拾取">>).
-define(_LANG_DROPTHING_TEAM_MEMBER_MSG,<<"<font color=\"#FFFFFF\">队友<font color=\"#FFFF00\">[~s]</font>拾取得到：~s</font>">>).
-define(_LANG_DROPTHING_BAG_FULL,<<"背包空间已满，请整理背包">>).

%%交易模块
-define(_LANG_EXCHANGE_ROLE_EXCHANGING_TARGET, <<"对方正在交易中，请稍等">>).
-define(_LANG_EXCHANGE_ROLE_FIGHTING_TARGET, <<"对方战斗中，无法交易">>).
-define(_LANG_EXCHANGE_ROLE_FIGHTING, <<"战斗状态无法交易">>).
-define(_LANG_EXCHANGE_ROLE_EXCHANGING, <<"已经处于交易状态中">>).
-define(_LANG_EXCHANGE_ROLE_DEAD, <<"死亡状态无法交易">>).
-define(_LANG_EXCHANGE_ROLE_DEAD_TARGET, <<"对方处于死亡状态，无法交易">>).
-define(_LANG_EXCHANGE_ROLE_NOT_ONLINE, <<"对方不在线">>).
-define(_LANG_EXCHANGE_OVER_DISTANCE, <<"距离超出可交易范围">>).
-define(_LANG_EXCHANGE_ALREADY_REQUEST, <<"已经发出交易请求，请等候对方处理">>).
-define(_LANG_EXCHANGE_NO_REQUEST, <<"指定交易请求不存在">>).
-define(_LANG_EXCHANGE_CANNT_LOCK, <<"无法锁定交易，是否已经锁定？">>).
-define(_LANG_EXCHANGE_NOT_HAS_ENOUGH_MONEY, <<"交易金钱不足">>).
-define(_LANG_EXCHANGE_STATUS_ERROR, <<"交易状态错误">>).
-define(_LANG_EXCHANGE_NO_GOODS, <<"交易物品错误，请确认背包中有该物品">>).
-define(_LANG_EXCHANGE_STATUS_ERROR_MAY_HAS_CONFIRM, <<"是否已经确认交易？">>).
-define(_LANG_EXCHANGE_FAILED, <<"交易失败">>).
-define(_LANG_EXCHANGE_BAG_NOT_ENOUGH, <<"你的背包空间不足，交易取消">>).
-define(_LANG_EXCHANGE_OTHER_BAG_NOT_ENOUGH, <<"对方背包空间不足，交易取消">>).
-define(_LANG_EXCHANGE_GOODS_ERROR, <<"交易物品出错">>).
-define(_LANG_EXCHANGE_MONEY_NOT_ENOUGH, <<"货币不足">>).
-define(_LANG_EXCHANGE_OTHER_MONEY_NOT_ENOUGH, <<"对方货币不足">>).
-define(_LANG_EXCHANGE_MONEY_ERROR, <<"货币数量错误">>).
-define(_LANG_EXCHANGE_CANCEL, <<"对方取消了交易">>).
-define(_LANG_EXCHANGE_REQUEST_SELF, <<"不能向自己发出邀请">>).
-define(_LANG_EXCHANGE_FIGHT_CANCEL, <<"战斗状态，交易取消">>).
-define(_LANG_EXCHANGE_ROLE_STALL, <<"寄售中不能进行交易">>).
-define(_LANG_EXCHANGE_TARGET_STALL, <<"对方正在寄售中，不能进行交易">>).
-define(_LANG_EXCHANGE_CANCEL_FIGHT, <<"对方进入战斗状态，交易取消">>).
-define(_LANG_EXCHANGE_CANCEL_DISTANCE, <<"对方离开距离过远交易取消">>).
-define(_LANG_EXCHANGE_GOLD_MONEY_ERROR, <<"交易的元宝不能为负数">>).
-define(_LANG_EXCHANGE_NPC_DEAL_SUCC_BC, <<"兑换获得：~s">>).
-define(_LANG_EXCHANGE_NPC_DEAL_BAG_FULL, <<"背包空间已满，请整理背包！">>).
-define(_LANG_EXCHANGE_NPC_DEAL_DEDUCT_ITEM_NOT_ENOUGH, <<"您的背包中可供兑换的物品数量不足">>).
-define(_LANG_EXCHANGE_NPC_DEAL_DEDUCT_ITEM_NOT_EXISTS, <<"您的背包中没有可供兑换的物品">>).
-define(_LANG_EXCHANGE_NPC_DEAL_LOST_ZHANGONG, <<"你失去了~w点战功">>).
-define(_LANG_EXCHANGE_NPC_DEAL_LIMIT_NUM, <<"该物品最多允许兑换~w个">>).
-define(_LANG_EXCHANGE_NPC_DEAL_LIMIT_MAP, <<"必须在限定的地图才能进行兑换">>).
-define(_LANG_EXCHANGE_NPC_DEAL_INVALID_DEAL, <<"非法的兑换项">>).
-define(_LANG_EXCHANGE_NPC_DEAL_NO_ARENA_SCORE, <<"竞技场积分不足，无法兑换">>).
-define(_LANG_EXCHANGE_NPC_DEAL_NO_COLLECT_SCORE, <<"没有足够的宗族采集积分">>).
-define(_LANG_EXCHANGE_NPC_DEAL_NO_FML_GONGXIAN, <<"没有足够的宗族贡献度">>).
-define(_LANG_EXCHANGE_NPC_DEAL_NO_ZHANGONG, <<"没有足够的战功值">>).
-define(_LANG_EXCHANGE_NPC_DEAL_ZERO_ARENA_SCORE, <<"竞技场积分为零，无法兑换">>).
-define(_LANG_EXCHANGE_NPC_DEAL_NO_PET, <<"没有足够的斗兽场积分,无法兑换">>).
%%摊位系统
-define(_LANG_STALL_SYSTEM_ERROR, <<"系统错误">>).
-define(_LANG_STALL_ALREADY_STALL, <<"您已经处于寄售状态或托管寄售状态">>).
-define(_LANG_STALL_CANNT_STALL_WHEN_FIGHTING, <<"战斗状态无法寄售">>).
-define(_LANG_STALL_AROUND_HAS_STALL, <<"周围空间不足，无法寄售">>).
-define(_LANG_STALL_CANNOT_STALL, <<"当前位置无法寄售">>).
-define(_LANG_STALL_NOT_ENOUGH_SILVER, <<"银子不足，无法交税">>).
-define(_LANG_STALL_LEVEL_NOT_ENOUGH, <<"等级不足无法寄售，最低需要30级">>).
-define(_LANG_STALL_BAD_REQUEST, <<"非法请求">>).
-define(_LANG_STALL_NO_GOODS, <<"摊位中至少需要摆放一件物品">>).
-define(_LANG_STALL_HAS_FINISH, <<"该玩家的摊位已经结束了">>).
-define(_LANG_STALL_GOODS_ALL_SELLED, <<"你来迟了，该物品已经卖光了">>).
-define(_LANG_STALL_GOODS_NOT_ENOUGH, <<"该物品数量不足，可能已被其他玩家买走了部分">>).
-define(_LANG_STALL_YOUR_SILVER_NOT_ENOUGH, <<"你的银子不足以完成本次交易">>).
-define(_LANG_STALL_NOT_ENOUGH_BAG_SPACE, <<"背包空间不足，还需要空出~w格">>).
-define(_LANG_STALL_NOT_ENOUGH_SILVER_FOR_EMPOLY, <<"银子不足支付本次托管操作">>).
-define(_LANG_STALL_TARGET_ROLE_NOT_STALLING, <<"目标玩家不在寄售状态">>).
-define(_LANG_STALL_NOT_ENOUGH_BAG_SPACE_2, <<"背包空间不足，请整理背包后再继续操作">>).
-define(_LANG_STALL_MAX_OF_GOODS, <<"摊位空间已满">>).
-define(_LANG_STALL_GOODS_CANNT_STALL, <<"该物品无法寄售">>).
-define(_LANG_STALL_GOODS_NOT_EXIST, <<"指定物品不存在">>).
-define(_LANG_STALL_THE_TARGET_GOODS_CANNT_STALL, <<"指定物品无法寄售">>).
-define(_LANG_STALL_BIND_GOODS_CANNT_STALL, <<"绑定物品无法寄售">>).
-define(_LANG_STALL_NO_GOODS_IN_STALL, <<"请先放置物品">>).
-define(_LANG_STALL_CANNT_GETALL_WHEN_STALLING, <<"寄售状态下无法清空摊位物品">>).
-define(_LANG_STALL_NOT_STALL, <<"玩家未处于寄售状态">>).
-define(_LANG_STALL_ROLE_EXCHANGE, <<"交易中不能寄售">>).
-define(_LANG_STALL_ROLE_DEAD, <<"角色死亡，不能寄售">>).
-define(_LANG_STALL_ERROR_GOODS_BEEN_USED, <<"寄售失败，摊位上的物品已经被使用">>).
-define(_LANG_STALL_GETOUT_ERROR_GOODS_BEEN_USED, <<"摊位上的物品已经被使用">>).
-define(_LANG_STALL_NOT_IN_STALL_MAP, <<"操作失败，不在摊位所在地图">>).
-define(_LANG_STALL_GOODS_PRICE_CHANGE, <<"该道具已经下架">>).
-define(_LANG_STALL_GOODS_BIND, <<"绑定道具不能放上摊位">>).
-define(_LANG_STALL_YOUR_GOLD_NOT_ENOUGH, <<"你的元宝不足以完成本次交易">>).
-define(_LANG_STALL_NUM_ILLEGAL, <<"购买出错，数量不合法">>).

%%精炼系统
-define(_LANG_REINFORCE_HAS_OTHER,         <<"强化装备时，不能有其它物品">>).
-define(_LANG_REINFORCE_NO_EQUIP,          <<"没有需要强化的装备">>).
-define(_LANG_REINFORCE_CAN_NOT_MANY_EQUIP, <<"该装备不在背包中，不能进行强化">>).
-define(_LANG_REINFORCE_CAN_NOT_STUFF,     <<"没有可以使用的强化石">>).
-define(_LANG_REINFORCE_USED_PROTECT,      <<"强化失败，强化星级不变">>).
-define(_LANG_REINFORCE_NO_UPGRADE,        <<"当前星级已经强化至最高，不需要再强化">>).
-define(_LANG_REINFORCE_POS_NOT_5,         <<"请将装备放到装备框内">>).
-define(_LANG_REINFORCE_PLACED,           <<"请放入装备、强化石">>).
-define(_LANG_REINFORCE_PLACED_STUFF,      <<"请放入强化石">>).
-define(_LANG_REINFORCE_PLACED_MEET_STUFF, <<"请放入等级、数量相符的强化石">>).
-define(_LANG_REINFORCE_SAWP_STUFF,       <<"装备星级已升至最高级，请提高强化石的数量或级别">>).
-define(_LANG_REINFORCE_SUCC,       <<"恭喜你，【~s】的强化提升为 ~s级~s星">>).
-define(_LANG_REINFORCE_ERROR,       <<"装备强化出错">>).
-define(_LANG_REINFORCE_MOUNT_ERROR,        <<"坐骑不能进行强化">>). 
-define(_LANG_REINFORCE_FASHION_ERROR,      <<"时装不能进行强化">>). 
-define(_LANG_REINFORCE_ADORN_ERROR,        <<"特殊装备不能进行强化">>).
-define(_LANG_REINFORCE_STUFF_ERROR,        <<"使用 ~s 个【~s】才能继续强化此装备">>).

-define(_LANG_INLAY_HAS_OTHER,          <<"装备镶嵌灵石时，不能用其它物品">>).
-define(_LANG_INLAY_NO_EQUIP,           <<"没有需要镶嵌灵石的装备">>).
-define(_LANG_INLAY_HOLE_FULL,          <<"装备没有孔可以镶嵌灵石">>).
-define(_LANG_INLAY_MAX_STONE,          <<"装备已经镶嵌满灵石，不需要再镶嵌">>).
-define(_LANG_INLAY_CAN_NOT_MANY_EQUIP,  <<"不能有多个装备同时镶嵌灵石">>).
-define(_LANG_INLAY_NO_STONE,           <<"没有需要镶嵌的灵石">>).
-define(_LANG_INLAY_CAN_NOT_MANY_STONE,  <<"不能有多个灵石同时镶嵌">>).
-define(_LANG_INLAY_STONE_NOT_CAN_INLAY, <<"该灵石不能镶嵌在这件装备上">>).
-define(_LANG_INLAY_NOT_SYMBOL,         <<"没有相应的镶嵌符">>).
-define(_LANG_INLAY_HAS_OTHER_SYMBOL,    <<"镶嵌符等级过低">>).
-define(_LANG_INLAY_POS_NOT_5,          <<"请将装备放到装备框内">>).
-define(_LANG_INLAY_WITH_TYPE,          <<"该装备已镶嵌同类灵石">>). 
-define(_LANG_INLAY_ERROR,              <<"装备镶嵌灵石出错">>). 
-define(_LANG_INLAY_MOUNT_ERROR,        <<"坐骑不能镶嵌灵石">>). 
-define(_LANG_INLAY_FASHION_ERROR,      <<"时装不能镶嵌灵石">>). 
-define(_LANG_INLAY_ADORN_ERROR,        <<"特殊装备不能镶嵌灵石">>).

-define(_LANG_UNLOAD_HAS_OTHER,         <<"拆卸装备灵石时，不能有其它物品">>).
-define(_LANG_UNLOAD_NO_EQUIP,          <<"没有需要拆卸灵石的装备">>).
-define(_LANG_UNLOAD_CAN_NOT_MANY_EQUIP, <<"不能有多个装备同时拆卸灵石">>).
-define(_LANG_UNLOAD_DO_NOT_UNLOAD,     <<"当前装备没有镶嵌灵石">>).
-define(_LANG_UNLOAD_NO_SYMBOL,         <<"没有拆卸符不能进行拆卸">>).
-define(_LANG_UNLOAD_POS_NOT_ENOUGH,     <<"装备拆卸灵石后，存放位置不足">>).
-define(_LANG_UNLOAD_STONE_DESTROY,      <<"装备拆卸灵石失败，灵石摧毁">>).
-define(_LANG_UNLOAD_STONE_DEMOTE,      <<"装备拆卸灵石失败，灵石降级">>).
-define(_LANG_UNLOAD_POS_NOT_5,         <<"请将装备放到装备框内">>).
-define(_LANG_UNLOAD_ERROR,             <<"装备拆卸灵石失败">>).
-define(_LANG_UNLOAD_MAX_SYMBOL,         <<"拆卸符过多，请重新操作">>).
-define(_LANG_UNLOAD_MOUNT_ERROR,        <<"坐骑不能折卸灵石">>). 
-define(_LANG_UNLOAD_FASHION_ERROR,      <<"时装不能折卸灵石">>). 
-define(_LANG_UNLOAD_ADORN_ERROR,        <<"特殊装备不能折卸灵石">>).

-define(_LANG_COMPOSE_ERROR_TYPE,         <<"不合法的合成类型">>).
-define(_LANG_COMPOSE_NOT_ENOUGH_NUM,     <<"合成材料数量不足">>).
-define(_LANG_COMPOSE_NO_GOODS,           <<"请放入要合成的物品">>).
-define(_LANG_COMPOSE_MORE_THAN_ONE_KIND, <<"合成的时候，只能放置一种材料">>).
-define(_LANG_COMPOSE_CANT_COMPOSE,       <<"所放的材料不能进行合成">>).
-define(_LANG_COMPOSE_COMPOSE_ERROR,      <<"合成失败">>).
-define(_LANG_COMPOSE_COMPOSE_SUCC,       <<"合成成功，获得~s">>).
-define(_LANG_COMPOSE_INTO_GOODS,        <<"请在材料框内放进你想要合成的材料">>).
-define(_LANG_COMPOSE_EQUIP_NOT_CAN,      <<"装备不能作为合成材料进行合成">>).
-define(_LANG_COMPOSE_SPACE_NOT_MEET,     <<"合成生成物品时，空间不足">>).
-define(_LANG_COMPOSE_GOODS_NUMBER_DIFF,  <<"要合成的数量与背包物品的数不符合">>).
-define(_LANG_COMPOSE_ERROR,              <<"合成材料出错">>).

-define(_LANG_PUNCH_CANT_PUNCH,           <<"开孔锥等级过低">>).
-define(_LANG_PUNCH_MAX_HOLE,             <<"当前装备已经开满了6个镶嵌孔">>).
-define(_LANG_PUNCH_NOT_ENOUGH_GOODS,      <<"开孔锥不足">>).
-define(_LANG_PUNCH_NO_EQUIP,             <<"没有需要开孔的装备">>).
-define(_LANG_PUNCH_MULTI_EQUIP,          <<"请不要放置多件需要开孔的装备">>).
-define(_LANG_PUNCH_POS_NOT_5,            <<"请将装备放到装备框内">>).
-define(_LANG_PUNCH_INTO_SYMBOL,          <<"请放入开孔锥">>).
-define(_LANG_PUNCH_INTO_OTHER,           <<"请不要放入其它物品">>).
-define(_LANG_PUNCH_ERROR,                <<"装备开孔失败">>).
-define(_LANG_PUNCH_FAIL,                <<"装备开孔失败，请继续努力哦">>).
-define(_LANG_PUNCH_SUCC,                <<"装备成功锥开第~s个镶嵌孔">>).
-define(_LANG_PUNCH_MOUNT_ERROR,        <<"坐骑不能开孔">>). 
-define(_LANG_PUNCH_FASHION_ERROR,      <<"时装不能开孔">>). 
-define(_LANG_PUNCH_ADORN_ERROR,        <<"特殊装备不能开孔">>).

-define(_LANG_UNLOAD_BAG_FULL,           <<"天工炉放置不下拆卸出来的宝石，拆卸失败">>).

-define(_LANG_RETAKE_ERROR,              <<"取回天工炉物品出错">>).
-define(_LANG_RETAKE_NO_GOODS,           <<"天工炉物品没有物品可取回">>).  
-define(_LANG_RETAKE_NOT_BAG_POS,        <<"背包空间不足，需要~s个空格子，取回失败">>).  

-define(_LANG_UPQUALITY_NOT_ENOUGH_GOODS,      <<"装备重铸材料不足">>).
-define(_LANG_UPQUALITY_NO_EQUIP,             <<"请放入需要重铸的装备">>).
-define(_LANG_UPQUALITY_GOODS_ERROR,      <<"装备重铸材料不合法">>).
-define(_LANG_UPQUALITY_FULL,<<"装备重铸等级已经最高级，不需要重铸">>).
-define(_LANG_UPQUALITY_GOODS_LEVEL_NOT_ENOUGH,        <<"装备重铸需要更高级的材料">>).
-define(_LANG_UPQUALITY_ERROR, <<"装备重铸出错">>).
-define(_LANG_UPQUALITY_FAIL, <<"装备重铸失败，请继续加油哦">>).
-define(_LANG_UPQUALITY_SUCC, <<"装备重铸成功，品质加成为：~s%">>).
-define(_LANG_UPQUALITY_MOUNT_ERROR,        <<"坐骑不能重铸">>). 
-define(_LANG_UPQUALITY_FASHION_ERROR,      <<"时装不能重铸">>). 
-define(_LANG_UPQUALITY_ADORN_ERROR,        <<"特殊装备不能重铸">>).
-define(_LANG_UPQUALITY_FAIL_GOODS_ERROR,        <<"使用 ~s 个【~s】才能继续装备重铸此装备">>).

-define(_LANG_ADD_MAGIC_NOT_ENOUGH_GOODS,<<"装备附魔材料不足">>).
-define(_LANG_ADD_MAGIC_NO_EQUIP,<<"请放入需要附魔的装备">>).
-define(_LANG_ADD_MAGIC_GOODS_ERROR,<<"装备附魔材料不合法">>).
-define(_LANG_ADD_MAGIC_NO_VALID_GOODS,<<"附魔失败，存在不合法的材料">>).
-define(_LANG_ADD_MAGIC_ERROR, <<"装备附魔出错">>).
-define(_LANG_ADD_MAGIC_MOUNT_ERROR,<<"坐骑不能附魔">>). 
-define(_LANG_ADD_MAGIC_FASHION_ERROR,<<"时装不能附魔">>). 
-define(_LANG_ADD_MAGIC_ADORN_ERROR,<<"特殊装备不能附魔">>).
-define(_LANG_ADD_MAGIC_CAN_NOT_DO,<<"此装备不能附魔">>).
-define(_LANG_ADD_MAGIC_COLOR_CODE_ERROR,<<"装备附魔失败，类型不合法">>).
-define(_LANG_ADD_MAGIC_NOT_ENOUGH_OP_FEE,<<"装备附魔失败，费用不足">>).
-define(_LANG_ADD_MAGIC_THE_SAME_LIGHT_CODE,<<"此装备已经是这种附魔类型">>).

-define(_LANG_UPEQUIP_ERROR, <<"装备升级出错">>).
-define(_LANG_UPEQUIP_TYPE_ERROR, <<"装备升级操作出错">>).
-define(_LANG_UPEQUIP_PARAM_ERROR, <<"装备升级出错，请确认放入要升级的装备和升级材料">>).
-define(_LANG_UPEQUIP_NO_EQUIP_ERROR, <<"要升级装备不合法，无法升级">>).
-define(_LANG_UPEQUIP_MOUNT_ERROR, <<"坐骑不能升级">>). 
-define(_LANG_UPEQUIP_FASHION_ERROR, <<"时装不能升级">>). 
-define(_LANG_UPEQUIP_ADORN_ERROR, <<"特殊装备不能升级">>).
-define(_LANG_UPEQUIP_NOT_ENOUGH_GOODS, <<"装备升级材料不足">>).
-define(_LANG_UPEQUIP_INVALID_GOODS, <<"装备升级材料不合法">>).
-define(_LANG_UPEQUIP_EQUIP_LINK_ERROR, <<"此装备无法升级">>).
-define(_LANG_UPEQUIP_NEXT_EQUIP_ERROR, <<"生成升级的目标装备信息出错，无法升级">>).
-define(_LANG_UPEQUIP_SAME_EQUIP_ERROR, <<"升级材料可升级的装备与要升级的装备一样，无法升级">>).

-define(_LANG_UPCOLOR_ERROR, <<"提升装备颜色出错">>).
-define(_LANG_UPCOLOR_TYPE_ERROR, <<"提升装备颜色操作出错">>).
-define(_LANG_UPCOLOR_NO_EQUIP_ERROR, <<"没有提升装备颜色的装备">>).
-define(_LANG_UPCOLOR_TOO_MUCH_EQUIP_ERROR, <<"没有指定要提升颜色的装备">>).
-define(_LANG_UPCOLOR_NO_GOODS_ERROR, <<"没有材料可提升装备颜色">>).
-define(_LANG_UPCOLOR_TOO_MUCH_GOODS_ERROR, <<"提升装备颜色的材料过多">>).
-define(_LANG_UPCOLOR_INVALID_GOODS_ERROR, <<"存在不合法的提升材料">>).
-define(_LANG_UPCOLOR_INVALID_COLOR_GOODS, <<"存在不合法的提升材料装备">>).
-define(_LANG_UPCOLOR_GOODS_NO_IN_BAG, <<"材料的在背包查找不到">>).
-define(_LANG_UPCOLOR_MAX_COLOR, <<"装备颜色已经最高级，不需要提升">>).
-define(_LANG_UPCOLOR_INVALID_COLOR_EQUIP, <<"~s 材料不可以用来提升装备材料">>).
-define(_LANG_UPCOLOR_MAX_PROBABILITY, <<"不需要这么多的材料，请取消多余的材料">>).
-define(_LANG_UPCOLOR_SUCC_BC, <<"装备颜色提升成功，~s 提升为：~s">>).
-define(_LANG_UPCOLOR_FAIL_BC, <<"装备颜色提升失败">>).
-define(_LANG_UPCOLOR_MOUNT_ERROR, <<"坐骑不能在天工炉提升颜色">>). 
-define(_LANG_UPCOLOR_FASHION_ERROR, <<"时装不能在天工炉提升颜色">>). 
-define(_LANG_UPCOLOR_ADORN_ERROR,        <<"特殊装备不能在天工炉提升颜色">>).
-define(_LANG_UPCOLOR_SUCC_FACTION_BC,        <<"~s的<font color=\"#FFFF00\">[~s]</font>在天工炉将~s提升到~s，装备属性大幅提升">>).
-define(_LANG_UPCOLOR_USE_TWO_ERROR, <<"要提升颜色的装备同时在提升的材料中">>).

-define(_LANG_UPCOLOR_MOUNT_M_ERROR, <<"坐骑不是合法材料">>). 
-define(_LANG_UPCOLOR_FASHION_M_ERROR, <<"时装不是合法材料">>). 
-define(_LANG_UPCOLOR_ADORN_M_ERROR,        <<"特殊装备【~s】不是合法材料">>).


-define(_LANG_COLOR_WHITE,  <<"<font color=\"#EDE8E1\">白色</font>">>).
-define(_LANG_COLOR_GREEN,  <<"<font color=\"#12CC12\">绿色</font>">>).
-define(_LANG_COLOR_BLUE,   <<"<font color=\"#0D79FF\">蓝色</font>">>).
-define(_LANG_COLOR_PURPLE, <<"<font color=\"#FE00E9\">紫色</font>">>).
-define(_LANG_COLOR_ORANGE, <<"<font color=\"#FF7E00\">橙色</font>">>).
-define(_LANG_COLOR_GOLD,   <<"<font color=\"#FFD700\">金色</font>">>).

-define(_LANG_BOX_OP_TYPE_ERROR, <<"天工开物操作出错">>).
-define(_LANG_BOX_OP_FEE_TYPE_ERROR, <<"立即更新操作出错">>).
-define(_LANG_BOX_ON_LINE_ERROR, <<"玩家不在线，操作出错">>).
-define(_LANG_BOX_IS_OPEN_ERROR, <<"天工开物功能，未开放">>).
-define(_LANG_BOX_IS_FREE_ERROR, <<"天工开物，立即更新功能未开放">>).
-define(_LANG_BOX_INIT_ERROR, <<"天工开物未初始化，不能立即更新">>).
-define(_LANG_BOX_HAS_GOODS_ERROR, <<"天工开物，还有物品未提取，无法立即更新">>).
-define(_LANG_BOX_NOT_GOODS_ERROR,<<"天工开物没有物品可提取">>).
-define(_LANG_BOX_IN_BAG_ERROR,<<"提取物品放入背空出错">>).
-define(_LANG_BOX_IN_BAG_NOT_BAG_POS_ERROR,<<"背包空间不足，提取失败">>).
-define(_LANG_BOX_IN_BAG_SUCC_BC_CENTER,<<"~s的<font color=\"#FFFF00\">[~s]</font>在天工炉中提取了~s，真是赚到了">>).
-define(_LANG_BOX_IN_BAG_SUCC_BC_LEFT,<<"~s的<font color=\"#FFFF00\">[~s]</font>在天工炉中提取了-g，真是赚到了！<a href=\"event:openRefining\"><font color=\"#00FF00\"><u>天工开物</u></font></a>">>).

-define(_LANG_BOX_OPEN_ERROR, <<"立即更新操作出错">>).
-define(_LANG_BOX_OPEN_NOT_GOLD, <<"你元宝不足，不能立即更新">>).
-define(_LANG_BOX_OPEN_NO_BOX_POS, <<"你临时仓库没有足够的空间，无法刷新，请整理或提取物品">>).

-define(_LANG_BOX_QUERY_ERROR, <<"查询临时仓库物品操作出错">>).

-define(_LANG_BOX_RESTORE_NOT_GOODS_ERROR, <<"没有物品可以放置">>).
-define(_LANG_BOX_RESTORE_BOX_POS_NO_ENOUGH, <<"临时仓库没有足够的空间可放置物品，请整临时仓库物品">>).
-define(_LANG_BOX_RESTORE_ERROR, <<"放置物品到临时仓库出错">>).

-define(_LANG_BOX_GET_NOT_GOODS_ERROR, <<"临时仓库没有物品可提取">>).
-define(_LANG_BOX_GET_NOT_GOODS_ID_ERROR, <<"请选择临时仓库物品再提取">>).
-define(_LANG_BOX_GET_NO_GOODS_ERROR, <<"临时仓库没有此物品，无法提取">>).
-define(_LANG_BOX_GET_NOT_BAG_POS_ERROR,<<"背包空间不足，提取失败">>).
-define(_LANG_BOX_GET_ERROR, <<"临时仓库物品提取失败">>).

-define(_LANG_BOX_DESTORY_NOT_GOODS_ERROR, <<"临时仓库没有物品可以销毁">>).
-define(_LANG_BOX_DESTORY_NO_GOODS_ERROR, <<"临时仓库没有此物品，无法销毁">>).
-define(_LANG_BOX_DESTORY_ERROR, <<"临时仓库物品销毁失败">>).

-define(_LANG_BOX_MERGE_ERROR, <<"临时仓库没有物品不需要整理">>).

%%仓库模块
-define(_LANG_DEPOT_NOT_CAN_LEAPFROG_DREDGE,  <<"仓库不能越级开通">>).
-define(_LANG_DEPOT_HAS_BEEN_OPENED,         <<"仓库已经开通，不用再开通了">>).
-define(_LANG_DEPOT_NOT_MOENY,              <<"你开通仓库的钱不够">>).
-define(_LANG_DEPOT_NOT_DRAG_GOODS,          <<"没有找到要拖入仓库的物品">>).
-define(_LANG_DEPOT_POS_ERROR,              <<"物品拖放的位置错误">>).
-define(_LNAG_DEPOT_NOT_BAG,                <<"没有找到相应的背包">>).
-define(_LANG_DEPOT_NOT_DEPOT,              <<"没有找到相应的仓库">>).
-define(_LANG_DEPOT_POS_FULL,               <<"位置已满，没有位置放置物品">>).
-define(_LANG_DEPOT_NOT_CAN_OPENED,          <<"此仓库不能开通">>).
-define(_LANG_DEPOT_BAG_NOT_POS,            <<"背包空间不足，物品不能出仓">>).

%%门派系统
-define(_LANG_FAMILY_DOING_YBC_CAN_NOT_CHANGE, <<"正在做拉镖任务，不能进入门派副本">>).
-define(_LANG_FAMILY_NAME_ALREADY_EXIST, <<"门派名称已存在">>).
-define(_LANG_FAMILY_ONLY_OWNER_OR_SECOND_OWNER_CAN_APPLY, <<"只有掌门或者长老才能报名参加王座争霸战">>).
-define(_LANG_WAROKFING_NO_FAMILY, <<"没有门派无法占领王座">>).
-define(_LANG_WAROKFING_CANNT_HOLD_TIME_LIMIT, <<"安全期5分钟之后才能开始抢占王座">>).
-define(_LANG_WAROKFING_CANNT_HOLD_WHEN_DEAD, <<"死亡状态不能占领王座">>).
-define(_LANG_FAMILY_NAME_MUST_MORE_THAN_ONE, <<"门派名称至少需要两个字符">>).
-define(_LANG_FAMILY_SET_OWNER_INTERVAL, <<"一天之内只能转让一次掌门">>).
-define(_LANG_FAMILY_NOT_SAME_FACTION_CANNT_INVITE, <<"不能邀请非本国玩家加入门派">>).
-define(_LANG_FAMILY_NOT_ENOUGH_SILVER, <<"银子不足，无法创建门派">>).
-define(_LANG_FAMILY_ALREADY_REQUEST, <<"您已经申请加入该门派">>).
-define(_LANG_FAMILY_MIN_LEVEL_JOIN_FAMILY, <<"等级不够，无法加入门派">>).
-define(_LANG_FAMILY_TARGET_ALREADY_HAS_A_FAMILY, <<"目标玩家已有门派">>).
-define(_LANG_FAMILY_LAST_OP_TIME_CREATE_LIMIT, <<"退出门派后，需要第二天才能创建新的门派">>).
-define(_LANG_FAMILY_ALREADY_HAVE, <<"已有门派">>).
-define(_LANG_FAMILY_NOT_SAME_FACTION, <<"对方不是本国的">>).
-define(_LANG_FAMILY_NO_FAMILY, <<"你没有门派">>).
-define(_LANG_FAMILY_NO_RIGHT_TO_INVITE, <<"你没有权限邀请玩家">>).
-define(_LANG_FAMILY_NO_RIGHT_CALL_MEMBER, <<"只有掌门或者长老才能召唤帮众">>).
-define(_LANG_FAMILY_NO_ACT_ITERNER, <<"该角色不能担当内务使">>).
-define(_LANG_FAMILY_NOT_NWS, <<"对方不是内务使">>).

-define(_LANG_FAMILY_MEMBER_LIMIT, <<"门派已满员">>).
-define(_LANG_FAMILY_ALREAD_HAS_A_FAMILY, <<"对方已有门派">>).
-define(_LANG_FAMILY_ALREADY_HAVE_FAMILY_WHEN_AGREE, <<"您已经有门派了，无法同意加入另外一个门派">>).
-define(_LANG_FAMILY_NOT_IN_INVITE_LIST, <<"对方门派似乎没有邀请你">>).
-define(_LANG_FAMILY_ALREADY_IN_INVITE_LIST, <<"已经邀请对方了">>).
-define(_LANG_FAMILY_MEMBER_LIMIT_WHEN_AGREE, <<"门派成员已满无法继续邀请">>).
-define(_LANG_FAMILY_MEMBER_LIMIT_WHEN_AGREE_F, <<"门派成员已满，无法同意加入门派请求">>).
-define(_LANG_FAMILY_NOT_IN_REQUEST_LIST, <<"指定玩家不在门派申请列表中">>).
-define(_LANG_FAMILY_TARGET_ALREADY_HAVE_FAMILY_WHEN_AGREE_F, <<"该玩家已有门派">>).
-define(_LANG_FAMILY_NO_RIGHT_TO_AGREE_F, <<"你没有权限批准玩家加入门派">>).
-define(_LANG_FAMILY_NO_RIGHT_TO_FIRE, <<"你无权开除成员">>).
-define(_LANG_FAMILY_CANNT_FIRE_OWNER_OR_SECOND_OWNER, <<"掌门或长老不能直接被开除">>).
-define(_LANG_FAMILY_NOT_MEMBER_WHEN_FIRE, <<"对方不是本门派成员">>).
-define(_LANG_FAMILY_OWNER_CANNT_LEAVE_WHEN_MORE_THAN_ONE_MEMBER, <<"门派还有帮众，无法解散门派">>).
-define(_LANG_FAMILY_NOT_MEMBER, <<"非门派成员">>).
-define(_LANG_FAMILY_PUBLIC_NOTICE_LEN_LIMIT, <<"对外公告长度超过限制">>).
-define(_LANG_FAMILY_PRIVATE_NOTICE_LEN_LIMIT, <<"对内公告长度超过限制">>).
-define(_LANG_FAMILY_CONNECT_NUMBER_LEN_LIMIT, <<"号码长度超过限制">>).
-define(_LANG_FAMILY_NO_RIGHT_TO_DISMISS, <<"你无权解散门派">>).
-define(_LANG_FAMILY_OWNER_OR_SEC_OWNER_CANNT_SET_TITLE, <<"不能给掌门或者长老设置称号">>).
-define(_LANG_FAIMLY_NOT_MEMBER, <<"对方不是门派成员">>).
-define(_LANG_FAMILY_NO_RIGHT_TO_SET_TITLE, <<"你无权给帮众设置称号">>).
-define(_LANG_FAMILY_CAN_USE_SYSTEM_TITLE_TO_SET_TITLE, <<"不能使用系统保留称号">>).
-define(_LANG_FAMILY_SET_OWNER_ONLY_TO_SEC_OWNER, <<"只能转让掌门给长老">>).
-define(_LANG_FAMILY_NO_RIGHT_SET_OWNER, <<"你无权转让掌门">>).
-define(_LANG_FAMILY_ONLY_COMMON_MEMBER_CAN_BE_SET_SEC_OWNER, <<"只能设置普通成员为长老">>).
-define(_LANG_FAMILY_SECOND_OWNER_NUMBER_LIMIT, <<"长老数量已达到上限">>).
-define(_LANG_FAMILY_NO_RIGHT_SET_SECOND_OWNER, <<"你无权任命长老">>).
-define(_LANG_FAMILY_NO_RIGHT_SET_INTERIOR_MANAGER, <<"你无权任命内务使">>).
-define(_LANG_FAMILY_NOT_SECOND_OWNER, <<"对方不是长老">>).
-define(_LANG_FAMILY_NO_RIGHT_UNSET_SECOND_OWNER, <<"你无权解职长老">>).
-define(_LANG_FAMILY_LEVE_NOT_ENOUGH, <<"加入门派的等级不够">>).
-define(_LANG_FAIMLY_MEMBER_LIMIT_WHEN_REQUEST, <<"门派成员数量已满，无法申请">>).
-define(_LANG_FAMILY_NAME_DUPLICATEED, <<"已存在同名门派">>).
-define(_LANG_FAMILY_LEVE_NOT_ENOUGH_WHEN_CREATE, <<"创建门派的等级不够，需要等级：~p">>).
-define(_LANG_FAMILY_THE_REQUEST_FAMILY_NOT_EXIST, <<"指定门派不存在">>).
-define(_LANG_FAMILY_ALREAD_HAS_A_FAMILY_WHEN_CREATE, <<"您已经有门派了，无法创建新门派">>).
-define(_LANG_FAMILY_LEVE_NOT_ENOUGH_WHEN_INVITE, <<"对方的等级不够加入门派">>).
-define(_LANG_FAMILY_NO_RIGHT_TO_CANCEL_INVITE, <<"您无权取消门派对外邀请">>).
-define(_LANG_FAMILY_NO_RIGHT_SET_PUBLIC_NOTICE, <<"只有掌门或者长老才能设置门派对外公告">>).
-define(_LANG_FAMILY_NO_RIGHT_SET_PRI_NOTICE, <<"只有掌门或者长老才能设置门派对内公告">>).
-define(_LANG_FAMILY_NO_RIGHT_SET_CONNECT_NUMBER, <<"只有掌门或者长老才能设置联系号码">>).
-define(_LANG_FAMILY_NOT_FAMILY_MEMBER_WHEN_CANCEL_TITLE, <<"对方不是本门派成员">>).
-define(_LANG_FAMILY_CANNT_CANCEL_TITLE_ON_OWNER_OR_SEC_OWNER, <<"不能取消掌门或者长老的称号">>).
-define(_LANG_FAMILY_NO_RIGHT_CANCEL_TITLE, <<"只有掌门或者长老才能取消玩家称号">>).
-define(_LANG_FAMILY_ALREADY_ENABLE_MAP, <<"门派地图已经激活">>).
-define(_LANG_FAMILY_ENABLE_MAP_NEED_ONLINE, <<"门派成员在线不足5位">>).
-define(_LANG_FAMILY_NOT_ENABLE_GOLD_FOR_ENABLE_MAP, <<"激活门派地图需要50元宝费用">>).
-define(_LANG_FAMILY_MAP_NOT_ENABLE, <<"门派地图尚未开启，无法进入">>).
-define(_LANG_FAMILY_SHOULD_KILL_BOSS_FIRST, <<"升级门派前需要先完成门派升级任务（杀死升级boss）">>).
-define(_LANG_FAMILY_NOT_ENOUGH_MONEY_FOR_UPLEVEL, <<"门派资金不足，无法进行门派升级操作">>).
-define(_LANG_FAMILY_NOT_ENOUGH_ACTIVE_POINTS_FOR_UPLEVEL, <<"门派繁荣度不足，无法进行门派升级操作">>).
-define(_LANG_FAMILY_MAX_LEVEL, <<"门派等级已经升到最高级了">>).
-define(_LANG_FAMILY_DOWNLEVEL_NOT_ENOUGH_SILVER, <<"门派资金不足以支撑今天的地图维护费用">>).
-define(_LANG_FAMILY_DOWNLEVEL_NOT_ENOUGH_ACTIVE_POINTS, <<"门派活跃度不足以支撑今天的地图维护费用">>).
-define(_LANG_FAMILY_UPLEVEL_BOSS_CALLED, <<"门派升级boss已经召唤">>).
-define(_LANG_FAMILY_UPLEVEL_BOSS_KILLED, <<"门派升级boss已经被打败了">>).
-define(_LANG_FAMILY_UPLEVEL_BOSS_NOT_OPEN, <<"门派升级boss未开放，请持续关注">>).
-define(_LANG_FAMILY_COMMONBOSS_ALREAD_CALLED, <<"门派boss已经召唤">>).
-define(_LANG_FAMILY_MAP_NOT_STARTED, <<"门派副本正在启动中，请重试">>).
-define(_LANG_FAMILY_COMMONBOSS_CALL_ONE_TIME_PER_DAY, <<"普通boss每天只能召唤一次">>).
-define(_LANG_FAMILY_ONLY_OWNER_CAN_ENABLE_MAP, <<"只有掌门才能激活门派地图">>).
-define(_LANG_FAMILY_ROLE_NOT_EXISTS, <<"指定的玩家不存在">>).
-define(_LANG_FAMILY_ONLY_OWNER_OR_SEC_OWNER_CAN_CALL_UPLEVEL_BOSS, <<"只有掌门或者长老才能召唤门派升级boss">>).
-define(_LANG_FAMILY_ONLY_OWNER_OR_SEC_OWNER_CAN_CALL_COMMON_BOSS, <<"只有掌门或者长老才能召唤门派boss">>).
-define(_LANG_FAMILY_ALREADY_TOP_LEVEL, <<"门派等级已经升级到最高级了，无法继续升级:)">>).
-define(_LANG_FAMILY_ZERO_LEVEL_CANNT_CALL_BOSS, <<"0级门派无法召唤，请先召唤升级Boss">>).
-define(_LANG_FAMILY_ACTIVE_POINTS_NOT_ENOUGH,<<"门派繁荣度不够">>).
-define(_LANG_FAMILY_BOSS_NOT_ALIVE_OR_CALLED,<<"boss已经被打死了">>).
-define(_LANG_FAMILY_MAP_DISABLE,<<"未开启门派地图">>).
-define(_LANG_FAMILY_NO_SUCH_MAP,<<"没有找到门派地图">>).
-define(_LANG_FAMILY_MAINTAIN_FAMILY_AP_NOT_ENOUGH,<<"门派活跃度不足以维护门派">>).
-define(_LANG_FAMILY_MAINTAIN_FAMILY_MONEY_NOT_ENOUGH,<<"门派金钱不足以维护门派">>).
-define(_LANG_FAMILY_CANNT_CHANGE_MEMBER_WHEN_JOIN_WAROFKING, <<"王座争霸战进行中，门派成员暂时禁止变动">>).
-define(_LANG_ITEM_FAMILY_INVALID_STATE, <<"使用条件不满足，不能传送">>).
-define(_LANG_ITEM_FAMILY_INVALID_TRADING_STATE, <<"商贸中无法传送，请寻路到目标地点">>).

-define(_LANG_FAMILY_ENABLE_MAP_IN_LAST_REQUEST, <<"正在处理激活门派请求中，请稍等">>).
-define(_LANG_FAMILY_ENABLE_MAP_TIMEOUT, <<"激活门派地图超时">>).

-define(_LANG_FAMILY_NOT_EXITS_WHEN_REQUEST_DETAIL, <<"门派不存在，可能已解散">>).

-define(_LANG_FAMILY_YBC_ONLY_OWNER_OR_SECOND_OWNER_CAN_PUBLISH, <<"只有掌门或者长老才能发布门派拉镖任务">>).
-define(_LANG_FAMILY_YBC_ONE_DAY_ONLY_ONE_PUBLISH, <<"门派镖车任务一天只能进行一次">>).
-define(_LANG_FAMILY_YBC_ALREADY_IN_YBC_DOING_STATUS, <<"本门派当前正在拉镖中">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_CHECK_PUBLISH, <<"检查门派能否发布拉镖任务时发生系统错误">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_REDUCE_SILVER_ON_PUBLISH, <<"发布镖车扣除押金时发生系统错误">>).
-define(_LANG_FAMILY_YBC_NOT_ENOUGH_MONEY_FOR_PUBLISH, <<"发布门派镖车需要银子：~s">>).
-define(_LANG_FAMILY_YBC_NOT_DOING, <<"门派镖车任务尚未发布或者已经结束了">>).
-define(_LANG_FAMILY_YBC_ALREADY_IN_YBC_WHEN_AGREE_PUBLISH, <<"你已经处于拉镖状态中">>).
-define(_LANG_FAMILY_YBC_ALREADY_IN_TRADING_WHEN_AGREE_COLLECT, <<"你当前正在商贸，请先寻路到王都-史可法参加门派拉镖">>).
-define(_LANG_FAMILY_YBC_LEVEL_NOT_ENOUGH_WHEN_AGREE_PUBLISH, <<"你的等级不足，无法参与接镖">>).
-define(_LANG_FAMILY_YBC_SILVER_NOT_ENOUGH_WHEN_AGREE_PUBLISH, <<"你的银子不足，还缺 <font color='#cde643'>~s</font> 才可加入镖队。银子可到 <font color='#3be450'>钱庄</font> 购买">>).
-define(_LANG_FAMILY_YBC_POS_NOT_IN_SENCE_WHEN_AGREE_PUBLISH, <<"你不在史可法附近，无法加入镖队">>).
-define(_LANG_FAMILY_YBC_ALREADY_IN_ROLE_LIST, <<"你已经加入门派拉镖了">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_AGREE_PUBLISH, <<"处理同意门派拉镖时发生系统错误">>).
-define(_LANG_FAMILY_YBC_NOTHING_TO_COMMIT, <<"尚未接镖">>).
-define(_LANG_FAMILY_YBC_NOT_CREATOR_WHEN_COMMIT, <<"你不是接镖人">>).
-define(_LANG_FAMILY_YBC_YBC_NOT_NEAR_NPC, <<"镖车距离NPC过远">>).
-define(_LANG_FAMILY_YBC_NOT_EXIST_WHEN_COMMIT, <<"镖车任务已经完成">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_KICK, <<"处理镖车踢人时发生系统错误">>).
-define(_LANG_FAMILY_YBC_ONLY_OWNER_OR_SECOND_OWNER_CAN_KICK, <<"只有掌门或者长老才能踢人">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_COLLECT, <<"处理门派拉镖拉人时发生系统错误">>).
-define(_LANG_FAMILY_YBC_ONLY_OWNER_OR_SECOND_OWNER_CAN_COLLECT, <<"只有掌门或者长老才能拉人">>).
-define(_LANG_FAMILY_YBC_CANNT_COLLECT_WHEN_DOING_YBC, <<"门派拉镖期间不能执行拉人动作">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_COMMIT, <<"处理完成门派镖车任务时发生系统错误">>).
-define(_LANG_FAMILY_YBC_ALREADY_COMMIT, <<"镖车任务已交">>).
-define(_LANG_FAMILY_YBC_MEMBER_NOT_IN_ROLELIST, <<"该帮众已被踢出运镖队伍">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_AGREE_COLLECT, <<"处理同意拉镖拉人时发生系统错误">>).
-define(_LANG_FAMILY_YBC_NO_COLLECT_CODE, <<"没有镖车拉人动作指令">>).
-define(_LANG_FAMILY_YBC_TIMEOUT, <<"门派镖车超时了">>).
-define(_LANG_FAMILY_YBC_CANNT_KICK_SELF, <<"不能踢掉自己">>).
-define(_LANG_FAMILY_YBC_CREATE_ERROR, <<"镖车创建失败，请重试">>).
-define(_LANG_FAMILY_YBC_DO_WITH_LAST_PUBLISH_REQUEST, <<"正在处理上一条拉镖指令，请等待">>).
-define(_LANG_FAMILY_YBC_SPECIAL_STATUS_CANNT_ACCEPT_COLLECT, <<"特殊状态不能传送：~s">>).
-define(_LANG_FAMILY_YBC_SPECIAL_STATUS_CANNT_PUBLISH, <<"特殊状态不能发布门派镖车：~s">>).
-define(_LANG_FAMILY_YBC_SPECIAL_STATUS_CANNT_ACCEPT_PUBLISH, <<"特殊状态下不能参与门派拉镖活动：~s">>).
-define(_LANG_FAMILY_YBC_PARTAKE_TODAY_LIMIT, <<"<font color='#ff0000'>你今天已经参与过门派拉镖，不能重复参与。</font>">>).
-define(_LANG_FAMILY_YBC_DO_WITH_LAST_AGREE_PUBLISH_REQUEST, <<"正在处理上一次加入镖队请求中，请稍等">>).
-define(_LANG_FAMILY_CANNT_DISMISS_WHEN_DOING_YBC, <<"门派拉镖期间不允许解散门派">>).
-define(_LANG_FAMILY_CANNT_LEAVE_WHEN_DOING_YBC, <<"门派拉镖期间不允许解散门派">>).
-define(_LANG_FAMILY_YBC_ALERT_YOUR_SELF, <<"需要提醒自己吗？:)">>).
-define(_LANG_FAMILY_YBC_ONLY_OWNER_OR_SECOND_OWNER_CAN_ALERT, <<"只有掌门或者长老才能使用提醒功能">>).
-define(_LANG_FIGHT_CANNT_ATTACK_SELF_YBC, <<"不能攻击自己的镖车">>).
-define(_LANG_FIGHT_CANNT_ATTACK_SELF_FAMILY_YBC, <<"不能攻击本门派的镖车">>).
-define(_LANG_FIGHT_YBC_CANNT_ATTACK, <<"镖车处于无敌状态">>).
-define(_LANG_FAMILY_YBC_LEVEL_LIMIT_WHEN_PUBLISH, <<"门派拉镖需要25级">>).
-define(_LANG_FAMILY_YBC_DEAD, <<"镖车被打爆了，拉镖失败">>).
-define(_LANG_FAMILY_CANNT_FIRE_WHEN_YBC_DOING, <<"门派拉镖期间不能开除门派成员">>).
-define(_LANG_FAMILY_CANNT_SET_OWNER_WHEN_YBC_DOING, <<"门派拉镖期间不允许转让掌门">>).
-define(_LANG_FAMILY_CANNT_UNSET_SECOND_OWNER_WHEN_YBC_DOING, <<"门派拉镖期间不允许解除长老职位">>).
-define(_LANG_FAMILY_YBC_CANNT_KICK_CREATOR, <<"不能踢掉接镖人">>).
-define(_LANG_FAMILY_YBC_LEVEL_LIMIT_WHEN_COLLECT, <<"等级不足25级，无法进行拉人动作">>).
-define(_LANG_FAMILY_YBC_CREATOR_NOT_NEAR_NPC, <<"必须在NPC(边城-蓝玉)附近才能交镖">>).
-define(_LANG_FAMILY_YBC_CREATOR_NOT_ONLINE, <<"接镖人当前不在线，无法交镖">>).
-define(_LANG_FAMILY_YBC_ONLY_CREATOR_CAN_COMMIT, <<"你不是接镖人，无权交镖">>).
-define(_LANG_FAMILY_YBC_COMMIT_IN_PROCESSING, <<"正在处理中请稍候">>).
-define(_LANG_FAMILY_YBC_DO_COMMIT_TIMEOUT, <<"交镖超时请重试">>).
-define(_LANG_FAMILY_YBC_TIME_OUT_24_HOUR, <<"镖车24小时自动消失">>).
-define(_LANG_FAMILY_CREATE_REQUEST_IN_PROCESS, <<"正在处理创建门派中，请稍等">>).
-define(_LANG_FAMILY_YBC_ALREADY_IN_PUBLISH, <<"当前门派正在发布镖车">>).
-define(_LANG_FAMILY_YBC_NOT_PUBLISHING, <<"门派镖车尚未发布">>).
-define(_LANG_FAMILY_CANNT_UNSET_SECOND_OWNER_WHEN_YBC_PUBLISHING, <<"门派镖车发布中，不能解除长老">>).
-define(_LANG_FAMILY_CANNT_SET_OWNER_WHEN_YBC_PUBLISHING, <<"门派镖车发布中，不能转让掌门">>).
-define(_LANG_FAMILY_CANNT_DISMISS_WHEN_PUBLISHING_YBC, <<"门派镖车发布中，不能解散门派">>).
-define(_LANG_FAMILY_CANNT_LEAVE_WHEN_PUBLISHING_YBC, <<"门派镖车发布中，不能退出门派">>).
-define(_LANG_FAMILY_CANNT_FIRE_WHEN_YBC_PUBLISHING, <<"门派镖车发布中，不能开除门派成员">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_JOIN, <<"加入门派拉镖时发生系统错误">>).
-define(_LANG_FAMILY_YBC_ROLE_NOT_ONLINE_WHEN_AGREE_PUBLISH, <<"处理玩家同意加入门派拉镖时玩家不在线">>).
-define(_LANG_FAMILY_YBC_DO_PUBLISH_TIMEOUT, <<"处理发布门派镖车请求超时，请重试">>).
-define(_LANG_FAMILY_YBC_AGREE_PUBLISH_TIMEOUT, <<"处理加入镖车队伍请求超时，请重试">>).
-define(_LANG_FAMILY_YBC_NOT_CREATOR_WHEN_SURE, <<"只有镖车发布人才能确认开始拉镖">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_SURE, <<"确认拉镖时发生系统错误，请联系GM">>).
-define(_LANG_FAMILY_YBC_NOT_NEAR_NPC_WHEN_SURE, <<"必须在史可法附近才能确认拉镖">>).
-define(_LANG_FAMILY_YBC_DO_WITH_LAST_SURE_REQUEST, <<"正在处理上一次确认拉镖请求中，请稍等">>).
-define(_LANG_FAMILY_YBC_DO_SURE_TIMEOUT, <<"处理确认拉镖超时，请重试">>).
-define(_LANG_FAMILY_YBC_SYSTEM_ERROR_WHEN_GIVEUP, <<"放弃拉镖时发生系统错误，请联系GM">>).
-define(_LANG_FAMILY_YBC_NOT_BEGIN_WHEN_GIVEUP, <<"门派拉镖已结束">>).
-define(_LANG_FAMILY_YBC_DOING_WHEN_GIVEUP, <<"门派拉镖已正式开始，无法退出">>).
-define(_LANG_FAMILY_YBC_NOT_IN_LIST_WHEN_GIVEUP,  <<"你不在拉镖队伍中">>).
-define(_LANG_FAMILY_YBC_FARAWAY_SELF, <<"你已远离门派镖车">>).
-define(_LANG_FAMILY_YBC_FARAWAY_OTHER, <<"~s 已远离镖车">>).
-define(_LANG_FAMILY_MEMBER_GATHER,<<"掌门正在使用门派令召集帮众，请确定是否接受征召，接受后将被免费传送到掌门身边">>).
-define(_LANG_FAMILY_YBC_NOT_CREATOR_WHEN_INVITE, <<"只有镖车创建者才能邀请帮众拉镖">>).
-define(_LANG_FAMILY_YBC_NOT_BEGIN_WHEN_INVITE, <<"拉镖尚未开始">>).
-define(_LANG_FAMILY_YBC_DOING_WHEN_INVITE, <<"拉镖已经开始，不能邀请帮众加入镖队">>).
-define(_LANG_FAMILY_YBC_NOT_PUBLISHING_WHEN_AGREE_PUBLISH, <<"镖队已经解散了">>).
-define(_LANG_FAMILY_YBC_DOING_WHEN_AGREE_PUBLISH, <<"门派拉镖进行中">>).
-define(_LANG_FAMILY_YBC_CANCEL_WHEN_AGREE_PUBLISH, <<"镖队已经解散了">>).
-define(_LANG_FAMILY_EXPEL_NOTIFY, "你已经被<font color=\"#FFFF00\">[~s]</font>开除出~s门派了").
-define(_LANG_FAMILY_GATHERREQUEST_IN_JAIL, <<"在监狱中不能被召集">>).
-define(_LANG_FAMILY_YBC_IN_JAIL, <<"在监狱中不能被召集">>).
-define(_LANG_FAMILY_MEMBER_ENTER_MAP_ERROR_IN_JAIL, <<"在监狱中不能被召集">>).
-define(_LANG_FAMILY_YBC_GIVEUP_GIVE_BACK_COST, <<"<font color=\"#FFC000\">你已退出门派拉镖，退回押金。</font>">>).
-define(_LANG_FAMILY_YBC_GIVEUP_NO_GIVE_BACK_COST, <<"<font color=\"#FFC000\">你已退出门派拉镖，不退回押金。</font>">>).
-define(_LANG_FAMILY_COMBINE_NOT_AUTH_ERROR, <<"只能由两个门派的掌门组队进行门派合并操作">>).
-define(_LANG_FAMILY_COMBINE_NOT_LEADER_ERROR, <<"请让队长来进行门派合并操作">>).
-define(_LANG_FAMILY_COMBINE_FULL_MEMBERS_ERROR, <<"门派人数太多，无法合并门派">>).
-define(_LANG_FAMILY_COMBINE_SUCC, <<"门派 <font color='#3be450'>~s</font> 成功并入门派 <font color='#3be450'>~s</font>">>).
-define(_LANG_FAMILY_COMBINE_REQUEST_SUCC, <<"已发送合并邀请，等待门派<font color='#3be450'>~s</font>掌门[~s]合并确认">>).
-define(_LANG_FAMILY_COMBINE_REQUEST_MSG, <<"确定将门派 <font color='#3be450'>~s</font> 合并到门派 <font color='#3be450'>~s</font> 吗? <font color='#3be450'>~s</font> 门派将被解散，并且门派资金、门派繁荣度、门派仓库、门派技能将被清空，数据无法恢复">>).
-define(_LANG_FAMILY_COMBINE_MAP_EXIST_ROLES_ERROR, <<"门派<font color='#3be450'>~s</font>的门派地图中有帮众，无法合并门派">>).
-define(_LANG_FAMILY_COMBINE_SELF_MAP_EXIST_ROLES_ERROR, <<"你的门派地图中有帮众，无法合并门派">>).
-define(_LANG_FAMILY_COMBINE_YBC_DOING_ERROR, <<"门派 <font color='#3be450'>~s</font> 还在护送门派镖车中，无法合并门派">>).
-define(_LANG_FAMILY_COMBINE_YBC_PUBLISHING_ERROR, <<"门派 <font color='#3be450'>~s</font> 镖车发布中，无法合并门派">>).
-define(_LANG_FAMILY_COMBINE_ERROR_WHEN_JOIN_WAROFKING, <<"门派 <font color='#3be450'>~s</font> 正在进行王座争霸战，暂时无法合并门派">>).
-define(_LANG_FAMILY_COMBINE_HAS_INVALID, <<"门派合并请求已经失效">>).
-define(_LANG_FAMILY_COMBINE_NOT_AGREE, <<"对方不同意合并门派">>).
-define(_LANG_FAMILY_COMBINE_SUCC_BROADCAST, <<"恭喜门派 <font color='#3be450'>~s</font> 成功并入门派 <font color='#3be450'>~s</font>，共创天之刃">>).
-define(_LANG_FAMILY_COMBINE_REPEAT_REQUEST, <<"已发送合并门派请求，无需重复发送">>).
-define(_LANG_FAMILY_COMBINE_NPC_RANGE, <<"双方掌门必须在同屏范围内才能进行门派合并">>).
-define(_LANG_FAMILY_YBC_ALREADY_IN_YBC_WHEN_AGREE_COLLECT, <<"你正在进行个人拉镖，不能参与门派拉镖">>).
-define(_LANG_FAMILY_YOU_NOT_OWNER, <<"你不是掌门，不能设置篝火燃烧时间">>).
-define(_LANG_FAMILY_HAS_BURN, <<"改动后的时间从明天开始生效哦">>).
-define(_LANG_FAMILY_CHANGE_BONFIRE_BURN, <<"掌门修改了门派篝火的点燃时间">>).

-define(_LANG_FAMILY_JOIN_ACTIVITY_BOSS_BC_MSG_1, <<"参与击杀门派升级boss获得门派贡献度：~s\n门派资金：~s\n门派繁荣度：~s\n">>).
-define(_LANG_FAMILY_JOIN_ACTIVITY_BOSS_BC_MSG_2, <<"参与击杀门派普通boss获得门派贡献度：~s\n门派资金：~s\n门派繁荣度：~s\n活跃度：~s\n">>).
-define(_LANG_FAMILY_JOIN_ACTIVITY_BOSS_BC_MSG_3, <<"本门派击杀普通boss成功，门派资金增加：~s\n门派繁荣度增加：~s\n">>).
-define(_LANG_FAMILY_CONVENE_MEMBER_BC_1, <<"掌门正在召集帮众前往门派地图：<font color=\"#ffff00\">~s</font>">>).
-define(_LANG_FAMILY_CONVENE_MEMBER_BC_2, <<"长老正在召集帮众前往门派地图：<font color=\"#ffff00\">~s</font>">>).
-define(_LANG_FAMILY_CALL_GENERAL_BOSS_MAX_TIMES,<<"普通boss每天只能召唤~s次">>).

-define(_LANG_FAMILY_DOANTE_TYPE_ERROR,<<"捐献类型错误">>).
-define(_LANG_FAMILY_DOANTE_MONEY_ERROR,<<"捐献金额错误">>).
-define(_LANG_FAMILY_DOANTE_NO_ENOUGH_GOLD,<<"您没有足够的元宝捐献">>).
-define(_LANG_FAMILY_DOANTE_NO_ENOUGH_SILVER,<<"您没有足够的金币捐献">>).

%%加入门派发送信件的标题和内容
-define(JOIN_FAMILY_LETTER_TITLE_FOR_ROLE,"来自门派管理员的温馨提示").
-define(JOIN_FAMILY_LETTER_CONTENT_FOR_ROLE,"亲爱的[<font color=\"#FFFF00\">~s</font>]：\n      欢迎你加入门派<font color=\"#FFFF00\"> ~s </font>！\n      门派的好处：25级可参加讨伐敌营副本赚经验，30级可参加<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>商贸</u></font></a>赚银子！\n      希望你门派中踊跃发言、积极参加门派活动，我们一起闯荡天之刃，成就我们的英雄传奇！\n\n<p align=\"right\">门派管理员</p>").
-define(_LANG_JOIN_FAMILY_MAX_TIMES,<<"今天最多可以加入或创建3个门派">>).

-define(_LANG_FAMILY_CANNT_DISMISS_WHEN_HAS_MEMBER, <<"当门派成员数量大于1时掌门无法解散门派">>).


%%----------------------  钱庄模块  ----------------------
-define(_LANG_BANK_PRICE_NUM_ZERO, <<"不合法的价格或数量">>).
-define(_LANG_BANK_NOT_ENOUGH_SILVER, <<"没有足够的银子">>).
-define(_LANG_BANK_BUY_MORE_THAN_FIVE, <<"买单的数量已达上限">>).
-define(_LANG_BANK_NOT_ENOUGH_GOLD, <<"没有足够的元宝出售">>).
-define(_LANG_BANK_SELL_MORE_THAN_FIVE, <<"卖单的数量已达上限">>).
-define(_LANG_BANK_PRICE_NOT_EXIST, <<"你来迟一步，该挂单已经不存在">>).
-define(_LANG_BANK_SHEET_NOT_EXIST, <<"挂单不存在">>).
-define(_LANG_BANK_REQUEST_TIMEOUT, <<"操作失败，请求超时">>).
-define(_LANG_BANK_ILLEGAL_INPUT, <<"操作失败，不合法的请求">>).

%% 消息广播
-define(_LANG_BROADCAST_MESSAGE_RECORD_ERROR, <<"消息记录不合法">>).
-define(_LANG_BROADCAST_MESSAGE_TYPE_ERROR, <<"消息类型不合法">>).
-define(_LANG_BROADCAST_MESSAGE_CONTENT_ERROR, <<"消息内容不合法">>).
-define(_LANG_BROADCAST_MESSAGE_GET_PROCESS_PID, <<"获取消息处理进程服务出错">>).
-define(_LANG_BROADCAST_LABA_CONTENT_NULL, <<"发送喇叭消息的内容为空">>).
-define(_LANG_BROADCAST_LABA_ENOUGH_MONEY, <<"你不够银子发送喇叭消息">>).
-define(_LANG_BROADCAST_LABA_DEDUCT_FEE, <<"费用扣除失败">>).
-define(_LANG_BROADCAST_LABA_SEND_FAIL, <<"发送失败">>).
-define(_LANG_BROADCAST_LABA_NOT_ENOUGH_LABA, <<"发送失败，喇叭道具不存在">>).

%% 装备打造
-define(_LANG_EQUIP_BUILD_LEVEL_INVALID, <<"打造列表ID出错">>).
-define(_LANG_EQUIP_BUILD_EQUIP_LIST_NULL, <<"打造列表为空，不合法">>).
-define(_LANG_EQUIP_BUILD_EQUIP_TYPE_ID_ERROR, <<"打造道具ID，不合法">>).
-define(_LANG_EQUIP_BUILD_BASE_GOODS_ERROR,<<"打造的装备的基础材料不合法">>).
-define(_LANG_EQUIP_BUILD_GET_GOODS,<<"打造材料不合法">>).
-define(_LANG_EQUIP_BUILD_BAG_FULL,<<"角色背包已经满，暂不能打造">>).
-define(_LANG_EQUIP_BUILD_ENOUGH_MONEY,<<"打造扣费操作失败，费用不足">>).
-define(_LANG_EQUIP_BUILD_DEDUCT_FEE,<<"打造扣费操作失败，扣费失败">>).
-define(_LANG_EQUIP_BUILD_BUILD_ERROR,<<"打造失败">>).
-define(_LANG_EQUIP_BUILD_GOODS_ENOUGH,<<"材料不足，操作失败">>).
-define(_LANG_EQUIP_BUILD_GET_GOODS_PARAM_ERROR,<<"获取角色背包打造材料参数为合法">>).
-define(_LANG_EQUIP_BUILD_SERVER_ERROR,<<"打造装备服务出错">>).
-define(_LANG_EQUIP_BUILD_EQUIP_NAME_SUFFIX,<<"打造">>).
-define(_LANG_EQUIP_BUILD_EQUIP_BIND_ERROR,<<"打造装备失败，绑定装备出错">>).
-define(_LANG_EQUIP_BUILD_EQUIP_BIND_SUCC,<<"<font color=\"#FFFFFF\">恭喜~s的<font color=\"#FFFF00\">[~s]</font>使用~s打造出一件~s</font>">>).
-define(_LANG_EQUIP_BUILD_EQUIP_BIND_LEFT_SUCC,<<"<font color=\"#FFFFFF\">恭喜~s的<font color=\"#FFFF00\">[~s]</font>使用~s打造出一件-g</font>">>).

%% 装备绑定
-define(_LANG_EQUIP_BIND_TYPE_ERROR,<<"装备绑定操作类型不合法">>).
-define(_LANG_EQUIP_BIND_GOODS_ERROR,<<"装备绑定时，材料不存在">>).
-define(_LANG_EQUIP_BIND_EQUIP_ID_ERROR,<<"该装备不在背包中，无法操作">>).
-define(_LANG_EQUIP_BIND_GOODS_ID_ERROR,<<"装备绑定时，绑定材料不合法">>).
-define(_LANG_EQUIP_BIND_GOODS_NUM_ERROR,<<"装备绑定时，绑定材料数据不够">>).
-define(_LANG_EQUIP_BIND_EQUIP_BASE_ERROR,<<"绑定装备基本信息出错">>).
-define(_LANG_EQUIP_BIND_FIRST_EQUIP_BIND,<<"执行装备第一次绑定时，此装备已经绑定">>).
-define(_LANG_EQUIP_BIND_EQUIP_CODE_ERROR,<<"装备绑定时装备类型编码出错">>).
-define(_LANG_EQUIP_BIND_ERROR,<<"装备绑定出错">>).
-define(_LANG_EQUIP_BIND_GOODS_ENOUGH,<<"角色装备绑定材料不足">>).
-define(_LANG_EQUIP_BIND_EQUIP_GOODS_ERROR,<<"绑定装备信息出错">>).
-define(_LANG_EQUIP_BIND_REBIND_EQUIP_BIND,<<"装备重新绑定时，装备没有绑定过">>).
-define(_LANG_EQUIP_BIND_UPGRADE_EQUIP_BIND,<<"装备提升绑定附加属性级别时，装备没有绑定过">>).
-define(_LANG_EQUIP_BIND_UPGRADE_EQUIP_BIND_ATTR,<<"装备提升绑定附加属性级别时，装备没有绑定属性">>).
-define(_LANG_EQUIP_BIND_UPGRADE_FULL,<<"所有绑定属性已经达到最大值，无法继续提升">>).
-define(_LANG_EQUIP_BIND_UPGRADE_ERROR,<<"装备提升绑定附加属性级别失败，级别没有变化">>).
-define(_LANG_EQUIP_BIND_UPGRADE_SUCC,<<"装备提升绑定附加属性级别成功">>).
-define(_LANG_EQUIP_BIND_UPGRADE_ITEM_LEVEL,<<"材料无法提升装备绑定属性当前级别">>).
-define(_LANG_EQUIP_BIND_MOUNT_ERROR,        <<"坐骑不能绑定">>). 
-define(_LANG_EQUIP_BIND_FASHION_ERROR,      <<"时装不能绑定">>). 
-define(_LANG_EQUIP_BIND_ADORN_ERROR,        <<"特殊装备不能绑定">>). 
-define(_LANG_EQUIP_BIND_UPGRADE_MOUNT_ERROR,        <<"坐骑不能提升绑定属性">>). 
-define(_LANG_EQUIP_BIND_UPGRADE_FASHION_ERROR,      <<"时装不能提升绑定属性">>). 
-define(_LANG_EQUIP_BIND_UPGRADE_ADORN_ERROR,        <<"特殊装备不能提升绑定属性">>). 
-define(_LANG_EQUIP_BIND_GOODS_VALID_ERROR,        <<"使用 ~s 个【~s】才能继续提升装备的绑定属性">>).

-define(_LANG_REFINING_ENOUGH_MONEY,<<"操作失败，费用不足">>).
-define(_LANG_REFINING_DEDUCT_FEE_ERROR,<<"操作失败，扣费失败">>).
-define(_LANG_REFINING_FEE_RULE_ERROR,<<"操作失败，计算费用出错">>).


%% 装备改造
-define(_LANG_EQUIP_CHANGE_Q_PARAM_ERROR,<<"装备改造参数不合法">>).
-define(_LANG_EQUIP_CHANGE_Q_PARAM_EQUIP,<<"装备品质改造失败，装备信息出错">>).
-define(_LANG_EQUIP_CHANGE_Q_PARAM_GOODS,<<"装备品质改造失败，附加材料出错">>).
-define(_LANG_EQUIP_CHANGE_Q_NO_CHANGE,<<"装备品质改造失败，品质没有变化">>).
-define(_LANG_EQUIP_CHANGE_Q_SUCC,<<"装备品质改造成功，品质提升了">>).
-define(_LANG_EQUIP_CHANGE_Q_EXCEPTION,<<"装备品质改造失败，改造异常">>).
-define(_LANG_EQUIP_CHANGE_Q_NOT_UPDATE,<<"提升此装备品质需要更高级的材料">>).
-define(_LANG_EQUIP_CHANGE_Q_FULL,<<"装备品质等级已经最高级，不需要改造">>).
-define(_LANG_EQUIP_CHANGE_Q_MOUNT_ERROR,        <<"坐骑不能品质改造">>). 
-define(_LANG_EQUIP_CHANGE_Q_FASHION_ERROR,      <<"时装不能品质改造">>). 
-define(_LANG_EQUIP_CHANGE_Q_ADORN_ERROR,        <<"特殊装备不能品质改造">>).

%% 装备更改签名
-define(_LANG_EQUIP_CHANGE_S_PARAM_ERROR,<<"装备更改签名参数不合法">>).
-define(_LANG_EQUIP_CHANGE_S_EXIST_SIGN,<<"此装备您已经签名了">>).
-define(_LANG_EQUIP_CHANGE_S_EXCEPTION,<<"装备更改签名失败，改造异常">>).
-define(_LANG_EQUIP_CHANGE_S_SUFFIX,<<"打造">>).
-define(_LANG_EQUIP_CHANGE_S_MOUNT_ERROR,        <<"坐骑不能更改签名">>). 
-define(_LANG_EQUIP_CHANGE_S_FASHION_ERROR,      <<"时装不能更改签名">>). 
-define(_LANG_EQUIP_CHANGE_S_ADORN_ERROR,        <<"特殊装备不能更改签名">>).

%% 装备分解
-define(_LANG_EQUIP_CHANGE_D_PARAM_ERROR,<<"装备分解参数出错">>).
-define(_LANG_EQUIP_CHANGE_D_COLOR,<<"装备不能分解，装备颜色最少是蓝色的">>).
-define(_LANG_EQUIP_CHANGE_D_EXCEPTION,<<"装备分解失败">>).
-define(_LANG_EQUIP_CHANGE_D_FAIL,<<"装备分解失败">>).
-define(_LANG_EQUIP_CHANGE_D_SUCC,<<"装备分解成功">>).
-define(_LANG_EQUIP_CHANGE_D_ERROR_BAG,<<"装备分解失败，背包满了">>).
-define(_LANG_EQUIP_CHANGE_D_STONE_ERROR,<<"装备不能分解，需要将宝石全部拆卸才能分解">>).
-define(_LANG_EQUIP_CHANGE_D_MOUNT_ERROR,        <<"坐骑不能分解">>). 
-define(_LANG_EQUIP_CHANGE_D_FASHION_ERROR,      <<"时装不能分解">>). 
-define(_LANG_EQUIP_CHANGE_D_ADORN_ERROR,        <<"特殊装备不能分解">>).

%% 装备升级
-define(_LANG_EQUIP_CHANGE_U_PARAM_ERROR,<<"装备升级参数出错">>).
-define(_LANG_EQUIP_CHANGE_U_NOT_UPGRADE,<<"装备无法升级">>).
-define(_LANG_EQUIP_CHANGE_U_FULL_LEVEL,<<"装备无法再升级">>).
-define(_LANG_EQUIP_CHANGE_U_CONGIG,<<"装备升级配置出错">>).
-define(_LANG_EQUIP_CHANGE_U_NEW_EQUIP,<<"升级装备基本信息出错">>).
-define(_LANG_EQUIP_CHANGE_U_BASE_ERROR,<<"升级装备出错，基础材料不合法">>).
-define(_LANG_EQUIP_CHANGE_U_QUALITY_ERROR,<<"升级装备出错，保留品质材料不合法">>).
-define(_LANG_EQUIP_CHANGE_U_REINFORCE_ERROR,<<"升级装备出错，保留强化石不合法">>).
-define(_LANG_EQUIP_CHANGE_U_FIVEELE_ERROR,<<"升级装备出错，保留五行材料不合法">>).
-define(_LANG_EQUIP_CHANGE_U_BIND_ERROR,<<"升级装备出错，保留绑定材料不合法">>).
-define(_LANG_EQUIP_CHANGE_U_EXCEPTION,<<"装备升级出错">>).

%% 装备五行处理
-define(_LANG_EQUIP_CHANGE_FIVEELE_PARAM_ERROR,<<"获取装备五行获取参数出错">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR,<<"装备五行改造操作参数出错">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR2,<<"装备五行获取时，装备五行信息已经存在">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_TYPE_ERROR3,<<"装备五行重洗和提升时，装备五行信息不存在">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_EQUIP_ERROR,<<"装备五行改造装备Id参数出错">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_GOOD_ERROR,<<"装备五行改造材料Id参数出错">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_GOOD_LEVEL,<<"当前材料无法提升装备五行级别">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_WHOLE_EQUIP,<<"此装备无法进行五行改造">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_ERROR,<<"装备五行改造出错">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_U_ERROR,<<"装备五行改造，属性升级出错">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_U_NO_CHANGE,<<"装备五行升级改造失败，级别没有变化">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_MAX_LEVEL,<<"装备五行级别已经是最高级别">>).
-define(_LANG_EQUIP_CHANGE_FIVEELE_IS_OPEN,<<"装备五行改造功能未开放">>).


%%师徒
-define(_LANG_EDUCATE_NOT_TEAM, <<"拜师的时候必须两个人组队来找我">>).
-define(_LANG_EDUCATE_NPC_RANGE, <<"结为师徒关系，两人必须在我附近">>).
-define(_LANG_EDUCATE_ALREADY_IS_TEACHER,<<"你们已经是师徒关系了">>).
-define(_LANG_EDUCATE_ALREADY_IS_XD,<<"你们已经是师兄弟关系了">>).
-define(_LANG_EDUCATE_ALREADY_IS_GS,<<"你们已经是师公与徒孙的关系了">>).
-define(_LANG_EDUCATE_HAS_TEACHER, <<"你已经有师傅了">>).
-define(_LANG_EDUCATE_OTHER_SIDE_HAS_TEACHER, <<"对方已经有师傅了">>).
-define(_LANG_EDUCATE_NOT_TITLE, <<"你还没有成为初级导师，请先到王都-李梦阳获取导师资格">>).
-define(_LANG_EDUCATE_OTHER_SIDE_NOT_TITLE, <<"对方未获得导师称号，需要对方到王都-李梦阳获取导师资格">>).
-define(_LANG_EDUCATE_LEVEL_LOW, <<"你的等级过低不能拜师">>).
-define(_LANG_EDUCATE_OTHER_SIDE_LEVEL_LOW, <<"对方等级过低不能收对方为徒">>).
-define(_LANG_EDUCATE_LEVEL_MAX, <<"50级以下的玩家才可以拜师，你已经做到导师的等级了">>).
-define(_LANG_EDUCATE_OTHER_SIDE_LEVEL_MAX, <<"50级以下的玩家才可以收为徒弟，对方已经到导师的等级了">>).
-define(_LANG_EDUCATE_LEVEL_POOR_LOW, <<"对方等级没比你高出5级，不能收你为徒">>).
-define(_LANG_EDUCATE_LEVEL_OTHER_SIDE_POOR_LOW, <<"你的等级没比对方高出5级，无法收其为徒">>).
-define(_LANG_EDUCATE_STUDENT_NUM_MAX, <<"你的收徒名额已满，现在不能再收徒弟了">>).
-define(_LANG_EDUCATE_OTHER_SIDE_STUDENT_NUM_MAX, <<"对方徒弟数量已满，现在不能拜他为师">>).
-define(_LANG_EDUCATE_EXPEL1_TIME, "你在24小时内强制解除过师徒关系，暂时不能拜师，剩余时间:").
-define(_LANG_EDUCATE_EXPEL2_TIME, "对方在24小时内强制解除过师徒关系，暂时不能拜师，剩余时间:").
-define(_LANG_EDUCATE_DROPOUT1_TIME, "你在24小时内开除过徒弟，暂时不能收徒弟，朝廷需要重新考核你的师德，剩余时间:").
-define(_LANG_EDUCATE_DROPOUT2_TIME, "对方在24小时内开除过徒弟，暂时不能收徒弟，朝廷需要重新考核对方的师德，剩余时间:").
-define(_LANG_EDUCATE_IS_ENEMY_APPRENTICE, <<"你们是仇人，不能拜对方为师">>).
-define(_LANG_EDUCATE_IS_ENEMY_ADMISSIONS, <<"你们是仇人，不能收对方为徒">>).
-define(_LANG_EDUCATE_AGREE_REPLY_APPRENTICE, <<"对方同意你的拜师请求了">>).
-define(_LANG_EDUCATE_AGREE_REPLY_ADMISSIONS, <<"对方同意做你的徒弟了">>).
-define(_LANG_EDUCATE_REFUSAL_INVITE, <<"对方拒绝了你的邀请">>).
-define(_LANG_EDUCATE_ALREADY_MAX_TITLE, <<"你已经是一代名师了">>).
-define(_LANG_EDUCATE_NOT_MORALS, <<"你的师德值不够，请继续努力">>).
-define(_LANG_EDUCATE_NOT_LEVEL,<<"你的等级不够">>).
-define(_LANG_EDUCATE_NOT_FIND_STUDENT,<<"没找到适合做你徒弟的玩家">>).
-define(_LANG_EDUCATE_NOT_FIND_TEACHER,<<"没找到适合做你师父的玩家">>).
-define(_LANG_EDUCATE_NOT_TEACHER,<<"你还没有师傅">>).
-define(_LANG_EDUCATE_DROPOUT_NOT_MORALS,<<"师德值不够，离开师门不成功">>).
-define(_LANG_EDUCATE_EXPEL_NOT_MORALS, <<"师德值不够，开除徒弟不成功">>).
-define(_LANG_EDUCATE_ALREADY_GRADUATE_DROPOUT,<<"你已经出师了，无法与恩师脱离师徒关系">>).
-define(_LANG_EDUCATE_ALREADY_GRADUATE_EXPEL,<<"你的高徒已经出师了，已经无法脱离师徒关系了">>).
-define(_LANG_EDUCATE_LEVEL_NOT_DO_EQUAL, <<"等级相等不能结为师徒">>).
-define(_LANG_EDUCATE_ALREADY_REPLY, <<"邀请已经发出">>).
-define(_LANG_EDUCATE_INVITE_OUTTIME,<<"邀请超时">>).
-define(_LANG_EDUCATE_INVITE_OK, <<"邀请已经成功发送">>).
-define(_LANG_EDUCATE_PERSONALS_FAIL, <<"结为好友失败">>).
-define(_LANG_EDUCATE_SWORN_OK, <<"你们已经成功结为师徒">>).
-define(_LANG_EDUCATE_YOU_REFUSAL_APPRENTICE_OK, <<"你成功拒绝了拜师请求">>).
-define(_LANG_EDUCATE_YOU_REFUSAL_ADMISSIONS_OK, <<"你成功拒绝了收徒请求">>).
-define(_LANG_EDUCATE_NOT_PRIMARY_TITLE,<<"你还没升级为初级导师，现在还不能挑选徒弟">>).
-define(_LANG_EDUCATE_NOT_FIND_SUTDENT, <<"没找到你要开除的徒弟">>).
-define(_LANG_EDUCATE_APPRENTICE_FAIL, <<"拜师失败，请重新拜师">>).
-define(_LANG_EDUCATE_ADMISSIONS_FAIL, <<"收徒失败，请重新收徒">>).
-define(_LANG_EDUCATE_MORALS_EXIST, <<"师德值不够，换取经验失败">>).
-define(_LANG_EDUCATE_MORAL_VALUE_NOT_ENOUGH, <<"没有足够的师德值">>).
-define(_LANG_EDUCATE_NOT_SELF_STUDENT,"不是你的徒弟").
-define(_LANG_EDUCATE_MORALS_ERROR, <<"你要兑换的师德值不能小于1">>).
-define(_LANG_EDUCATE_RELEASE_TYPE_ERROR,<<"发布类型错误">>).

%%----------------------车夫-------------------------
-define(_LANG_DRIVER_DISTANCE_ERROR, <<"距离传送点太远">>).
-define(_LANG_DRIVER_MONEY_NOT_ENOUGH, <<"您的银子不足，无法传送">>).
-define(_LANG_DRIVER_LEVEL_NOT_MATCH, <<"您的等级不够，无法传送到该处">>).
-define(_LANG_DRIVER_DOING_YBC_MISSION, <<"您正在做拉镖任务，无法使用车夫功能">>).
-define(_LANG_DRIVER_DOING_ROLE_TRADING, <<"您正在商贸，无法使用车夫功能">>).
-define(_LANG_DRIVER_MAP_FACTION_DOING_PERSONYBC_FACTION, <<"您要前往的国家正在进行国运，10分钟内无法传送到该国">>).
-define(_LANG_DRIVER_RED_NAME, <<"你当前处于红名状态，不能使用车夫传送">>).
%%--------------------系统----------------------------
-define(_LANG_SYSTEM_FCM_102, <<"您未满18周岁，为了您的健康成长，您的游戏收益将受到限制">>).
-define(_LANG_SYSTEM_FCM_201, <<"请输入正确的真实姓名">>).
-define(_LANG_SYSTEM_FCM_202, <<"请输入正确的身份证">>).
-define(_LANG_SYSTEM_FCM_ILLEGAL, <<"错误的防沉迷数据">>).


%%--------------------排行榜----------------------------
-define(_LANG_RANKING_EQUIP_NOT_EXIST, <<"装备不存在">>).
-define(_LANG_RANKING_EQUIP_IS_TASK_EQUIP, <<"特殊装备不能参与神兵排行榜">>).
-define(_LANG_RANKING_EQUIP_NO_CHANGE, <<"你的装备没有任何改变">>).
-define(_LANG_RANKING_EQUIP_OUT_RANK, <<"你的装备未能进入排行，请继续努力">>).
-define(_LANG_RANKING_PET_NO_CHANGE, <<"你的宠物没有任何改变">>).
-define(_LANG_RANKING_PET_OUT_RANK, <<"你的宠物未能进入排行，请继续努力">>).
-define(_LANG_RANKING_NOT_OPEN, <<"当前排行榜还未开启">>).

%%-------------------新手模块-------
-define(_LANG_NEWCOMER_ACTIVATE_CODE_WRONG, <<"激活码不正确，新重新输入">>).
-define(_LANG_NEWCOMER_ACTIVATE_CODE_TYPE_ERROR, <<"该激活码类型无效">>).
-define(_LANG_NEWCOMER_ACTIVATE_CODE_BE_AWARED, <<"该激活码已经被领取过了">>).
-define(_LANG_NEWCOMER_ACTIVATE_CODE_ROLE_ONLY_ONCE, <<"相同帐号，每次活动只能使用一个激活码">>).
-define(_LANG_NEWCOMER_ACTIVATE_CODE_BAG_FULL, <<"您的背包已满，请整理背包后再重新激活">>).
-define(_LANG_NEWCOMER_ACTIVATE_CODE_BEGINTIME_ERR, <<"激活码的必须在~s的时间之后才能领取">>).
-define(_LANG_NEWCOMER_ACTIVATE_CODE_ENDTIME_ERR, <<"激活码的必须在~s的时间之前才能领取">>).


%%-------------------抢国王-------

-define(_LANG_WAROFKING_IN_SAFE_TIME, <<"当前处于王座争霸战的安全期，无法战斗">>).
-define(_LANG_WAROFKING_AGREE_ENTER_TIMEOUT, <<"进入战场超时了">>).
-define(_LANG_WAROFKING_APPLY_NOT_START, <<"王座争霸战尚未开始报名，报名时间为：周六晚18:00—20:30">>).
-define(_LANG_WAROFKING_ALREADY_APPLY, <<"你的门派已经提交了王座争霸战的申请">>).
-define(_LANG_WAROFKING_NO_RIGHT_TO_APPLY, <<"你的门派没有入选本届王座争霸战">>).
-define(_LANG_WAROFKING_NOT_BEGIN, <<"王座争霸战尚未开始">>).
-define(_LANG_WAROFKING_ALREADY_HOLD, <<"你已经占领王座了">>).
-define(_LANG_WAROFKING_BEEN_HOLDING_BY_SOMEONE, <<"当前已经有人占领王座了">>).
-define(_LANG_WAROFKING_NO_RIGHT_TO_ENTER, <<"你没有获取参加王座争霸战的资格">>).
-define(_LANG_WAROFKING_SPECIAL_STATUS_CANNT_ENTER, <<"此状态不能传送，你可以到王宫守卫手动参加">>).
-define(_LANG_WAROFKING_TRADING_STATUS_CANNT_ENTER, <<"你当前正在商贸，请先寻路到王宫参加争霸战">>).
-define(_LANG_WAROFKING_IN_JAIL_CANNT_ENTER, <<"在监狱中不能参加王座争霸战">>).
-define(_LANG_WAROFKING_NOT_NEED_TO_APPLY, <<"王座争霸战不用再报名啦">>).
-define(_LANG_WAROFKING_BEGIN_BROADCAST, <<"王座争霸战将于今晚20:30开始，本期获得资格的宗族名单为：~s，请各宗族做好战斗准备，争夺国王权利。">>).
-define(_LANG_WAROFKING_NO_JOIN_MESSAGE_STRING, <<"本期王座争霸战没有宗族参与，王座宝位保留上次状态">>).
-define(_LANG_WAROFKING_LETTER_TITLE, <<"王座争霸战通知">>).
%%----------------地图-----------
-define(_LANG_MAP_TRANSFER_NO_SCROLL, <<"传送失败，没有传送卷">>).
-define(_LANG_MAP_TRANSFER_OTHER_COUNTRY, <<"本地图不能使用传送卷">>).
-define(_LANG_MAP_TRANSFER_ILLEGAL_POS, <<"传送失败，不可走的点">>).
-define(_LANG_MAP_TRANSFER_SOMEONE_THERE, <<"传送失败，目标点上有其它角色或怪物">>).
-define(_LANG_MAP_TRANSFER_DEAD_STATE, <<"死亡状态下不能使用传送功能">>).
-define(_LANG_MAP_TRANSFER_TRAINING_STATE, <<"打坐状态下不能使用传送功能">>).
-define(_LANG_MAP_TRANSFER_STALL_STATE, <<"寄售状态下不能使用传送功能">>).
-define(_LANG_MAP_TRANSFER_EXCHANGE_STATE, <<"交易状态下不能使用传送功能">>).
-define(_LANG_MAP_CHANGE_MAP_LEVEL_LIMIT, <<"等级不够不能跳转到该地图">>).
-define(_LANG_MAP_CHANGE_MAP_IN_WAROFFACTION, <<"国战准备阶段非本国玩家不能进入该地图">>).
-define(_LANG_MAP_TRANSFER_LEVEL_LIMIT, <<"~w级才能传送到该地图">>).
-define(_LANG_MAP_TRANSFER_ROLE_FIGHTING, <<"PK状态中不能使用传送道具">>).
-define(_LANG_MAP_TRANSFER_TRADING_STATE, <<"商贸状态下不能使用传送功能">>).
-define(_LANG_MAP_TRANSFER_IN_FAMILY_MAP, <<"门派地图中不能使用传送功能">>).
-define(_LANG_MAP_TRANSFER_IN_10500_MAP, <<"大明宝藏地图中不能使用传送功能">>).
-define(_LANG_MAP_TRANSFER_IN_JAIL, <<"在监狱中不能使用传送功能">>).
-define(_LANG_MAP_TRANSFER_OTHER_FACTION_SAFE_MAP, <<"不能进入其它国家的安全挂机地图">>).
-define(_LANG_MAP_TRANSFER_DEST_MAP_ALREADY, <<"已经在目标地图">>).
-define(_LANG_MAP_TRANSFER_TRANSFERING, <<"正在切换在图，请稍候">>).
-define(_LANG_MAP_ENTER_NOT_IN_JUMP_POINT, <<"切换地图失败，当前不在跳转点">>).
-define(_LANG_MAP_TRANSFER_ENOUGH_MONEY, <<"传送失败，费用不足">>).
-define(_LANG_MAP_TRANSFER_NOT_FAMILY, <<"你未加入门派，无法进入门派地图">>).
-define(_LANG_MAP_TRANSFER_RETURN_FAMILY_IN_FAMILY_MAP, <<"你已在门派地图">>).
-define(_LANG_MAP_TRANSFER_GUIDE_FREE_ERROR, <<"传送失败，你已经不能使用此类型的传送">>).

%%----------------消费记录-----------
%% 消费类型,银子    
 

%%----------------训练营-----------
-define(_LANG_TRAINING_TRAINING_POINT_ILLEGAL, <<"输入的训练点不合法">>).
-define(_LANG_TRAINING_NOT_ENOUGH_GOLD, <<"没有足够的元宝">>).
-define(_LANG_TRAINING_TIME_ILLEGAL, <<"不合法的训练时间">>).
-define(_LANG_TRAINING_ALREADY_IN_TRAINING, <<"已经处于训练状态">>).
-define(_LANG_TRAINING_NOT_ENOUGH_POINT, <<"没有足够的训练点">>).
-define(_LANG_TRAINING_NOT_IN_TRAINING, <<"不在训练状态中">>).
-define(_LANG_TRAINING_START_SYSTEM_ERROR, <<"系统错误">>).
-define(_LANG_TRAINING_START_ROLE_DEAD, <<"死亡状态下不能训练">>).
-define(_LANG_TRAINING_START_ROLE_STALL, <<"亲自寄售状态下不能训练">>).
-define(_LANG_TRAINING_START_ROLE_FIGHT, <<"战斗状态下不能训练">>).
-define(_LANG_TRAINING_START_ROLE_EXCHANGE, <<"交易状态下不能训练">>).
-define(_LANG_TRAINING_START_ROLE_TRADING, <<"跑商状态下不能训练">>).
-define(_LANG_TRAINING_START_IN_JAIL, <<"在监狱中不能进行离线挂机">>).

%%----------------官职-----------
-define(_LANG_OFFICE_NOT_SAME_FACTION, <<"本国官职只能任命本国玩家">>).
-define(_LANG_OFFICE_NOT_VALID_OFFICEID, <<"官职不存在">>).
-define(_LANG_OFFICE_NOT_RIGHT_TO_APPOINT, <<"你没有权限任命官职">>).
-define(_LANG_OFFICE_ALREADY_APPOINT, <<"该官职已有玩家任职了">>).
-define(_LANG_OFFICE_ALREADY_APPOINT_NOT_AGREE, <<"该官职已经任命玩家了">>).
-define(_LANG_OFFICE_ROLE_NOT_EXISTS, <<"指定玩家不存在">>).
-define(_LANG_OFFICE_NO_RIGHT_TO_DISAPPOINT, <<"你没有权限免除官职">>).
-define(_LANG_OFFICE_NOT_APPOINTED, <<"国王已经取消了你的官职任命">>).
-define(_LANG_OFFICE_CANNT_APPOINT_SELF, <<"不能任命自己">>).
-define(_LANG_OFFICE_NOT_ENOUGH_MONEY_TO_DONATE, <<"你的银子不足">>).
-define(_LANG_OFFICE_DONATE_MUST_MORE_THAN_ZERO, <<"捐款必须大于0">>).
-define(_LANG_OFFICE_DONATE_FACTION_SILVER_LIMITED, <<"国库银子已达上限，无法捐献">>).
-define(_LANG_OFFICE_HAS_ALREADY, <<"你已有官职了">>).
-define(_LANG_OFFICE_ALREADY_HAS_OFFICE, <<"对方已有官职">>).
-define(_LANG_OFFICE_SYSTEM_ERROR_WHEN_APPOINT, <<"任命官职时出现意外错误">>).
-define(_LANG_OFFICE_NOT_APPOINT_WHEN_CANCEL, <<"取消官职任命失败，可能玩家已经同意任职了">>).
-define(_LANG_OFFICE_APPOINT_ANOTHER_ALREADY, <<"该玩家已被任命其他官职，请等待对方答复">>).
-define(_LANG_OFFICE_SYSTEM_ERROR_WHEN_SET_NOTICE, <<"设置国家公告时发生系统错误">>).
-define(_LANG_OFFICE_NOT_RIGHT_TO_SET_NOTICE, <<"只有国王才能设置国家公告">>).
-define(_LANG_OFFICE_SET_NOTICE_MAX_LENGTH_LIMIT, <<"国家公告的内容长度不能超过200">>).
-define(_LANG_OFFICE_NOT_RIGHT_TO_LANUCH_COLLECTION, <<"你没有权限发动募捐">>).
-define(_LANG_OFFICE_RETAKE_OFFICE_EQUIP, <<"王座争霸战期间，官职装备回收，请于王座争霸战结束后重新领取">>).
-define(_LANG_OFFICE_RETRIEVE_OFFICE_EQUIP, <<"由于卸任~ts官职，你的【~ts】被收回">>).
-define(_LANG_OFFICE_NOT_RIGHT_TO_TAKE_OFFICE_EQUIP, <<"本装备为【~ts】的权力凭证，你未获得该权力，不能领取">>).
-define(_LANG_OFFICE_ALREADY_TAKE_OFFICE_EQUIP, <<"你已经领取装备，无法重复领取">>).
-define(_LANG_OFFICE_NOT_TAKE_OFFICE_EQUIP_IN_WAR_OF_KING, <<"王座争霸战期间不能领取官职装备">>).
-define(_LANG_OFFICE_NOT_DISAPPOINT_IN_WAR_OF_KING, <<"王座争霸战期间不能任命官职">>).
-define(_LANG_OFFICE_SYSTEM_ERROR_WHEN_TAKE_EQUIP, <<"领取官职装备出现意外错误">>).


%%----------------地图争夺战----------
-define(_LANG_WAROFCITY_MUST_HAS_A_FAMILY, <<"你必须在拥有一个门派之后才能申请参加地图争夺战">>).
-define(_LANG_WAROFCITY_NO_RIGHT_TO_APPLY, <<"只有掌门或者长老才能申请参加地图争夺战">>).
-define(_LANG_WAROFCITY_ALREADY_HOLD, <<"你的门派已经占领了一个城市了">>).
-define(_LANG_WAROFCITY_CANNT_APPLY_WHEN_WARTIME, <<"地图争夺战进行中，无法申请">>).
-define(_LANG_WAROFCITY_ALREADY_APPLY, <<"每个门派每次只能申请一个地图的争夺战">>).
-define(_LANG_WAROFCITY_FAMILY_MONEY_NOT_ENOUGH, <<"门派资金不足">>).
-define(_LANG_WAROFCITY_NO_FAMILY_WHEN_AGREE_ENTER, <<"没有门派无法参加地图争夺战">>).
-define(_LANG_WAROFCITY_FAMILY_NOT_APPLY, <<"你的门派没有申请参加本届地图争夺战">>).
-define(_LANG_WAROFCITY_AT_LEAST_ONE_LEVEL, <<"门派等级至少达到1才能申请参加地图争夺战">>).
-define(_LANG_WAROFCITY_LEVEL_NOT_ENOUGH, <<"你的门派等级达不到申请本地图争夺战的要求">>).
-define(_LANG_WAROFCITY_CAN_ONLY_APPLY_SELF_FACTION_CITY, <<"只能申请参加本国地图的争夺战">>).
-define(_LANG_WAROFCITY_HOLD_SYSTEM_ERROR, <<"系统错误:占领图腾出错">>).
-define(_LANG_WAROFCITY_FLAG_ALREADY_HOLD, <<"该图腾已被占领">>).
-define(_LANG_WAROFCITY_IN_SAFE_TIME, <<"地图争霸战安全期无法战斗">>).
-define(_LANG_WAROFCITY_NOT_BEGIN_OR_IN_SAFETIME, <<"地图争霸战尚未开始或者出于安全期">>).
-define(_LANG_WAROFCITY_HOLD_CITY_NOT_NEED_TO_APPLY, <<"你的门派已经占领本地图，无需报名">>).
-define(_LANG_WAROFCITY_OPEN_PANEL_MANAGE_ERROR, <<"打开地图争夺战信息查看面板出错">>).
-define(_LANG_WAROFCITY_OPEN_PANEL_MANAGE_NO_RIGHT, <<"你无权查看该面板">>).
-define(_LANG_WAROFCITY_SYSTEM_ERROR_WHEN_CHECH_FAMILY_HOLDED, <<"检查门派是否已经占领地图时发生系统错误">>).
-define(_LANG_WAROFCITY_SYSTEM_ERROR_WHEN_FAMILY_APPLYED, <<"检查门派是否已经申请地图争夺战时发生系统错误">>).
-define(_LANG_WAROFCITY_SYSTEM_ERROR_WHEN_GET_REWARD, <<"领取连续占领奖励时发生系统错误">>).
-define(_LANG_WAROFCITY_NOT_HOLD_THIS_CITY, <<"你的门派没有占领当前城市">>).
-define(_LANG_WAROFCITY_NO_RIGHT_TO_GET_REWARD, <<"你的门派没有占领该地图，不能领取奖励">>).
-define(_LANG_WAROFCITY_ONLY_OWNER_CAN_GET_REWARD, <<"只有掌门才能领取地图争夺战连续占领的奖励">>).
-define(_LANG_WAROFCITY_NOT_REACH_CONDITION_OF_GET_REWARD, <<"当前没有满足领取该奖励的条件">>).
-define(_LANG_WAROFCITY_ALREADY_GET_REWARD_OF_THIS_TYPE, <<"你已经领取过该奖励了">>).


%%--------------------------管理模块---------------
-define(_LANG_ADMIN_SYSTEM_ERROR_WHEN_SEND_GOLD, <<"赠送元宝时发生系统错误">>).


%% 成就系统资源文件
-define(_LANG_ACHIEVEMENT_NOTICE_QRY_ERROR, <<"查询成就详细信息出错">>).
-define(_LANG_ACHIEVEMENT_NOTICE_ERROR, <<"同步成就信息时出错">>).
-define(_LANG_ACHIEVEMENT_NOTICE_PARAM_ERROR, <<"同步成就状态时参数出错">>).
-define(_LANG_ACHIEVEMENT_AWARD_PARAM_ERROR, <<"请选择一件武器">>).
-define(_LANG_ACHIEVEMENT_AWARD_STATUS_3_ERROR, <<"您已经被领取奖励了">>).
-define(_LANG_ACHIEVEMENT_AWARD_STATUS_1_ERROR, <<"此成就未完成还不可以领取奖励">>).
-define(_LANG_ACHIEVEMENT_AWARD_STATUS_ERROR, <<"领取成就奖励时成就状态出错">>).
-define(_LANG_ACHIEVEMENT_AWARD_ITEM_EMPTY, <<"此成就没有道具奖励，领奖失败">>).
-define(_LANG_ACHIEVEMENT_AWARD_ERROR, <<"领取成就奖励时出错">>).
-define(_LANG_ACHIEVEMENT_AWARD_TPYE_ERROR,<<"不合法的成就奖励类型">>).
-define(_LANG_ACHIEVEMENT_AWARD_BAG_ERROR,<<"背包空间不足">>).
-define(_LANG_ACHIEVEMENT_AWARD_GOOD_ERROR,<<"物品信息出错">>).
-define(_LANG_ACHIEVEMENT_NOT_OPEN,<<"成就系统暂未开放">>).
-define(_LANG_ACHIEVEMENT_QUERY_OP_TYPE,<<"查询类型不合法，无法查询">>).
-define(_LANG_ACHIEVEMENT_QUERY_PARAM_ERROR,<<"查询条件出错，无法查询">>).
-define(_LANG_ACHIEVEMENT_QUERY_GROUP_ID,<<"没有此成就组出错，无法查询">>).

%%采集
-define(_LANG_COLLECT_NOT_START,<<"没有开始采集">>).
-define(_LANG_ITEM_ROLE_COLLECT,<<"玩家在采集，不能使用道具">>).
-define(_LANG_COLLECT_STOP,<<"采集中断">>).
-define(_LANG_COLLECT_NO_TOOL,<<"没有使用采集工具">>).
-define(_LANG_COLLECT_NO_GRAFTS,<<"没有对应的采集物">>).
-define(_LANG_COLLECT_ROLE_COLLECTED,<<"该物品正在被 <font color=\"#FFFF00\">[~s]</font> 挖掘中">>).
-define(_LANG_GOLLECT_HAS_COLLECT,<<"已经被人采集">>).
-define(_LANG_COLLECT_EXCEPTION,<<"用外挂！你完蛋了">>).
-define(_LANG_COLLECT_FAR_FROM, <<"你的距离太远，不能采集">>).
-define(_LANG_COLLECT_LEVEL_ENOUGH,<<"你的等级不够，不能采集">>).
-define(_LANG_COLLECT_BREAK,<<"采集被打断">>).
-define(_LANG_NOT_TAKE_COLLECT_MISSION, <<"您没有接采集任务，不能在该采集点采集">>).
-define(_LANG_COLLECT_BAG_NOT_ENOUGH, <<"背包空间不足，采集失败">>).
-define(_LANG_COLLECT_ROLE_STATE_DEAD, <<"角色处于死亡状态，不能采集">>).
-define(_LANG_COLLECT_ROLE_STATE_FIGHT, <<"角色处于战斗状态，不能采集">>).
-define(_LANG_COLLECT_ROLE_STATE_EXCHANGE,<<"角色处于交易状态，不能采集">>).
-define(_LANG_COLLECT_ROLE_STATE_ZAZEN, <<"角色处于打坐状态，不能采集">>).
-define(_LANG_COLLECT_ROLE_STATE_STALL, <<"角色处于寄售状态，不能采集">>).
-define(_LANG_COLLECT_ROLE_STATE_TRAINING, <<"角色处于训练状态，不能采集">>).
-define(_LANG_COLLECT_ROLE_STATE_COLLECT, <<"角色已经处于采集状态，不能再次采集">>).
-define(_LANG_COLLECT_HONGWU_COLOR, "<font color=\"#00FF00\">云州</font>").
-define(_LANG_COLLECT_YONGLE_COLOR, "<font color=\"#FC00FF\">沧州</font>").
-define(_LANG_COLLECT_WANLI_COLOR, "<font color=\"#00AEFF\">幽州</font>").
-define(_LANG_COLLECT_CENTER_BROADCAST_1,"[~s]在 ~s 采集挖到一个~s，运气太好了").
-define(_LANG_COLLECT_CHAT_BROADCAST_1, "<font color=\"#FFFFFF\"><font color=\"#FFC000\">[~s]</font>在<font color=\"#FFC000\">~s</font>采集挖到一个~s，运气太好了！</font>").
-define(_LANG_COLLECT_CENTER_BROADCAST_2,"~s 的 [~s]在 ~s 采集挖到一个~s，真是太走运了").
-define(_LANG_COLLECT_CHAT_BROADCAST_2, "~s<font color=\"#FFFFFF\"> 的 <font color=\"#FFC000\">[~s]</font>在<font color=\"#FFC000\">~s</font>采集挖到一个~s，真是太走运了！</font>").
-define(_LANG_COLLECT_CENTER_BROADCAST_2_10500,"~s 的 [~s]在 ~s 挖宝挖到一个~s，真是太走运了").
-define(_LANG_COLLECT_CHAT_BROADCAST_2_10500, "~s<font color=\"#FFFFFF\"> 的 <font color=\"#FFC000\">[~s]</font>在<font color=\"#FFC000\">~s</font>挖宝挖到一个~s，</font>").
-define(_LANG_COLLECT_CENTER_BROADCAST_2_10500_TAIL_1, "<font color=\"#FFFFFF\">掠夺~s和~s宝藏积分各1点，\\n~s增加2点宝藏积分</font>").
-define(_LANG_COLLECT_CENTER_BROADCAST_2_10500_TAIL_2, "<font color=\"#FFFFFF\">掠夺~s宝藏积分1点，\\n~s增加一点宝藏积分</font>").
-define(_LANG_COLLECT_CENTER_BROADCAST_2_10500_TAIL_3, "<font color=\"#FFFFFF\">由于~s和~s宝藏积分为0点，\\n~s宝藏积分未增加</font>").
-define(_LANG_COLLECT_DELETE_GRAFTS, <<"采集物，消失啦">>).

%%国战
-define(_LANG_WAROFFACTION_DECLARE_DAY_LESS_THAN_SEVEN,<<"宣战之后需要过3天才能再次宣战">>).
-define(_LANG_WAROFFACTION_DEFENCE_DAY_LESS_THAN_THREE,<<"被宣战之后需要过1天才能再次被宣战">>).
-define(_LANG_WAROFFACTION_DECLARE_NOT_ENOUGH_RIGHT,<<"只有国王、大将军才有权限对外宣战">>).
-define(_LANG_WAROFFACTION_CAN_NOT_DECLARE_ON_FRIDAY, <<"为避免与王座争霸战时间冲突，周五不能宣战">>).
-define(_LANG_WAROFFACTION_FACTION_SILVER_NOT_ENOUGH,<<"国库银子不足">>).
-define(_LANG_WAROFFACTION_CONVENE_FACTION_POWER_NOT_ENOUGH,<<"只有国王和大将军可以进行国家传送">>).
-define(_LANG_WAROFFACTION_CONVENE_FAMILY_POWER_NOT_ENOUGH,<<"只有掌门可以进行门派传送">>).
-define(_LANG_WAROFFACTION_FACTION_CONVENE_TIME_OVER,<<"国战召集次数最多三次">>).
-define(_LANG_WAROFFACTION_FAMILY_CONVENE_TIME_OVER,<<"门派召集次数最多五次">>).
-define(_LANG_WAROFFACTION_CONVENE_NOT_IN_WAR_TIME,<<"非国战期间不能召唤">>).
-define(_LANG_WAROFFACTION_TRANSFER_TIME_OUT,<<"抄送时间已过">>).
-define(_LANG_FACTION_LANUCH_COLLECTED_TODAY,<<"每天只能向全体国民发起1次募捐活动">>).
-define(_LANG_FACTION_BUY_GUARDER_TIME_WRONG,<<"只有在国战准备阶段可以购买守卫">>).
-define(_LANG_FACTION_GUARDER_ALREADLY_EXIST,<<"不能重复招募守卫和拒马">>).
-define(_LANG_WAROFFACTION_BUY_GUARDER_FACTION_RIGHT_NOT_ENOUGH,<<"只有国王和大将军可以招募守卫和拒马">>).
-define(_LANG_WAROFFACTION_GATHER_FACTIONIST_KING, <<"国王<font color=\"#FFFF00\">[~s]</font>正在征集国民前往参加国战，您是否确认接受征召，确定则免费传送至国王身边">>).
-define(_LANG_WAROFFACTION_GATHER_FACTIONIST_GENERAL, <<"大将军<font color=\"#FFFF00\">[~s]</font>正在征集国民前往参加国战，您是否确认接受征召，确定则免费传送至大将军身边">>).
-define(_LANG_WAROFFACTION_GATHER_CONFIRM_NOT_IN_WAR, <<"国战已经结束，召集令失效">>).
-define(_LANG_WAROFFACTION_GATHER_CONFIRM_LEVEL_NOT_ENOUGH, <<"确认召集失败，等级不够">>).
-define(_LANG_WAROFFACTION_GATHER_CONFIRM_SPEC_STATE, <<"当前状态下不能被召集">>).
-define(_LANG_WAROFFACTION_GATHER_CONFIRM_TIME_OVER, <<"确认失败，如今时间已过">>).
-define(_LANG_WAROFFACTION_GATHER_CONFIRM_IN_JAIL, <<"在监狱中不能响应召集">>).
-define(_LANG_WAROFFACTION_ROLE_ONLINE_ATTACK, <<"本国已向~s下达战书，将于~w年~w月~w日20:00正式对~s发起总攻">>).
-define(_LANG_WAROFFACTION_ROLE_ONLINE_DEFENCE, <<"~s已向本国进行宣战，将于~w年~w月~w日20:00正式向我国发起进攻">>).


%% 逐鹿天下副本资源文件
-define(_LANG_VIE_WORLD_FB_PARAM_ERROR,<<"无法进入副本">>).
-define(_LANG_VIE_WORLD_FB_TYPE_ID_ERROR,<<"无法进入副本">>).
-define(_LANG_VIE_WORLD_FB_NPC_ID_ERROR,<<"无法进入副本">>).
-define(_LANG_VIE_WORLD_FB_ERROR,<<"无法进入副本">>).
-define(_LANG_VIE_WORLD_FB_NO_TEAM,<<"敌军异常凶猛，需组成3人以上队伍方可前往">>).
-define(_LANG_VIE_WORLD_NOT_LEADER,<<"让你的队长来找我">>).
-define(_LANG_VIE_WORLD_NOT_RANGE,<<"你有队员不在附近">>).
-define(_LANG_VIE_WORLD_FACTION,<<"你不是本国成员，无法开启副本">>).
-define(_LANG_VIE_WORLD_ROLE_LEVEL,<<"队伍中有人不足25级，不可前往挑战">>).
-define(_LANG_VIE_WORLD_IN_ENTER,<<"无法进入副本">>).
-define(_LANG_VIE_WORLD_CREATE_FB,<<"无法进入副本">>).
-define(_LANG_VIE_WORLD_QUIT_FB,<<"无法离开副本">>).
-define(_LANG_VIE_WORLD_CLOSE_FB,<<"副本将在~s秒后关闭，请通过“敌营传送人”传送出去">>).
-define(_LANG_VIE_WORLD_HOLD_TIME,<<"<font color=\"#FF0000\">讨伐敌营副本将在~s分钟后关闭</font>">>).
-define(_LANG_VIE_WORLD_BOSS_BRON,<<"强大的BOSS已经出现在副本中">>).


%% 逐鹿天下副本消息广播资源
-define(_LANG_VIE_WORLD_FB_BC_MSG_BEFORE_S_CENTER,<<"讨伐敌营副本将在~s时~s分~s秒开启，请组好队伍，准备挑战">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_BEFORE_S_LEFT,<<"<font color=\"#FFCC00\">“讨伐敌营” 副本将在~s分钟后开启，请25级以上的豪杰，组好队伍，准备参加">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_START_CENTER,<<"明军统领在王都招募各路英雄豪杰前往讨伐敌营，名额有限，请速赶来">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_START_LEFT,<<"<font color=\"#FFCC00\">请25级以上的豪杰，组成3人以上队伍，速往王都找到“明军统领”，开启“讨伐敌营” 副本，歼灭敌军！</font>">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_END_LEADER,<<"<font color=\"#FFFFFF\"><font color=\"#FFFF00\">~s</font> 率领队伍，在 ~s 成功挑战副本 <font color=\"#FF6600\">“讨伐敌营”</font>，获得了丰厚奖励！</font>">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_END_MEMBER,<<"副本完成，请通过“敌营传送人”传送出去">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_END_CENTER,<<"本次“讨伐敌营”副本活动已结束">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_END_LEFT,<<"本次“讨伐敌营”副本活动已结束">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_RUNNING,<<"敌军（~s/30）">>).
-define(_LANG_VIE_WORLD_FB_BC_MSG_RUNNING_ELITE,<<"敌军精英（~s/1）">>).


%%个人镖车
-define(_LANG_PERSONYBC_SILVER_NOT_ENOUGH, "您的银子不足，拉镖需要 ~ts").
-define(_LANG_PERSONYBC_MAX_TIMES, "已经达到今天拉镖的最大次数").
-define(_LANG_PERSONYBC_OWNER, "~s的镖车").
-define(_LANG_PERSONYBC_NOT_PUBLIC, "您还没有接镖"). 
-define(_LANG_PERSONYBC_HAS_PUBLIC, "拉镖已经开始，请勿重复接镖"). 
-define(_LANG_PERSONYBC_HAS_PUBLIC_CAN_NOT_CHANGE_COLOR, "拉镖已经开始，不能使用换车令"). 
-define(_LANG_PERSONYBC_HAS_GOT_THE_BEST_COLOR, "已经获得最佳颜色，无需继续使用换车令"). 
-define(_LANG_PERSONYBC_GET_GOOD_COLOR, "哇！~s的 [~s] 成功接到一辆 ~s 镖车，完成任务将获得超值奖励").
-define(_LANG_PERSONYBC_DISTANCE, " 哇，英雄你这么高级了，请沿着护镖路线将镖车运往前方哦"). 
-define(_LANG_PERSONYBC_LEVEL_LIMIT, "您的等级不满足要求，拉镖需要等级到达30"). 
-define(_LANG_PERSONYBC_FAMILY, "拉镖需要先加入门派，您还没有加入任何门派，赶快去加入一个门派吧"). 
-define(_LANG_PERSONYBC_DOING_FAMILY_YBC, "您当前处于门派拉镖状态，暂时不能进行个人拉镖"). 
-define(_LANG_PERSONYBC_GIVE_BACK_COST, "<FONT COLOR='#FFCC00'>完成拉镖任务<br />退回押金：~s</FONT>").
-define(_LANG_PERSONYBC_SUCC_PUBLIC_YBC, "<FONT COLOR='#FFCC00'>收取押金~s<br />成功领取到一辆  ~s 的镖车</FONT>").
-define(_LANG_YBC_PERSON_NOT_ENOUGH_GOLD_WHEN_AUTO_YBC, <<"当前国运时间，你的元宝不足~p，无法进行自动拉镖">>).
-define(_LANG_PERSONYBC_SYSTEM_ERROR_WHEN_AUTO_YBC, <<"自动拉镖时发生系统错误，请联系GM">>).
-define(_LANG_PERSONYBC_SYSTEM_ERROR_WHEN_SET_AUTO, <<"设置自动拉镖开关时发生系统错误">>).
-define(_LANG_YBC_POS, "你的镖车在 <A HREF=\"event:goto#~w，~w，~w\"><FONT color=\"#EBED32\"><U>~s</U></FONT></A>").
-define(_LANG_PERSONYBC_YBC_DISTANCE, "你的镖车不在附近，无法提交，快沿途去找找吧").
-define(_LANG_ITEM_CAN_NOT_USE_RANDOM_MOVE_DOING_YBC, <<"您正在拉镖，不能使用瞬移符">>).
-define(_LANG_ITEM_CAN_NOT_USE_RANDOM_IN_ENEMY, <<"您正在敌国，不能使用瞬移符">>).
-define(_LANG_ITEM_SYSTEM_ERROR_WHEN_BATCH_SELL, <<"批量卖出物品时发生系统错误，请联系GM">>).
-define(_LANG_ITEM_GOODS_NOT_EXIST, <<"卖出道具列表错误，请刷新背包后，重新打开卖出界面">>).
-define(_LANG_ITEM_LIST_IS_EMPTY_WHEN_BATCH_SELL, <<"卖出道具列表为空">>).
-define(_LANG_ITEM_CANNT_SELL, <<"卖出列表中存在不能卖出的道具">>).
-define(_LANG_PERSONYBC_TIMEOUT_NO_GIVE_BACK_COST, "拉镖超时，不退回押金").
-define(_LANG_PERSONYBC_KILLED_NO_GIVE_BACK_COST, "拉镖被劫，不退回押金").
-define(_LANG_PERSONYBC_FACTION_HAS_PUBLIC, <<"今日国运已经开始，请不要重复发布">>).
-define(_LANG_PERSONYBC_FACTION_SILVER_NOT_ENOUGH, <<"国运发布失败，国库不足10锭银子">>).
-define(_LANG_PERSONYBC_HAVE_NO_AUTH, <<"抱歉，只有国王或内阁大臣可以发布国运">>). 
-define(_LANG_PERSONYBC_NOT_ENOUGH_FAMILY_CONTRIBUTE, <<"参与国运需要门派贡献度5，您的门派贡献度不足">>).
-define(_LANG_PERSONYBC_FACTION_LEVEL_LIMIT, <<"抱歉，您的等级小于31级，不能参与国运">>). 
-define(_LANG_PERSONYBC_NOT_FACTION_YBC_TIME, <<"国民需要时间休养生息，请12：00之后再发布国运">>). 
-define(_LANG_PERSONYBC_FACTION_DOING_SPY, <<"国探期间不能发布国运">>). 
-define(_LANG_PERSONYBC_FACTION_SPY_SAME, <<"你所设定的国探时间与国运时间冲突">>). 
-define(_LANG_PERSONYBC_FACTION_WAROFFACTION_LIMIT, <<"国战期间不允许发布国运">>). 
-define(_LANG_PERSONYBC_HAS_END, <<"今日国运已经结束，不能再次发布">>).

-define(_LANG_YBC_BE_ATTACKING, <<"您的镖车正被攻击，请赶快救援">>).
-define(_LANG_YBC_DEAD, <<"您的镖车已经被劫，拉镖失败了">>).
-define(_LANG_YBC_CAN_NOT_ATTACK_SELF, <<"不能攻击自己的镖车">>).
-define(_LANG_YBC_CAN_NOT_ATTACK_SELF_FAMILY, <<"不能攻击本门派的镖车">>).
-define(_LANG_YBC_FAMILY_FARAWAY, <<"镖队里有门派成员已远离了镖车">>).
-define(_LANG_YBC_PERSON_FARAWAY, <<"你已远离镖车">>).
-define(_LANG_YBC_CAN_NOT_MEMBERGATHER, <<"您当前正在拉镖，不能使用门派传送令">>).
-define(_LANG_YBC_CAN_NOT_FAMILY_MAP_ENTER, <<"您当前正在拉镖，不能进入门派副本">>).
-define(_LANG_YBC_CAN_NOT_TRANSFORM_TO_WAROFKING, <<"您当前正在拉镖，不能被传送参加王座争霸战">>).
-define(_LANG_PERSONYBC_FACTION_CHANGE_TIME_LIMIT, "每天只能修改一次国运时间").
%% 装备品质描述常量定义
-define(_LANG_EQUIP_CONST_QUALITY_GENERAL,<<"普通的">>).
-define(_LANG_EQUIP_CONST_QUALITY_WELL,<<"精良的">>).
-define(_LANG_EQUIP_CONST_QUALITY_GOOD,<<"优质的">>).
-define(_LANG_EQUIP_CONST_QUALITY_FLAWLESS,<<"无暇的">>).
-define(_LANG_EQUIP_CONST_QUALITY_PERFECT,<<"完美的">>).
-define(_LANG_EQUIP_CONST_QUALITY_GOLD,<<"绝世的">>).
%% 国家描述常量定义
-define(_LANG_FACTION_CONST_1,<<"云州">>).
-define(_LANG_FACTION_CONST_2,<<"沧州">>).
-define(_LANG_FACTION_CONST_3,<<"幽州">>).

%% 一键换装
-define(_LANG_EQUIPONEKEY_EQUIPSID_NOT_EXIST, <<"不存在的自定义套装ID">>).

%% 天工炉炼制功能资源定义
-define(_LANG_REINFORCE_FORGING_EMPTY,<<"没有物品可炼制">>).
-define(_LANG_REINFORCE_FORGING_ERROR,<<"无法炼制，请注意炼制配方和物品数量">>).
-define(_LANG_REINFORCE_FORGING_STONE,<<"炼制物品中存在镶嵌有宝石的装备物品">>).
-define(_LANG_REINFORCE_FORGING_FAIL,<<"炼制失败">>).
-define(_LANG_REINFORCE_FORGING_BAG,<<"炼制创建物品失败，天工炉位置不够">>).
-define(_LANG_REINFORCE_FORGING_SUCC,<<"<font color=\"#FFFFFF\">恭喜 ~s 的<font color=\"#FFFF00\">[~s]</font>在天工炉炼制获得~s</font>">>).
-define(_LANG_REINFORCE_FORGING_NOT_OPEN,<<"天工炉炼制功能暂未开放">>).
-define(_LANG_REINFORCE_FORGING_ADORN_ERROR,<<"特殊装备【~s】不是合法炼制物品">>).

-define(_LANG_MOUNT_COLOR1, "<FONT COLOR='#FFFFFF'>白色</FONT>").
-define(_LANG_MOUNT_COLOR2, "<FONT COLOR='#10ff04'>绿色</FONT>").
-define(_LANG_MOUNT_COLOR3, "<FONT COLOR='#00c6ff'>蓝色</FONT>").
-define(_LANG_MOUNT_COLOR4, "<FONT COLOR='#ff00c6'>紫色</FONT>").
-define(_LANG_MOUNT_COLOR5, "<FONT COLOR='#FF6c00'>橙色</FONT>").

-define(_LANG_YBC_COLOR1, "<FONT COLOR='#FFFFFF'>白色</FONT>").
-define(_LANG_YBC_COLOR2, "<FONT COLOR='#10ff04'>绿色</FONT>").
-define(_LANG_YBC_COLOR3, "<FONT COLOR='#00c6ff'>蓝色</FONT>").
-define(_LANG_YBC_COLOR4, "<FONT COLOR='#ff00c6'>紫色</FONT>").
-define(_LANG_YBC_COLOR5, "<FONT COLOR='#FF6c00'>橙色</FONT>").
-define(_LANG_CHANGE_YBC_COLOR_SUCC, "消耗换车令×1，镖车颜色成功刷新为 ~s").
%% 商贸活动功能资源定义
-define(_LANG_TRADING_NOT_OPENT,<<"商贸活动功能暂未开放">>).
-define(_LANG_TRADING_NOT_VALID_TIME,<<"今日商贸时间为：00:00~19:00、22:00~24:00">>).
-define(_LANG_TRADING_NOT_VALID_TIME_SUNDAY,<<"今日商贸时间为：00:00~19:00">>).
-define(_LANG_TRADING_NOT_VALID_DISTANCE,<<"不在NPC附近，无法操作">>).
-define(_LANG_TRADING_SUNDAY_BC_CENTER,<<"今天是门派商贸日，完成商贸后使用商贸宝典可获得双倍收益">>).
-define(_LANG_TRADING_SUNDAY_BC_CHAT,<<"<font color=\"#FFFF00\">今天是门派商贸日，完成商贸后使用商贸宝典可获得双倍收益。商贸宝典可使用5点门派贡献在门派长老处兑换。</font>">>).
-define(_LANG_TRADING_SUNDAY_BC_END_CENTER,<<"商贸将在 ~s 分钟后结束，24:00重新开启，请抓紧时间">>).
-define(_LANG_TRADING_SUNDAY_BC_END_CHAT,<<"<font color=\"#FFFF00\">商贸将在 ~s 分钟后结束，24:00重新开启，请抓紧时间。</font>">>).
-define(_LANG_TRADING_DAY_BC_END_CENTER,<<"商贸将在 ~s 分钟后结束，22:00重新开启，请抓紧时间">>).
-define(_LANG_TRADING_DAY_BC_END_CHAT,<<"<font color=\"#FFFF00\">商贸将在 ~s 分钟后结束，22:00重新开启，请抓紧时间。</font>">>).
-define(_LANG_TRADING_SUNDAY_BC_END_CENTER_Z,<<"本次商贸已结束，24:00重新开启">>).
-define(_LANG_TRADING_SUNDAY_BC_END_CHAT_Z,<<"<font color=\"#FFFF00\">本次商贸已结束，24:00重新开启。</font>">>).
-define(_LANG_TRADING_DAY_BC_END_CENTER_Z,<<"本次商贸已结束，22:00后重新开启">>).
-define(_LANG_TRADING_DAY_BC_END_CHAT_Z,<<"<font color=\"#FFFF00\">本次商贸已结束，22:00后重新开启。</font>">>).

-define(_LANG_TRADING_LETTER_MONSTER,<<"你遭受了死亡的巨大打击，【商票】丢失，本次商贸失败">>).
-define(_LANG_TRADING_LETTER_ROLE,<<"你被~s的玩家<font color=\"#FFFF00\">[~s]</font>杀死，【商票】丢失，本次商贸失败">>).

-define(_LANG_TRADING_SHOP_PARAM_ERROR,<<"获取商店信息出错">>).
-define(_LANG_TRADING_SHOP_NOT_VALID_FACTION,<<"不能在别国的打开商贸商店">>).

-define(_LANG_TRADING_BUY_PARAM_ERROR,<<"无法购买此物品">>).
-define(_LANG_TRADING_BUY_NOT_BILL,<<"到夏原吉处领取商票后才能购买商品">>).
-define(_LANG_TRADING_BUY_GOODS_NOT_SALE,<<"在别处购买的商贸物品必须出售之后，才能购买新的物品">>).
-define(_LANG_TRADING_BUY_NOT_ENOUGH,<<"当前商贸价值不足购买此物品">>).
-define(_LANG_TRADING_BUY_LARGE_THAN_MAX_BILL,<<"商票价值超过上限，请回王都夏原吉处交还商票">>).
-define(_LANG_TRADING_BUY_POS_FULL,<<"商贸货舱已满">>).
-define(_LANG_TRADING_BUY_ERROR,<<"购买商贸商店物品失败">>).
-define(_LANG_TRADING_BUY_NOT_VALID_FACTION,<<"不能在别国购买商贸物品">>).

-define(_LANG_TRADING_SALE_PARAM_ERROR,<<"无法出售商贸物品">>).
-define(_LANG_TRADING_SALE_NOT_VALID_FACTION,<<"不能在别国出售商贸物品">>).
-define(_LANG_TRADING_SALE_NOT_BILL,<<"没有商票，不能出售商贸物品">>).
-define(_LANG_TRADING_SALE_SAME_SHOP,<<"不能在购买商店出售刚购买的物品">>).
-define(_LANG_TRADING_SALE_GOODS_EMPTY,<<"没有商贸商品可出售">>).
-define(_LANG_TRADING_SALE_NOT_VALID_GOODS,<<"无法出售商贸物品，物品不合法">>).
-define(_LANG_TRADING_SALE_ERROR,<<"出售商贸物品失败">>).

-define(_LANG_TRADING_GET_PARAM_ERROR,<<"无法领取商贸商票">>).
-define(_LANG_TRADING_GET_ACTIVE_POINTS,<<"活跃度为极其活跃时才能领取商票">>).
-define(_LANG_TRADING_GET_ERROR,<<"领取商贸商票失败">>).
-define(_LANG_TRADING_GET_BAG_ENOUGH,<<"背包空间不足，无法领取商票">>).
-define(_LANG_TRADING_GET_FULL_TIMES,<<"您今天已完成三次商贸，请明天再来">>).
-define(_LANG_TRADING_GET_ROLE_LEVEL,<<"英雄，请30级以后再来找我">>).
-define(_LANG_TRADING_GET_NOT_FAMILY,<<"加入门派后才能领取商票">>).
-define(_LANG_TRADING_GET_STATE_TRADING,<<"您上次的商贸还没有完成">>).
-define(_LANG_TRADING_GET_STATE_ERROR,<<"您当前的状态不能进行商贸活动">>).

-define(_LANG_TRADING_RETURN_PARAM_ERROR,<<"无法交还商贸商票">>).
-define(_LANG_TRADING_RETURN_ERROR,<<"交还商贸商票失败">>).
-define(_LANG_TRADING_RETURN_BAG_ERROR,<<"背包内没有商票，不能交票">>).
-define(_LANG_TRADING_RETURN_NOT_BILL,<<"您没有可交还的商票">>).
-define(_LANG_TRADING_RETURN_HAVE_GOODS,<<"您还有商贸商品没有出售，无法交还商票">>).
-define(_LANG_TRADING_RETURN_NOT_GOODS,<<"您没有商贸宝典物品">>).
-define(_LANG_TRADING_RETURN_INCOME_GOODS,<<"选择的增加商贸收益物品不合法">>).
-define(_LANG_TRADING_RETURN_INCOME_GOODS_NOT_USE,<<"此增加商贸收益物品不可以在今天使用">>).
-define(_LANG_TRADING_RETURN_SUCC_BIND,<<"<font color=\"#FFFFFF\">本帮众<font color=\"#FFFF00\">[~s]</font>完成商贸任务，获得绑定银子<font color=\"#FFFF00\">~s</font>文，增加门派资金<font color=\"#FFFF00\">~s</font>文</font>">>).
-define(_LANG_TRADING_RETURN_SUCC_NOT_BIND,<<"<font color=\"#FFFFFF\">本帮众<font color=\"#FFFF00\">[~s]</font>完成商贸任务，获得银子<font color=\"#FFFF00\">~s</font>文，增加门派资金<font color=\"#FFFF00\">~s</font>文</font>">>).

-define(_LANG_TRADING_EXCHANGE_PARAM_ERROR,<<"无法领取商贸宝典">>).
-define(_LANG_TRADING_EXCHANGE_ERROR,<<"领取商贸宝典失败">>).
-define(_LANG_TRADING_EXCHANGE_FC_ERROR,<<"兑换的门派贡献度不足">>).
-define(_LANG_TRADING_EXCHANGE_FC_NOT_ENOUGH,<<"您没有足够的门派贡献度可以兑换">>).
-define(_LANG_TRADING_EXCHANGE_BAG_ENOUGH,<<"背包满了，兑换失败">>).

-define(_LANG_TRADING_STATUS_ERROR,<<"获取玩家商贸状态失败">>).
%% 玩家财富
-define(_LANG_ROLE_MONEY_SYSTEM_ERROR_WHEN_REDUCE, <<"消耗玩家财富时发生系统错误">>).
-define(_LANG_ROLE_MONEY_SYSTEM_ERROR_WHEN_ADD, <<"增加玩家财富时发生系统错误">>).
-define(_LANG_ROLE_MONEY_NOT_ONLINE, <<"当前玩家不在线">>).
-define(_LANG_ROLE_MONEY_NOT_ENOUGH_GOLD_ANY, <<"元宝不足">>).
-define(_LANG_ROLE_MONEY_NOT_ENOUGH_GOLD_BIND, <<"绑定元宝不足">>).
-define(_LANG_ROLE_MONEY_NOT_ENOUGH_GOLD, <<"元宝不足">>).
-define(_LANG_ROLE_MONEY_NOT_ENOUGH_SILVER_ANY, <<"银子不足">>).
-define(_LANG_ROLE_MONEY_NOT_ENOUGH_SILVER_BIND, <<"绑定银子不足">>).
-define(_LANG_ROLE_MONEY_NOT_ENOUGH_SILVER, <<"银子不足">>).
%%鲜花功能
-define(_LANG_FLOWERS_SYSTEM_ERROR,<<"鲜花赠送系统错误">>).
-define(_LANG_FLOWERS_NOT_ROLE,<<"没有找到你要赠送的玩家">>).
-define(_LANG_FLOWERS_SAME_SEX,<<"性别相同，不能签名送花">>).
-define(_LANG_FLOWERS_FEMALE_TO_MALE,<<"只能男性向女性签名送花">>).
-define(_LANG_FLOWERS_NOT_FLOWER,<<"背包中没有你要赠送的鲜花">>).
-define(_LANG_FLOWERS_DEFAULT_BROADCASTING,"哇！神秘人物向[~s]赠送了 ~s，[~s]好幸福啊").
%% 在线挂机状态资源定义
-define(_LANG_ROLE2_ON_HOOK_BEGIN_BIG_PK_POINTS,<<"你 PK 值过大，无法在线挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_NOT_IN_STALL,<<"在王都的寄售区在才能在线挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_NOT_IN_MAPID,<<"在王都的寄售区在才能在线挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_IN_ON_HOOK_STATUS,<<"你已处于在线挂机状态">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_IN_ZAZEN_STATUS,<<"你处于打坐状态下，请先取消再操作在线挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_IN_STALL_STATUS,<<"你在亲自寄售，请收摊后再进行“在线挂机”">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_IN_FIGHTING_STATUS,<<"PK过程中无法挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_IN_DEAD_STATUS,<<"死亡状态下中无法挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_IN_FIGHT_STATUS,<<"战斗状态下无法挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_IN_EXCHANGE_STATUS,<<"交易状态下无法挂机">>).
-define(_LANG_ROLE2_ON_HOOK_BEGIN_GRAY_NAME,<<"灰名状态下，无法在线挂机">>).
-define(_LANG_ROLE2_ON_ZAZEN_GET_EXP,<<"本次打坐获得~s点经验">>).

-define(_LANG_ROLE2_ON_HOOK_END_PARAM_ERROR,<<"无法取消在线挂机">>).
-define(_LANG_ROLE2_ON_HOOK_END_NOT_IN_ON_HOOK_STATUS,<<"你不在在线挂机状态，不需要取消">>).
-define(_LANG_ROLE2_ON_HOOK_END_NOT_IN_MAPID,<<"你不在王都的寄售区，无法取消在线挂机">>).

-define(_LANG_ROLE2_ON_HOOK_STATUS_PARAM_ERROR,<<"无法获取玩家在线挂机状态">>).
-define(_LANG_ROLE2_ON_HOOK_STATUS_NOT_IN_ON_HOOK_STATUS,<<"你不在在线挂机状态，没有在线挂机状态">>).
-define(_LANG_ROLE2_ON_HOOK_STATUS_NOT_IN_MAPID,<<"你不在王都的寄售区，无法获取在线挂机状态">>).

%%等级礼包
-define(_LANG_LEVEL_GIFT_ERROR_LEVEL, <<"你的等级不能领取这个等级礼包">>).
-define(_LANG_LEVEL_GIFT_HAS_ACCEPT,<<"这个礼包已经提取">>).
-define(_LANG_LEVEL_GIFT_NOT_GIFT,<<"没有找到这种礼包">>).
-define(_LANG_LEVEL_GIFT_ENOUGH_POS,<<"背包空间不足，请整理背包后再领取礼包">>).
-define(_LANG_LEVEL_GIFT_SYSTEM_ERROR,<<"领取等级礼包，发生系统错误！请尝试刷新游戏">>).

%%时间礼包
-define(_LANG_TIME_GIFT_WRONG_TIME, <<"等待时间未到,不能领取这个时间礼包">>).
-define(_LANG_TIME_GIFT_HAS_ACCEPT,<<"这个礼包已经提取">>).
-define(_LANG_TIME_GIFT_NOT_GIFT,<<"没有找到这种礼包">>).
-define(_LANG_TIME_GIFT_ENOUGH_POS,<<"背包空间不足，请整理背包后再领取礼包">>).
-define(_LANG_TIME_GIFT_SYSTEM_ERROR,<<"领取时间礼包，发生系统错误！请尝试刷新游戏">>).

%% 活动资源定义

%% 极速讨伐敌营活动资源
-define(_LANG_ACTIVITY_VWF_CENTER,<<"[~s]率领队伍，在 ~s 以迅雷不及掩耳之速成功挑战“讨伐敌营”副本">>).
-define(_LANG_ACTIVITY_VWF_CHAT,<<"<font color=\"#FFFFFF\"><font color=\"#FFFF00\">[~s]</font>率领队伍，在 ~s 以迅雷不及掩耳之速成功挑战<font color=\"#FF6600\">“讨伐敌营”</font>副本！</font>">>).
-define(_LANG_ACTIVITY_VWF_ROLE,<<"<font color=\"#FFFF00\">您在春节活动期间快速完成了讨伐敌营，获得一笔额外奖励，请从奖励发放信件中提取！</font>">>).
-define(_LANG_ACTIVITY_VWF_LETTER,<<"尊贵的《天之刃》玩家：\n\t\t由于您在活动期间（~s）以迅雷不及掩耳之势完成讨伐敌营，特此奖励您 ~s 一张，请从 <font color=\"#FF0000\">本信件</font> 中提取。\n\t\t感谢您对我们游戏的支持！\n<p align=\"right\">《天之刃》运营团队</p>">>).
-define(_LANG_ACTIVITY_VWF_LETTER_TITLE, <<"极速讨伐敌营奖励发放">>).
-define(_LANG_ACTIVITY_HAS_GET_WHEN_GET_FIRST_PAY, <<"你已经领取首充礼包">>).
-define(_LANG_ACTIVITY_NOT_PAYED_WHEN_GET_FIRST_PAY, <<"你尚未充值，无法领取首充礼包">>).
-define(_LANG_ACTIVITY_SYSTEM_ERROR_WHEN_GET_PAY_FIRST_GIFT, <<"领取礼包时发生系统错误，请联系GM">>).
-define(_LANG_ACTIVITY_BAG_ENOUGH_WHEN_GET_PAY_FIRST_GIFT, <<"你的背包已满无法领取礼包">>).
-define(_LANG_ACTIVITY_SYSTEM_ERROR_WHEN_GET_PAY_GIFT_INFO, <<"获取充值礼包信息时发生系统错误，请联系GM">>).
-define(_LANG_ACTIVITY_HAS_GET_WHEN_FETCH, <<"你已经领取该礼包了">>).
-define(_LANG_ACTIVITY_AWARD_ITEM, <<"恭喜你获得~s">>).
-define(_LANG_ACTIVITY_AWARD_ITEM_BAG_NOT_POS, <<"您的背包已满，无法赠送节日活动的物品">>).
-define(_LANG_ACTIVITY_JOIN_AND_GET_AWARD, <<"必须参加活动之后，才能领取奖励">>).
-define(_LANG_ACTIVITY_MAX_LEVEL_MAX_EXP_ADD_EXP, <<"您已经达到最高等级的最高经验，日常福利不再增加经验">>).
-define(_LANG_ACTIVITY_HAS_AWARD_ITEM_NOT_BUY, <<"今日已领取奖励，不需购买活动勋章">>).



%% 大明宝藏副本资源定义
-define(_LANG_COUNTRY_TREASURE_NOT_OPEN, <<"大明宝藏副本功能未开启">>).
-define(_LANG_COUNTRY_TREASURE_NOT_VALID_DISTANCE, <<"不在NPC附近，无法操作">>).
-define(_LANG_COUNTRY_TREASURE_NOT_OPEN_TIME,<<"大明宝藏副本时间未到，无法进入">>).
-define(_LANG_COUNTRY_TREASURE_ENTER_PARAM_ERROR, <<"无法进入大明宝藏副本">>).
-define(_LANG_COUNTRY_TREASURE_ENTER_LEVEL, <<"你级别不足~s级，无法进入大明宝藏副本">>).
-define(_LANG_COUNTRY_TREASURE_ENTER_ENOUGH_MONEY, <<"你银子不足，无法进入大明宝藏副本">>).
-define(_LANG_COUNTRY_TREASURE_ENTER_FB_MAX_NUMBER, <<"当前大明宝藏地图人数达到满员~s人，无法继续进入，请您稍后尝试">>).

-define(_LANG_COUNTRY_TREASURE_QUIT_PARAM_ERROR, <<"无法退出大明宝藏副本">>).
-define(_LANG_COUNTRY_TREASURE_QUIT_FACTION, <<"你不是该国国民，无法传送">>).

-define(_LANG_COUNTRY_TREASURE_QUERY_ERROR, <<"无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_FIGHTING_STATUS, <<"战斗状态下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_STALL_STATUS, <<"寄售状态下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_DEAD_STATUS, <<"死亡状态下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_EXCHANGE_STATUS, <<"交易状态下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_TRAINING_STATUS, <<"离线挂机状态下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_TRADING_STATUS, <<"商贸状态状态下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_SPECIAL_MAP, <<"特殊场景下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_IN_FB_MAP, <<"副本场景下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_COLLECT_STATUS, <<"采集状态下无法传送">>).
-define(_LANG_COUNTRY_TREASURE_TRAINING_STATUS, <<"训练状态下无法传送">>).


-define(_LANG_COUNTRY_TREASURE_B_CHAT, <<"<font color=\"#FFFCA2\">大明宝藏地图将于~s开启，所有等级达到~s级的人都可以进入地图内挖掘宝物， 在<a href=\"event:goto_country_treasure\"><font color=\"#00FF00\"><u>王都-宝藏传送员</u></font></a>处可传送进入宝藏地图！</font>">>).
-define(_LANG_COUNTRY_TREASURE_B_CHAT_OK, <<"<font color=\"#FFFCA2\">大明宝藏地图开启，所有等级达到~s级的人都可以进入地图内挖掘宝物， 在<a href=\"event:goto_country_treasure\"><font color=\"#00FF00\"><u>王都-宝藏传送员</u></font></a>处可传送进入宝藏地图！</font>">>).
-define(_LANG_COUNTRY_TREASURE_P_CHAT, <<"<font color=\"#FFFCA2\">大明宝藏地图已经开启，所有等级达到~s级的人都可以进入地图内挖掘宝物， 在<a href=\"event:goto_country_treasure\"><font color=\"#00FF00\"><u>王都-宝藏传送员</u></font></a>处可传送进入宝藏地图！</font>">>).
-define(_LANG_COUNTRY_TREASURE_E_CENTER, <<"大明宝藏地图将于~s关闭，请大家抓紧时间挖掘宝物">>).
-define(_LANG_COUNTRY_TREASURE_E_CHAT, <<"<font color=\"#FFFCA2\">大明宝藏地图关闭，下一次开启时间为~s</font>">>).
-define(_LANG_COUNTRY_TREASURE_E_CHAT_F, <<"<font color=\"#FFFCA2\">大明宝藏地图关闭</font>">>).
-define(_LANG_COUNTRY_TREASURE_QUIT_BROADCAST_1, <<"<font color=\"#FFFFFF\">本次大明宝藏积分第一为~s，在宝藏地图的~s国民获得半个小时的额外的战斗状态加成。</font>">>).
-define(_LANG_COUNTRY_TREASURE_QUIT_BROADCAST_2, <<"<font color=\"#FFFFFF\">本次大明宝藏积分为~s和~s并列第一，在宝藏地图的~s和~s国民\\n获得半个小时额外的战斗力提升。</font>">>).
-define(_LANG_COUNTRY_TREASURE_QUIT_BROADCAST_3, "<font color=\"#FFFFFF\">本次大明宝藏积分为云州、沧州和幽州并列第一，在宝藏地图的所有人\\n获得半个小时额外的战斗力提升。</font>").

%% 刺探
-define(_LANG_SPY_FACTION_ONLY_KING_AND_GENERAL_CAN_PUBLISH, <<"只有国王或锦衣卫指挥使才能发布国探">>).
-define(_LANG_SPY_FACTION_PUBLISH_TIME_ILLEGAL, <<"国民需要时间休养生息，请12:00之后再发布国探">>).
-define(_LANG_SPY_FACTION_HAS_PUBLISHED, <<"今天已发布过国探">>).
-define(_LANG_SPY_FACTION_IN_PERSONYBC_FACTION, <<"当前正在国运，不能发布国探">>).
-define(_LANG_SPY_FACTION_IN_WAR_OF_FACTION, <<"国战期间不能发布国探，请国战结束再来发布">>).
-define(_LANG_SPY_TIME_REACH_LIMIT, <<"去该国家刺探的次数已超过限制，选择另外一个国家吧">>).
-define(_LANG_SPY_FACTION_IN_SPY_FACTION, <<"正在进行国探">>).
-define(_LANG_SPY_FACTION_SILVER_NOT_ENOUGH, <<"目前国库亏空，已无法发起国探">>).
-define(_LANG_SPY_TIME_SYSTEM_ERROR, <<"修改国探时间失败，系统错误">>).
-define(_LANG_SPY_TIME_SET_BROADCAST, <<"我国~s<font color=\"#FFFF00\">[~s]</font>把默认国探时间修改为~w:~s点，请我国国民密切留意">>).
-define(_LANG_SPY_TIME_ONLY_KING_AND_JINYIWEI, <<"只有国王和锦衣卫指挥使才能修改国探时间">>).
-define(_LANG_SPY_TIME_WAROFFACTION_TIME_CONFLICT_TOMORROW, <<"明日有国战，19：30至国战结束不能设置为国探时间">>).
-define(_LANG_SPY_TIME_WAROFFACTION_TIME_CONFLICT_TODAY, <<"今日有国战，19：30至国战结束不能设置为国探时间">>).
-define(_LANG_SPY_TIME_TODAY_COUNT_LIMITED, <<"今天已经设置过国探时间了，每天只能设置一次">>).
-define(_LANG_SPY_TIME_INPUT_HOUR_ILLEGAL, <<"输入的小时不合法，小于0或大于23">>).
-define(_LANG_SPY_TIME_INPUT_MIN_ILLEGAL, <<"输入的分钟不合法，小于0或大于59">>).
-define(_LANG_SPY_TIME_ILLEGAL, <<"国探时间只能设在12:00-24:00">>).
-define(_LANG_SPY_FACTION_START_15_MIN_BEFORE, <<"我国国探将于15分钟后开始">>).
-define(_LANG_SPY_FACTION_START_5_MIN_BEFORE, <<"我国国探将于5分钟后开始">>).
-define(_LANG_SPY_FACTION_START, <<"我国国探开始了，请国民赶紧到王都-冯胜处领取刺探军情任务，参与国探">>).
-define(_LANG_SPY_FACTION_END, <<"我国今天的国探已结束">>).
-define(_LANG_SPY_TIME_NPC_POS_TOO_FAR, <<"设置失败，与NPC距离过远">>).
-define(_LANG_SPY_TIME_GET_SYSTEM_ERROR, <<"获取国探开始时间失败，系统错误">>).
-define(_LANG_SPY_TIME_FACTION_YBC_SAME, <<"你设定的时间和国运时间冲突">>). 

%%宠物系统
-define(_LANG_PET_BAG_NOT_ENOUGH, <<"<font color='#FFFF00'>宠物背包已满，不可携带更多的宠物！按X可查看</font>">>).
-define(_LANG_ROLE_LEVEL_NOT_ENOUGH_TO_GET_PET, <<"<font color='#FFFF00'>您的等级不足，不可使用此召唤符</font>">>).
-define(_LANG_OTHER_PET_SUMMONED, <<"<font color='#FFFF00'>请先收回当前出战宠物再召唤</font>">>).
-define(_LANG_PET_NOT_SUMMONED, <<"<font color='#FFFF00'>您当前没有正在出战的宠物</font>">>).
-define(_LANG_CAN_NOT_THROW_SUMMONED_PET, <<"<font color='#FFFF00'>您的宠物正处于出战状态，请召回后再进行放生操作</font>">>).
-define(_LANG_PET_NOT_EXIST, <<"<font color='#FFFF00'>没有该宠物。</font>">>).
-define(_LANG_PET_SUMMONED_CAN_NOT_LEARN_SKILL,<<"<font color='#FFFF00'>您的宠物正处于出战状态，请召回后再学习技能</font>">>).
-define(_LANG_PET_LIFE_NOT_ENOUGH_TO_SUMMON,<<"您的宠物寿命不足，不可召唤。\n<font color='#FFFF00'>可按X打开宠物面板进行延寿</font>">>).
-define(_LANG_PET_CALL_BACK_FOR_LIFE_OVER,<<"您的宠物寿命不足，已收入宠物背包，按X查看。\n<font color='#FFFF00'>可按X打开宠物面板进行延寿</font>">>).
-define(_LANG_PET_ADD_HP_ITEM_USE_OK,<<"成功使用宠物药，宠物的血量提升了">>).
-define(_LANG_PET_ADD_EXP_ITEM_USE_OK,<<"成功使用宠物经验药，宠物的经验提升了">>).
-define(_LANG_PET_ADD_REFINING_EXP_ITEM_USE_OK,<<"成功使用宠物经验葫芦，您的宠物获得了~w经验">>).
-define(_LANG_PET_ADD_HP_FAIL_HP_FULL,<<"宠物的血是满的，无需使用宠物药">>).
-define(_LANG_PET_ADD_EXP_FAIL_HP_FULL,<<"宠物的经验是满的，无需使用宠物药">>).
-define(_LANG_PET_RESET_ATTR_ITEM_USE_FAIL_NO_SUMMONED_PET,<<"<font color='#FFFF00'>您当前没有正在出战的宠物，不能使用洗髓丹</font>">>).
-define(_LANG_PET_RESET_ATTR_ITEM_USE_OK,<<"成功使用洗髓丹，宠物的属性重置了">>).
-define(_LANG_PET_ADD_PET_ROOM_ITEM_USE_OK,<<"成功使用宠物栏，宠物栏的数量增加了">>).
-define(_LANG_PET_CONFIG_ERROR,<<"宠物配置文件错误">>).
-define(_LANG_ADD_PET_LIFE_ITEM_TYPE_ERROR,<<"请使用延寿丹进行延寿">>).
-define(_LANG_PET_REMAIN_ATTR_POINT_NOT_ENOUGH,<<"<font color='#FFFF00'>宠物潜能为0，无法分配</font>">>).
-define(_LANG_PET_SUMMONED_CAN_NOT_REFRESH_APTITUDE,<<"<font color='#FFFF00'>您的宠物正处于出战状态，请召回后再洗灵</font>">>).
-define(_LANG_PET_SUMMONED_CAN_NOT_ADD_UNDERSTANDING,<<"<font color='#FFFF00'>您的宠物正处于出战状态，请召回后再提悟</font>">>).
-define(_LANG_PET_UNDERSTANDING_IS_FULL,<<"<font color='#FFFF00'>您的宠物已达顶级悟性，无需继续提悟</font>">>).
-define(_LANG_PET_ADD_UNDERSTANDING_ITEM_ERROR,<<"<font color='#FFFF00'>当前宠物提悟需更高级的提悟符</font>">>).
-define(_LANG_PET_REFRESH_APTITUDE_ITEM_ERROR,<<"<font color='#FFFF00'>当前宠物洗灵，需更高级的洗灵丹</font>">>).
-define(_LANG_PET_SUMMONED_CAN_NOT_CHANGE_NAME,<<"<font color='#FFFF00'>您的宠物正处于出战状态，请召回后再改名。</font>">>).
-define(_LANG_PET_ADD_UNDERSTANDING_MORE_THAN_SIX,<<"<font color='#FFFF00'>[~s]</font>将爱宠悟性提高到~w，宠物资质大大提升了">>).
-define(_LANG_PET_REFRESH_APTITUDE_GET_GOOD_PET,<<"<font color='#FFFF00'>[~s]</font>使用<a href='event:openPetWin:2'><font  color=\"#00ff00\">【洗灵丹】</font></a>洗出了极品宠物，真是功夫不负有心人啊">>).
-define(_LANG_PET_ROLE_GET_NEW_PET,<<"<font color='#FFFF00'>[~s]</font>小心翼翼地使用宠物召唤符，获得了一个可爱无比的<a href='event:pet_info:~w' ><u><font color='~s'>[~s]</font></u></a>">>).
-define(_LANG_CAN_NOT_FEED_SUMMONED_PET,<<"<font color='#FFFF00'>宠物正在出战，请收回后再训练</font>">>).
-define(_LANG_PET_SUMMONED_CAN_NOT_FORGET_SKILL,<<"<font color='#FFFF00'>宠物正在出战，请收回后再遗忘宠物技能</font>">>).
-define(_LANG_PET_ALREADLY_FEEDED,<<"<font color='#FFFF00'>宠物正在训练中</font>">>).
-define(_LANG_PET_TODAY_FEED_TIME_OVER,<<"<font color='#FFFF00'>今日训练次数已达上限</font>">>).
-define(_LANG_PET_NOT_IN_FEEDING,<<"<font color='#FFFF00'>宠物没有在训练状态</font>">>).
-define(_LANG_PET_FEEDING_NOT_OVER,<<"宠物训练还未完成">>).
-define(_LANG_PET_FEED_STAR_UP_BROADCAST,<<"~s<font color='#FFFF00'>[~s]</font>将自己本周的训练宠物星级提升为~w星，\\n本周内他的每次宠物训练都将获得海量的宠物经验">>).
-define(_LANG_PET_GROW_NOT_OVER,<<"训宠还未完成">>).
-define(_LANG_PET_GROW_LEVEL_FULL,<<"已达最高训宠等级">>).
-define(_LANG_PET_GROW_LEVEL_NOT_ENOUGH,<<"角色等级不够，不能提升驯养等级">>).
-define(_LANG_PET_GROW_SILVER_NOT_ENOUGH,<<"银子不足，不能提升驯养等级">>).
-define(_LANG_PET_GROW_GOLD_NOT_ENOUGH,<<"元宝不足，不能加速完成驯养">>).
-define(_LANG_PET_GROW_PRE_SKILL_NOT_LEARN,<<"前置驯养技能等级不足">>).
-define(_LANG_PET_SKILL_NOT_EXIST,<<"宠物没有学该技能">>).
-define(_LANG_PET_GROW_BROADCAST,<<"<font color='#FFFF00'>[~s]</font>花费~w元宝，立即将<a href='event:pet_grow'><u><font color='#00ff00'>驯宠能力</font></u></a>：~s提升到了~w级，出战宠物的能力大大提升了">>).
-define(_LANG_PET_SUMMONED_CAN_NOT_REFINING,<<"<font color='#FFFF00'>您的宠物正处于出战状态，请召回后再炼制</font>">>).
-define(_LANG_PET_EGG_ITEM_NOT_EXIST,<<"缺少神宠蛋">>).
-define(_LANG_PET_EGG_CONFIG_FILE_ERROR,<<"宠物蛋配置文件错误">>).
-define(_LANG_PET_EGG_NO_PET_IN_TYPE,<<"您没有该类型的宠物">>).
-define(_LANG_PET_EGG_OUT_OF_USE_TIME,<<"您的宠物蛋已经过期">>).
-define(_LANG_PET_ROLE_GET_EGG_PET,<<"<font color='#FFFF00'>[~s]</font>对着神宠蛋念念有词，不料竟从中走出一个<a href='event:pet_info:~w' ><u><font color='~s'>[~s]</font></u></a>！<a href='event:openShop' ><u><font color='#00ff00'>购买神宠蛋</font></u></a>">>).
-define(_LANG_PET_TRICK_CONFIG_FILE_ERROR,<<"宠物特技配置文件错误">>).
-define(_LANG_PET_TRICK_LEARN_ROLE_LEVELL_NOE_ENOUGH,<<"等级不足，不能领悟技能">>).
-define(_LANG_PET_TRICK_UPGRADE_SKILL_NOT_LEARN,<<"没有学习该技能，不能升级">>).
-define(_LANG_PET_TRICK_SKILL_LEVEL_FULL,<<"技能已经达到最高等级，不能再学习">>).
-define(_LANG_PET_BAG_IS_FULL,<<"宠物栏位已满">>).
-define(_LANG_PET_ADD_TRAINING_ROOM_ENOUGH,<<"宠物训练位已满">>).
-define(_LANG_PET_IS_TRAINING,<<"宠物正处于训练状态">>).
-define(_LANG_PET_TRAINING_LEVEL_FULL,<<"宠物等级不能超过角色等级，不能再训练">>).
-define(_LANG_PET_TRAINING_HOURS_ILLEGAL,<<"宠物训练时间非法">>).
-define(_LANG_PET_IS_FREE,<<"宠物不在训练状态，请重新选择">>).
-define(_LANG_PET_FLY_TRAINING_CDING,<<"突飞时间尚未冷却，请耐心等待">>).
-define(_LANG_PET_NEED_NOT_TO_RESET_FLY_CD_TIME,<<"不需要清除突飞猛进时间">>).
-define(_LANG_PET_TRAINING_MODE_ILLEGAL,<<"所选的训练模式无效">>).
-define(_LANG_FLY_PET_TRAINING_NO_GOODS,<<"宠物突飞令数量不足">>).
-define(_LANG_PET_TRAINING_NOT_VIP,<<"VIP等级不够不能选择此训练模式">>).
-define(_LANG_PET_BAG_NO_PET,<<"当前没有宠物，还不用增加宠物栏">>).
%% 监狱
-define(_LANG_JAIL_DONATE_SYSTEM_ERROR, <<"捐献监狱建设费失败：系统错误">>).
-define(_LANG_JAIL_OUT_FORCE_SYSTEM_ERROR, <<"强行出狱失败：系统错误">>).
-define(_LANG_JAIL_OUT_PK_POINTS_TOO_MUCH, <<"你的PK值<font color=\"#FF0000\">~w</font>点≥~w点，罪孽深重，不能重返江湖">>).
-define(_LANG_JAIL_DONATE_NOT_ENOUGH_GOLD, <<"不足~w元宝，捐献失败">>).
-define(_LANG_JAIL_OUT_FORCE_NOT_ENOUGH_SILVER, <<"强行出狱失败：没有足够的银子">>).
-define(_LANG_JAIL_KILL_BY_SERVER_NPC, <<"<font color=\"#FFFF00\">[~s]</font>玩家杀人如麻，已被<font color=\"#FF0000\">~s</font>抓入监狱">>).
-define(_LANG_JAIL_KILL_BY_MONSTER, <<"杀人狂<font color=\"#FFFF00\">[~s]</font>已被朝廷缉拿归案，送入监狱">>).
-define(_LANG_JAIL_KILL_BY_PLAYER, <<"<font color=\"#FFFF00\">[~s]</font>英明神武，已帮朝廷擒获杀人狂魔<font color=\"#FFFF00\">[~s]</font>">>).
-define(_LANG_JAIL_DONATE_PK_POINT_ZERO, <<"你的PK为0 ，不需要捐献元宝">>).

%% 师门同心副本资源定义
-define(_LANG_EDUCATE_FB_NOT_VALID_DISTANCE,<<"不在NPC附近，无法操作">>).

-define(_LANG_EDUCATE_FB_ENTER_PARAM_ERROR,<<"无法进入此副本">>).
-define(_LANG_EDUCATE_FB_ENTER_NOT_TEAM,<<"请和你的师门中人组成~s人以上队伍再来参加">>).
-define(_LANG_EDUCATE_FB_ENTER_NOT_LEADER,<<"让你的队长来找我">>).
-define(_LANG_EDUCATE_FB_ENTER_NOT_RANGE,<<"有队员不在附近">>).
-define(_LANG_EDUCATE_FB_ENTER_FACTION,<<"你不是本国成员，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_LEVEL,<<"<font color=\"#FFFF00\">~s</font>的不足~s级，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_LEVEL_ONE,<<"你的未到~s级，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_POS,<<"<font color=\"#FFFF00\">~s</font>不在附近，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_TIMES,<<"<font color=\"#FFFF00\">~s</font>今天完成~s次了，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_TIMES_ONE,<<"你今天完成~s次了，请明天再来">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_COMPLETE,<<"<font color=\"#FFFF00\">~s</font>上次完成副本未领取奖励，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_COMPLETE_ONE,<<"你上次完成副本未领取奖励，请在“师门副本传送者”领取">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_TIMES_COMPLETE,<<"队员条件不合法，无法进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_STATE,<<"<font color=\"#FFFF00\">~s</font>在寄售，交易或死亡中，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_STATE_ONE,<<"你在寄售或死亡中，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_CREATE_MAP,<<"副本上限，请稍后再试">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_ITEM,<<"请让<font color=\"#FFFF00\">~s</font>将背包空出一格后再进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_ROLE_ITEM_ONE,<<"将背包空出一格后才能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_DIFF_EDUCATE,<<"<font color=\"#FFFF00\">~s</font>和队伍中的其他玩家均无师门关系，不可参与挑战">>).
-define(_LANG_EDUCATE_FB_ENTER_NO_EDUCATE,<<"<font color=\"#FFFF00\">~s</font>队伍中没有与你同师门的人，不可参与挑战">>).
-define(_LANG_EDUCATE_FB_ENTER_EDUCATE_HOME_ERROR,<<"队伍师门关系不正确，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_DIFF_EDUCATE_ONE,<<"队伍中没有与你同师门的人，不可参与挑战">>).
-define(_LANG_EDUCATE_FB_ENTER_NO_EDUCATE_ONE,<<"你没有师门关系，不能进入副本">>).
-define(_LANG_EDUCATE_FB_ENTER_LEADER_NO_EDUCATE,<<"你没有师门关系，不能进入副本">>).

-define(_LANG_EDUCATE_FB_QUIT_PARAM_ERROR, <<"无法退出师门副本地图">>).

-define(_LANG_EDUCATE_FB_AWARD_PARAM_ERROR, <<"无法领取奖励">>).
-define(_LANG_EDUCATE_FB_AWARD_NOT_FACTION, <<"不是本国国民，无法操作">>).
-define(_LANG_EDUCATE_FB_AWARD_NOT_AWARD, <<"你没有可以领取的奖励">>).
-define(_LANG_EDUCATE_FB_AWARD_NOT_ENOUGH_COUNT, <<"你的师门副本积分过低，无法获取奖励">>).
-define(_LANG_EDUCATE_FB_AWARD_BAG_POS, <<"背包空间不足，领取奖励失败">>).
-define(_LANG_EDUCATE_FB_AWARD_SUCC_BC, <<"<font color=\"#FFFFFF\">哇，~s的<font color=\"#FFFF00\">[~s]</font>在“师徒副本”中获得了-g奖励，真是太幸运了！</font>">>).


-define(_LANG_EDUCATE_FB_QUERY_PARAM_ERROR, <<"无法查询到玩家的师门副本信息">>).
-define(_LANG_EDUCATE_FB_QUERY_NOT_FACTION, <<"不是本国国民，无法操作">>).
-define(_LANG_EDUCATE_FB_QUERY_NOT_GOODS, <<"此物品不存在，无法使用">>).
-define(_LANG_EDUCATE_FB_QUERY_GOODS_EXPIRED,<<"物品已经过期，无法使用">>).
-define(_LANG_EDUCATE_FB_QUERY_CUR_GOODS_EXPIRED,<<"此副本道具不是本次副本的合法道具，无法使用">>).
-define(_LANG_EDUCATE_FB_QUERY_NOT_EDUCATE_FB,<<"不在师徒副本内，无法操作">>).
-define(_LANG_EDUCATE_FB_QUERY_ONLY_LEADER_USE,<<"只有队长才能操作">>).
-define(_LANG_EDUCATE_FB_QUERY_NOT_CUR_USE,<<"当前不是使用此道具">>).
-define(_LANG_EDUCATE_FB_QUERY_ERROR,<<"操作失败">>).

-define(_LANG_EDUCATE_FB_QUERY_WAIT_USE,<<"已经通知<font color=\"#FFFF00\">[~s]</font>使用道具召唤“挑衅者”">>).
-define(_LANG_EDUCATE_FB_QUERY_WAIT_FOCUS,<<"已经通知<font color=\"#FFFF00\">~s</font>前往当前召唤位置">>).
-define(_LANG_EDUCATE_FB_QUERY_WAIT_USE_OFFLINE,<<"<font color=\"#FFFF00\">[~s]</font>掉线了，请等待其上线再操作">>).
-define(_LANG_EDUCATE_FB_QUERY_WAIT_FOCUS_LEADER,<<"你还没有前往当前召唤位置">>).
-define(_LANG_EDUCATE_FB_QUERY_MONSTER,<<"召唤的“挑衅者”，未被完全击败，无法操作">>).
-define(_LANG_EDUCATE_FB_QUERY_CALL_ITEM_ERROR,<<"召唤道具已经被丢弃，无法召唤副本BOSS">>).
-define(_LANG_EDUCATE_FB_QUERY_CALL_BOSS_ERROR,<<"副本中还有“挑衅者”，请速度将它击败">>).
-define(_LANG_EDUCATE_FB_QUERY_CALL_BOSS_SUCC,<<"成功召唤师徒副本BOSS">>).
-define(_LANG_EDUCATE_FB_QUERY_CALL_BOSS_SUCC_BC,<<"强大的boss已经出生在地图上，请大家将它击败">>).


-define(_LANG_EDUCATE_FB_ITEM_FB_MAP_ID, <<"此道具不能在此地图使用">>).
-define(_LANG_EDUCATE_FB_ITEM_PARAM_ERROR, <<"此道具无法使用">>).
-define(_LANG_EDUCATE_FB_ITEM_NOT_VALID_DISTANCE, <<"队员不在此周围，无法使用">>).
-define(_LANG_EDUCATE_FB_ITEM_USE_NOT_IN_VALID_DISTANCE, <<"此道具不能在此处使用">>).
-define(_LANG_EDUCATE_FB_ITEM_NOT_GOODS, <<"你背包没有此物品，无法使用">>).
-define(_LANG_EDUCATE_FB_ITEM_GOODS_EXPIRED, <<"此副本道具已经过期，不可使用">>).
-define(_LANG_EDUCATE_FB_ITEM_CUR_GOODS_EXPIRED, <<"此副本道具不是本次副本的合法道具，无法使用">>).
-define(_LANG_EDUCATE_FB_ITEM_USE_ORDER, <<"当前轮到<font color=\"#FFFF00\">[~s]</font>使用副本道具召唤“挑衅者”">>).
-define(_LANG_EDUCATE_FB_ITEM_USE_ORDER_ERROR, <<"当前还未轮到你使用副本道具召唤“挑衅者”">>).
-define(_LANG_EDUCATE_FB_ITEM_USE_LEADER_ITEM, <<"“队长令牌”只能在师徒副本地图内使用">>).
-define(_LANG_EDUCATE_FB_ITEM_DROP_MEMBER_ITEM, <<"<font color=\"#FFFF00\">[~s]</font>丢弃了副本召唤道具">>).
-define(_LANG_EDUCATE_FB_ITEM_DROP_LEADER_ITEM, <<"队长摧毁了【队长令牌】，师徒副本失败">>).
-define(_LANG_EDUCATE_FB_ITEM_MONSTER, <<"召唤的“挑衅者”，未被完全击败，无法召唤下一批">>).

-define(_LANG_EDUCATE_FB_BROADCAST_COUNT_CHANGE, <<"副本积分为 ~s">>).
-define(_LANG_EDUCATE_FB_BROADCAST_CLOSE_FB,<<"副本将在~s秒后关闭，请通过“副本传送者”传送出去">>).
-define(_LANG_EDUCATE_FB_BROADCAST_COUNT_CHANGE_ROLE_DEAD, <<"副本积分为 ~s，<font color=\"#FFFF00\">[~s]</font> 死亡扣除 ~s 积分">>).
-define(_LANG_EDUCATE_FB_BROADCAST_ENTER_FB,<<"<font color=\"#FF0000\">副本将在~s:~s:~s后关闭，请速度配合完成</font>">>).
-define(_LANG_EDUCATE_FB_BROADCAST_COMPLETE_FB, <<"<font color=\"#FFFFFF\"><font color=\"#FFFF00\">[~s]</font>率领众人，击败了“挑衅者”，完成了<font color=\"#FF6600\">“师门同心历险副本”</font>！</font>">>).

-define(_LANG_EDUCATE_FB_GAMBLING_PARAM_ERROR, <<"无法刷新师徒副本幸运积分">>).
-define(_LANG_EDUCATE_FB_GAMBLING_NOT_FACTION, <<"不是本国国民，无法操作">>).
-define(_LANG_EDUCATE_FB_GAMBLING_NOT_AWARD, <<"你没有可以领取的奖励">>).
-define(_LANG_EDUCATE_FB_GAMBLING_NOT_ENOUGH_COUNT, <<"你的师门副本积分过低，无法获取奖励">>).
-define(_LANG_EDUCATE_FB_GAMBLING_MAX_LUCKY_COUNT, <<"你的幸运积分已经最高，不需要刷新">>).
-define(_LANG_EDUCATE_FB_GAMBLING_NOT_GOLD, <<"你元宝不足，无法操作">>).
-define(_LANG_EDUCATE_FB_GAMBLING_MAX_SUM_COUNT, <<"你获得的奖励已经最高，不需要刷新">>).



-define(_LANG_CONLOGIN_BAG_NO_ENOUGH_POS_WHEN_FETCH, <<"背包空间不足，无法领取奖励">>).
-define(_LANG_CONLOGIN_ALREADY_FETCH, <<"你已经领取该奖励">>).
-define(_LANG_CONLOGIN_FETCH_ALREADY, <<"你已经领取该奖励">>).
-define(_LANG_CONLOGIN_NO_ENOUGH_NUM_FOR_FETCH, <<"奖励数量不够，请刷新">>).
-define(_LANG_CONLOGIN_NOT_ENOUGH_SILVER_WHEN_FETCH, <<"银两不足，无法领取该奖励">>).
-define(_LANG_CONLOGIN_NOT_ENOUGH_GOLD_WHEN_FETCH, <<"元宝不足，无法领取该奖励">>).
-define(_LANG_CONLOGIN_SYSTEM_ERROR_WHEN_FETCH, <<"领取奖励时发生系统错误">>).
-define(_LANG_CONLOGIN_SYSTEM_ERROR_WHEN_NOTSHOW, <<"设置当天不显示连续登录时发生系统错误">>).

%% 个人副本
-define(_LANG_PERSONAL_FB_DROP_BROADCAST, <<"<font color=\"#BDE620\">~s在战役副本中奋勇杀敌，击杀第~w关头目<font color=\"#FF0000\">~s</font>，\\n获得~s</font>">>).
-define(_LANG_PERSONAL_FB_ENTER_SYSTEM_ERROR, <<"进入副本失败，系统错误">>).
-define(_LANG_PERSONAL_FB_ENTER_NO_ITEM, <<"你当前没有挑战凭证【英雄令】无法挑战，可以通过<a href='event:openShop'><font color='#3be450'><u>高级商店</u></font></a>购买获得，也可以通过参加门派除恶令任务获得">>).
-define(_LANG_PERSONAL_FB_ENTER_DISTANCE_ILLEGAL, <<"与NPC距过远，无法进入副本">>).
-define(_LANG_PERSONAL_FB_ENTER_EVER_ENTER, <<"当前副本已挑战，请选择其它副本">>).
-define(_LANG_PERSONAL_FB_ENTER_FB_LOCK, <<"你当前想要挑战的是第~w关，需要成功打通第~w关之后才有资格开通">>).
-define(_LANG_PERSONAL_FB_FIRST_RECORD_BROADCAST, <<"~s在战役副本第~w关留下了~s的通关记录">>).
-define(_LANG_PERSONAL_FB_BREAKOUT_BROADCAST, <<"~s在战役副本第~w关以~s的通关成绩打破~s的通关记录">>).
-define(_LANG_PERSONAL_FB_ENTER_TIMES_LIMITED, <<"今天挑战次数已达限制，明天再来吧">>).
-define(_LANG_PERSONAL_fB_ENTER_ROLE_DEAD, <<"死亡状态不能进入个人副本">>).
-define(_LANG_PERSONAL_FB_QUIT_NOT_IN_PERSONAL_FB, <<"返回入口失败，不在个人副本中">>).
-define(_LANG_PERSONAL_FB_QUIT_SYSTEM_ERROR, <<"返回入口失败，系统错误">>).
-define(_LANG_PERSONAL_FB_NEXT_LEVEL_SYSTEM_ERROR, <<"进入下一关卡失败，系统错误">>).
-define(_LANG_PERSONAL_FB_NEXT_LEVEL_NOT_IN_FB, <<"进入下一关卡失败，不在副本地图中">>).
-define(_LANG_PERSONAL_FB_ENTER_MAX_LOST, <<"本轮挑战失败次数已达限制，领取经验后开始新一轮挑战">>).
-define(_LANG_PERSONAL_FB_NEXT_LEVEL_NOT_PASS, <<"必须先击杀本关BOSS，才能进入下一关">>).
-define(_LANG_PERSONAL_FB_ENTER_LOWER_FB, <<"进入副本失败，有更高级的副本已经打通">>).
-define(_LANG_PERSONAL_FB_ENTER_MAX_FB, <<"当前已经是最后一关，无法继续挑战">>).
-define(_LANG_PERSONAL_FB_ENTER_ROLE_STALL, <<"寄售状态不能进入个人副本">>).
-define(_LANG_PERSONAL_FB_CLEAR_ALL_MONSTER, <<"挑战成功，本次挑战消耗时间：~s">>).

%% 活动(包括活跃度福利)模块
-define(_LANG_ACTIVITY_REWARD_ONETIME_PERDAY_ERR, <<"每天只可以领取1次福利">>).
-define(_LANG_ACTIVITY_REWARD_DATETIME_LIMIT, <<"每天00:00~00:10 不能进行领取奖励">>).
-define(_LANG_ACTIVITY_BENEFIT_REWARD_BROADCAST, <<"~s的<font color=\"#FFFF00\">[~s]</font>今日完成~w个任务，领取了<a href='event:open_activity_benefit' ><u><font color=\"#00FF00\">日常福利</font></u></a>，获得极其丰厚的经验奖励">>).
-define(_LANG_ACTIVITY_ADD_ACTPOINT_HIGHEST_ERR, <<"活跃度已达到最高级别，无需提高">>).
-define(_LANG_ACTIVITY_BUY_ACTPOINT_REWARDED_ERROR, <<"今日已领取奖励，不需购买活跃度">>).
 

%%个人镖车
-define(_LANG_PERSON_YBC_CLEAR_OTHER_FACTION_ROLE, <<"该国处于国运前10分钟保护时间，已将你传送回国">>).


%% 累积经验
-define(_LANG_ACCUMULATE_EXP_NOT_FIT, <<"你未满足累积经验条件">>).
-define(_LANG_ACCUMULATE_NOT_VALID_ID, <<"累积经验参数非法">>).
-define(_LANG_ACCUMULATE_EXP_NOTHING_TO_FETCH, <<"没有经验可以领取">>).
-define(_LANG_ACCUMULATE_EXP_NEED_DO_IT_ONCE, <<"至少完成一次对应活动才能领取累积经验">>).
-define(_LANG_ACCUMULATE_EXP_NOT_ENOUGH_GOLD, <<"背包里不足~w元宝，无法提升经验">>).
-define(_LANG_ACCUMULATE_EXP_SYSTEM_ERROR_WHEN_FETCH, <<"领取经验时发生系统错误">>).
-define(_LANG_ACCUMULATE_EXP_SYSTEM_ERROR_WHEN_REFRESH, <<"刷新经验时发生系统错误">>).
-define(_LANG_ACCUMULATE_EXP_NUM_NOT_ENOUGH_WHEN_REFRESH, <<"你的背包没有幸运石，你可以通过元宝方式提升经验">>).
-define(_LANG_ACCUMULATE_EXP_MAX_RATE, <<"你已可以领取100%的累积经验，无需再提升">>).
-define(_LANG_ACCUMULATE_EXP_NEED_DONE_IT_TODAY, <<"你需要先完成对应任务才能领取该累积经验">>).
-define(_LANG_ACCUMULATE_EXP_NO, <<"你目前没有累积经验信息，无法提升">>).
-define(_LANG_ACCUMULATE_EXP_REF_FAIL, <<"提升累积经验失败，消耗~w元宝">>).
-define(_LANG_ACCUMULATE_EXP_REF_OK, <<"成功提升累积经验，消耗~w元宝">>).
-define(_LANG_ACCUMULATE_EXP_VIP_REF_OK, <<"成功提升累积经验，VIP免费">>).
%% vip
-define(_LANG_VIP_ACTIVE_SYSTEM_ERROR, <<"开通VIP失败，系统错误">>).
-define(_LANG_VIP_ACTIVE_NOT_ENOUGH_GOLD, <<"开通VIP失败，您的元宝不足">>).
-define(_LANG_VIP_MULTI_EXP_SYSTEM_ERROR, <<"领取VIP多倍经验失败，系统错误">>).
-define(_LANG_VIP_MULTI_EXP_VIP_EXPIRED, <<"领取VIP多倍经验失败，VIP已过期">>).
-define(_LANG_VIP_MULTI_EXP_NOT_VIP, <<"领取VIP多倍经验失败，您不是VIP">>).
-define(_LANG_VIP_MULTI_EXP_ALL_USED, <<"领取VIP多倍经验失败，今天已经领取过了">>).
-define(_LANG_VIP_STOP_NOTIFY_NOT_VIP, <<"设置失败，您不是VIP">>).
-define(_LANG_VIP_STOP_NOTIFY_SYSTEM_ERROR, <<"设置失败，系统错误">>).
-define(_LANG_VIP_ACTIVE_BROADCAST, <<"<font color=\"#FFFF00\">[~s]</font>成为了<a href='event:openVip'><font color='#3be450'><u>《天之刃》VIP</u></font></a>，正享受着多倍经验、快速任务、折扣商店等众多福利">>).
-define(_LANG_VIP_ACTIVE_FRINED, <<"你的好友<font color=\"#FFFF00\">[~s]</font>成为了<font color='#3be450'>《天之刃》VIP</font>，正享受着多倍经验、快速任务、折扣商店等众多福利。<a href='event:openVip'><u><font color=\"#3be450\">去看看</font></u></a>">>).
-define(_LANG_PERSONAL_FB_ENTER_EXP_GET, <<"领取经验后才能开始下一轮挑战">>).
-define(_LANG_VIP_MULTI_EXP_CLOSE, <<"VIP领取多倍经验功能已经关闭">>).
-define(_LANG_VIP_LIST_MAX_PAGE, <<"当前已经是最后一页">>).
-define(_LANG_VIP_REMOTE_DEPOT_SYSTEM_ERROR, <<"开通远程仓库系统错误">>).
-define(_LANG_VIP_REMOTE_DEPOT_NOT_VIP, <<"您还不是VIP，不能开通远程仓库">>).
-define(_LANG_VIP_REMOTE_DEPOT_LEVEL_NOT_ENOUGH, <<"VIP等级不够，不能开通远程仓库">>).
-define(_LANG_VIP_REMOTE_DEPOT_MAX_DEPOT, <<"您已经开通了所有仓库，不能继续开通">>).
-define(_LANG_VIP_REMOTE_DEPOT_NOT_ENOUGH_GOLD, <<"您当前元宝不足，不能开通远程仓库">>). 
-define(_LANG_VIP_GET_PRESTIGE_SUCC,<<"成功领取VIP每日返还声望：~s">>).
-define(_LANG_VIP_GET_PRESTIGE_NOT_VIP,<<"领取VIP每日返还声望失败，你还不是VIP">>).
-define(_LANG_VIP_GET_PRESTIGE_ALREADY,<<"今日返还声望已领取">>).
-define(_LANG_VIP_GET_NO_PRESTIGE,<<"没有可领取的返还声望">>).
%% 场景大战副本资源
-define(_LANG_SCENE_WAR_FB_NOT_VALID_DISTANCE,<<"请靠近在NPC，再操作">>).

-define(_LANG_SCENE_WAR_FB_ENTER_ERROR,<<"无法进入此副本">>).
-define(_LANG_SCENE_WAR_FB_ENTER_FACTION,<<"你不是本国成员，不能进入副本">>).
-define(_LANG_SCENE_WAR_FB_ENTER_LEVEL,<<"你不足~s级，不能进入副本">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MAX_TIME,<<"今天完成~s次了，请明天再继续">>).
-define(_LANG_SCENE_WAR_FB_ENTER_NOT_GOLD, <<"你元宝不足，不能进入副本">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_FB_CLOSE, <<"副本正在关闭中，无法进入">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_FB_RECORD, <<"队员还在副本中，无法进入">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_FB_AFTER, <<"副本创建时不你在队伍中，无法进入">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_FB_STATUS, <<"副本快结束，无法进入">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_FB_VALID, <<"副本进入时间有效已过，无法进入">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_FB_AGAIN, <<"你已经退出此副本，无法再次进入">>).
-define(_LANG_SCENE_WAR_FB_ENTER_CREATE_MAP, <<"副本上限，请稍后再试">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_FB_CREATE, <<"发现有队员进入副本，请重新操作">>).
-define(_LANG_SCENE_WAR_FB_QUIT_ERROR, <<"无法退出此副本">>).
-define(_LANG_SCENE_WAR_FB_ENTER_NOT_LEADER, <<"只有队长才能开启副本">>).

-define(_LANG_SCENE_WAR_FB_ENTER_NOT_VALID_MAP, <<"<a href='event:gotoNPC#~s'><font color=\"#3be450\"><u>队长进入了 ~s-~s 难度，请点击前往</u></font></a>">>).
-define(_LANG_SCENE_WAR_FB_ENTER_NOT_VALID_MAP_TIMES, <<"队长进入了 <font color=\"#3be450\">~s-~s</font> 副本，你今天已经全部完成">>).

-define(_LANG_SCENE_WAR_FB_QUERY_ERROR, <<"参数不合法，操作无效">>).

-define(_LANG_SCENE_WAR_FB_LETTER_TITLE, <<"腰牌">>).
-define(_LANG_SCENE_WAR_FB_BC_MONSTER, <<"<font color=\"#FFFFFF\">副本怪物（~s/~s）</font>">>).
-define(_LANG_SCENE_WAR_FB_BC_MONSTER_GOODS, <<"获得道具：~s">>).
-define(_LANG_SCENE_WAR_FB_BROADCAST_CLOSE_FB,<<"副本将在~s秒后关闭，请通过~s传送出去">>).
-define(_LANG_SCENE_WAR_FB_BROADCAST_ENTER_FB,<<"<font color=\"#FF0000\">副本将在~s:~s:~s后关闭。</font>">>).
-define(_LANG_SCENE_WAR_FB_BROADCAST_PICK_GOODS,<<"<font color=\"#C8EF1D\">~s在~s越战越勇，获得了-g！<a href='event:gotoSWFBNPC#~s'><font color=\"#3be450\"><u>点击前往</u></font></a></font>">>).
-define(_LANG_SCENE_WAR_FB_BROADCAST_PICK_GOODS_CENTER,<<"<font color=\"#FFFFFF\">~s的<font color=\"#FFFF00\">[~s]</font>在“~s”越战越勇，获得了~s">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_NOT_ENOUGH, <<"敌军异常凶猛，需组成~s人以上队伍方可前往">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_MAX_TIME, <<"队伍成员~s今天完成~s次了，不能继续挑战">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_NOT_GOLD, <<"队伍成员~s元宝不足，不能挑战副本">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_TOO_FAR, <<"队伍有成员不在附近，不能进入挑战">>).
-define(_LANG_SCENE_WAR_FB_ENTER_MEMBER_LEVEL, <<"队伍成员~s等级不足~s级，不能前往">>).

-define(_LANG_SCENE_WAR_FB_MONSTER_NOT_CLEAR,<<"副本中还有怪物没杀死，不能召唤新怪物">>).
-define(_LANG_SCENE_WAR_FB_NOT_CALL_MONSTER_TYPE,<<"此副本不能召唤怪物">>).
-define(_LANG_SCENE_WAR_FB_NOT_REACH_PASS,<<"未达到召唤怪物要求">>).
%% 道具礼包资源
-define(_LANG_GIFT_ITEM_QUERY_ERROR, <<"无法查询道具礼包信息">>).
-define(_LANG_GIFT_ITEM_QUERY_GIFT_NOT_CONFIG, <<"系统没有配置道具礼包信息">>).
-define(_LANG_GIFT_ITEM_QUERY_NOT_GIFT, <<"你已经没有道具礼包可以领取了">>).
-define(_LANG_GIFT_ITEM_QUERY_GIFT_CONFIG_ERROR, <<"道具礼包配置出错误">>).

-define(_LANG_GIFT_ITEM_AWARD_ERROR, <<"无法领取道具奖励">>).
-define(_LANG_GIFT_ITEM_AWARD_AWARD_ROLE_LEVEL, <<"你的等级不够哦，赶快升到~s级吧">>).
-define(_LANG_GIFT_ITEM_AWARD_NOT_GIFT, <<"没有道具奖励可领取">>).
-define(_LANG_GIFT_ITEM_AWARD_DONE_GET, <<"道具奖励已经全部领取完成">>).
-define(_LANG_GIFT_ITEM_AWARD_GIFT_DIFF, <<"道具奖励出错，无法领取">>).
-define(_LANG_GIFT_ITEM_AWARD_NOT_BAG_POS, <<"背包空间不足无法领取">>).
-define(_LANG_GIFT_ITEM_AWARD_BC_MONSTER_GOODS, <<"获得道具：~s">>).

%%门派采集IT
-define(_LANG_FAMILY_COLLECT_NO_ROLE_PRIZE, <<"当前没有可以领取的门派采集经验奖励">>).
-define(_LANG_FAMILY_COLLECT_WILL_BEGIN,<<"门派采集活动即将开启，采集竹笋、击杀馋嘴熊均能获得门派积分，门派积分影响活动结束后所有参与帮众可领取的经验。本活动中杀怪不扣精力值">>).
-define(_LANG_FAMILY_COLLECT_END_BROADCAST, <<"我族帮众齐心协力，采得大量【竹笋】，获得~w点门派繁荣度。请参加活动的众帮众到门派长老处领取奖励">>).
-define(_LANG_FAMILY_COLLECT_BROADCAST_GET_PRIZE,<<"<font color=\'#FFFF00\'>[~s]</font>在门派采集活动中贡献卓著，获得了经验奖励~w">>).
-define(_LANG_FAMILY_COLLECT_SUMMON_BOSS,<<"馋嘴熊来我们田园捣乱了，大家快去收拾它">>).

%% 英雄副本
-define(_LANG_HERO_FB_PANEL_SYSTEM_ERROR, <<"打开战役副本界面系统错误">>).
-define(_LANG_HERO_FB_ENTER_SYSTEM_ERROR, <<"进入战役副本系统错误">>).
-define(_LANG_HERO_FB_QUIT_NOT_IN_FB, <<"退出战役副本失败，当前不在副本中">>).
-define(_LANG_HERO_FB_QUTI_SYSTEM_ERROR, <<"退出战役副本时发生系统错误">>).
-define(_LANG_HERO_FB_ENTER_LEVEL_LIMITED, <<"必须要等级达到~s级才可以开启战役">>).
-define(_LANG_HERO_FB_ENTER_ROLE_DEAD, <<"死亡状态下不能进入战役副本">>).
-define(_LANG_HERO_FB_ENTER_ROLE_STALL, <<"寄售状态下不能进入战役副本">>).
-define(_LANG_HERO_FB_ENTER_BARRIER_LOCK, <<"该副本还没开通，不能进行挑战">>).
-define(_LANG_HERO_FB_ENTER_ROLE_TRAINING, <<"离线训练状态下不能进入战役副本">>).
-define(_LANG_HERO_FB_ENTER_ROLE_FIGHT, <<"战斗状态下不能进入战役副本">>).
-define(_LANG_HERO_FB_ENTER_TIMES_LIMITED, <<"今天挑战次数已达限制，明天再来吧">>).
-define(_LANG_HERO_FB_DROP_BROADCAST, <<"~s在<a href=\"event:goto_herofb\"><font color=\"#00FF00\"><u>战役副本</u></font></a>成功击败【~s】，获得了~s">>).
-define(_LANG_HERO_FB_REWARD_SYSTEM_ERROR, <<"领取奖励失败，系统错误">>).
-define(_LANG_HERO_FB_REWARD_EVER_GOT, <<"领取奖励失败，已经领取过了">>).
-define(_LANG_HERO_FB_BUY_SYSTEM_ERROR, <<"购买出错，系统错误">>).
-define(_LANG_HERO_FB_BUY_NOT_ENOUGH_GOLD, <<"购买出错，没有足够的元宝">>).
-define(_LANG_HERO_FB_BUY_MAX_TIMES, <<"今天的购买次数已达限制">>).
-define(_LANG_HERO_FB_REWARD_BAG_FULL, <<"背包空间不足，请整理背包后重新领取">>).
-define(_LANG_HERO_FB_ENTER_ONE_BARRIER_LIMITED,<<"本关的挑战次数已到上限，请等到下个刷新时间">>).
-define(_LANG_HERO_FB_BREAK_RECORD,<<"恭喜【~s】的【<font color=\"#FFFF00\">~s</font>】成功打破记录，成为战役第~s关的霸主！">>).
-define(_LANG_HERO_FB_ILLEGAL_ENTER_MAP,<<"当前所在地图不允许进入战役">>).
-define(_LANG_HERO_FB_FOREIGET_ENTER_MAP,<<"在外国地图不允许进入战役">>).
-define(_LANG_HERO_FB_GET_REWARD_FROM_LETTER_NOTICE,<<"你的背包已满，系统自动把奖励转至信件附件！">>).

%% 任务副本
-define(_LANG_MISSION_FB_ENTER_SYSTEM_ERROR, <<"进入任务副本系统错误">>).
-define(_LANG_MISSION_FB_QUTI_SYSTEM_ERROR, <<"退出任务副本时发生系统错误">>).
-define(_LANG_MISSION_FB_QUTI_NOT_COMPLETE, <<"任务未完成，退出任务副本失败">>).
-define(_LANG_MISSION_FB_ENTER_LEVEL_LIMITED, <<"必须要等级达到指定等级才可以开启大明任务副本">>).
-define(_LANG_MISSION_FB_ENTER_ROLE_DEAD, <<"死亡状态下不能进入任务副本">>).
-define(_LANG_MISSION_FB_ENTER_ROLE_STALL, <<"寄售状态下不能进入任务副本">>).
-define(_LANG_MISSION_FB_ENTER_ROLE_TRAINING, <<"离线训练状态下不能进入任务副本">>).
-define(_LANG_MISSION_FB_ENTER_TIMES_LIMITED, <<"今天挑战次数已达限制，明天再来吧">>).

-define(_LANG_BONFIRE_ADD_FAGOT_FAIL, <<"已经加过柴火了">>).
-define(_LANG_BONFIRE_NOT_FAGOT, <<"你背包中没有柴火">>).
-define(_LANG_BONFIRE_NOT_BONFIRE, <<"没有要加柴火的篝火">>).

%% 天工炉资源
-define(_LANG_REFINING_OP_TYPE_ERROR, <<"锻造操作不合法">>).
-define(_LANG_REFINING_NOT_BAG_POS_ERROR, <<"你背包空间不足，操作失败">>).

%%积分兑换
-define(_LANG_FAMILY_SCORE_EXCHANGE_NOSCORE, <<"当前没有足够的门派积分，无法兑换">>).
-define(_LANG_FAMILY_SCORE_EXCHANGE_OK, <<"兑换成功">>).
-define(_LANG_FAMILY_SCORE_EXCHANGE_MESSAGE, <<"兑换错误">>).

%% 传奇目标
-define(_LANG_GOAL_SYSTEM_ERROR_WHEN_FETCH, <<"领取传奇目标的奖励时发生系统错误">>).
-define(_LANG_GOAL_NOT_FINISH, <<"该传奇目标尚未完成">>).
-define(_LANG_GOAL_CANNT_FETCH_BECAUSE_DAY, <<"该目标奖励必须在登录第~p天领取，当前你登录天数为第~p天">>).
-define(_LANG_GOAL_NOT_ENOUGH_POS_WHEN_FETCH, <<"背包空间不足，请整理背包后再领取奖励">>).
-define(_LANG_GOAL_HAS_FETCHED, <<"你已领该奖励">>).

%%转让掌门
-define(_LANG_FAMILY_CHANGE_OWNER, <<"~s把掌门之位让给了~s">>).
-define(_LANG_FAMILY_ACTIVE_MAP, <<"掌门~s为本门派开启了门派地图">>).

%% 镖车
-define(_LANG_YBC_TIMEOUT_LETTER_CONTENT_PERSON, <<"护镖已超过30分钟，系统已经回收你的镖车，请到 王都-镖师 [63,36]处重新领取镖车">>).
-define(_LANG_YBC_TIMEOUT_LETTER_CONTENT_FAMILY, <<"护镖已超过30分钟，系统已经回收你的镖车，请到 王都-镖师 [63,36]处重新领取镖车">>).
-define(_LANG_YBC_TIMEOUT_LETTER_TITLE, <<"镖车超时通知">>).

%% 声望
-define(_LANG_PRESTIGE_QUERY_PARAM_ERROR, <<"查询参数出错，无法查询">>).
-define(_LANG_PRESTIGE_DEAL_PARAM_ERROR, <<"无法找到要兑换的物品，兑换失败">>).
-define(_LANG_PRESTIGE_DEAL_NOT_ENOUGH_ERROR, <<"你的声望不足，兑换失败">>).
-define(_LANG_PRESTIGE_NOT_BAG_POS_ERROR, <<"背包空间不足，兑换失败">>).
-define(_LANG_PRESTIGE_DEAL_ERROR, <<"兑换失败">>).

%%买回物品
-define(_LANG_SHOP_BUY_BACK_SYSTEM_ERROR,<<"买回失败，系统错误">>).
-define(_LANG_SHOP_BUY_BACK_NOT_ENOUGH_SILVER,<<"绑定银子不足，无法买回道具。">>).
-define(_LANG_SHOP_BUY_BACK_NOT_ENOUGH_UNBIND_SILVER,<<"银子不足，无法买回道具。">>).
-define(_LANG_SHOP_BUY_BACK_NO_SUCH_GOODS,<<"买回失败，找不到物品">>).
-define(_LANG_SHOP_BUY_BACK_NOT_ENOUTH_POS,<<"背包空间不足，无法买回道具。">>).

%%boss群
-define(_LANG_BOSS_GROUP_BUSY,<<"系统繁忙，请稍候再试">>).
-define(_LANG_BOSS_GROUP_CLOSE,<<"boss活动已取消">>).

-define(_LANG_FAMKLY_SKILL_WHEN_LEAVE_FAMILY,<<"你离开了门派，所有已学门派技能数据被清零">>).
-define(_LANG_FML_SKILL_LEARN_MUST_JOIN_FAMILY,<<"门派技能需要加入门派才能学习，请先加入门派">>).
-define(_LANG_FML_SKILL_LEARN_WHEN_MAX_LEVEL,<<"已经达到最高技能，不需要继续学习">>).
-define(_LANG_FML_SKILL_LEARN_WHEN_NOT_RESEARCH,<<"门派没有研究该技能，请告知掌门或长老进行研究">>).
-define(_LANG_FML_SKILL_LEARN_WHEN_LARGE_THAN_FAMILY_LEVEL,<<"学习失败，不能超过门派的研究等级">>).
-define(_LANG_FML_SKILL_WHEN_GONGXIAN_NOT_ENOUGH,<<"门派贡献度不足">>).
-define(_LANG_FML_SKILL_FORGET_MUST_JOIN_FAMILY,<<"必须加入门派才能遗忘技能">>).

%%刷棋副本
-define(_LANG_SQ_FB_SYSTEM_ERROR,<<"副本繁忙，请稍后再来">>).
-define(_LANG_SQ_FB_NO_FB_TYPE,<<"找不到当前类型副本">>).
-define(_LANG_SQ_FB_NO_FB_NPC,<<"找不到npc信息">>).
-define(_LANG_SQ_FB_ERROR_FACTION_NPC,<<"不是本国npc">>).
-define(_LANG_SQ_FB_NOT_IN_NPC_VALID_RANGE,<<"不在npc的有效范围内">>).
-define(_LANG_SQ_FB_BROADCAST_CLOSE_FB,<<"副本将在~s秒后关闭，请通过~s传送出去">>).
-define(_LANG_SQ_FB_BROADCAST_ENTER_FB,<<"<font color=\"#FF0000\">副本将在~s:~s:~s后关闭。</font>">>).
-define(_LANG_SQ_FB_BROADCAST_WARINING_BORN_MONSTER,<<"怪物将在~s秒之后出生">>).
-define(_LANG_SQ_FB_NOT_FB_MAP,<<"当前不是副本地图">>).
-define(_LANG_SQ_FB_NO_TEAM,<<"当前副本需要3人以上组队进入">>).
-define(_LANG_SQ_FB_NO_ENOUGH_TEAM_MEMBER,<<"副本难度较大，请多找几个队员一起挑战">>).
-define(_LANG_SQ_FB_NOT_LEADER,<<"请让你的队长来找我">>).
-define(_LANG_SQ_FB_TOO_FAR,<<"你距离我太远了">>).
-define(_LANG_SQ_FB_NOT_ENOUGH_LEVEL,<<"你的等级不符合条件，无法进入副本">>).
-define(_LANG_SQ_FB_NOT_OPEN,<<"现在不是副本开启时间，请稍后再来">>).
-define(_LANG_SQ_FB_FIGHT_TIME_LIMIT,<<"你的副本挑战次数到达上限">>).
-define(_LANG_SQ_FB_MEMBER_TOO_FAR,<<"你有队员不在附近">>).
-define(_LANG_SQ_FB_MEMBER_TOO_FAR2,<<"队员~s不在附近">>).
-define(_LANG_SQ_FB_MEMBER_NOT_ENOUGH_LEVEL,<<"队员~s等级不符，无法进入副本">>).
-define(_LANG_SQ_FB_MEMBER_FIGHT_TIME_LIMIT,<<"队员~s副本挑战次数到达上限">>).

%%练功房副本
-define(_LANG_EXE_FB_BROADCAST_CLOSE_FB,<<"副本将在~s秒后关闭，请尽快传送出去">>).
-define(_LANG_EXE_FB_BROADCAST_ENTER_FB,<<"<font color=\"#FF0000\">副本将在~s:~s:~s后关闭。</font>">>).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 纯粹字符串的
-define(_LANG_NONE,"无").
-define(_LANG_NPC_DEAL_TIP_EXP,"经验").
-define(_LANG_NPC_DEAL_TIP_FAMILY_MONEY,"文宗族资金").
-define(_LANG_NPC_DEAL_TIP_FAMILY_CONB,"宗族贡献度").
-define(_LANG_NPC_DEAL_TIP_FAMILY_ACTPOINT,"宗族繁荣度").
-define(_LANG_MISSION_AUTO_LETTER_EXP,"经验，").
-define(_LANG_MISSION_AUTO_LETTER_SILVER,"银子，").
-define(_LANG_MISSION_AUTO_LETTER_BIND_SILVER,"绑定银子，").
-define(_LANG_MISSION_AUTO_LETTER_GET_TIP,"获得委托任务的奖励").
-define(_LANG_MISSION_AUTO_LETTER_GET_PROP,"\n本次委托奖励了道具：").
-define(_LANG_MISSION_AUTO_LETTER_GET_TIMES_1,"\n      您委托第").
-define(_LANG_MISSION_AUTO_LETTER_GET_TIMES_2,"次任务，获得").
-define(_LANG_MAP_ENTER_BC_MSG_GONGXUN_99,"~s危险人物[~s]在~s出没，广大国民请做好防范工作").
-define(_LANG_MAP_ENTER_BC_MSG_GONGXUN_199,"~s丧心病狂[~s]在~s出没，广大国民请做好防范工作").
-define(_LANG_MAP_ENTER_BC_MSG_GONGXUN_200,"~s杀人狂魔[~s]在~s出没，广大国民请做好防范工作").

%%国战连杀广播
-define(_LANG_WAR_FACTION_CONTINUE_KILL_5,<<"~s连斩5人，正在大杀特杀！">>).
-define(_LANG_WAR_FACTION_CONTINUE_KILL_10,<<"~s连斩10人，已经主宰战场了！">>).
-define(_LANG_WAR_FACTION_CONTINUE_KILL_20,<<"~s连斩20人，已经杀得变态了！">>).
-define(_LANG_WAR_FACTION_CONTINUE_KILL_30,<<"~s连斩30人，跟妖怪一样了！">>).
-define(_LANG_WAR_FACTION_CONTINUE_KILL_40,<<"~s连斩40人，如同神一样了！">>).
-define(_LANG_WAR_FACTION_CONTINUE_KILL_50,<<"~s连斩50人，已经超越神了，拜托谁去杀了他吧！">>).
-define(_LANG_WAR_FACTION_CONTINUE_KILL_MSG,<<"~s连斩~w人了！">>).
-define(_LANG_WAR_FACTION_CONTINUE_KILL_MSG_DEAD,<<"~s成功终结了~s连续~w次的疯狂杀戮！">>).

