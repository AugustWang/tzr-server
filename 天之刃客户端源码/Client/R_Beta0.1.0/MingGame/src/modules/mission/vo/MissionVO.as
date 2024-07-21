package modules.mission.vo {

	public class MissionVO {
		public function MissionVO() {

		}

		public var id:int;
		public var model:int;
		public var type:int;
		public var typeStr:String;
		public var followTitle:String;
		public var name:String;
		public var desc:String;
		// 当前状态  见MissionConstant
		public var currentStatus:int;
		// 任务模型的状态
		public var currentModelStatus:int;
		public var preModelStatus:int;
		public var maxModelStatus:int;
		public var statusNpcList:Vector.<int>;
		public var statusCollectList:Array;
		public var statusTimeLlimit:int;
		public var statusChangeTime:int;
		public var acceptTime:int;
		public var acceptLevel:int;
		
		public var commitTimes:int;
		public var succTimes:int;
		public var target:String;
		public var targetId:int;
		public var targetName:String;
		public var rewardData:MissionRewardVO;
		public var npcDialogues:Object;
		public var listenerList:Object;
		public var bigGroup:int = 0;
		public var smallGroup:int = 0;
		
		public var sortID:int = 0;//排序
		
		public var	maxDotimes:int = 0;//最大次数
		
		//是否是预览
		public var isPreview:Boolean = false;
		
		public var pinfo_int_list_1:Array=[];
		public var pinfo_int_list_2:Array=[];
		public var pinfo_int_list_3:Array=[];
		public var pinfo_int_list_4:Array=[];
		
	}
}