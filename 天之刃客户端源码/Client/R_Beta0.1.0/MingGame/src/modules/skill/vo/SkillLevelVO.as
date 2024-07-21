package modules.skill.vo
{
	
	public class SkillLevelVO
	{
		public var level:int//级数
		public var discription:String//描述
		public var cooldown:int = 0;//冷却时间
		public var consume_mp:int = 0;//法力消耗
		public var buff:Array = [];
		public var debuff:Array = [];
		public var conditions:Array = []//条件
	}
}