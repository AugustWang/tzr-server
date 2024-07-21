package modules.Activity.vo {

	public class AwardVo {
		/*<award id="1" name="" actpoint="3" expAdd="10000" expMult="410">
		 <item type="1" itemId="10100001" num="1" bind="true" />*/

		public var id:int=0; //  1
		public var expAdd:int=0; //10000
		public var expMult:int=0; //410
		public var itemArr:Array=[];
		public var isMatch:Boolean = false;
		public var isRewarded:Boolean = false;
		public var taskName:String; //任务名称
		public var taskCondition:String; //任务条件
		public var npcId:int;//连接传送的npc的id
		public var mapId:int;//地图id

		private var item:Object={}; // Object = {type:1,itemId:10100001,num:1,bind:true};


		public function AwardVo() {
		}
	}
}