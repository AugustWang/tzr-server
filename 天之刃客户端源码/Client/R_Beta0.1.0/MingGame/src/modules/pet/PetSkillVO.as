package modules.pet
{
	import modules.skill.vo.SkillVO;
	
	public class PetSkillVO
	{
		public var skill:SkillVO;
		public var skill_type:int;
		
		public function PetSkillVO(s:SkillVO, type:int)
		{
			skill=s;
			skill.level=1;
			skill_type=type;
		}
	}
}