package modules.achievement.views
{
	import com.components.BasePanel;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	
	import flash.utils.Dictionary;
	
	import modules.achievement.AchievementDataManager;
	import modules.achievement.vo.AchievementGroupVO;
	import modules.achievement.vo.AchievementTypeVO;
	
	public class AchievementPanel extends BasePanel
	{
		private var tabNav:TabNavigation;
		private var achievementFinishView:AchievementFinishView;
		private var views:Array;
		public function AchievementPanel()
		{
			super();
			initView();
		}
		
		private function initView():void{
			width = 600;
			height = 450;
			addImageTitle("title_ach");
			addTitleBG(446);
			addContentBG(12,14,33);
			
			views = new Array();
			achievementFinishView = new AchievementFinishView();
			views.push(achievementFinishView);
			
			tabNav = new TabNavigation();
			tabNav.x = 15;
			tabNav.y = 5;
			tabNav.width = 560;
			tabNav.height = 380;
			tabNav.tabBarPaddingLeft = 15;
			tabNav.addItem("完成度",achievementFinishView,60,28);
			
			var bigGroups:Array  = AchievementDataManager.getInstance().getBigGroups();
			for each(var groupVO:AchievementTypeVO in bigGroups){
				var detailView:AchievementDetailView = new AchievementDetailView();
				detailView.bigGroupVO = groupVO;
				views.push(detailView);
				tabNav.addItem(groupVO.name,detailView,60,28);
			}
			addChild(tabNav);
		}
		
		public function set selectedIndex(value:int):void{
			tabNav.selectedIndex = value;
		}
	}
}