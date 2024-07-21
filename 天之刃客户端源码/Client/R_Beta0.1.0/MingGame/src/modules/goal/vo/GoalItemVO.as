package modules.goal.vo
{
	import modules.goal.GoalDataManager;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;

	public class GoalItemVO
	{
		/**
		 * 目标ID
		 */		
		public var id:int;
		/**
		 * 目标名称 
		 */		
		public var name:String;
		/**
		 * 目标完成条件
		 */		
		public var condition:String;
		/**
		 * 目标奖励 
		 */		
		public var rewardVO:GoalRewardVO;
		/**
		 * 目标描述 
		 */		
		public var desc:String;
		/**
		 * 父级节点
		 */		
		public var parent:GoalVO;
		/**
		 * 状态: 0,未开启,1进行中，2可领奖 ,3已完成 
		 */		
		public var status:int = 0;
		/**
		 * 是否领取奖励 
		 */		
		public var takeReward:Boolean = false;
		/**
		 * 是否完成 
		 * 
		 */		
		public var finished:Boolean = false;
		
		
		public function GoalItemVO()
		{
		}
		
		/**
		 * 当前目标的详细XML段，由于在显示选项卡时，不需要奖励XML全部解析，所以是按需要时再进行数据解析
		 */
		public var goalXML:XML;
		public function parse():void{
			if(rewardVO == null){
				id = goalXML.@id;
				name = goalXML.@name;
				condition = goalXML.child("condition").text();
				desc = goalXML.child("desc").text();
				var rewardXML:XML = goalXML.reward[0];
				rewardVO = new GoalRewardVO();
				rewardVO.bindGold = rewardXML.@bindGold;
				rewardVO.gold = rewardXML.@gold;
				rewardVO.bindSilver = rewardXML.@bindSilver;
				rewardVO.silver = rewardXML.@silver;
				rewardVO.exp = rewardXML.@exp;
				rewardVO.muti_choose = rewardXML.@muti_choose;
				rewardVO.goods = [];
				var goodsXMLList:XMLList = rewardXML.goods;
				for each(var item:XML in goodsXMLList){
					var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(item.@typeId);
					baseItemVO.color = item.@color;
					baseItemVO.quality = item.@quality;
					baseItemVO.num = item.@num;
					baseItemVO.bind = int(item.@isbind) == 0 ? false : true;
					baseItemVO.timeoutData = item.@end_time;
					rewardVO.goods.push(baseItemVO);
				}
				GoalDataManager.getInstance().wrapperGoalItem(this);
			}
		}
	}
}