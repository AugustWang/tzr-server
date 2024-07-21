package modules.mission.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.Activity.ActivityModule;
	import modules.ModuleCommand;
	import modules.mission.MissionDataManager;
	import modules.mission.MissionModule;
	import modules.mission.vo.MissionRewardVO;
	import modules.mission.vo.MissionVO;
	import modules.mypackage.managers.ItemLocator;


	/**
	 * 日常任务查看窗口，对相关任务有详细的描述，可放弃任务。
	 * @author Administrator
	 *
	 */
	public class MissionWindow extends BasePanel {

		public var tabNav:TabNavigation;
		private var currentMission:MissionListView;
		private var canAcceptMission:MissionListView;
		private var autoMission:AutoMissionView;

		private var missionFollowBtn:Button
		private var activityBtn:Button;

		public function MissionWindow() {
			super();
		}

		/**
		 * 初始化界面
		 *
		 */
		override protected function init():void {
			width = 552;
			height = 445;

			addTitleBG(468);
			addImageTitle("title_mission");
			addContentBG(25,8,24);
			
			currentMission = new MissionListView();
			canAcceptMission = new MissionListView();
			autoMission = new AutoMissionView();
			currentMission.y = canAcceptMission.y = autoMission.y = 8;

			tabNav = new TabNavigation();
			tabNav.tabBarPaddingLeft = 5;
			tabNav.width = 527;
			tabNav.height = 410;
			tabNav.x = 13;
			addChild(tabNav);
			tabNav.addItem("当前任务", currentMission, 74, 25);
			tabNav.addItem("可接任务", canAcceptMission, 74, 25);
			tabNav.addItem("委托任务", autoMission, 74, 25);
			tabNav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, selectTabChangeHandler);

//			ComponentUtil.createTextField("主线任务进行的同时也伴随着支线任务", 12, 335, null, 300, 25, this);

			activityBtn = ComponentUtil.createButton("日常活动", 330, 1, 100, 25, this);
			activityBtn.addEventListener(MouseEvent.CLICK, activityHandler);

			missionFollowBtn = new Button();
			missionFollowBtn = ComponentUtil.createButton("任务追踪", 435, 1, 100, 25, this);
			missionFollowBtn.addEventListener(MouseEvent.CLICK, missionFollowHandler);

			addEventListener(WindowEvent.OPEN, onOpenWindow);
		}
		
		private function selectTabChangeHandler(event:TabNavigationEvent):void{
			if(event.index){
				Dispatch.dispatch(ModuleCommand.MISSION_REQUEST_LIST_AUTO_MISSION);
			}
		}

		public function updateMissionList():void{
			if(WindowManager.getInstance().isPopUp(this)){
				currentMission.dataProvdier = MissionDataManager.getInstance().currentMissionList;
				canAcceptMission.dataProvdier = MissionDataManager.getInstance().canAcceptMissionList;
				autoMission.listData = MissionDataManager.getInstance().autoMissionList;
			}
		}
		
		
		private function onOpenWindow(event:WindowEvent):void {
			activityBtn.visible = GlobalObjectManager.getInstance().user.attr.level >= 20;
			currentMission.dataProvdier = MissionDataManager.getInstance().currentMissionList;
			canAcceptMission.dataProvdier = MissionDataManager.getInstance().canAcceptMissionList;
			autoMission.listData = MissionDataManager.getInstance().autoMissionList;
		}
		
		/**
		 * 点击活动按钮 
		 * @param event
		 * 
		 */		
		private function activityHandler(event:MouseEvent):void {
			ActivityModule.getInstance().openActivityWin(0);
		}
		/**
		 * 点击任务追踪按钮 
		 * @param event
		 * 
		 */		
		private function missionFollowHandler(event:MouseEvent):void {
			Dispatch.dispatch( ModuleCommand.MISSION_CHANGE_FOLLOW_VIEW );
		}
		/**
		 * 设置选择索引项 
		 * @param value
		 * 
		 */		
		public function set seleteIndex(value:int):void {
			if (value != tabNav.selectedIndex) {
				tabNav.selectedIndex = value;
			}
		}
		/**
		 * 获取 选择索引项 
		 * @return 
		 * 
		 */		
		public function get seleteIndex():int {
			return tabNav.selectedIndex;
		}
		
		public function get autoMissionView():AutoMissionView{
			return autoMission;
		}
	}
}