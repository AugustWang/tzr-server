package modules.official.views
{
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	
	import modules.factionsWar.FactionWarModule;
	import modules.factionsWar.views.FactionsWarView;

	public class OfficiaView extends Sprite
	{
		private var placardView:OfficiaPlacardView;
		private var factionWarView:FactionsWarView;
		private var tabBar:TabBar;
		private var container:UIComponent;
		public function OfficiaView()
		{
			tabBar = new TabBar();
			tabBar.x = 10;
			tabBar.addItem("官职列表",80,25);
			tabBar.addItem("国战管理", 80, 25);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onChanged);
			addChild(tabBar);
			
			container = ComponentUtil.createUIComponent(0,0,467,319);
			Style.setBorderSkin(container);
			container.y = 24;
			container.mouseEnabled = false;
			addChild(container);
		}
		
		private function onChanged(event:TabNavigationEvent):void{
			if(event.index == 0){
				if(factionWarView && factionWarView.parent){
					factionWarView.parent.removeChild(factionWarView);
				}
				if(placardView == null){
					placardView = new OfficiaPlacardView();
				}
				container.addChild(placardView);
			}else if(event.index == 1){
				if(placardView && placardView.parent){
					placardView.parent.removeChild(placardView);
				}
				if(factionWarView == null){
					factionWarView = FactionWarModule.getInstance().factionCase.getFactionWarView();
				}
				container.addChild(factionWarView);
			}
		}
	}
}