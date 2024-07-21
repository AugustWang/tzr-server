package modules.factionsWar.cases {
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.managers.WindowManager;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.factionsWar.FactionWarModule;
	import modules.factionsWar.views.FactionCountDownView;
	import modules.factionsWar.views.FactionsWarView;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;
	
	import proto.line.m_waroffaction_buy_guarder_toc;
	import proto.line.m_waroffaction_buy_guarder_tos;
	import proto.line.m_waroffaction_count_down_toc;
	import proto.line.m_waroffaction_declare_toc;
	import proto.line.m_waroffaction_declare_tos;
	import proto.line.m_waroffaction_gather_confirm_toc;
	import proto.line.m_waroffaction_gather_confirm_tos;
	import proto.line.m_waroffaction_gather_factionist_toc;
	import proto.line.m_waroffaction_record_toc;
	import proto.line.m_waroffaction_record_tos;
	import proto.line.m_waroffaction_warinfo_toc;
	import proto.line.m_waroffaction_warinfo_tos;


	public class FactionsWarCase {
		private var inited:Boolean;
		private var factionView:FactionsWarView;
		private var countDown:FactionCountDownView;
		private var timer:Timer;
		private var timerLeft:int;

		public function FactionsWarCase() {
			initView();
		}

		private function initView():void {
			if (inited == false) {
				factionView=new FactionsWarView;
				factionView.addEventListener(Event.ADDED_TO_STAGE, toAskWarInfo);
				factionView.addEventListener(FactionsWarView.DECLAREWAR_EVENT, toDeclare);
				factionView.addEventListener(FactionsWarView.BUYGUARDER_EVENT, toAskBugGuard);
				factionView.addEventListener(FactionsWarView.ASKRECORD_EVENT, toAskRecord);
				countDown=new FactionCountDownView;

				if (timer == null) {
					timer=new Timer(1000, 0);
					timer.addEventListener(TimerEvent.TIMER, onTimer);
				}

				inited=true;
			}
		}

		public function getFactionWarView():FactionsWarView{
			initView();
			return factionView;
		}
		
		//打开国战主面板
		public function showFactionPaned(vo:NpcLinkVO):void {
			
		}

		public function toAskWarInfo(e:Event=null):void {
			factionView.addDataLoading();
			var vo:m_waroffaction_warinfo_tos=new m_waroffaction_warinfo_tos;
			vo.faction_id=0;
			FactionWarModule.getInstance().sendServerMessage(vo);
		}

		public function onAskWarInfo(vo:m_waroffaction_warinfo_toc):void {
			factionView.update(vo);
		}

		public function toAskBugGuard(e:ParamEvent):void {
			var guardType:int=e.data as int;
			var vo:m_waroffaction_buy_guarder_tos=new m_waroffaction_buy_guarder_tos;
			vo.guarder_type=guardType;
			FactionWarModule.getInstance().sendServerMessage(vo);
		}

		public function onAskBugGuard(vo:m_waroffaction_buy_guarder_toc):void {
			//factionView.updateGuard(vo);
			if (vo.succ) {
				toAskWarInfo();
				factionView.closeGuardView();
				Alert.show("购买成功", null, null, null, "确定", "", null, false);
			} else {
				Alert.show(vo.reason, null, null, null, "确定", "", null, false);
			}
		}

		// 同意召集
		private function gatherConfirm():void {
			var vo:m_waroffaction_gather_confirm_tos=new m_waroffaction_gather_confirm_tos;
			vo.mapid=callerMapID;
			vo.tx=callerTX;
			vo.ty=callerTY;
			FactionWarModule.getInstance().sendServerMessage(vo);
		}

		// 使用国王令返回
		private var gatherId:String="";
		private var callerMapID:int;
		private var callerTX:int;
		private var callerTY:int;

		public function onGatherFactionist(vo:m_waroffaction_gather_factionist_toc):void {
			// 纪录召集者位置
			callerMapID=vo.mapid;
			callerTX=vo.tx;
			callerTY=vo.ty;

			if (!Alert.isPopUp(gatherId)) {
				gatherId=Alert.show(vo.message, "提示", gatherConfirm);
			}
		}

		// 确认召集返回
		public function onGatherConfirm(vo:m_waroffaction_gather_confirm_toc):void {
			if (!vo.succ) {
				BroadcastSelf.logger(vo.reason);
			}
		}

		public function toDeclare(ee:ParamEvent):void {
			var faction_id:int=ee.data as int;
			var vo:m_waroffaction_declare_tos=new m_waroffaction_declare_tos;
			vo.defence_faction_id=faction_id;
			FactionWarModule.getInstance().sendServerMessage(vo);
		}

		public function onDeclare(vo:m_waroffaction_declare_toc):void {
			if (vo.return_self == true) {
				if (vo.succ) {
					factionView.resetDeclareBtn(false);
					toAskWarInfo();
//					Tips.getInstance().addTipsMsg("成功向" + SceneDataManager.getContryName(vo.defence_faction_id) + "宣战");
				} else {
					Alert.show(vo.reason, null, null, null, "确定", "", null, false);
				}
			} else { //后台给广播了
//				Tips.getInstance().addTipsMsg(SceneDataManager.getContryName(vo.attack_faction_id) + "向" + SceneDataManager.getContryName(vo.defence_faction_id) + "宣战");
			}

		}


		public function toAskRecord(e:Event):void {
			var vo:m_waroffaction_record_tos=new m_waroffaction_record_tos;
			FactionWarModule.getInstance().sendServerMessage(vo);
		}


		public function OnAskRecord(vo:m_waroffaction_record_toc):void {
			factionView.updateRecord(vo)
		}

		public function onCountDown(vo:m_waroffaction_count_down_toc):void {
			// 传送回国倒计时
			if (vo.type == 4) {
				timerLeft=vo.tick;
				onTimer();
				timer.start();
				return;
			}
			countDown.reset(vo);
		}

		private function onTimer(e:TimerEvent=null):void {
			timerLeft--;
			if (timerLeft >= 0) {
				BroadcastView.getInstance().addBroadcastMsg("国战结束，" + timerLeft + "秒后免费传送回国");
			}
		}

		// 跨地图的话清掉计时
		public function onChangeMap(mapId:int):void {
			if (mapId != 11000) {
				timer.stop();
			}
		}
	}
}