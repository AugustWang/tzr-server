package modules.goal.vo
{
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;

	/**
	 * 目标VO，从解析XML获取数据，并 解析为VO存储
	 * @author mingchao235
	 * 
	 */	
	public class GoalVO{
		/**
		 * 选项卡索引
		 */		
		public var index:int;
		/**
		 * 标签名称 
		 */		
		public var label:String;
		/**
		 * 激活天数 
		 */		
		public var active:int;
		/**
		 * 目标列表集合 
		 */
		public var goalItems:Array;
		/**
		 * 第几天的目标XML段 
		 */		
		public var goalXML:XML;
		
		public function GoalVO()
		{
			
		}
		
		public function parse():void{
			if(goalItems == null){
				goalItems = [];
				var itemXMLList:XMLList = goalXML.goalItem;
				for each(var item:XML in itemXMLList){
					var goalItemVo:GoalItemVO = new GoalItemVO();
					goalItemVo.goalXML = item;
					goalItemVo.parent = this;
					goalItemVo.parse();
					goalItems.push(goalItemVo);
				}
			}
		}
	}
}