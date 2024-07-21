package modules.nearPlayer
{
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	
	import flash.events.Event;

	public class NearPlayerView extends BasePanel
	{
		private var nav:TabNavigation;
		private var roleView:NearRoleView;
		private var npcView:NearNPCView;
		private var team:Button;
		private var chat:Button;
		private var follow:Button;
		private var friend:Button;
		private var deal:Button;

		public function NearPlayerView()
		{
			super("NearPlayerWindow");
		}

		override protected function init():void
		{
			width=343;
			height=410;
			title = "附近人物";
			
			addContentBG(35,8,24);
			
			nav=new TabNavigation();
			nav.x=6;
			nav.tabBarPaddingLeft=14;
			nav.width=328;
			nav.height=320;
			roleView=new NearRoleView();
			npcView=new NearNPCView();
			roleView.y = npcView.y = 3;
			nav.addItem("附近玩家", roleView, 65, 25);
			nav.addItem("NPC", npcView, 65, 25);
			addChild(nav);
		}

		public function selectedIndex(value:int):void{
			nav.selectedIndex = value;	
		}
		
		public function refreshHandler(e:Event):void
		{
			roleView.refreshHandler();
			npcView.refreshHandler();
		}
	}
}