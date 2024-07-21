package modules.mission.vo
{
	import modules.mypackage.vo.BaseItemVO;

	/**
	 *  道具奖励VO
	 * @author hyb
	 * 
	 */	
	public class MissionPropRewardVO
	{
		static public var I_PROP_ID:int = 0;
		static public var I_PROP_TYPE:int = 1;
		static public var I_PROP_NUM:int = 2;
		static public var I_BIND:int = 3;
		
		public function MissionPropRewardVO()
		{
			
		}
		
		public var prop_id:int;
		public var prop_type:int;
		public var prop_num:int;
		public var bind:int;
		public var baseItemVO:BaseItemVO;
	}
}