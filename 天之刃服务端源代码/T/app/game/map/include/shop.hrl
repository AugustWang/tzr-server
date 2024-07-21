%%DEFINE DATA
-define(DICT_TIMER_REF, dict_key_timer_ref_key_shop).
-define(PRICE_HANDLE_MODULE, mod_price_handle).

%%RECORD DATA


%%TEST DATA
-define(IS_ITME(ID), ID < 25).
-define(IS_EQUIP(ID), (ID > 25) and (ID < 1236)).
-define(IS_STONE(ID), (ID > 1235) and (ID < 31006)).
-define(IS_GOLD(ID), 2).
-define(IS_SILVER(ID), 1).

-define(BIND_GOLD, 4).
-define(BIND_SILVER, 3).
-define(GOLD, 2).
-define(SILVER, 1).
-define(UNAVAI, 0).
%% 买回物品列表物品数量
-define(BUY_BACK_NUM,6).
%% 客户端请求类型
-define(GET_LIST,1). %%获取买回物品列表
-define(BUY_BACK,2). %%玩家买回物品



