-define(LETTER_GM,gm).

%%-----------------------------------------------------
-define(DICT_EXPIRED_DAY,      letter_expired_day).
-define(DICT_DEFAULT_TYPE,     letter_default_type).
-define(DICT_TYPE_LIST,        letter_type_list).
-define(DICT_SEND_COUNT,       letter_send_count).
-define(DICT_MAX_SEND_COUNT,   letter_max_send_count).
-define(DICT_TOMORROW_TIME,    letter_tomorrow_time).
-define(DICT_SEND_GOODS_PRICE, letter_send_goods_price).

%%-------------------------------------------------------
-define(DICT_LETTER_CONFIG,      letter_config).

%%---------------------------------------------------------
-define(LETTER_NOT_OPEN,  1). %%信件没有打开
-define(LETTER_HAS_OPEN,  2). %%信件打开了
-define(LETTER_HAS_ACCEPT_GOODS, 3). %%信件已收取物品
-define(LETTER_REPLY, 4).  %% gm回复的信件（用于给gm回复的信件评分）

%%------------------------------------------------------

-define(TYPE_LETTER_PRIVATE,0). %% 私人信件
-define(TYPE_LETTER_FAMILY,1). %% 门派信件
-define(TYPE_LETTER_SYSTEM,2). %% 系统信件
-define(TYPE_LETTER_RETURN,3). %% 退信
-define(TYPE_LETTER_GM,4).  %% GM信件

%%----------------------------------------------------
-define(NPC_CHANG_YU_CHUN,{"11100103","12100103","13100103"}). %%常遇春
-define(NPC_ZHANG_SAN_FENG,{"11100136","12100136","13100136"}). %% 张三丰.
-define(NPC_BAO_ZANG_CHUAN_SONG,{"11100129","12100129","13100129"}). %% 宝藏传送
-define(NPC_LI_MENG_YANG,{"11100121","12100121","13100121"}). %% 李梦阳
-define(NPC_XIA_YUAN_JI,{"11100104","12100104","13100104"}). %%夏元吉
-define(NPC_MU_YING,{"11105100","12105100","13105100"}). %% 沐英
-define(NPC_SHANG_MAO,{"11100104","12100104","13100104"}).%% 商贸
-define(NPC_PERSONAL_BIAO_CHE,{"11100113","12100113","13100113"}). %镖车
%%-------------------------------------------------------
-define(LETTER_DEFAULT_SAVE_DAYS, 14).
-define(LETTER_SEND_COST,1000).
-define(LIMIT_SEND_LETTER_COUNT,50).
-define(LIMIT_LETTER_LENGTH,400).

%% 计数器
-define(COMMON_LETTER_COUNTER_KEY,common_letter_counter_key).
-define(PERSONAL_LETTER_COUNTER_KEY,personal_letter_counter_key).
-define(PUBLIC_LETTER_COUNTER_KEY,pubilc_letter_counter_key).

-define(SEND_TO_MAP_LETTER(RoleID,FunctionType,Msg),
        common_misc:send_to_rolemap(RoleID,{mod_letter,{FunctionType,Msg}})).

%% 存在数据库中的公共信件
-define(DATABASE_LETTER,0).
%% 放在模板中的公共信件
-define(TEMPLATE_LETTER,1).

%% 获取物品请求队列
-define(ACCEPT_GOODS_REQUEST_QUEUE,accept_goods_request_queue).
%% 请求获取物品队列
-record(r_accept_goods_request,{time,letter_id,table}).

%% 信件属性 用于表示信件存储在哪个表中
-define(LETTER_PERSONAL,0).
-define(LETTER_PUBLIC,1).

%% 信件删除状态
-define(LETTER_DELETE_BY_SENDER,-1).
-define(LETTER_DELETE_BY_RECEIVER,1).
-define(LETTER_NOBODY_DELETE,0).



%% 获取物品超时时间
-define(REQUEST_OVER_TIME,5). %%秒

%% 每次发送信件条数上限
-define(ONE_TIME_SEND_MAX,3000).
-define(SEND_SPLIT_TIME,15000).  %%毫秒

-define(LETTER_SEND_TO_FAMILY_TITLE,"发给[~s]门派帮众的信件").
-define(LETTER_FROM_FAMILY_TITLE,"来自[~s]门派掌门的信件").
%% --------------------------------------------------------------------
-define(LEVEL_TEN_LETTER,1001).
%%-define(LEVEL_SIXTEEN_LETTER,1002).
-define(LEVEL_TWENTY_LETTER,1003).
-define(LEVEL_TWENTY_TWO_LETTER,1004).
%%-define(LEVEL_TWENTY_FIVE_LETTER,1005).
-define(LEVEL_TWENTY_SIX_LETTER,1006).
-define(LEVEL_TWENTY_EIGHT_LETTER,1007).
-define(LEVEL_THIRTY_ONE_LETTER,1008).
-define(LEVEL_THIRTY_NINE_LETTER,1009).
-define(LEVEL_SIXTEEN_LETTER,1010).
-define(LEVEL_TWENTY_FIVE_LETTER,1011).
-define(LEVEL_THIRTY_LETTER,1012).

-define(FAMILY_LEVEL_DOWN_WARNING_LETTER,2001).
-define(FAMILY_LEVEL_DOWN_LETTER,2002).
-define(FAMILY_FIRE_OWNER_WARNING_LETTER,2003).
-define(FAMILY_FIRE_OWNER_LETTER,2004).
-define(FAMILY_CREATE_FAMILY_LETTER,2005).
-define(FAMILY_ROLE_JOIN_LETTER,2006).
-define(FAMILY_FIRE_MEMBER_LETTER,2007).
-define(FAMILY_COMBINE_LETTER,2008).

-define(ADMIN_SEND_GOLD_LETTER,3001).
-define(ADMIN_SEND_SILVER_LETTER,3002).

-define(DEAD_LETTER,4001).
-define(JAIL_LETTER,4002).
-define(AUTO_MISSION_LETTER,4003).
-define(SUSAN_LETTER,4004).
-define(STALL_TIME_UP_LETTER,4005).
-define(STALL_HALF_TIME_LETTER,4006).
-define(TRADING_LOST_ROLE_LETTER,4007).
-define(TRADING_LOST_MONSTER_LETTER,4008).
-define(TRAINING_TIME_UP_LETTER,4009).
-define(FRIEND_LEVEL_CHANGE_LETTER,4010).
-define(KING_OFFER_LETTER,4011).
-define(WAROFKING_BEGIN_LETTER,4012).
-define(PAY_FIRST_LETTER,4013).
-define(BANK_BUY_GOLD_LETTER,4014).
-define(BANK_SELL_GOLD_LETTER,4015).
-define(ACTIVITY_VWF_LETTER,4016).
-define(RECHARGE_SUCCESS_LETTER,4017).
-define(YUANXIAO_GIFT_LETTER,4018).
-define(SCENE_WAR_FB_GOODS_LETTER,4019).
-define(SCENE_WAR_FB_GOODS_LETTER_2,4020).
-define(SKILL_RETURN_EXP_LETTER, 4021).
-define(WAROFKING_BEGIN_LETTER2,4022).
-define(PERSONAL_YBC_TIME_OUT,4023).
-define(FAMILY_YBC_TIME_OUT,4024).
-define(HERO_FB_GET_REWARD,4025).
-define(HERO_FB_GET_REWARD2,4026).

-define(EDUCATE_TEACHER_GIFT_LETTER,5001).
-define(EDUCATE_STUDENT_GIFT_LETTER,5002).
-define(EDUCATE_STUDENT_LEAVE_LETTER,5003).
-define(EDUCATE_QUIT_STUDENT_LETTER,5004).
-define(FRIEND_ZERO_LEVEL_CHANGE_LETTER,5005).
