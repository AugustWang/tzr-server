package modules.skill {

	public class SkillConstant {
		public static const SKILL_TREE_TIP:String="SkillTreeTip";

		//技能学习状态 0为条件不满足，1为条件满足，2为达到最高级别
		public static const CONDITION_MAXLEVEL:int=0;
		public static const CONDITION_ACCORD:int=1;
		public static const CONDITION_DISACCORD:int=2;
		public static const CONDITION_DIS_ROLE_LEVEL:int=4;
		public static const CONDITION_DIS_PRE_SKILL:int=6;
		public static const CONDITION_DIS_NEED_ITEM:int=7;
		public static const CONDITION_DIS_NEED_SILVER:int=8;
		public static const CONDITION_DIS_EXP:int=9;

		//技能使用状态
		public static const SKILL_OK:int=0;
		public static const SKILL_NO_CD:int=1;
		public static const SKILL_NO_MP:int=2;
		public static const SKILL_NO_WEAPON:int=3;
		public static const SKILL_NO_TARGET:int=4;

		//生活技能id
		public static const LIFE_SKILL_MOUNT:int=9999991; //骑马术
		public static const LIFE_SKILL_AUTO:int=9999992; //挂机

		//技能界面事件
		public static const EVENT_SKILL_UPGRADE:String="EVENT_SKILL_UPGRADE";
		public static const EVENT_SKILL_ITEM_CLICK:String="EVENT_SKILL_ITEM_CLICK";
		public static const EVENT_PET_GROW_ITEM_CLICK:String="EVENT_PET_GROW_ITEM_CLICK";

		//技能系统 
		public static const CATEGORY_WARRIOR:int=1;
		public static const CATEGORY_ARCHER:int=2;
		public static const CATEGORY_RANGER:int=3;
		public static const CATEGORY_PRIEST:int=4;
		public static const CATEGORY_FAMILY:int=7;
		public static const CATEGORY_PET1:int=8;
		public static const CATEGORY_PET2:int=9;
		public static const CATEGORY_LIFE:int=99;

		public static const categorys:Array=["", "职业技能"];
		public static const categorys_name:Array=["没职业", "战士", "射手", "侠客", "医仙"];
		//技能系统
		public static const CATEGORY_LABEL_WARRIOR:String="职业技能";
		public static const CATEGORY_LABEL_ARCHER:String="职业技能";
		public static const CATEGORY_LABEL_RANGER:String="职业技能";
		public static const CATEGORY_LABEL_PRIEST:String="职业技能";
		public static const CATEGORY_LABEL_FAMILY:String="门派";
		public static const CATEGORY_LABEL_LIFE:String="基础";
		public static const CATEGORY_LABEL_PETGROW:String="驯宠能力";

		//武器类型
		public static const NO_EQUIP:int=0;
		public static const WARRIOR_EQUIP:int=101; //刀
		public static const ARCHER_EQUIP:int=102; //弓
		public static const RANGER_EQUIP:int=104; //扇
		public static const PRIEST_EQUIP:int=103; //杖

		//技能效果
		public static const KIND_POSITIVE:int=1; //正面
		public static const KIND_NEGATIVE:int=2; //负面

		//技能发动类型
		public static const ATTACK_TYPE_INITIATIVE:int=1 //主动
		public static const ATTACK_TYPE_PASSIVITY:int=2 //被动

		//技能有效目标
		public static const EFFECT_TYPE_SELF:int=1; //自身
		public static const EFFECT_TYPE_FRIEND:int=2; //友方全部
		public static const EFFECT_TYPE_ENEMY:int=3; //敌方全部
		public static const EFFECT_TYPE_FRIEND_ROLE:int=4; //友方玩家
		public static const EFFECT_TYPE_ENEMY_ROLE:int=5; //敌方玩家
		public static const EFFECT_TYPE_MONSTER:int=6; //怪物
		public static const EFFECT_TYPE_PET:int=7; //宠物
		public static const EFFECT_TYPE_YBC:int=8; //押送物
		public static const EFFECT_TYPE_ALL:int=9; //所有玩家
		public static const EFFECT_TYPE_ALL_TARGET:int=10; //所有目标（所有玩家和怪物等）
		public static const EFFECT_TYPE_SERVER_NPC:int=11; //后台NPC
		public static const EFFECT_TYPE_MASTER:int=12; //宠物主人
		public static const EFFECT_TYPE_MOUNT:int=13; //坐骑
		//技能作用范围类型
		public static const TARGET_TYPE_SELF:int=1; //施法者自己
		public static const TARGET_TYPE_SELF_AROUND:int=2; //施法者自己的周围
		public static const TARGET_TYPE_SELF_FRONT:int=3; //施法者前方区域
		public static const TARGET_TYPE_OTHER:int=4; //选择的目标
		public static const TARGET_TYPE_OTHER_AROUND:int=5; //选择目标的周围区域
		public static const TARGET_TYPE_OTHER_FRONT:int=6; //选择目标的前方区域
		public static const TARGET_TYPE_AREA_MAP:int=7; //选择的坐标点范围区域内的地图

		//技能BUFF持续效果类型,同时是扣血类型
		//经验
		public static const EXP_ADD:int=-1;
		//自己减血
		public static const REDUCE_HP_SELF:int=5;
		//减血
		public static const BUFF_INTERVAL_EFFECT_REDUCE_HP:int=1;
		//加血
		public static const BUFF_INTERVAL_EFFECT_ADD_HP:int=2;
		//减蓝
		public static const BUFF_INTERVAL_EFFECT_REDUCE_MP:int=3;
		//加蓝
		public static const RESULT_TYPE_ADD_MP:int=4;

		//特效类型
		public static const TYPE_NORAML:int=0;
		public static const TYPE_ARROW:int=1;

		//出现时机
		public static const START_NORMAL:int=0;
		public static const START_ARROW_END:int=1;

		//技能施放对象
		public static const TAR_SCENE:int=0;
		public static const TAR_SRC:int=1;
		public static const TAR_DEST:int=2;
		public static const TAR_DESTS:int=3;

		//技能效果的目标点
		public static const POS_BOTTOM:int=0;
		public static const POS_MIDDLE:int=1;
		public static const POS_SRC_BOTTOM:int=2;
		public static const POS_SRC_MIDDLE:int=3;
		public static const POS_DEST_BOTTOM:int=4;
		public static const POS_DEST_MIDDLE:int=5;

		//技能存在的层
		public static const TOP_LAYER:int=0;
		public static const BOTTOM_LAYER:int=1;

		//训宠技能
		public static const PET_GROW_SKILL_PHY_ATTACK:int=1;
		public static const PET_GROW_SKILL_MAGIC_ATTACK:int=2;
		public static const PET_GROW_SKILL_PHY_DEFENCE:int=3;
		public static const PET_GROW_SKILL_MAGIC_DEFENCE:int=4;
		public static const PET_GROW_SKILL_CON:int=5;

	}
}