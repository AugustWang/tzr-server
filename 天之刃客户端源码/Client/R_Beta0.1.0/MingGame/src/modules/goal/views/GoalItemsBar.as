package modules.goal.views
{
	import com.events.ParamEvent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.goal.GoalResource;
	import modules.goal.vo.GoalItemVO;
	
	public class GoalItemsBar extends Sprite
	{
		public static const MAX_WIDTH:int = 600;
		public static const ITEM_WIDTH:int = 71;
		public static const GOAL_ITEM_CLICK:String = "GOAL_ITEM_CLICK";
		public static const MIN_PADDING:int = 50;
		
		private var itemsPool:Vector.<GoalItem>;
		private var itemsArray:Vector.<GoalItem>;
		public function GoalItemsBar()
		{
			super();
			itemsPool = new Vector.<GoalItem>();
			itemsArray =  new Vector.<GoalItem>();
		}
		
		private var _goalItems:Array;
		public function set goalItems(items:Array):void{
			_goalItems = items;
			createItems();
		}	
		
		public function get toalItems():Array{
			return _goalItems;
		}
		
		private function createItems():void{
			if(_goalItems){
				var size:int = _goalItems.length;
				var padding:int = (MAX_WIDTH - size*ITEM_WIDTH)/(size-1);
				var goalItem:GoalItem;
				while(itemsArray.length > 0){
					goalItem = itemsArray.shift();
					if(goalItem.parent == this){
						removeChild(goalItem);
					}
					itemsPool.push(goalItem);
				}
				for (var i:int = 0; i < size; i++) 
				{
					goalItem = getItem(_goalItems[i]);
					addChild(goalItem);
					itemsArray.push(goalItem);
				}
				
				if(padding >= MIN_PADDING){
					LayoutUtil.layoutHorizontal(this,MIN_PADDING);
				}else{
					LayoutUtil.layoutHorizontal(this,padding);
				}
				if(itemsArray.length > 0){
					itemsArray[0].dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
			}
		}
		
		private function getItem(goalItemVO:GoalItemVO):GoalItem{
			var goalItem:GoalItem;
			if(itemsPool.length > 0){
				goalItem = itemsPool.shift();
			}else{
				goalItem = new GoalItem();
				goalItem.addEventListener(MouseEvent.CLICK,itemClickHandler);
			}
			goalItem.goalItemVo = goalItemVO;
			return goalItem;
		}
		
		
		public function update(goalItemVO:GoalItemVO):void{
			for each(var goalItem:GoalItem in itemsArray){
				if(goalItem.goalItemVo == goalItemVO){
					goalItem.update();
					break;
				}
			}
		}
		
		private var currentSelected:GoalItem;
		private function itemClickHandler(event:MouseEvent):void{
			var goalItem:GoalItem = event.currentTarget as GoalItem;
			if(goalItem){
				if(currentSelected){
					currentSelected.selected = false;
				}
				currentSelected = goalItem;
				goalItem.selected = true;
				dispatchEvent(new ParamEvent(GOAL_ITEM_CLICK,goalItem.goalItemVo));
			}
		}
	}
}