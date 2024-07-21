package modules.familyCollect {
	import com.Message;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.tile.Pt;
	import com.utils.PathUtil;

	import flash.filters.ColorMatrixFilter;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.familyCollect.views.FamilyCollectPrizeView;
	import modules.familyCollect.views.FamilyCollectScoreView;
	import modules.mission.MissionModule;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;

	import proto.line.m_family_collect_begin_toc;
	import proto.line.m_family_collect_get_prize_toc;
	import proto.line.m_family_collect_info_toc;
	import proto.line.m_family_collect_prize_info_toc;
	import proto.line.m_family_collect_prize_info_tos;
	import proto.line.m_family_collect_refresh_prize_toc;


	public class FamilyCollectModule extends BaseModule {
		private static var _instance:FamilyCollectModule;
		private var scoreView:FamilyCollectScoreView;
		private var prizeView:FamilyCollectPrizeView;

		public function FamilyCollectModule() {
			if (_instance != null) {
				throw new Error("PetModule只能存在一个实例。");
			}
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.FAMILY_COLLECT_PRIZE, toOpenPrizeView);
			addMessageListener(NPCActionType.NA_93, toOpenPrizeView);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);

			addSocketListener(SocketCommand.FAMILY_COLLECT_BEGIN, onBegin);
			addSocketListener(SocketCommand.FAMILY_COLLECT_GET_PRIZE, OnGetPrize);
			addSocketListener(SocketCommand.FAMILY_COLLECT_INFO, onInfo);
			addSocketListener(SocketCommand.FAMILY_COLLECT_PRIZE_INFO, onPrizeInfo);
			addSocketListener(SocketCommand.FAMILY_COLLECT_REFRESH_PRIZE, onRefreshPrize);

		}

		public function send(vo:Message):void {
			sendSocketMessage(vo);
		}

		public static function getInstance():FamilyCollectModule {
			if (_instance == null) {
				_instance=new FamilyCollectModule;
			}
			return _instance;
		}

		private function onBegin(vo:m_family_collect_begin_toc=null):void {
			if (scoreView == null)
				scoreView=new FamilyCollectScoreView();
			if (SceneDataManager.isFamilyMap) {
				var vo2:m_family_collect_info_toc=new m_family_collect_info_toc();
				vo2.left_tick=vo.left_tick;
				scoreView.update(vo2);
			}
			Prompt.show("雨后初霁，春笋丛生。请各帮众前往门派地图采集(击杀本活动怪物不扣精力值)。作为回报，长老将奖励大量经验！", "门派长老的号召", transToNpc, searchToNpc, "使用传送卷传送", "寻路到门派管理员", null, true, true);
		}

		private function OnGetPrize(vo:m_family_collect_get_prize_toc):void {
			if (vo.succ) {
				prizeView.update();
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function onInfo(vo:m_family_collect_info_toc):void {
			if (scoreView == null)
				scoreView=new FamilyCollectScoreView();
			scoreView.update(vo);
			if (scoreView.parent == null) {
				dispatch(ModuleCommand.MISSION_HIDE_FOLLOW_VIEW);
				LayerManager.windowLayer.addChild(scoreView);
				dispatch(ModuleCommand.MISSION_HIDE_FOLLOW_VIEW);
			}
		}

		private function onPrizeInfo(vo:m_family_collect_prize_info_toc):void {
			if (prizeView == null)
				prizeView=new FamilyCollectPrizeView();
			prizeView.update(vo.info);
		}

		private function onRefreshPrize(vo:m_family_collect_refresh_prize_toc):void {
			if (prizeView == null)
				prizeView=new FamilyCollectPrizeView();
			if (vo.succ) {
				prizeView.update(vo.info);
				dispatch(ModuleCommand.BROADCAST_SELF, "成功将奖励刷为" + prizeView.getColorCNStr(vo.info.color));
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function transToNpc():void {
			PathUtil.carry(10300, new Pt(44, 0, 15), PathUtil.MAP_TRANSFER_TYPE_NORMAL);
		}

		private function searchToNpc():void {
			var factionId:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String="";

			if (factionId == 1) {
				npcId="11100120";
			} else if (factionId == 2) {
				npcId="12100120";
			} else if (factionId == 3) {
				npcId="13100120";
			} else {
				return;
			}
			PathUtil.findNpcAndOpen(npcId);
		}

		private function toOpenPrizeView(link:NpcLinkVO=null):void {
			if (prizeView == null)
				prizeView=new FamilyCollectPrizeView();
			WindowManager.getInstance().popUpWindow(prizeView);
			WindowManager.getInstance().centerWindow(prizeView);
			var vo:m_family_collect_prize_info_tos=new m_family_collect_prize_info_tos();
			sendSocketMessage(vo);
		}

		private function onStageResize(value:Object):void {
			if (scoreView)
				scoreView.onStageResize();

		}

	}
}