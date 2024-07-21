package modules.bigExpresion.view
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.gs.TweenLite;
	import com.loaders.SourceLoader;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	
	import flash.display.Sprite;
	
	public class BigExpresionView extends BasePanel
	{
		private var arr:Array = [];
		private var normalView:BigExpressionNormalView;
		private var vipView:BigExpressionVIPView;
		private var tabBar:TabNavigation;
		private var currentIndex:int;
		private var currentView:Sprite;
		
		public function BigExpresionView()
		{
			super("BigExpresionView");
			initView();
		}
		
		public function initView():void{
			this.width = 300;
			this.height = 410;
			addSmaillTitleBG();
			addImageTitle("title_bigface");
			addContentBG(5,8,24);
			
			normalView = new BigExpressionNormalView();
			vipView = new BigExpressionVIPView();
			normalView.y = vipView.y = 4;
			
			tabBar = new TabNavigation();
			tabBar.width = 248;
			tabBar.height = 341;
			tabBar.addItem("普通", normalView, 70, 25);
			tabBar.addItem("VIP", vipView, 70, 25);
			tabBar.x = 14;
			addChild(tabBar);
		}
	}
}