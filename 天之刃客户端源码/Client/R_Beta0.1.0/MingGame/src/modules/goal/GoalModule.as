package modules.goal {
	import com.common.GlobalObjectManager;
	import com.common.effect.FlickerEffect;
	import com.common.effect.GlowTween;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.SocketCommand;

	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.goal.GoalDataManager;
	import modules.goal.GoalResource;
	import modules.goal.views.GoalPanel;

	import proto.line.m_goal_fetch_toc;
	import proto.line.m_goal_fetch_tos;
	import proto.line.m_goal_info_toc;
	import proto.line.m_goal_info_tos;
	import proto.line.m_goal_update_toc;

	public class GoalModule extends BaseModule {
		private var goalPanel:GoalPanel;
		private var goalBtn:UIComponent;
		private var goalDic:Dictionary;
		private var glowTween:GlowTween;

		public function GoalModule() {
			super();
		}

		private static var instance:GoalModule;

		public static function getInstance():GoalModule {
			if (instance == null) {
				instance=new GoalModule();
			}
			return instance;
		}

		override protected function initListeners():void {
//			addSocketListener(SocketCommand.GOAL_UPDATE, onGoalUpdate);
//			addSocketListener(SocketCommand.GOAL_FETCH, onGoalFetch);
//			addSocketListener(SocketCommand.GOAL_INFO, onGoalInfo);
//			addMessageListener(ModuleCommand.OPEN_GOAL_PANEL, onOpenGoalPanel);
//			addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
//			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
//			addMessageListener(ModuleCommand.GOAL_START_FLICK, onGoalStartFlick);
		}

		private function onStageResize(param:Object):void {
			if (goalBtn) {
				goalBtn.x=GlobalObjectManager.GAME_WIDTH - 280;
			}
		}

		private function onEnterGame():void {
			goalBtn=new UIComponent();
			goalBtn.buttonMode=true;
			goalBtn.x=GlobalObjectManager.GAME_WIDTH - 280;
			goalBtn.addEventListener(MouseEvent.CLICK, onOpenGoalPanel);
			goalBtn.bgSkin=Style.getButtonSkin("mccq_goal_btn_normal", "mccq_goal_btn_over", "mccq_goal_btn_normal", "", GameConfig.T1_UI);
			LayerManager.uiLayer.addChild(goalBtn);
			getGoalInfo();
		}

		private function onGoalStartFlick():void {
			if (goalPanel && WindowManager.getInstance().isPopUp(goalPanel)) {
				return;
			}
			if (glowTween == null) {
				glowTween=new GlowTween();
			}
			if (!glowTween.running()) {
				glowTween.startGlow(goalBtn);
			}
		}

		private function stopFlick():void {
			if (glowTween) {
				glowTween.stopGlow();
			}
		}

		private function onOpenGoalPanel(event:MouseEvent=null):void {
			stopFlick();
			if (GoalResource.loaded == false) {
				GoalResource.callBack=openGoalPanel;
				GoalResource.loadGoalResource();
			}else if(GoalResource.loaded){
				openGoalPanel();
			}

		}

		private function openGoalPanel():void {
			if (GoalResource.loaded) {
				if (goalPanel == null) {
					goalPanel=new GoalPanel();
				}
				goalPanel.initView();
				goalPanel.open();
				WindowManager.getInstance().centerWindow(goalPanel);
			}
		}

		/**
		 * 获取奖励
		 * @param goal_id
		 *
		 */
		public function goalFetch(goal_id:int, goodsTypeId:int=0):void {
			var vo:m_goal_fetch_tos=new m_goal_fetch_tos();
			vo.goal_id=goal_id;
			sendSocketMessage(vo);
		}

		public function getGoalInfo():void {
			sendSocketMessage(new m_goal_info_tos());
		}

		/**
		 *
		 * 创奇目标有更新
		 *
		 */
		private function onGoalUpdate(vo:m_goal_update_toc):void {
			GoalDataManager.getInstance().updateGoalItem(vo.goal_item);
		}

		/**
		 *
		 * 获取奖励返回
		 */
		private function onGoalFetch(vo:m_goal_fetch_toc):void {
			if (vo.succ) {
				GoalDataManager.getInstance().fetchGoal(vo.goal_id);
				Tips.getInstance().addTipsMsg("成功领取奖励！");
			} else {
				if (goalPanel) {
					goalPanel.addMessage(vo.reason);
				} else {
					BroadcastSelf.logger(vo.reason);
				}
			}
		}

		/**
		 * 获取目标的一些状态信息
		 *
		 */
		private function onGoalInfo(vo:m_goal_info_toc):void {
			if (vo.succ) {
				GoalDataManager.getInstance().day=vo.info.days;
				GoalDataManager.getInstance().setGoalData(vo.info.goals);
				if (goalPanel) {
					goalPanel.initView();
				}
			} else {
				if (goalPanel) {
					goalPanel.addMessage(vo.reason);
				} else {
					BroadcastSelf.logger(vo.reason);
				}
			}
		}

	}
}