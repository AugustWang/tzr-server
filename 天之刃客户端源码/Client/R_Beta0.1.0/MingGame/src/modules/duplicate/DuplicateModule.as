package modules.duplicate {
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameParameters;
	import com.loaders.queueloader.QueueEvent;
	import com.loaders.queueloader.QueueLoader;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.tile.Hash;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.PathUtil;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.duplicate.views.DuplicateAwardView;
	import modules.duplicate.views.DuplicateListView;
	import modules.duplicate.views.DuplicateMemberView;
	import modules.duplicate.views.DuplicateNPCPanel;
	import modules.duplicate.views.vo.DuplicateAwardVO;
	import modules.duplicate.views.vo.DuplicateLeaderVO;
	import modules.duplicate.vo.ContentVO;
	import modules.duplicate.vo.TalkContentVO;
	import modules.duplicate.vo.TalkVO;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.GeneralVO;
	import modules.scene.SceneDataManager;
	
	import proto.common.p_educate_fb_item;
	import proto.line.m_educate_fb_award_toc;
	import proto.line.m_educate_fb_award_tos;
	import proto.line.m_educate_fb_enter_toc;
	import proto.line.m_educate_fb_enter_tos;
	import proto.line.m_educate_fb_gambling_toc;
	import proto.line.m_educate_fb_gambling_tos;
	import proto.line.m_educate_fb_item_toc;
	import proto.line.m_educate_fb_item_tos;
	import proto.line.m_educate_fb_query_toc;
	import proto.line.m_educate_fb_query_tos;
	import proto.line.m_educate_fb_quit_toc;
	import proto.line.m_educate_fb_quit_tos;

	public class DuplicateModule extends BaseModule {
		private static var _instance:DuplicateModule;

		public function DuplicateModule() {

		}

		public static function getInstance():DuplicateModule {
			if (_instance == null)
				_instance = new DuplicateModule();
			return _instance;
		}

		override protected function initListeners():void {
			//服务端消息
			this.addSocketListener(SocketCommand.EDUCATE_FB_ENTER,doEducateFbEnterToc);
			this.addSocketListener(SocketCommand.EDUCATE_FB_QUIT,doEducateFbQuitToc);
			this.addSocketListener(SocketCommand.EDUCATE_FB_GAMBLING,doEducateFbGamblingToc);
			this.addSocketListener(SocketCommand.EDUCATE_FB_QUERY,doEducateFbQueryToc);
			this.addSocketListener(SocketCommand.EDUCATE_FB_AWARD,doEducateFbAwardToc);
			this.addSocketListener(SocketCommand.EDUCATE_FB_ITEM,doEducateFbItemToc);
			//模块消息
			this.addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY,doChangeMapRoleReady); //切换地图
			this.addMessageListener(ModuleCommand.USE_EDUCATE_FB_LEADER_ITEM,doUseEducateFbLeaderItem);
			this.addMessageListener(ModuleCommand.USE_EDUCATE_FB_MEMBER_ITEM,doUseEducateFbMemberItem);
		}

		private function wrapper(name:String):String {
			return DuplicateConstant.DUPLICATE + "_" + name;
		}

		private var curNpcId:int;

		/**
		 * 点击师门副本相关NPC的操作界面
		 * @param vo
		 *
		 */
		public function doMouseClickNpc(npcId:int):void {
			this.curNpcId = npcId;
			if (npcId == 11100131 || npcId == 12100131 || npcId == 13100131) {
				//进入师门副本NPC对话界面
				//发消息查询当前玩家的副本状态
				var queryvo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
				queryvo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_OPEN;
				this.sendSocketMessage(queryvo);
			} else if (npcId == 10600100) {
				//退出师门副本NPC对话同
				this.openQuitNPCPanel();
			} else {

			}
		}
		/**
		 * 师徒副本传着NPC对话内容
		 */
		private var npcPanel:DuplicateNPCPanel;
		private var isAutoOpenAwardNPCPanel:Boolean = false;

		private function openQuitNPCPanel():void {
			if (npcPanel == null) {
				npcPanel = new DuplicateNPCPanel();
				npcPanel.addEventListener(DuplicateNPCPanel.SHOW_CONTENT,onShowContent);
				npcPanel.addEventListener(DuplicateNPCPanel.OTHER,onOhter);
			}
			WindowManager.getInstance().openDistanceWindow(npcPanel);
			WindowManager.getInstance().centerWindow(npcPanel);

			var talkVO:TalkVO = new TalkVO();
			talkVO.name = "副本传送者";
			talkVO.talks = new Vector.<TalkContentVO>();

			var talkContent:TalkContentVO = new TalkContentVO();
			talkContent.contents = new Vector.<ContentVO>();
			talkContent.type = DuplicateNPCPanel.FINISH;

			var titleContent:ContentVO = new ContentVO();
			titleContent.type = DuplicateNPCPanel.CONTENT;
			titleContent.text = "副本传送者：\n \t\t你已打败“挑衅者”，证明你的实力吧！";
			talkContent.contents.push(titleContent);

			var quitLink:ContentVO = new ContentVO();
			quitLink.type = DuplicateNPCPanel.LINK;
			quitLink.text = "离开师门副本";
			quitLink.linkType = DuplicateNPCPanel.OTHER;
			quitLink.data = "quitLink";
			talkContent.contents.push(quitLink);

			talkVO.talks.push(talkContent);
			npcPanel.talkVO = talkVO;
		}

		private function openEnterNPCPanel(status:int):void {
			if (npcPanel == null) {
				npcPanel = new DuplicateNPCPanel();
				npcPanel.addEventListener(DuplicateNPCPanel.SHOW_CONTENT,onShowContent);
				npcPanel.addEventListener(DuplicateNPCPanel.OTHER,onOhter);
				npcPanel.addEventListener(DuplicateNPCPanel.FINISH,onFinish);
			}
			WindowManager.getInstance().openDistanceWindow(npcPanel);
			WindowManager.getInstance().centerWindow(npcPanel);

			var talkVO:TalkVO = new TalkVO();
			talkVO.name = "师徒副本传送者";
			talkVO.talks = new Vector.<TalkContentVO>();

			var talkContent:TalkContentVO = new TalkContentVO();
			talkContent.contents = new Vector.<ContentVO>();
			talkContent.type = DuplicateNPCPanel.FINISH;


			var titleContent:ContentVO = new ContentVO();
			titleContent.type = DuplicateNPCPanel.CONTENT;
			titleContent.text = "师徒副本传送者：\n" + "    ≧15级，和同师门内其他玩家组成2-6人的队伍，即可挑战师徒同心副本；完成副本还有机会获得稀有灵石。\n" + "    （师门关系：队长的师傅、师祖、同门、徒弟、徒孙）\n" +
				"    每天可挑战次数：2次";
			talkContent.contents.push(titleContent);

			if (status == 1) {
				var awardLink:ContentVO = new ContentVO();
				awardLink.type = DuplicateNPCPanel.LINK;
				awardLink.text = "领取副本奖励";
				awardLink.linkType = DuplicateNPCPanel.OTHER;
				awardLink.data = "awardLink";
				talkContent.contents.push(awardLink);
			} else {
				var enterLink:ContentVO = new ContentVO();
				enterLink.type = DuplicateNPCPanel.LINK;
				enterLink.text = "挑战师门同心副本";
				enterLink.linkType = DuplicateNPCPanel.OTHER;
				enterLink.data = "enterLink";
				talkContent.contents.push(enterLink);
			}

			var showLink:ContentVO = new ContentVO();
			showLink.type = DuplicateNPCPanel.LINK;
			showLink.text = "副本介绍";
			showLink.linkType = DuplicateNPCPanel.SHOW_CONTENT;
			showLink.data = "showLink";
			talkContent.contents.push(showLink);

			talkVO.talks.push(talkContent);
			npcPanel.talkVO = talkVO;

		}
		
		/**
		 * 显示师徒副本NPC对话内容处理
		 * @param event
		 *
		 */
		private function onShowContent(event:ParamEvent):void {
			if (event.data == "showLink") {
				var talk:TalkContentVO = new TalkContentVO();
				talk.contents = new Vector.<ContentVO>();
				talk.type = DuplicateNPCPanel.GO_BACK;
				talk.data = 0;

				var content:ContentVO = new ContentVO();
				content.type = DuplicateNPCPanel.CONTENT;
				content.text = "我想挑战：\n" + "等级≥15，组成2人以上队伍，且队伍中有和自己同师门的人即可挑战。\n" + "我想查看师门：\n" + "按O打开『社会』，点击“师徒”即可查看师门。\n" +
					"我想拜师：\n" + "10级后，和有导师称号的玩家组成队伍，到李梦阳处可结为师徒。\n" + "我想收徒：\n" + "25级后，到李梦阳处获得导师称号，即可收徒。";
				talk.contents.push(content);
				npcPanel.wrapperTalk(talk);
			}
		}
		/**
		 * 是否可以点击挑战副本链接
		 */
		private var isClickEnterLink:Boolean = false;

		/**
		 * 其它链接事件
		 * @param event
		 *
		 */
		private function onOhter(event:ParamEvent):void {
			if (event.data == "enterLink") {
				if (!this.isClickEnterLink) {
					if (this.npcPanel != null && WindowManager.getInstance().isPopUp(this.npcPanel)) {
						WindowManager.getInstance().removeWindow(this.npcPanel);
					}
					this.isClickEnterLink = true;
					var enterVo:m_educate_fb_enter_tos = new m_educate_fb_enter_tos;
					enterVo.npc_id = this.getEnterFbNpcId();
					enterVo.map_id = SceneDataManager.mapData.map_id;
					this.sendSocketMessage(enterVo);
				} else {
					Tips.getInstance().addTipsMsg("你已经点击了“挑战师门同心副本”，请稍后再点操作！");
				}
			}
			if (event.data == "awardLink") {
				var vo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
				vo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_AWARD_VIEW;
				this.sendSocketMessage(vo);
			}
			if (event.data == "quitLink") {
				var quitVo:m_educate_fb_quit_tos = new m_educate_fb_quit_tos;
				quitVo.map_id = SceneDataManager.mapData.map_id;
				quitVo.npc_id = this.curNpcId;
				this.sendSocketMessage(quitVo);
				if (this.npcPanel != null && WindowManager.getInstance().isPopUp(this.npcPanel)) {
					WindowManager.getInstance().removeWindow(this.npcPanel);
				}
			}
		}

		/**
		 * 关闭师徒副本NPC对话窗口事件
		 * @param event
		 *
		 */
		private function onFinish(event:ParamEvent):void {
			if (awardPanel != null) {
				if (WindowManager.getInstance().isPopUp(awardPanel)) {
					WindowManager.getInstance().removeWindow(awardPanel);
				}
				awardPanel = null;
			}
		}
		private var leaderPanel:DuplicateListView;

		/**
		 * 打开队长帮助界面
		 * @param itemVoList
		 *
		 */
		private function openLeaderView(itemVoList:Array):void {
			if (leaderPanel == null) {
				leaderPanel = new DuplicateListView();
				leaderPanel.addEventListener(DuplicateConstant.LEADER_EVENT,onLeaderEvent);
			}
			this.leaderPanel.dataProvider = itemVoList;
			if (!WindowManager.getInstance().isPopUp(leaderPanel)) {
				WindowManager.getInstance().popUpWindow(leaderPanel);
				WindowManager.getInstance().centerWindow(leaderPanel);
			}
			MessageIconManager.getInstance().stopFlickTeamLeaderIcon();
		}

		/**
		 * 队长帮助界面事件处理
		 * @param event
		 *
		 */
		private function onLeaderEvent(event:ParamEvent):void {
			if (SceneDataManager.mapData.map_id == 10600) {
				var eventData:Object = event.data;
				if (eventData.type == DuplicateConstant.GO_TO) {
					var gotoVo:DuplicateLeaderVO = eventData.data as DuplicateLeaderVO;
					if (gotoVo.status == 1) {
						Tips.getInstance().addTipsMsg("此道具已经使用");
					} else {
						if (gotoVo.role_id == gotoVo.cur_use_role_id) {
							gotoEducateFbMap(gotoVo.use_tx,gotoVo.use_ty);
							var gotoPVo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
							gotoPVo.item_id = gotoVo.item_id;
							gotoPVo.use_role_id = gotoVo.cur_use_role_id;
							gotoPVo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_NOTICE;
							this.sendSocketMessage(gotoPVo);
						} else {
							Tips.getInstance().addTipsMsg("当前轮到[".concat(gotoVo.cur_role_name).concat("]").concat("使用道具召唤“挑衅者”"));
						}
					}
				}
				if (eventData.type == DuplicateConstant.LEADER_EVENT_NOTICE) {
					var cmdVo:DuplicateLeaderVO = eventData.data as DuplicateLeaderVO;
					if (cmdVo.status == 1) {
						Tips.getInstance().addTipsMsg("此队员已经提醒");
					} else {
						if (cmdVo.role_id == cmdVo.cur_use_role_id) {
							gotoEducateFbMap(cmdVo.use_tx,cmdVo.use_ty);
							var cmdPVo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
							cmdPVo.item_id = cmdVo.item_id;
							cmdPVo.use_role_id = cmdVo.cur_use_role_id;
							cmdPVo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_NOTICE;
							this.sendSocketMessage(cmdPVo);
						} else {
							Tips.getInstance().addTipsMsg("当前应该提醒[".concat(cmdVo.cur_role_name).concat("]"));
						}
					}
				}
			}
		}

		/**
		 * 师徒副本内寻路操作
		 * @param tx
		 * @param ty
		 *
		 */
		private function gotoEducateFbMap(tx:int,ty:int):void {
			PathUtil.goto(10600,new Pt(tx,0,ty));
		}
		private var awardPanel:DuplicateAwardView;

		/**
		 * 领取奖励界面
		 * @param awardVo
		 *
		 */
		private function openAwardNPCPanel(awardVo:DuplicateAwardVO):void {
			if (awardPanel == null) {
				awardPanel = new DuplicateAwardView()
				awardPanel.addEventListener(DuplicateConstant.AWARD_EVENT,onAwardEvent);
			}
			awardPanel.awardData = awardVo;
			if (!WindowManager.getInstance().isPopUp(awardPanel)) {
				WindowManager.getInstance().openDistanceWindow(awardPanel);
				WindowManager.getInstance().centerWindow(awardPanel);
			}
		}

		/**
		 * 获取进入副本的npc id
		 * @return
		 *
		 */
		private function getEnterFbNpcId():int {
			var npcId:int = 0;
			if (this.curNpcId != 0 && (this.curNpcId == 11100131 || this.curNpcId == 12100131 || this.curNpcId == 13100131)) {
				npcId = this.curNpcId;
			} else {
				if (GlobalObjectManager.getInstance().user.base.faction_id == 1) {
					npcId = 11100131
				}
				if (GlobalObjectManager.getInstance().user.base.faction_id == 2) {
					npcId = 12100131
				}
				if (GlobalObjectManager.getInstance().user.base.faction_id == 3) {
					npcId = 13100131
				}
			}
			return npcId;
		}

		/**
		 * 领取奖励界面事件处理
		 * @param event
		 *
		 */
		private function onAwardEvent(event:ParamEvent):void {
			var eventData:Object = event.data;
			//刷新积分 
			if (eventData.type == DuplicateConstant.AWARD_EVENT_REFRESH_COUNT) {
				var refreshVo:m_educate_fb_gambling_tos = new m_educate_fb_gambling_tos;
				refreshVo.map_id = SceneDataManager.mapData.map_id;
				refreshVo.npc_id = this.getEnterFbNpcId();
				this.sendSocketMessage(refreshVo);
			}
			//领取奖励 
			if (eventData.type == DuplicateConstant.AWARD_EVENT_AWARD_GOODS) {
				var awardVo:m_educate_fb_award_tos = new m_educate_fb_award_tos;
				awardVo.map_id = SceneDataManager.mapData.map_id;
				awardVo.npc_id = this.getEnterFbNpcId();
				this.sendSocketMessage(awardVo);
			}
		}

		private function doEducateFbEnterToc(vo:m_educate_fb_enter_toc):void {
			this.isClickEnterLink = false;
			if (vo.return_self) {
				if (vo.succ) {
					Tips.getInstance().addTipsMsg("进入师徒副本地图");
					SceneDataManager.monster_types = vo.monster_type_ids;
				} else {
					Tips.getInstance().addTipsMsg(vo.reason);
				}
			} else {
				if (vo.succ) {
					Tips.getInstance().addTipsMsg("进入师徒副本地图");
					SceneDataManager.monster_types = vo.monster_type_ids;
				} else {
					Tips.getInstance().addTipsMsg(vo.reason);
				}
			}
		}

		private function doEducateFbQuitToc(vo:m_educate_fb_quit_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("离开师徒副本图");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		/**
		 * 玩家切换场景师徒副本模块相关处理
		 *
		 */
		private function doChangeMapRoleReady():void {
			if (SceneDataManager.mapData.map_id == 10600) {
				//玩家进入师徒副本，如果是队长，即需要自动打开副本队长提示界面
				var goodsArray:Array = PackManager.getInstance().getGoodsByType(10100022);
				if (goodsArray != null && goodsArray.length > 0) {
					var sortGoodsArray:Array = goodsArray.sortOn("oid",Array.NUMERIC);
					var generalVO:GeneralVO = sortGoodsArray[sortGoodsArray.length - 1] as GeneralVO;
					var vo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
					vo.item_id = 10100022;
					vo.goods_id = generalVO.oid;
					vo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM_INIT;
					this.sendSocketMessage(vo);
					MessageIconManager.getInstance().showTeamLeaderIcon(onClickTeamLeaderIcon);
				}
				this.isAutoOpenAwardNPCPanel = true;
			} else {
				if (leaderPanel != null) {
					if (WindowManager.getInstance().isPopUp(leaderPanel)) {
						WindowManager.getInstance().removeWindow(leaderPanel);
					}
					leaderPanel == null;
				}
				if (this.memberView != null) {
					if (WindowManager.getInstance().isPopUp(memberView)) {
						WindowManager.getInstance().removeWindow(memberView);
					}
					memberView == null;
				}
				if (this.memberUseItemAlert != null) {
					this.memberUseItemAlert = "";
				}
				// 喷图
				this.removeDuplicateIcon();
				//ICON重构				MessageIconManager.removeTeamLeaderIcon();
				if (this.isAutoOpenAwardNPCPanel && (SceneDataManager.mapData.map_id == 11100 || SceneDataManager.mapData.
					map_id == 12100 || SceneDataManager.mapData.map_id == 13100)) {
					//需要自动打开师徒副本领取界面 加入判断是否存NPC附近
					var enterNpcId:int = this.getEnterFbNpcId();
					if (enterNpcId != 0) {
						var npc:NPC = NPCTeamManager.getNPC(enterNpcId);
						var d:int = ScenePtMath.checkDistance(npc.index,SceneDataManager.getMyPostion().pt);
						if (d <= 10) {
							var queryvo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
							queryvo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_OPEN;
							this.sendSocketMessage(queryvo);
						}
					}
				} else {
					this.isAutoOpenAwardNPCPanel = false;
				}
			}
			if (SceneDataManager.mapData.map_id != 10600 && SceneDataManager.mapData.map_id != 11100 && SceneDataManager.
				mapData.map_id != 12100 && SceneDataManager.mapData.map_id != 13100) {
				if (this.npcPanel != null) {
					if (WindowManager.getInstance().isPopUp(npcPanel)) {
						WindowManager.getInstance().removeWindow(npcPanel);
					}
					this.npcPanel = null;
				}
			}
		}

		/**
		 * 队长双击队长图标处理
		 *
		 */
		private function onClickTeamLeaderIcon():void {
			var goodsArray:Array = PackManager.getInstance().getGoodsByType(10100022);
			if (goodsArray != null && goodsArray.length > 0) {
				var sortGoodsArray:Array = goodsArray.sortOn("oid",Array.NUMERIC);
				var generalVO:GeneralVO = sortGoodsArray[sortGoodsArray.length - 1] as GeneralVO;
				var vo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
				vo.item_id = 10100022;
				vo.goods_id = generalVO.oid;
				vo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM;
				this.sendSocketMessage(vo);
				MessageIconManager.getInstance().stopFlickTeamLeaderIcon();
			}
			if (goodsArray == null || !(goodsArray.length > 0)) {
				Tips.getInstance().addTipsMsg("【队长令牌】已经被丢弃，无法打开队长界面");
			}
		}

		/**
		 * 队长双击击队长令牌处理
		 * @param itemVo
		 *
		 */
		private function doUseEducateFbLeaderItem(itemVo:GeneralVO):void {
			if (SceneDataManager.mapData.map_id == 10600) {
				var vo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
				vo.item_id = itemVo.typeId;
				vo.goods_id = itemVo.oid;
				vo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM;
				this.sendSocketMessage(vo);
			} else {
				Tips.getInstance().addTipsMsg("此道具只能在师徒副本地图使用");
			}
		}

		/**
		 * 队员使用副本道具处理
		 * @param itemVo
		 *
		 */
		private function doUseEducateFbMemberItem(itemVo:GeneralVO):void {
			if (SceneDataManager.mapData.map_id == 10600) {
				var vo:m_educate_fb_item_tos = new m_educate_fb_item_tos;
				vo.item_id = itemVo.typeId;
				vo.goods_id = itemVo.oid;
				this.sendSocketMessage(vo);
			} else {
				Tips.getInstance().addTipsMsg("此道具只能在师徒副本地图使用");
			}
		}

		private function doEducateFbItemToc(vo:m_educate_fb_item_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("“挑衅者”已经出现，请速度围剿");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		/**
		 * 玩家领取副本奖励处理
		 * @param vo
		 *
		 */
		private function doEducateFbAwardToc(vo:m_educate_fb_award_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("领取奖励成功");
				if (awardPanel != null) {
					if (WindowManager.getInstance().isPopUp(awardPanel)) {
						WindowManager.getInstance().removeWindow(awardPanel);
					}
					awardPanel = null;
				}
				this.openEnterNPCPanel(0);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function doEducateFbGamblingToc(vo:m_educate_fb_gambling_toc):void {
			if (vo.succ) {
				if (awardPanel != null) {
					var awardData:DuplicateAwardVO = awardPanel.awardData;
					awardData.luckyCount = vo.lucky_count;
					awardData.awardGoodsArray = vo.award_goods;
					awardPanel.awardData = awardData;
					BroadcastSelf.logger("<font color='#3BE450'>重置奖励成功，扣费 " + vo.fee.toString() + " 元宝</font>");
					if (!WindowManager.getInstance().isPopUp(awardPanel)) {
						WindowManager.getInstance().openDistanceWindow(awardPanel);
						WindowManager.getInstance().centerWindow(awardPanel);
					}
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		private var memberView:DuplicateMemberView;
		private var memberUseItemAlert:String = "";

		private function doEducateFbQueryToc(vo:m_educate_fb_query_toc):void {
			if (vo.return_self && vo.op_type == DuplicateConstant.EDUCATE_FB_OP_TYPE_OPEN) {
				if (vo.status == 2) {
					this.openEnterNPCPanel(1);
					if (this.isAutoOpenAwardNPCPanel) {
						var awardViewOpenVo:m_educate_fb_query_tos = new m_educate_fb_query_tos;
						awardViewOpenVo.op_type = DuplicateConstant.EDUCATE_FB_OP_TYPE_AWARD_VIEW;
						this.sendSocketMessage(awardViewOpenVo);
					}
				} else {
					this.openEnterNPCPanel(0);
				}
				this.isAutoOpenAwardNPCPanel = false;
			}
			if (vo.return_self && (vo.op_type == DuplicateConstant.EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM_INIT || vo.op_type ==
				DuplicateConstant.EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM) && GlobalObjectManager.getInstance().user.base.role_id ==
				vo.leader_role_id) {
				if (vo.succ) {
					if (vo.fb_items != null) {
						var data:Array = [];
						var fbItemArray:Array = vo.fb_items.sortOn("item_id",Array.NUMERIC);
						var curUseItemFlag:Boolean = false;
						var curUseRoleId:int = 0;
						var curUseRoleName:String = "";
						for (var i:int = 0;i < fbItemArray.length;i++) {
							var fbItem:p_educate_fb_item = fbItemArray[i];
							if (fbItem.status != 1 && fbItem.status != 2 && !curUseItemFlag) {
								curUseItemFlag = true;
								curUseRoleId = fbItem.role_id;
								curUseRoleName = fbItem.role_name;
							}
						}
						for (i = 0;i < fbItemArray.length;i++) {
							fbItem = fbItemArray[i];
							var itemVo:DuplicateLeaderVO = new DuplicateLeaderVO;
							itemVo.index = i + 1;
							itemVo.item_id = fbItem.item_id;
							itemVo.role_id = fbItem.role_id;
							itemVo.role_name = fbItem.role_name;
							itemVo.use_tx = fbItem.use_tx;
							itemVo.use_ty = fbItem.use_ty;
							itemVo.status = fbItem.status;
							itemVo.cur_role_name = curUseRoleName;
							itemVo.cur_use_role_id = curUseRoleId;
							data[i] = itemVo;
						}
						this.openLeaderView(data);
					} else {
						this.openLeaderView([]);
					}
					if (vo.all_fb_items != null && vo.op_type == DuplicateConstant.EDUCATE_FB_OP_TYPE_USE_LEADER_ITEM_INIT) {
						var allFbItemArray:Array = vo.all_fb_items.sortOn("item_id",Array.NUMERIC);
						var posArray:Array = [];
						for (i = 0;i < allFbItemArray.length;i++) {
							var allFbItem:p_educate_fb_item = allFbItemArray[i];
							posArray[i] = {id: i + 1,tx: allFbItem.use_tx,ty: allFbItem.use_ty};
						}
						// 喷图
						this.showDuplicateIcon(posArray);
					}
				} else {
					Tips.getInstance().addTipsMsg(vo.reason);
				}
			}
			if (vo.return_self && vo.op_type == DuplicateConstant.EDUCATE_FB_OP_TYPE_AWARD_VIEW) {
				if (vo.status == 2) {
					var awardVo:DuplicateAwardVO = new DuplicateAwardVO;
					awardVo.count = vo.count;
					awardVo.luckyCount = vo.lucky_count;
					awardVo.maxLuckyCount = vo.max_lucky_count;
					awardVo.awardGoodsArray = vo.award_goods;
					awardVo.awardConfigArray = vo.fb_award_config;
					this.openAwardNPCPanel(awardVo);
				} else {
					this.openEnterNPCPanel(0);
				}
			}
			if (vo.return_self && vo.op_type == DuplicateConstant.EDUCATE_FB_OP_TYPE_NOTICE) {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			if (!vo.return_self && vo.op_type == DuplicateConstant.EDUCATE_FB_OP_TYPE_NOTICE) {
				if (SceneDataManager.mapData.map_id == 10600) {
					if (this.memberView == null) {
						this.memberView = new DuplicateMemberView();
						this.memberView.addEventListener(DuplicateConstant.MEMBER_EVENT,onMemberEvent);
					}
					this.memberView.updateData(vo.use_tx,vo.use_ty);
					if (!WindowManager.getInstance().isPopUp(this.memberView)) {
						WindowManager.getInstance().openDistanceWindow(this.memberView);
						WindowManager.getInstance().centerWindow(this.memberView);
					}
					vo.all_fb_items.sortOn("item_id",Array.NUMERIC);
					var memberPosArray:Array = [];
					for (var im:int = 0;im < vo.all_fb_items.length;im++) {
						if (vo.all_fb_items[im].item_id == vo.item_id) {
							memberPosArray[im] = {id: im + 1,tx: vo.all_fb_items[im].use_tx,ty: vo.all_fb_items[im].use_ty};
						}
					}
					// 喷图
					this.showDuplicateIcon(memberPosArray);
				}
			}
			if (!vo.return_self && vo.op_type == DuplicateConstant.EDUCATE_FB_OP_TYPE_NOTICE_USE) {
				if (SceneDataManager.mapData.map_id == 10600) {
					var goodsArray:Array = PackManager.getInstance().getGoodsByType(vo.item_id);
					if (goodsArray != []) {
						var sortGoodsArray:Array = goodsArray.sortOn("oid",Array.NUMERIC);
						var generalVO:GeneralVO = sortGoodsArray[sortGoodsArray.length - 1] as GeneralVO;
						if (memberUseItemAlert == "") {
							var paramArray:Array = [];
							paramArray[0] = generalVO.oid;
							paramArray[1] = generalVO.typeId;
							memberUseItemAlert = Alert.show("队长：\n\t\t当前轮到你使用道具，请打开背包双击道具【" + generalVO.name + "】，召唤怪物将之击败！",
								"队长提示",onMemberUseItemEvent,null,"召唤怪物","",paramArray,false);
						}
					}
					vo.all_fb_items.sortOn("item_id",Array.NUMERIC);
					var memberPosArray2:Array = [];
					for (var im2:int = 0;im2 < vo.all_fb_items.length;im2++) {
						if (vo.all_fb_items[im2].item_id == vo.item_id) {
							memberPosArray2[im2] = {id: im2 + 1,tx: vo.all_fb_items[im2].use_tx,ty: vo.all_fb_items[im2].
										use_ty};
						}
					}
					this.showDuplicateIcon(memberPosArray2);
				}

			}
		}

		/**
		 * 队长提示界面事件处理
		 * @param event
		 *
		 */
		private function onMemberEvent(event:ParamEvent):void {
			if (SceneDataManager.mapData.map_id == 10600) {
				var eventData:Object = event.data;
				if (eventData.type == DuplicateConstant.GO_TO) {
					this.gotoEducateFbMap(eventData.tx,eventData.ty);
				}
			}
		}

		private function onMemberUseItemEvent(goodsId:int,itemId:int):void {
			this.memberUseItemAlert = "";
			var vo:m_educate_fb_item_tos = new m_educate_fb_item_tos;
			vo.item_id = itemId;
			vo.goods_id = goodsId;
			this.sendSocketMessage(vo);
		}

		private var _duplicateIconPosArray:Array = [];

		/**
		 * 师徒副本中显示召唤位置
		 * @param posArray
		 *
		 */
		private function showDuplicateIcon(posArray:Array):void {
			if (SceneDataManager.mapData.map_id == 10600) {
				this._duplicateIconPosArray = posArray;
				if (this._duplicateMapIcon == null || this._duplicateMapIcon.length < 5) {
					duplicateIconLoad();
				}
				if (this._duplicateMapIcon != null && this._duplicateMapIcon.length >= 5) {
					var param:Array = [];
					for each (var pos:Object in this._duplicateIconPosArray) {
						var key:String = GameParameters.getInstance().resourceHost + "com/assets/duplicate/" + String(pos.
							id) + ".png";
						var _bitmap:Bitmap = this._duplicateMapIcon.take(key) as Bitmap;
                        var pt:Point=TileUitls.getIsoIndexMidVertex(new Pt(int(pos.tx), 0, int(pos.ty)));
                        _bitmap.x=pt.x - (_bitmap.width >> 1);
                        _bitmap.y=pt.y - (_bitmap.height >> 1);
						param.push(_bitmap);
					}
                    GameScene.getInstance().addSign(param);
				}
			}
		}

		/**
		 * 删除师徒副本中显示的召唤位置
		 * TODO 需要重新删除处理
		 */
		private function removeDuplicateIcon():void {
			if (SceneDataManager.mapData.map_id != 10600) {
                GameScene.getInstance().clearSign();
			}
		}

		/**
		 * 加载师徒副本图标资源
		 *
		 */
		private function duplicateIconLoad():void {
			var q:QueueLoader = new QueueLoader;
			q.add(GameParameters.getInstance().resourceHost + 'com/assets/duplicate/1.png');
			q.add(GameParameters.getInstance().resourceHost + 'com/assets/duplicate/2.png');
			q.add(GameParameters.getInstance().resourceHost + 'com/assets/duplicate/3.png');
			q.add(GameParameters.getInstance().resourceHost + 'com/assets/duplicate/4.png');
			q.add(GameParameters.getInstance().resourceHost + 'com/assets/duplicate/5.png');
			q.addEventListener(QueueEvent.ITEM_COMPLETE,duplicateIconLoadItemFunc);
			q.addEventListener(QueueEvent.QUEUE_COMPLETE,duplicateIconLoadFunc);
			q.load();
		}
		private var _duplicateMapIcon:Hash;

		private function duplicateIconLoadItemFunc(event:QueueEvent):void {
            if(_duplicateMapIcon == null){
                _duplicateMapIcon = new Hash();
            }
			_duplicateMapIcon.put(event.data.content,event.loadItem.url);
			if (this._duplicateMapIcon != null && this._duplicateMapIcon.length >= 5) {
				this.showDuplicateIcon(this._duplicateIconPosArray);
			}
		}

		private function duplicateIconLoadFunc(e:QueueEvent = null):void {
			if (this._duplicateMapIcon != null && this._duplicateMapIcon.length >= 5) {
				this.showDuplicateIcon(this._duplicateIconPosArray);
			}
		}

	}
}