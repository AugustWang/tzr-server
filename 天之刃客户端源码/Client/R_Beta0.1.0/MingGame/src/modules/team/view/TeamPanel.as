package modules.team.view
{
	import com.components.BasePanel;
	import com.managers.Dispatch;
	import com.ming.ui.controls.TabNavigation;
	
	import flash.display.Sprite;
	
	import modules.ModuleCommand;
	
	public class TeamPanel extends BasePanel
	{
		public var myTeam:MyTeamView;
		public var nearTeamList:NearTeamView;
		private var nav:TabNavigation;
		public function TeamPanel()
		{
			super();
			initView();
		}
		
		public function initView():void{
			width = 662;
			height = 328;
			addTitleBG(450);
			addImageTitle("title_team");
			addContentBG(8,8,18);
			
			myTeam = new MyTeamView();
			nearTeamList = new NearTeamView();
			
			nav = new TabNavigation();
			nav.width = width - 16;
			nav.height = 278;
			nav.x=8;
			nav.y=0;
			nav.tabBarPaddingLeft = 16;
			nav.addItem("我的队伍",myTeam,70,21);
			nav.addItem("附近队伍",nearTeamList,70,21);
			addChild(nav);
		}
		
		public function updateNearbyTeam(datas:Array):void{
			if(nearTeamList){
				nearTeamList.updateNearbyTeam(datas);
			}
		}
	}
}