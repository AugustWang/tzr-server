package modules.finery.views.item
{
	import com.components.HeaderBar;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;

	public class RightBottomList extends Sprite
	{
		private var tabNavigation_shop:TabNavigation;
		
		public function RightBottomList()
		{
		}
		
		public function initUI(arr:Array):void{
		
			tabNavigation_shop = new TabNavigation();
			Style.setBorderSkin(tabNavigation_shop.tabContainer);
			this.addChild(tabNavigation_shop);
			tabNavigation_shop.width = 270;
			tabNavigation_shop.height = 168;
			tabNavigation_shop.y = 2;
			tabNavigation_shop.isTween=false;
			for each(var obj:Object in arr){
				tabNavigation_shop.addItem(obj.name,obj.reference,70,23);
			}
			tabNavigation_shop.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onSelectShopChangeHandler);
		}
		
		private var _ids:Array=[];
		private var _binds:Array=[];
		public function checkSelect(ids:Array,binds:Array):void{
			_ids=ids.concat();
			_binds=binds.concat();
			if(tabNavigation_shop.tabContainer.getDisplayObject(tabNavigation_shop.selectedIndex) is MaterialShopList){
				MaterialShopList(tabNavigation_shop.tabContainer.getDisplayObject(tabNavigation_shop.selectedIndex)).checkSelet(ids,binds);
			}
		}
		
		private function onSelectShopChangeHandler(event:TabNavigationEvent):void{
			if(tabNavigation_shop.tabContainer.getDisplayObject(tabNavigation_shop.selectedIndex) is MaterialShopList){
				MaterialShopList(tabNavigation_shop.tabContainer.getDisplayObject(tabNavigation_shop.selectedIndex)).checkSelet(_ids,_binds);
			}
		}
	}
}