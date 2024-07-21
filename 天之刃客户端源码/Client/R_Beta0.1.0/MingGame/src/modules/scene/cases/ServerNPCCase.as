package modules.scene.cases {
	import com.events.ParamEvent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.ServerNPC;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastView;
	import modules.duplicate.views.DuplicateNPCPanel;
	import modules.duplicate.vo.ContentVO;
	import modules.duplicate.vo.TalkContentVO;
	import modules.duplicate.vo.TalkVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneDataManager;
	import modules.scene.other.ServerNPC_Panel;
	
	import proto.common.p_map_server_npc;
	import proto.line.m_server_npc_attr_change_toc;
	import proto.line.m_server_npc_dead_toc;
	import proto.line.m_server_npc_enter_toc;
	import proto.line.m_server_npc_quit_toc;
	import proto.line.m_server_npc_walk_toc;
	import proto.line.m_vie_world_fb_enter_toc;
	import proto.line.m_vie_world_fb_enter_tos;
	import proto.line.m_vie_world_fb_quit_toc;
	import proto.line.m_vie_world_fb_quit_tos;

	public class ServerNPCCase extends BaseModule {
		private var npcPanel:DuplicateNPCPanel;
		private static var _instance:ServerNPCCase;

		public function ServerNPCCase() {
		}

		public static function getInstance():ServerNPCCase {
			if (_instance == null) {
				_instance=new ServerNPCCase;
			}
			return _instance;
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}

		/**
		 * 打开讨伐敌营副本面板 
		 * @param status
		 * 
		 */		
		private function openTFDYPanel():void {
			if (npcPanel == null) {
				npcPanel = new DuplicateNPCPanel();
				npcPanel.addEventListener(DuplicateNPCPanel.SHOW_CONTENT,onShowContent);
				npcPanel.addEventListener(DuplicateNPCPanel.OTHER,onOhter);
			}
			WindowManager.getInstance().openDistanceWindow(npcPanel);
			WindowManager.getInstance().centerWindow(npcPanel);
			
			var talkVO:TalkVO = new TalkVO();
			talkVO.name = "讨伐敌营";
			talkVO.talks = new Vector.<TalkContentVO>();
			
			var talkContent:TalkContentVO = new TalkContentVO();
			talkContent.contents = new Vector.<ContentVO>();
			talkContent.type = DuplicateNPCPanel.FINISH;
			
			
			var titleContent:ContentVO = new ContentVO();
			titleContent.type = DuplicateNPCPanel.CONTENT;
			titleContent.text = "明军统领：\n" + "    敌军欲与我等争夺天下，请各位义士速速前往讨伐敌营！。";
			talkContent.contents.push(titleContent);
			
			var enterLink:ContentVO = new ContentVO();
			enterLink.type = DuplicateNPCPanel.LINK;
			enterLink.text = "进入讨伐敌营";
			enterLink.linkType = DuplicateNPCPanel.OTHER;
			enterLink.data = "enterTFDYLink";
			talkContent.contents.push(enterLink);
			
			var showLink:ContentVO = new ContentVO();
			showLink.type = DuplicateNPCPanel.LINK;
			showLink.text = "副本介绍";
			showLink.linkType = DuplicateNPCPanel.SHOW_CONTENT;
			showLink.data = "showTFDYLink";
			talkContent.contents.push(showLink);
			
			talkVO.talks.push(talkContent);
			npcPanel.talkVO = talkVO;
			
		}

		private function onShowContent(event:ParamEvent):void {
			if(event.data == "showTFDYLink"){
				var talk:TalkContentVO = new TalkContentVO();
				talk.contents = new Vector.<ContentVO>();
				talk.type = DuplicateNPCPanel.GO_BACK;
				talk.data = 0;
				
				var content:ContentVO = new ContentVO();
				content.type = DuplicateNPCPanel.CONTENT;
				content.text = "副本介绍：\n      副本定时开启，25级以上的豪杰，组成3人以上队伍即可进入。\n      完成副本可获得大量经验、材料、宝石奖励。";
				talk.contents.push(content);
				npcPanel.wrapperTalk(talk);
			}
		}
		
		private function onOhter(event:ParamEvent):void {
			if(event.data == "enterTFDYLink"){
				toRequestEnter();
			}
		}
		
		public function onNPCEnter(vo:m_server_npc_enter_toc):void {
			if (SceneDataManager.isGaming == false) {
				return; //忽略，切地图map_enter_toc之前，后台莫名发这消息过来
			}
			for (var i:int=0; i < vo.server_npcs.length; i++) {
				serverNPCEnter(vo.server_npcs[i]);
			}
		}

		private function serverNPCEnter(vo:p_map_server_npc):void {
			var item:ServerNPC=SceneUnitManager.getUnit(vo.npc_id, SceneUnitType.SERVER_NPC_TYPE) as ServerNPC;
			if (item == null) {
				item=new ServerNPC;
				item.reset(vo);
				view.addUnit(item, vo.pos.tx, vo.pos.ty);
			} else {
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.tx, 0, vo.pos.ty));
				item.x=p.x;
				item.y=p.y;
				if (item.parent == null) {
					view.midLayer.addChild(item);
				}
			}
		}

		public function onNPCQuit(vo:m_server_npc_quit_toc):void {
			setTimeout(npcQuit, 2000, vo);
		}

		private function npcQuit(vo:m_server_npc_quit_toc):void {
			for (var i:int=0; i < vo.npc_ids.length; i++) {
				view.removeUnit(vo.npc_ids[i], SceneUnitType.SERVER_NPC_TYPE);
			}
		}

		private var npc_id:int;
		private var type_id:int;
		public function toOpenPanel(npc_id:int, type_id:int):void {
			this.npc_id = npc_id;
			this.type_id = type_id;
			openTFDYPanel();
		}

		public function toRequestEnter():void {
			var vo:m_vie_world_fb_enter_tos=new m_vie_world_fb_enter_tos;
			vo.npc_id=npc_id;
			vo.type_id=type_id;
			sendSocketMessage(vo);
		}

		public function onVIEEnter(vo:m_vie_world_fb_enter_toc):void {
			if (vo.succ) {
				BroadcastView.getInstance().addBroadcastMsg("进入讨伐敌营");
				if (npcPanel != null) {
					npcPanel.closeWindow();
				}
				SceneDataManager.monster_types=vo.monster_type_ids;
			} else {
				BroadcastView.getInstance().addBroadcastMsg(vo.reason);
			}
		}

		public function toQuitMap(npcLinkVO:NpcLinkVO):void {
			if (SceneDataManager.mapData.map_id == 10400) {
				var vo:m_vie_world_fb_quit_tos=new m_vie_world_fb_quit_tos;
				sendSocketMessage(vo);
			}
		}

		public function onQuitMap(vo:m_vie_world_fb_quit_toc):void {
			if (vo.succ) {
				BroadcastView.getInstance().addBroadcastMsg("退出讨伐敌营");
			} else {
				BroadcastView.getInstance().addBroadcastMsg("退出讨伐敌营失败");
			}
		}

		public function onAttrChanged(vo:m_server_npc_attr_change_toc):void {

		}

		public function onWalk(vo:m_server_npc_walk_toc):void {
			if (SceneDataManager.isGaming == false) {
				return;
			}
			var serverNPC:ServerNPC=SceneUnitManager.getUnit(vo.server_npc_info.npc_id, SceneUnitType.SERVER_NPC_TYPE) as ServerNPC;
			if (serverNPC != null) {
				serverNPC.speed=vo.server_npc_info.move_speed;
				var arr:Array=[new Pt(vo.pos.tx, 0, vo.pos.ty)];
				serverNPC.run(arr);
			} else {
				serverNPC=new ServerNPC();
				serverNPC.reset(vo.server_npc_info);
				view.addUnit(serverNPC, vo.pos.tx, vo.pos.ty, vo.pos.dir);
			}
		}

		public function onWalkPath():void {

		}

		public function onDead(vo:m_server_npc_dead_toc):void {
			var serverNPC:ServerNPC=SceneUnitManager.getUnit(vo.npc_id, SceneUnitType.SERVER_NPC_TYPE) as ServerNPC;
			if (serverNPC != null) {
				serverNPC.isDead=true;
				serverNPC.runEnd=true;
				LoopManager.setTimeout(delayDie, 460, [serverNPC]);
				updateSeleteRole(serverNPC.pvo, false);
			}
		}

		private function delayDie(tar:ServerNPC):void {
			if (tar.parent != null) {
				tar.parent.removeChild(tar);
				view.lowEffLayer.addChild(tar);
			}
			tar.die();
		}

		private function updateSeleteRole(vo:p_map_server_npc, visible:Boolean):void {
			var seletedVo:SeletedRoleVo=RoleStateDateManager.seletedUnit;
			var rolevo:SeletedRoleVo=new SeletedRoleVo();
			rolevo.setupServerNPC(vo);
			if (seletedVo != null && vo.npc_id == seletedVo.id && seletedVo.unit_type == SceneUnitType.SERVER_NPC_TYPE) {
				this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {'see': visible, 'vo': rolevo});
			}
		}

		override protected function initListeners():void {
			addMessageListener(NPCActionType.NA_22, toQuitMap);
			/////////////////////////////
			addSocketListener(SocketCommand.SERVER_NPC_ENTER, onNPCEnter); //后台NPC进入
			addSocketListener(SocketCommand.VIE_WORLD_FB_QUIT, onQuitMap); //后台NPC退出副本（讨伐敌营）
			addSocketListener(SocketCommand.SERVER_NPC_ATTR_CHANGE, onAttrChanged); //后台NPC数据改变
			addSocketListener(SocketCommand.SERVER_NPC_WALK, onWalk); //后台NPC走路
			addSocketListener(SocketCommand.SERVER_NPC_DEAD, onDead); //后台NPC死亡
			addSocketListener(SocketCommand.SERVER_NPC_QUIT, onNPCQuit); //后台NPC退出
			addSocketListener(SocketCommand.VIE_WORLD_FB_ENTER, onVIEEnter); //讨伐敌营NPC进入
		}
	}
}