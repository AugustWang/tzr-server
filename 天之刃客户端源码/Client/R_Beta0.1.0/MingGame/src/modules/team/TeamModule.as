package modules.team {
	import com.Message;
	import com.managers.LayerManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.team.view.RecommendTeamView;
	import modules.team.view.TeamPanel;
	import modules.team.view.TeamRoleView;


	public class TeamModule extends BaseModule {
		private static var _instance:TeamModule;
		private var _view:TeamView;
		private var inited:Boolean;
		public var pro:TeamProcessor;

		/**
		 * 组队模块主类
		 * 2010-5-5
		 */
		public function TeamModule() {
			if (_instance == null) {
				super();

			} else {
				throw new Error('该类为单例，只能用getInstance方法创建')
			}
		}

		public static function getInstance():TeamModule {
			if (_instance == null) {
				_instance=new TeamModule();
			}
			return _instance;
		}

		public function init():void {
			if (inited == false) {
				inited=true;
				_view=new TeamView();
				_view.setup();
				LayerManager.uiLayer.addChild(_view);
				pro=new TeamProcessor(_view, this);
				_view.icon.init();
				onEnterGame();
			}
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ENTER_GAME, init);
		}

		private function onEnterGame():void {
			addSocketListener(SocketCommand.TEAM_ACCEPT, pro.onAcceptBack);
			addSocketListener(SocketCommand.TEAM_KICK, pro.onKickBack);
			addSocketListener(SocketCommand.TEAM_REFUSE, pro.onRefuseBack);
			addSocketListener(SocketCommand.TEAM_INVITE, pro.onInviteBack);
			addSocketListener(SocketCommand.TEAM_MEMBER_INVITE, pro.onMemberInvite);
			addSocketListener(SocketCommand.TEAM_OFFLINE, pro.onOffline);
			addSocketListener(SocketCommand.TEAM_CHANGE_LEADER, pro.onChangeLeader);
			addSocketListener(SocketCommand.TEAM_LEAVE, pro.onLeaveBack);
			addSocketListener(SocketCommand.TEAM_DISBAND, pro.onDisband);
			addSocketListener(SocketCommand.TEAM_AUTO_DISBAND, pro.onAutoDisband);
			addSocketListener(SocketCommand.TEAM_AUTO_LIST, pro.onAutoList);
			addSocketListener(SocketCommand.TEAM_PICK, pro.onChangePick);
			addSocketListener(SocketCommand.TEAM_MEMBER_RECOMMEND, pro.recommendTeamDataBack);
			addSocketListener(SocketCommand.TEAM_APPLY, pro.onApplyTeamToc);
			addSocketListener(SocketCommand.TEAM_QUERY,pro.onTeamQuery);
			addSocketListener(SocketCommand.TEAM_CREATE,pro.onTeamCreate);
			
			addMessageListener(ModuleCommand.START_TEAM, toInvite);
			addMessageListener(ModuleCommand.APPLY_TEAM, toApplyTeam); //申请入队
			addMessageListener(ModuleCommand.LEVEL_TEAM, pro.toLeave); //退队
			/*暂时屏蔽*/
//			addMessageListener(ModuleCommand.UPDATE_FIVE, _view.five.setup);
//			addMessageListener(ModuleCommand.ROLE2_FIVE_ELE_ATTR, _view.five.setup);
			addMessageListener(ModuleCommand.OPEN_TEAM_PANEL,pro.openTeamPanel);
		}
				
		private function toInvite(obj:Object):void {
			pro.toInvite(int(obj.role_id), int(obj.type_id));
		}

		private function toApplyTeam(obj:Object):void {
			if (obj) {
				pro.onApplyTeamTos(int(obj.role_id));
			}
		}

		/**
		 *请求组队数据
		 * @return
		 *
		 */
		public function recommedTeam(posX:int, posY:int):void {
			if (pro) {
				pro.requestRecommendTeamData(posX, posY);
			}
		}

		public function closeRecommendView():void {
			RecommendTeamView.getInstance().closeWinHandler();
		}

		public function send(vo:Message):void {
			sendSocketMessage(vo);
		}

		/**
		 * 获取成全数据，给附近玩家模块用的
		 * @return
		 *
		 */
		public function get members():Array {
			var arr:Array=[];
			if (_view != null) {
				for (var i:int=0; i < _view.list.numChildren; i++) {
					arr.push(TeamRoleView(_view.list.getChildAt(i)).pvo);
				}
			}
			return arr;
		}
	}
}