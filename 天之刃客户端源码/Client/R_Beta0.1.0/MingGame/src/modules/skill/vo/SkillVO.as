package modules.skill.vo
{
	public class SkillVO
	{
		public var sid:int = 0;//技能ID
		public var name:String; //技能名称
		public var kind:int; //技能类型 正面负面其他1正面2附魔
		public var path:String; //技能图片
		public var levels:Array = [];//每一级技能的详细情况
		public var level:int = 0;
		public var max_level:int = 0; //技能最大等级
		public var need_equip_types:int = 0;//技能需要的武器类型
		public var is_common_phy:int = 0;//物理还是法术攻击
		public var cast_time:int = 0;//施法时间
		public var category:int = 0;//技能职业
		public var distance:int = 1;//距离
		public var attack_type:int = 0;
		public var effect_type:int = 0;//目标类型
		public var target_type:int = 0;//作用范围
		
		public var tree_x:int;
		public var tree_y:int;
		
		public var priority:int = 0;
		
		public var typeId:String;//技能CD标记符
		public var isSelectAuto:Boolean = false;
		public var useMethod:String;
		public var bookTip:Boolean = false;
		
		public var effect:SkillEffectVO;
		
		//门派技能等级		
		public var fml_level:int;
	}
}