package modules.greenHand.view
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	
	public class TreasuryWindow extends BasePanel
	{
		public function TreasuryWindow()
		{
			super("TreasuryWindow");
		}
		
		private var tabNavigation:TabNavigation;
		override protected function init():void{
			this.width = 560;
			this.height = 385;
			
			this.x = (1002 - this.width)/2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height)/2;
			
			this.title = "江湖宝典";
			
			var directoryView:DirectoryView = new DirectoryView();
			
			tabNavigation = new TabNavigation();
			this.addChild(tabNavigation);
			Style.setBorderSkin(tabNavigation.tabContainer);
			tabNavigation.width = 530;
			tabNavigation.height = 340;
			tabNavigation.x = 18;
			tabNavigation.y = 5;
			tabNavigation.selectedIndex = 0;
			tabNavigation.addItem("目录",directoryView,70,25);
			tabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onChangeHandler);
			
		}
		private function onChangeHandler(evt:TabNavigationEvent):void{}
	}
}