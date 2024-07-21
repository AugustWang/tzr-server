package modules.finery.views.item
{
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RightList extends Sprite
	{
		private var tabNavigation:TabNavigation;
		public function RightList(arr:Array)
		{
			super();
			init(arr);
		}
		
		private function init(arr:Array):void{
			//背景
			tabNavigation = new TabNavigation();
			Style.setBorderSkin(tabNavigation.tabContainer);
			this.addChild(tabNavigation);
			tabNavigation.width = 266;
			tabNavigation.height = 386;
			tabNavigation.isTween = false;
			for each(var obj:Object in arr){
				tabNavigation.addItem(obj.name,obj.reference,40,23);
			}
			tabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onSelectEquipChangedHandler);
		}
		
		private var _ids:Array = [];
		public function checkSelect(ids:Array):void{
			switch(ToggleButton(tabNavigation.tabBar.getChildAt(tabNavigation.selectedIndex)).label){
				case "全部":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).checkSelet(ids.concat());
					break;
				case "材料":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).checkSelet(ids.concat());
					break;
				case "灵石":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).checkSelet(ids.concat());
					break;
				case "装备":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).checkSelet(ids.concat());
					break;
			}
			_ids=ids;
		}
		
		public function update():void{
			switch(ToggleButton(tabNavigation.tabBar.getChildAt(tabNavigation.selectedIndex)).label){
				case "全部":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).update("ALL");
					break;
				case "材料":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).update("MATERIAL");
					break;
				case "灵石":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).update("STONE");
					break;
				case "装备":
					MaterialList(tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex)).update("EQUIP");
					break;
			}
			checkSelect(_ids);
		}
		
		private function onSelectEquipChangedHandler(event:TabNavigationEvent):void{
			update();
		}
	}
}