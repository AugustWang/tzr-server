package modules.vip.views
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.skins.Skin;
	
	import flash.geom.Rectangle;
	
	import modules.vip.VipModule;
	
	public class VipPanel extends BasePanel
	{
		private var _myVipView:MyVipView;
		private var _vipListView:VipListView;
		
		public function VipPanel(key:String=null)
		{
			super(key);
			initView();
		}
		
		private function initView():void
		{
			this.width = 560;
			this.height = 480;
			addTitleBG(446);
			addImageTitle("title_vip");
			addContentBG(5,8,23);
					
			_myVipView = new MyVipView;
			_vipListView = new VipListView;
			
			var tab:TabNavigation = new TabNavigation();
			tab.width = 515;
			tab.height = 429;
			tab.x = 10;
			tab.addItem("我的VIP", _myVipView, 79, 25);
			tab.addItem("寻找VIP", _vipListView, 79, 25);
			addChild(tab);
			tab.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, tabChangeHandler);			
		}
		
		private function tabChangeHandler(evt:TabNavigationEvent):void
		{
			if (evt.index == 0) {
				_myVipView.reset();
			}
			if (evt.index == 1) {
				VipModule.getInstance().RequestVipList();
			}
		}
		
		public function reset():void
		{
			_myVipView.reset();
		}
		
		public function vipListReturn(list:Array):void
		{
			_vipListView.setData(list);
		}
		
		public function setIndex(index:int):void
		{
			_myVipView.setIndex(index);
		}
	}
}