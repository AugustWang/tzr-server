package modules.family.views {
	import com.components.BasePanel;
	import com.ming.events.ItemEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	
	import modules.family.views.items.ContributeGoldView;
	import modules.family.views.items.ContributeSilverView;

	public class FamilyContributePanel extends BasePanel {
		private var nav:TabNavigation;
		private var goldView:ContributeGoldView;//元宝
		private var silverView:ContributeSilverView;//金币
		public function FamilyContributePanel() {
			initView();
		}

		private function initView():void {
			this.width = 315;
			this.height = 390;
			title="捐献";
			//addSmaillTitleBG();
			addContentBG(8,10,18);
			
			nav = new TabNavigation();
			nav.x=8;
			nav.y=0;
			nav.tabBarPaddingLeft = 16;
			goldView = new ContributeGoldView();
			silverView = new ContributeSilverView();
			nav.addItem("元宝捐献",goldView,75,21);
			nav.addItem("金币捐献",silverView,75,21);
			nav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChanged);
			addChild(nav);
		}
		
		private function onChanged(event:TabNavigationEvent):void{
			
		}
	}
}