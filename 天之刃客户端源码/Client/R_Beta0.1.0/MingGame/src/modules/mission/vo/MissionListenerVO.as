package modules.mission.vo {

	public class MissionListenerVO {

		static public const I_TYPE:int = 0;//类型 1怪物 2道具 
		static public const I_VALUE:int = 1;//类型对应的值 比如道具ID
		static public const I_INT_DATA:int = 2;//侦听器可能需要其他数据
		static public const I_NUM:int = 3;
		
		public function MissionListenerVO(){
			
		}
		
		public var type:int;
		public var value:int;
		public var int_data:Array;
		public var num:int;
		public var current_num:int;//这个值不需要有索引映射
	}
}