package modules.robKingWar {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.managers.LayerManager;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.robKingWar.view.RobKingResult;
	import modules.scene.SceneDataManager;
	import modules.scene.cases.RobKingSceneCase;
	
	import proto.line.m_warofking_agree_enter_toc;
	import proto.line.m_warofking_agree_enter_tos;
	import proto.line.m_warofking_apply_toc;
	import proto.line.m_warofking_apply_tos;
	import proto.line.m_warofking_break_toc;
	import proto.line.m_warofking_collect_toc;
	import proto.line.m_warofking_end_toc;
	import proto.line.m_warofking_enter_toc;
	import proto.line.m_warofking_enter_tos;
	import proto.line.m_warofking_getmarks_toc;
	import proto.line.m_warofking_getmarks_tos;
	import proto.line.m_warofking_hold_toc;
	import proto.line.m_warofking_hold_tos;
	import proto.line.m_warofking_holding_toc;
	import proto.line.m_warofking_safetime_toc;
	import proto.line.m_warofking_safetime_tos;

	public class RobKingWarModule extends BaseModule {
		private static var _instance:RobKingWarModule;
		private var inited:Boolean;
		private var _timer:Timer;
		private var resultList:RobKingResult;
		private var timeOutId:int;

		public function RobKingWarModule() {
			super();
			if (_instance != null) {
				throw new Error("RobKingWarModule只能存在一个实例。");
			}
		}

		public static function getInstance():RobKingWarModule {
			if (_instance == null) {
				_instance=new RobKingWarModule();
			}
			return _instance;
		}

		private function initView():void {
			if (inited == false) {
				inited=true;
			}
		}

		public function toSignUp(link:NpcLinkVO):void {
			var vo:m_warofking_apply_tos=new m_warofking_apply_tos;
			sendSocketMessage(vo);
		}

		public function onSignUp(vo:m_warofking_apply_toc):void {
			if (vo.succ) {
				BroadcastView.getInstance().addBroadcastMsg("成功报名参加王座争霸战");
			} else {
				Alert.show(vo.reason, null, null, null, "确定", "", null, false);
					//报名失败
			}
		}

		public function onCollect(vo:m_warofking_collect_toc):void {
			Prompt.show("是否参与王座争霸战？", "王座争霸征集令", toAgreeCollect, toRefuseCollect, "接受", "拒绝");
		}

		private function toAgreeCollect():void {
			var vo:m_warofking_agree_enter_tos=new m_warofking_agree_enter_tos;
			sendSocketMessage(vo);
		}

		private function toRefuseCollect():void {
			//啥也不做
		}

		public function onAgreeCollect(vo:m_warofking_agree_enter_toc):void {
			if (vo.succ == false) {
				BroadcastView.getInstance().addBroadcastMsg(vo.reason);
			}
		}

		public function onMapChange(map_id:int):void {
			if (SceneDataManager.isRobKingMap) {
				timeOutId=setTimeout(showResultPanel, 1500, true);
				toRequestSafeTime();
				dispatch(ModuleCommand.MISSION_HIDE_FOLLOW_VIEW);
			} else {
				showResultPanel(false);
			}
		}

		public function showResultPanel(show:Boolean):void {
			if (show == true) {
				if (resultList == null) {
					resultList=new RobKingResult;
					resultList.x=GlobalObjectManager.GAME_WIDTH - 183;
					resultList.y=157;
				}
				if (resultList.parent == null) {
					LayerManager.uiLayer.addChild(resultList);
				}
			} else {
				if (resultList != null && resultList.parent != null) {
					resultList.parent.removeChild(resultList);
				}
			}
		}

		public function toRequestSafeTime(e:TimerEvent=null):void {
			if (_timer == null) {
				_timer=new Timer(1000);
				_timer.addEventListener(TimerEvent.TIMER, toRequestSafeTime);
				_timer.start();
			}
			var vo:m_warofking_safetime_tos=new m_warofking_safetime_tos;
			sendSocketMessage(vo);
		}

		public function onSafeTime(vo:m_warofking_safetime_toc):void {
			var msg:String;
			if (vo.succ == true) {
				if (vo.remain_time > 0) {
					msg="安全保护时间剩余：" + vo.remain_time + "秒";
					if (RobKingSceneCase.isRobing == false) {
						RobKingSceneCase.isRobing=true;
					}
				} else {
					msg="安全保护时间结束，开始王座争霸战！";
					_timer.stop();
					_timer.removeEventListener(TimerEvent.TIMER, toRequestSafeTime);
					_timer.addEventListener(TimerEvent.TIMER, toGetMarks);
					_timer.start();
				}
				BroadcastView.getInstance().addBroadcastMsg(msg);

			} else {
				clearTimeout(timeOutId);
				showResultPanel(false);
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, toRequestSafeTime);
				_timer=null;
				//王座争霸战时间已过，就当普通地图;
				if (RobKingSceneCase.isRobing == true) {
					RobKingSceneCase.isRobing=false;
				}
			}
		}

		private function toGetMarks(e:TimerEvent):void {
			var vo:m_warofking_getmarks_tos=new m_warofking_getmarks_tos;
			sendSocketMessage(vo);
		}

		public function onGetMarks(vo:m_warofking_getmarks_toc):void {
			if (resultList != null) {
				resultList.update(vo);
			}
		}

		public function toHoldThrone():void {
			var vo:m_warofking_hold_tos=new m_warofking_hold_tos;
			sendSocketMessage(vo);
		}

		public function onHoldThrone(vo:m_warofking_hold_toc):void {
			if (vo.succ == true) {
				if (vo.return_self == false && vo.role_id == GlobalObjectManager.getInstance().user.base.role_id) { //自己会收到2条消息，一条是请求的，一条的广播的，排除广播的那条
					return;
				}
				var family:String=vo.return_self == true ? "本门派" : vo.family_name;
				BroadcastView.getInstance().addBroadcastMsg("王座正在被" + family + "成员占领！");
				this.dispatch(ModuleCommand.ROB_KING_HOLD_SEAT, vo);
			} else {
				BroadcastView.getInstance().addBroadcastMsg(vo.reason);
			}
		}

		public function toEnterRobKing(link:NpcLinkVO):void {
			var vo:m_warofking_enter_tos=new m_warofking_enter_tos;
			sendSocketMessage(vo);
		}

		public function onEnterRobKing(vo:m_warofking_enter_toc):void {
			if (vo.succ == false) {
				BroadcastSelf.getInstance().appendMsg(HtmlUtil.font(vo.reason, "#ff0000"));
			}
		}

		public function toHoldSeat():void {
			var vo:m_warofking_hold_tos=new m_warofking_hold_tos;
			sendSocketMessage(vo);
		}

		public function onHoldSeat(vo:m_warofking_hold_toc):void {
			this.dispatch(ModuleCommand.ROB_KING_HOLD_SEAT, vo);
		}

		public function onHolding(vo:m_warofking_holding_toc):void {
			this.dispatch(ModuleCommand.ROB_KING_HOLDING, vo);
		}

		public function onBreaking(vo:m_warofking_break_toc):void {
			this.dispatch(ModuleCommand.ROB_KING_BREAK, vo);
		}

		public function onRobEnd(vo:m_warofking_end_toc):void {
			if (vo.family_id == GlobalObjectManager.getInstance().user.base.family_id) {
				BroadcastView.getInstance().addBroadcastMsg("你的门派获胜了！");
			} else {
				BroadcastView.getInstance().addBroadcastMsg("王座争霸战结束！");
			}
			this.dispatch(ModuleCommand.ROB_KING_END, vo);
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, toGetMarks);
			_timer=null;
			if (RobKingSceneCase.isRobing == true) {
				RobKingSceneCase.isRobing=false;
			}
		}
		
		private function onStageResize(value:Object):void
		{
			if (resultList)
				resultList.onStageResize();
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.WAROFKING_APPLY, onSignUp);
			addSocketListener(SocketCommand.WAROFKING_COLLECT, onCollect);
			addSocketListener(SocketCommand.WAROFKING_AGREE_ENTER, onAgreeCollect);
			addSocketListener(SocketCommand.WAROFKING_SAFETIME, onSafeTime);
			addSocketListener(SocketCommand.WAROFKING_HOLD, onHoldThrone);
			addSocketListener(SocketCommand.WAROFKING_HOLDING, onHolding);
			addSocketListener(SocketCommand.WAROFKING_END, onRobEnd);
			addSocketListener(SocketCommand.WAROFKING_BREAK, onBreaking);
			addSocketListener(SocketCommand.WAROFKING_GETMARKS, onGetMarks);
			addSocketListener(SocketCommand.WAROFKING_ENTER, onEnterRobKing);
			/////////////////////////////////////////////////////////
			addMessageListener(ModuleCommand.CHANGE_MAP, onMapChange);
			addMessageListener(NPCActionType.NA_79, toSignUp);
			addMessageListener(NPCActionType.NA_80, toEnterRobKing);
			addMessageListener(ModuleCommand.ROB_KING_ONCLICK_THRONE, toHoldThrone);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
		}
	}
}