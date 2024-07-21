%%天功炉的背包id---------------------------------------------------
-define(REFINING_BAGID, 5).

%%主属性-----------------------------------------------------------
% 装备
-define(REFINING_BLOOD,       1).   %% 生命值
-define(REFINING_PHYSIC_ATT,  2).    %% 物功
-define(REFINING_MAGIC_ATT,   3).    %% 魔攻
-define(REFINING_PHYSIC_DEF,  4).    %% 物防
-define(REFINING_MAGIC_DEF,   5).    %% 魔防
% 宝石
-define(REFINING_DIZZY,           1).   %%击晕
-define(REFINING_DIZZY_RESIST,     8).   %%击晕抗性
-define(REFINING_POISONING,       3).   %%中毒
-define(REFINING_POISONING_RESIST, 7).   %%中毒抗性
-define(REFINING_FREEZE,          2).  %%冰冻
-define(REFINING_PREEZE_RESIST,    9).  %%冰冻抗性
-define(REFINING_HURT,            5).  %%伤害
-define(REFINING_HURT_SHIFT,       6).  %%伤害转移
-define(REFINING_DEAD_ATTACK,      4).  %%重击

%%强化材料----------------------------------------------------------
-define(REINFORCE_STUFF1,10401001).  %%1级
-define(REINFORCE_STUFF2,10401002).  %%2级
-define(REINFORCE_STUFF3,10401003).  %%3级
-define(REINFORCE_STUFF4,10401004).  %%4级
-define(REINFORCE_STUFF5,10401005).  %%5级
-define(REINFORCE_STUFF6,10401006).  %%6级

%%镶嵌符-----------------------------------------------------------
-define(INLAY_SYMBOL1,10600007).    %%1级
-define(INLAY_SYMBOL2,10600008).    %%2级
-define(INLAY_SYMBOL3,10600009).    %%3级
-define(INLAY_SYMBOL4,10600010).    %%4级
-define(INLAY_SYMBOL5,10600011).    %%5级
-define(INLAY_SYMBOL6,10600012).    %%6级

%%装备星级----------------------------------------------------------
-define(REFINING_GRADE1,1).   %%1星级
-define(REFINING_GRADE2,2).   %%2星级
-define(REFINING_GRADE3,3).   %%3星级
-define(REFINING_GRADE4,4).   %%4星级
-define(REFINING_GRADE5,5).   %%5星级
-define(REFINING_GRADE6,6).   %%6星级

%%拆卸保护符id----------------------------------------------------------
-define(REFINING_UNLOAD_SYMBOL,10600013).

%%强化的最大等级与星级------------------------------------------------
-define(REINFORCE_MAX_LEVEL, 6).
-define(REINFORCE_MAX_GRADE, 6).

%%开孔符------------------------------------------------------
-define(RUNE_LIST, [10600001, 10600002, 10600003,10600004 ,10600005 ,10600006]).

%%材料合成策略--------------------------------------------------------------------------
-define(FIVE_TO_ONE, 1).
-define(FOUR_TO_ONE, 2).
-define(THREE_TO_ONE, 3).

%%装备打孔-----------------------------------------------------------------------------
-define(MAX_PUNCH_NUM, 6).

%% 装备绑定类型
-define(EQUIP_BIND_TYPE_FIRST,1).
-define(EQUIP_BIND_TYPE_REBIND,2).
-define(EQUIP_BIND_TYPE_UPGRADE,3).
-define(DEFAULT_EQUIP_BIND_ATTR_NUM,1).
-define(DEFAULT_EQUIP_BIND_ATTR_LEVEL,1).
-define(DEFAULT_EQUIP_BIND_UPGRADE_ATTR_LEVEL,3).
%% 绑定材料记录 type：材料类型，1基础材料，2附加材料,材质,材料Id,材料级别,所需材料数量
-record(r_equip_bind_item,{type,material,item_id,item_level,item_num}).
%% 装备绑定记录 装备部位类型,protype内外偏向,0不分，1物理，2法力,装备可获取属性编码列表
-record(r_equip_bind_equip,{equip_code,protype,attr_list}).
%% 装备绑定属性记录，装备附加属性编码，加成类型,1:绝对值，2：百分比,级加，加成值
-record(r_equip_bind_attr,{attr_code, add_type, level, value}).
%% 装备绑定附加属性概念,
%% equip_color 装备颜色
%% attr_number 绑定属性个数
%% probability 概率
-record(r_equip_bind_attr_number,{equip_color,attr_number,probability}).
%% 装备绑定附加属性概念,属性级别，概率
-record(r_equip_bind_attr_level,{attr_level,probability}).
%% 重新绑定装备，并且使用附加材料进行绑定时，提高附加属性的级别概率配置
%% 附加材料级别，属性级别，级别概率
-record(r_equip_bind_add_level,{material_level,attr_level,probability}).


%% 物品的最大个数
-define(MAX_GOODS_NUMBER,50).

%% 装备消费日志记录
-record(r_equip_consume,{type,consume_type,consume_desc}).

%% 装备费用计算记录
%% type 计逄费用类型,fee_formula费用计算公式
%% equip_level 装备级别 material_level 材料级别 material_number 材料数量 refining_index 精炼系数
%% stone_num 宝石数量 punch_num 装备开孔数 equip_color 装备颜色 equip_quality 装备品质
-record(r_refining_fee,{type,fee_formula,equip_level = 1,material_level = 1,material_number = 1,
                        refining_index = 1,punch_num = 1,stone_num = 1,equip_color = 1,equip_quality = 1}).



%% 炼制记录
-define(REFINING_FORGING_CUSTOM,forging_custom).
-define(REFINING_FORGING_FORMULA,forging_formula).
%% 1 道具id, 2 道具类型 3 自定义分类
-define(REFINING_FORGING_MATERIAL_TYPE_ITEM,1).
-define(REFINING_FORGING_MATERIAL_TYPE_CLASS,2).
-define(REFINING_FORGING_MATERIAL_TYPE_CUSTOM,3).
-define(REFINING_FORGING_MATERIAL_TYPE_NORMAL,4).
%% 炼制道具自定义分类记录
%% id 分类id name 分类名称 item_ids 物品类型id列表 remark 备注
-record(r_forging_custom,{id,name,item_ids,remark}).
%% 炼制方案记录
%% id 炼制方案id name 炼制方案名称 desc 炼制方案描述
%% materials 炼制方案消耗材料记录列表 [r_forging_formula_item,...]
%% products 炼制方案获取材料记录列表 [r_forging_formula_item,..]
%% min_role_level 玩家最小级别 max_role_level 玩家最大级别
%% start_date 开始日期 格式为时间戳 end_date 结束日期 格式为时间戳
%% create_time 创建时间 格式为时间戳  update_time 格式为时间戳 更新时间 remark 备注
-record(r_forging_formula,{id,name,desc,materials,products,
                           min_role_level,max_role_level,
                           start_date,end_date,create_time,update_time,remark}).
%% 炼制方案子记录
%% type 道具类型 1 道具id, 2 道具类型 3 自定义分类 4 普通道具分类 type_value 道具类型值
%% item_num 道具数量 bind 绑定类型 1 绑定，2 不绑定，3 不要求，4 根据材料
%% color 颜色，quality 品质 min_level 最小级别 max_level 最大级别
%% min_index 最小精炼系数 max_index 最大精炼系数 slots 部位
%% result_weight 结果概率权值 succ_probability 成功概率 
%% is_broadcast 是否广播，0 不广播 1 广播
-record(r_forging_formula_item,{type,type_value,item_num,bind,
                                color,quality,min_level,max_level,min_index,max_index,
                                slots,result_weight,succ_probability,is_broadcast = 0}).

%% 天工炉新的操作接口
%% 操作类型 开孔100000,镶嵌200000,折卸300000,强化400000,合成500000,炼制600000,附加700000,提升800000
-define(FIRING_OP_TYPE_PUNCH,100000). %% 开孔
-define(FIRING_OP_TYPE_INLAY,200000). %% 镶嵌
-define(FIRING_OP_TYPE_UNLOAD,300000). %% 折卸
-define(FIRING_OP_TYPE_REINFORCE,400000). %% 强化
-define(FIRING_OP_TYPE_COMPOSE,500000). %% 合成 
-define(FIRING_OP_TYPE_FORGING,600000). %% 炼制
-define(FIRING_OP_TYPE_ADDPROP,700000). %% 附加
-define(FIRING_OP_TYPE_UPPROP,800000). %% 提升
-define(FIRING_OP_TYPE_UPCOLOR,900000). %% 提升装备颜色
-define(FIRING_OP_TYPE_UPEQUIP,110000).%% 装备升级
-define(FIRING_OP_TYPE_UPQUALITY,120000).%% 装备品质改造
-define(FIRING_OP_TYPE_RETAKE,999999). %% 取回天工炉物品
-define(FIRING_OP_TYPE_ADD_MAGIC,130000). %% 装备附魔

%% 物品类型
-define(FIRING_TYPE_TARGET,1).%% 目标物品
-define(FIRING_TYPE_MATERIAL,2).%% 材料物品

%% 材料全成子类型定义
-define(FIRING_OP_TYPE_COMPOSE_3,3). %% 3 合一
-define(FIRING_OP_TYPE_COMPOSE_4,4). %% 4 合一
-define(FIRING_OP_TYPE_COMPOSE_5,5). %% 5 合一

%% 取回天工炉物品子类型
-define(FIRING_OP_TYPE_RETAKE_1,1). %% 查询
-define(FIRING_OP_TYPE_RETAKE_2,2). %% 取回

%% 提升装备颜色子类型
-define(FIRING_OP_TYPE_UPCOLOR_1,1). %% 查询
-define(FIRING_OP_TYPE_UPCOLOR_2,2). %% 提升

%% 装备升级子类型
-define(FIRING_OP_TYPE_UPEQUIP_1,1). %% 查询
-define(FIRING_OP_TYPE_UPEQUIP_2,2). %% 升级

%% 提升装备颜色概率
%% min_color:最少色差
%% max_color:最多色差
%% material_type:类型 1:精练材料(min_index=0,max_index=0),2:装备
%% min_index:最少系数
%% max_index:最大系数
%% probability:概率 最大概率 100
-record(r_equip_color_probability,{min_color,max_color,material_type,min_index,max_index,probability}).


%% ======================天工开物配置开始====================

-define(BOX_OP_TYPE_FUN,100000).%% 查询天工开物信息
-define(BOX_OP_TYPE_SUB_FUN,100001).%% 查询天工开物功能信息 只查询或通知通前端箱子功能开放信息
-define(BOX_OP_TYPE_OPEN,200000). %% 开箱子
-define(BOX_OP_TYPE_OPEN_AUTO,200001).%% 开箱子并自动放置物品
-define(BOX_OP_TYPE_RESTORE,300000). %% 放置物品
-define(BOX_OP_TYPE_QUERY,400000). %% 查询放置物品
-define(BOX_OP_TYPE_GET,500000). %% 提取物品
-define(BOX_OP_TYPE_SALE,600000). %% 出售物品
-define(BOX_OP_TYPE_DESTROY,700000). %% 销毁物品
-define(BOX_OP_TYPE_INBAG,800000). %% 直接提取物品到背包
-define(BOX_OP_TYPE_MERGE,900000).%% 整理宝物空间物品接口

-define(DEFAULT_BOX_GOODS_ID,999998).

%% fee_flag 标记 0表示玩家未使用费用 1表示玩家使用费用
-define(BOX_FEE_FLAG_0,0).
-define(BOX_FEE_FLAG_1,1).

%% is_generate 表示是否已经按正常的时间生产箱子物品 0未生成 1已生成
-define(BOX_IS_GENERATE_0,0).
-define(BOX_IS_GENERATE_1,1).

%% fee_type 费用类型 0免费 1:9元宝
-define(BOX_FEE_TYPE_0,0).
-define(BOX_FEE_TYPE_1,1).

%% 
-define(BOX_USE_GOLD_0,0).%% 没有使用元宝 
-define(BOX_USE_GOLD_1,1).%% 元宝
-define(BOX_USE_GOLD_2,2).%% 绑定元宝


%% 查询箱子背包类型
-define(BOX_PAGE_TYPE_0,0).%%全部
-define(BOX_PAGE_TYPE_1,1).%%普通
-define(BOX_PAGE_TYPE_2,2).%%灵石
-define(BOX_PAGE_TYPE_3,3).%%装备
-define(BOX_PAGE_TYPE_4,4).%%材料

%% 是否自动放置箱子物品到宝物空间
-define(BOX_RESTORE_AUTO,1).%%自动
-define(BOX_RESTORE_MANUAL,0).%%手动

%% fee_type 费用类型 0免费 1:9元宝
%% item_type 材料类型概率 [0,0,0]表示 材料，宝石，装备的概率
%% item_number 材料个数概率 [1,2,3,...,N] 1个到N个对应的概率
-record(r_box_probability,{fee_type,item_number = [],item_type = []}).
%% fee_type 费用类型 0免费 1:9元宝
%% goods_type 物品类型 1材料，2宝石，3装备
%% goods_list 物品列表 [r_box_goods_probability,...] 
-record(r_box_sub_probability,{fee_type,goods_type,goods_list = []}).
%% fee_type 费用类型 0免费 1:9元宝
%% goods_type 物品类型 1材料，2宝石，3装备
%% goods_list 物品列表 [r_box_goods_probability,..] 
%% -record(r_box_goods_probability,{fee_type,goods_type,goods_list = []}).
%% item_id 道具id
%% item_type 道具类型 1材料，2宝石，3装备
%% item_number 道具数量
%% item_bind 绑定类型 1 绑定，2 不绑定，3 根据元宝
%% use_bind 装备使用绑定 1装备使用时绑定，当道具是装备时有效，且此时item_bind字段无效
%% weight 权重
%% equip_probability_id 装备概率id，如果道具是装备，需要指定其装备属性的概率id
%% role_category 玩家职业限制 [] 不限制 [1,2,3]只允许 1,2,3的职业使用
%% role_sex 玩家性别限制 [] 不限制 [1]只允许1性别的职业使用
%% role_level 玩家级别限制 []不限制  [MinLevel,MaxLevel]级别范围 MinLevel =< RoleLevel >= MaxLevel
%% is_broadcast 是否广播，如果是装备此字段不生效
%% start_time 开始时间 时间截
%% end_time 结束时间 时间截
%% days 创建此道具时 有效期多少天
-record(r_box_goods_probability,{weight = 0,equip_probability_id = 0, item_id,item_type,item_number,item_bind,use_bind,
start_time = 0,end_time = 0,days = 0,role_category = [],role_sex = [],role_level = [],is_broadcast = 0}).

%% 如果是装备的概率配置如下
%% id 装备概率id 1...N
%% color  颜色 [1,0,0,0,0,0]
%% quality 品质 [1,0,0,0,0]
%% sub_quality 子品质 [1,0,0,0]
%% reinforce 强化 [{1,[16]},{Weight,ReinforceList},...] ReinforceList = [16,..] 强化列表，十位数表时级别，个位数表进星级 不可以断级配置
%% punch_num 孔数 [1,0,0,0,0,0]
%% add_attr 绑定属性处理 不可以不配置 
%% 免费的概率{equip_bind_attr_number_box_free,equip_bind_attr_level_box_free},
%% 费用概率{equip_bind_attr_number_box_fee,equip_bind_attr_level_box_fee}
-record(r_box_equip_probability,{id,color=[],quality = [],sub_quality = [],reinforce =[],punch_num = [],add_attr}).

%% ======================天工开物配置结束========================

%% 装备升级配置
%% type_id 装备类型id
%% link_type 类型 1目标，原件 2原件
%% link_code 升级编码
-record(r_equip_upgrade_link,{type_id,link_type,link_code}).

%% 装备附魔基本信息
%% color_code 颜色编码
%% item_id 需要的道具id
%% item_number 需要的道具数量
%% op_fee 操作费用 单位文
-record(r_equip_add_magic_base_info,{color_code,item_id,item_number,op_fee}).
