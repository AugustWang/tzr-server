package modules.achievement
{
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.loaders.ViewLoader;
	import com.net.SocketCommand;
	
	import flash.events.MouseEvent;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.achievement.views.AchievementPanel;
	import modules.achievement.views.AchievementPopUpView;
	import modules.achievement.vo.AchievementGroupVO;
	
	import proto.line.m_achievement_award_toc;
	import proto.line.m_achievement_award_tos;
	import proto.line.m_achievement_notice_toc;
	import proto.line.m_achievement_query_toc;
	import proto.line.m_achievement_query_tos;
	
	public class AchievementModule extends BaseModule
	{
		private var achievementPanel:AchievementPanel;
		private var achievementDataManager:AchievementDataManager;
		private var achievementPopUpView:AchievementPopUpView;
		public function AchievementModule()
		{
			super();
			achievementDataManager = AchievementDataManager.getInstance();
			achievementDataManager.addEventListener(AchievementDataManager.GROUP_FINISH,onAchievementFinish);
			achievementDataManager.addEventListener(AchievementDataManager.ACHIEVEMENT_FINISH,onAchievementFinish);
		}
		
		private static var _instance:AchievementModule;
		public static function getInstance():AchievementModule{
			if(!_instance){
				_instance = new AchievementModule();
			}
			return  _instance;
		}
		
		override protected function initListeners():void{
			addMessageListener(ModuleCommand.OPEN_ACHIEVEMENT_PANEL,openAchievementPanel);
			addSocketListener(SocketCommand.ACHIEVEMENT_AWARD,setAchievementAward);
			addSocketListener(SocketCommand.ACHIEVEMENT_NOTICE,setNoticeAchievement);
			addSocketListener(SocketCommand.ACHIEVEMENT_QUERY,setAchievementInfo);
		}
		
		private function onAchievementFinish(event:ParamEvent):void{
			if(achievementPopUpView == null){
				achievementPopUpView = new AchievementPopUpView();
				achievementPopUpView.addEventListener(MouseEvent.CLICK,clickAchievmentHandler);
			}
			achievementPopUpView.addPopUpVO(event.data);
		}
		
		private function clickAchievmentHandler(event:MouseEvent):void{
			openAchievementPanel(0);
		}
		
		private function openAchievementPanel(tabIndex:int=-1):void{
			if(!ViewLoader.hasLoaded(GameConfig.ACHIEVEMENT_UI)){
				ViewLoader.load(GameConfig.ACHIEVEMENT_UI,openAchievementPanel,[tabIndex]);
				return;
			}
			if(achievementPanel == null){
				achievementPanel = new AchievementPanel();
			}
			if(tabIndex != -1){
				achievementPanel.selectedIndex = tabIndex;
			}
			if(!achievementPanel.isPopUp){
				achievementPanel.centerOpen();
			}
		}
		
		public function getAchievementAward(id:int):void{
			var vo:m_achievement_award_tos = new m_achievement_award_tos();
			vo.achieve_id = id;
			sendSocketMessage(vo);
		}
		
		public function getAchievements(groupId:int,op_type:int=2):void{
			var vo:m_achievement_query_tos = new m_achievement_query_tos();
			vo.op_type = op_type;
			vo.group_id = groupId;
			sendSocketMessage(vo);
		}
		/**
		 * 获取成就总览
		 */		
		public function getAchievementInfo():void{
			var vo:m_achievement_query_tos = new m_achievement_query_tos();
			vo.op_type = 3;
			sendSocketMessage(vo);
		}
		
		private function setAchievementAward(vo:m_achievement_award_toc):void{
			if(vo.succ){
				achievementDataManager.updateAchievementState(vo.group_id,vo.achieve_id,AchievementConstant.STATE_TAKE);
			}
		}
		
		private function setNoticeAchievement(vo:m_achievement_notice_toc):void{
			achievementDataManager.updateAchievementInfos(vo.total_points,vo.achievements);
		}
		
		private function setAchievementInfo(vo:m_achievement_query_toc):void{
			if(vo.succ){
				if(vo.op_type == 2){
					achievementDataManager.setAchievements(vo.group_id,vo.achievements);
				}else if(vo.op_type == 3){
				    achievementDataManager.setAchievementInfo(vo.total_points,vo.stat_info);
					achievementDataManager.setJustAchievements(vo.lately_achievements);
				}else if(vo.op_type == 5){
					achievementDataManager.setAchievements(vo.group_id,vo.rank_achievements);
				}
			}
		}
	}
}