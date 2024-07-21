
%%%%%%%%%%%%%%% 装备的一些公共定义  %%%%%%%%%%%%%%% 

%% 这里定义的PUT**对应的是 p_equip_base_info.slot_num
-define(PUT_ARM,1).         %% 1：武器
-define(PUT_NECKLACE, 2).   %% 2：项链
-define(PUT_FINGER,3).      %% 3：戒指
-define(PUT_ARMET,4).       %% 4：头盔
-define(PUT_BREAST,5).      %% 5：护甲
-define(PUT_CAESTUS,6).     %% 6：腰带
-define(PUT_HAND,7).        %% 7：护腕
-define(PUT_SHOES,8).       %% 8：靴子
-define(PUT_ASSISTANT,9).   %% 9：副手装备
-define(PUT_ADORN,10).      %% 10：挂饰
-define(PUT_FASHION,11).    %% 11：时装
-define(PUT_MOUNT,12).      %% 12：坐骑

%% 这里定义的UI_SLOT_NUM*对应的是玩家装备面板中的位置，即p_goods.loadposition
-define(UI_LOAD_POSITION_MOUNT,15).  %%默认的坐骑位置 !!!!!!(即玩家的坐骑面板)
-define(UI_LOAD_POSITION_FASHION,8). %%默认的时装位置(在装备面板中的位置)
-define(UI_LOAD_POSITION_ADORN_1,7).   %%默认的挂饰（特殊）位置
-define(UI_LOAD_POSITION_ADORN_2,14).  %%默认的挂饰（特殊）位置

-define(UI_LOAD_POSITION_ARM,4).  %%武器
-define(UI_LOAD_POSITION_NECKLACE,2).  %%项链
-define(UI_LOAD_POSITION_FINGER_1,12).  %%戒指
-define(UI_LOAD_POSITION_FINGER_2,13).  %%戒指
-define(UI_LOAD_POSITION_ARMET,1).  %%头盔
-define(UI_LOAD_POSITION_BREAST,3).  %%护甲
-define(UI_LOAD_POSITION_CAESTUS,11).  %%腰带
-define(UI_LOAD_POSITION_HAND_1,9).  %%护腕
-define(UI_LOAD_POSITION_HAND_2,10).  %%护腕
-define(UI_LOAD_POSITION_SHOES,6).  %%靴子
-define(UI_LOAD_POSITION_ASSISTANT,5).  %%副手装备




%%----------------------------
%%武器与副手装备冲突列表(整数相加)
%%----------------------------
-define(CONFLICT_EQUIP_LIST,[
                       1020901,        %%弓+盾牌,102*10000+901
                       1020902,        %%弓+弹药,102*10000+902
                       1030901,        %%扇+盾牌,103*10000+901
                       1030902,        %%扇+弹药,103*10000+902
                       1040901,        %%萧+盾牌,104*10000+901
                       1040902         %%萧+弹药,104*10000+902
                      ]).