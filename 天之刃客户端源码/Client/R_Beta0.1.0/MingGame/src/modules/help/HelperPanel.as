package modules.help
{
	import com.components.BasePanel;
	import com.loaders.CommonLocator;
	import com.managers.WindowManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class HelperPanel extends BasePanel
	{
		
		private var tabNavigation:TabNavigation;
		//玩家帮助界面
		private var helpView:HelperView;
		//搜索节目
		public var searchView:SearchView;
		
		private static const TAB_WIDTH:int=70;
		private static const TAB_HEIGHT:int=25;
		
		public function HelperPanel()
		{
			initUI();
			initData();
		}
		
		private function initData():void
		{
			// TODO Auto Generated method stub
			var xml:XML = CommonLocator.getXML(CommonLocator.HELP);
			helpView.setData(xml);
		}
		
		private function initUI():void
		{
			this.title = "天之刃帮助";
			
			this.height = 400;
			this.width = 560;
			
			helpView = new HelperView;
			this.addChild(helpView);
			
			searchView = new SearchView();
			this.addChild(searchView);
			
			// TODO Auto Generated method stub
			tabNavigation=new TabNavigation();
			this.addChild(tabNavigation);
			
			tabNavigation.width = this.width - 30;
			tabNavigation.height = this.height-50;
			tabNavigation.x=18;
			tabNavigation.y=8;
			tabNavigation.addItem("帮助",helpView,TAB_WIDTH,TAB_HEIGHT);
			tabNavigation.addItem("搜索",searchView,TAB_WIDTH,TAB_HEIGHT);
			tabNavigation.selectedIndex= 0;
			tabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onTabChange);
		}
		
		protected function onTabChange(event:TabNavigationEvent):void
		{
			switch(event.index){
				case 0:
					helpView.visible = true;
					searchView.visible = false;
					break;
				case 1:
					helpView.visible = false;
					searchView.visible = true;
					break;
			}
		}
		
		public function openPanel():void{
			tabNavigation.selectedIndex=0;
			WindowManager.getInstance().popUpWindow(this);
			WindowManager.getInstance().centerWindow(this);
		}
		
		public function openSearchView(word:String):void{
			openPanel();
			tabNavigation.selectedIndex=1;
			searchView.searchData(word);
		}
	}
}