package modules.personalybc {
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	
	import com.loaders.CommonLocator;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.sceneManager.LoopManager;
	import com.scene.tile.Pt;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	import com.utils.PathUtil;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	import modules.help.HelpManager;
	import modules.help.IntroduceConstant;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.personalybc.view.BiaoView;
	import modules.personalybc.view.PersonalYbcView;
	import modules.personalybc.view.PersonybcFactionView;
	import modules.personalybc.view.TimerView;
	
	import proto.line.m_personybc_auto_toc;
	import proto.line.m_personybc_cancel_toc;
	import proto.line.m_personybc_cancel_tos;
	import proto.line.m_personybc_color_change_toc;
	import proto.line.m_personybc_commit_toc;
	import proto.line.m_personybc_commit_tos;
	import proto.line.m_personybc_faction_notice_toc;
	import proto.line.m_personybc_faction_toc;
	import proto.line.m_personybc_faction_tos;
	import proto.line.m_personybc_info_toc;
	import proto.line.m_personybc_info_tos;
	import proto.line.m_personybc_public_toc;
	import proto.line.m_personybc_public_tos;
	import proto.line.m_personybc_sos_toc;
	import proto.line.p_personybc_award_attr;

	public class PersonalYbcModule extends BaseModule {
		public var view:PersonalYbcView;
		public var personybcFactionView:PersonybcFactionView;
		private var showYbcPanel:Boolean=false;

		private static var instance:PersonalYbcModule;

		public var biaoView:BiaoView;
		private var _timerView:TimerView;

		public function PersonalYbcModule() {
			initView();
		}

		private function initView():void {
			this.view=new PersonalYbcView;
		}

		private var _doingYBC:Boolean=false;

		public function set doingYBC(_bool:Boolean):void {
			if (_bool == false) {
				_doingYBC=false;
				this.dispatch(ModuleCommand.SCENE_CLEAR_SIGN);
			} else {
				_doingYBC=true;
				this.dispatch(ModuleCommand.SCENE_SHOW_SIGN);
			}
		}

		public function get doingYBC():Boolean {
			return _doingYBC;
		}

		public function get showYBCArrow():Boolean {
			//不直接调用doingYBC 是因为可能有其他条件限制
			return doingYBC;
		}

		override protected function initListeners():void {
			addMessageListener(NPCActionType.NA_51, personybcFactionFunc);
			addMessageListener(NPCActionType.NA_44, openAbout);
			addMessageListener(NPCActionType.NA_43, doRequestInfoOpen);
			addMessageListener(NPCActionType.NA_89, doRequestCommit);
			addMessageListener(ModuleCommand.ENTER_GAME, doRequestInfo);
			addMessageListener(NPCActionType.NA_45, publicFuncFaction);
			addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY, showArrow);

			addSocketListener(SocketCommand.PERSONYBC_CANCEL, setAfterCancle);
			addSocketListener(SocketCommand.PERSONYBC_COLOR_CHANGE, setAfterChange);
			addSocketListener(SocketCommand.PERSONYBC_COMMIT, setAfterCommit);
			addSocketListener(SocketCommand.PERSONYBC_INFO, doReturnInfo);
			addSocketListener(SocketCommand.PERSONYBC_PUBLIC, setAfterPublic);
			addSocketListener(SocketCommand.PERSONYBC_FACTION, setAfterFaction);
			addSocketListener(SocketCommand.PERSONYBC_FACTION_NOTICE, setAfterFactionNotice);
			addSocketListener(SocketCommand.PERSONYBC_AUTO, autoYbc);
			addSocketListener(SocketCommand.PERSONYBC_SOS, setYbcSOS);
		}

		private function autoYbc(vo:m_personybc_auto_toc):void {
			if (!this._timerView) {
				this._timerView=new TimerView();
			}
			_timerView.updateAuto(vo);
		}

		private function showArrow():void {
			if (this.showYBCArrow) {
				this.dispatch(ModuleCommand.SCENE_SHOW_SIGN);
			}
		}

		/**
		 * 打开关于拉镖面板，配置文件在 com/data/introduce.xml
		 * @param vo
		 *
		 */
		private function openAbout(vo:NpcLinkVO=null):void {
			HelpManager.getInstance().openIntroduce(IntroduceConstant.PERSONYBC_HELP);
		}

		/**
		 * 打开领取国运镖车面板
		 * @param vo
		 *
		 */
		private function publicFuncFaction(vo:NpcLinkVO=null):void {
			if (!this.view) {
				this.view=new PersonalYbcView;
			}
			doRequestInfoOpen(vo);
		}

		/**
		 * 请求个人拉镖的信息并在成功返回后自动打开镖车领取面板
		 * @param param
		 *
		 */
		private function doRequestInfoOpen(param:NpcLinkVO=null):void {
			var flag:Boolean;
			var vo:m_personybc_info_tos
			if(param.dispatchMessage == "NPCAction_45")
			{
				if( GlobalObjectManager.getInstance().user.attr.level >= 31){
					//标识是否够钱领取镖车
					flag = judge();
					if( flag == true ){
						if(GlobalObjectManager.getInstance().user.attr.family_contribute >= 5){
							if(PersonalYbcModule.getInstance().view.info_toc.info.do_times > 3){
								Tips.getInstance().addTipsMsg("今天已完成3次拉镖，休息一下，请明天再来吧");
							}else{
								this.view.type=1;
								this.showYbcPanel=true;
								vo=new m_personybc_info_tos;
								vo.type=1;
								sendSocketMessage(vo);	
							}
						}else{
							Tips.getInstance().addTipsMsg("门派贡献度（参与门派活动可获得）不足5点，无法参与国运");
						}
					}
					else
					{
						Tips.getInstance().addTipsMsg("你的银子不足"+MoneyTransformUtil.silverToOtherString(needSilver)+",不能领取镖车");
					}
				}
				else
				{
					Tips.getInstance().addTipsMsg("需31级以上才可以领取国运拉镖");
				}
			}
			else if(param.dispatchMessage == "NPCAction_43")
			{
				if( GlobalObjectManager.getInstance().user.attr.level >= 20){
					//标识是否够钱领取镖车
					flag = judge();
					if( flag == true ){
						if(PersonalYbcModule.getInstance().view.info_toc.info.do_times > 3){
							Tips.getInstance().addTipsMsg("今天已完成3次拉镖，休息一下，请明天再来吧");
						}
						else{
							this.view.type=0;
							this.showYbcPanel=true;
							vo=new m_personybc_info_tos;
							vo.type=0;
							sendSocketMessage(vo);
						}
					}
					else
					{
						Tips.getInstance().addTipsMsg("你的银子不足" + MoneyTransformUtil.silverToOtherString(needSilver) + "，不能领取镖车");
					}
				}
				else
				{
					Tips.getInstance().addTipsMsg("需20级以上才可以领取个人拉镖");
				}
			}
		}

		
		/**
		 *判断当前玩家的钱是否够获取个人镖车 
		 * 
		 */
		private var needSilver:int;
		private function judge():Boolean {
			//当前玩家的级数
			var currentLV:int=GlobalObjectManager.getInstance().user.attr.level;
			var data:XML=CommonLocator.getXML(CommonLocator.YBC_PERSON_COST);
			var silver:String;
			//目前玩家拥有的银子
			var currentMoney:int;
			//拉镖需要的银子
			var needMoney:int;
			if (data.ybc_person_cost.(hasOwnProperty('@lv'))) {
				var result:XML=data.ybc_person_cost.(@lv == currentLV.toString())[0] as XML;
				needSilver = conversion(result.@bsilver);
				var roleSilver:int = GlobalObjectManager.getInstance().user.attr.silver;
				var roleSilverBind:int = GlobalObjectManager.getInstance().user.attr.silver_bind;
				if (needSilver > roleSilver + roleSilverBind) {
					return false;
				}
				return true;
			}
			return false;
		}
		
		/**
		 * 
		 * @param money
		 * @return 
		 * 将12两12文转换为1212
		 */		
		private function conversion(money:String):int
		{
			var silver:int = 0;
			var tmp:int = 0;
			var char:String = "";
			
			for (var i:int = 0; i < money.length; i ++) {
				char = money.charAt(i);
				switch (char) {
					case "锭":
						silver += tmp * 10000;
						tmp = 0;
						break;
					case "两":
						silver += tmp * 100;
						tmp = 0;
						break;
					case "文":
						silver += tmp;
						tmp = 0;
						break;
					default:
						tmp = tmp * 10 + int(char);
						break
				}
			}
			
			return silver;
		}

		/**
		 * 请求个人拉镖的信息
		 * @param param
		 *
		 */
		public function doRequestInfo(param:NpcLinkVO=null):void {
			this.showYbcPanel=false;
			var vo:m_personybc_info_tos=new m_personybc_info_tos;
			vo.type=0;
			sendSocketMessage(vo);
		}


		private function setYbcSOS(vo:m_personybc_sos_toc):void {
			BroadcastModule.getInstance().popup("本门派<font color='#58f1ff'>[" + vo.role_name + "]</font>的镖车正在被他人攻击。消耗一个【传送卷】可传送前往救援。",
				"传送前往", sosYBC, vo, 15);
		}

		private function sosYBC(vo:m_personybc_sos_toc):void {
			PathUtil.carry(vo.map_id, new Pt(vo.pos.tx, 0, vo.pos.ty));
		}

		/**
		 * 有人发布国运了
		 * @param vo
		 *
		 */
		public function setAfterFaction(vo:m_personybc_faction_toc):void {
			if (vo.succ == true) {
				if (this.view) {
					if (this.view.info_toc != null) {
						this.view.info_toc.info.faction_start_time=vo.today_start_time;
						this.view.info_toc.info.time_limit=vo.time_limit;
					}
				}
				doRequestInfo();
			} else {
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}

		/**
		 * 镖车信息返回
		 */
		public function doReturnInfo(vo:m_personybc_info_toc):void {
			if (!this.view) {
				this.view=new PersonalYbcView('个人拉镖');
			}
			if (vo.succ == false) {
				BroadcastSelf.getInstance().appendMsg(vo.reason);
				return;
			}

			view.updataTaskCar(vo);
			var _regTimer:Boolean=false;
			if (vo.info.status > 0) {
				MessageIconManager.getInstance().showPersonBiao(mouseClickFunc);
				doingYBC=true;
				_regTimer=true;
			}

			if (vo.info.start_time > 0 || vo.info.faction_start_time > 0) {
				if (!this._timerView) {
					this._timerView=new TimerView();
//					SceneTopTimeIconManager.getInstance().addChildren(this._timerView);
					BroadcastModule.getInstance().countdownView.addChilren(this._timerView);
				}
				this._timerView.update();
				LoopManager.addToSecond(this, this.updateTimerView);
//				TimerManager.getInstance().add(this.updateTimerView, 10, 0);
			}
			if (this.showYbcPanel) {
				if (!WindowManager.getInstance().isPopUp(view)) {
					WindowManager.getInstance().popUpWindow(view);
					WindowManager.getInstance().centerWindow(view);
				}
			}
		}

		/**
		 * 处理服务端推过来的镖车信息
		 *
		 */
		public function setAfterChange(vo:m_personybc_color_change_toc):void {
			if (!view) {
				view=new PersonalYbcView("个人拉镖");
			}
			view.updataColor(vo.color);
		}

		private function mouseClickFunc():void {
			if (biaoView == null) {
				biaoView=new BiaoView;
			}
			biaoView.x=550;
			biaoView.y=150;
			biaoView.updata()
			WindowManager.getInstance().popUpWindow(biaoView);
		}

		/**
		 * 处理返回发布镖车请求后的信息
		 *
		 */
		public function setAfterPublic(vo:m_personybc_public_toc):void {
			if (vo) {
				if (vo.succ == false) {
					BroadcastSelf.getInstance().appendMsg(vo.reason);
					BroadcastView.getInstance().addBroadcastMsg(vo.reason);
					return;
				}

				if (GlobalObjectManager.getInstance().user.attr.level <= 30) {
					BroadcastView.getInstance().addBroadcastMsg("成功领取镖车，请顺着护镖路线护镖。");
				}
				this.view.info_toc.info=vo.info;
				this.view.info_toc.info.status=1;
				doingYBC=true;
				MessageIconManager.getInstance().showPersonBiao(mouseClickFunc);
				doRequestInfo();
			}
		}

		/**
		 * 处理提交镖车请求后的信息
		 *
		 */
		public function setAfterCommit(vo:m_personybc_commit_toc):void {
			try {
				if (vo.succ == false) {
					Tips.getInstance().addTipsMsg(vo.reason);
					BroadcastSelf.getInstance().appendMsg(vo.reason);
					return;
				}
				doingYBC=false;
				MessageIconManager.getInstance().removePersonBiao();

				if (this.biaoView) {
					if (this.biaoView.parent)
						this.biaoView.parent.removeChild(this.biaoView);
				}
				removeTimerView();
				var str:String='<FONT COLOR="#FFCC00">护送完成：\n';
				for (var i:int=0; i < vo.attr_award_list.length; i++) {
					var p:p_personybc_award_attr=vo.attr_award_list[i]
					if (p.attr_type == 1) {
						if (p.attr_num > 0)
							str+='获得经验：' + p.attr_num + '\n';

					} else if (p.attr_type == 2) {
						if (p.attr_num > 0)
							str+='银    子：' + MoneyTransformUtil.silverToOtherString(p.attr_num) + '\n';
					} else if (p.attr_type == 3) {
						if (p.attr_num > 0)
							str+='绑定银子：' + MoneyTransformUtil.silverToOtherString(p.attr_num) + '\n';
					}
				}
				str+='</FONT>'
				BroadcastSelf.getInstance().appendMsg(str)
				view.info_toc.info.status=0;
				doRequestInfo();
			} catch (e:Error) {
			}
		}

		/**
		 * 处理提交镖车请求后的信息
		 *
		 */
		public function setAfterCancle(vo:m_personybc_cancel_toc):void {
			if (vo.succ == false) {
				BroadcastSelf.getInstance().appendMsg(vo.reason);
				return;
			}


			doingYBC=false;
			MessageIconManager.getInstance().removePersonBiao();
			if (this.biaoView) {
				if (this.biaoView.parent)
					this.biaoView.parent.removeChild(this.biaoView);
			}
			doRequestInfo();
			this.showYbcPanel=false;
			view.info_toc.info.status=0;
		}

		/**
		 * 处理国运广播
		 */
		public function setAfterFactionNotice(vo:m_personybc_faction_notice_toc):void {
			var _msg:String='';
			switch (vo.type) {
				case 1:
					_msg='我国国运将于15分钟后开始！';
					break;
				case 2:
					_msg='我国国运将于5分钟后开始！';
					break;
				case 3:
					var _npcID:int=this.view.info_toc.info.public_npc_id;
					_msg='国运开始了，请国民赶紧到<font color="#00ff00">';
					_msg+=HtmlUtil.link('京城-张将军', 'gotoNpc#' + _npcID, true);
					_msg+='</font>处领取国运镖车！';
					Tips.getInstance().addTipsMsg(_msg);
					if (!this._timerView) {
						this._timerView=new TimerView();
//						SceneTopTimeIconManager.getInstance().addChildren(this._timerView);
						BroadcastModule.getInstance().countdownView.addChilren(this._timerView);
					}

					this.doRequestInfo();
					MessageIconManager.getInstance().showFactionYbcIcon();
//					TimerManager.getInstance().add(this.updateTimerView, 10, 0);
					LoopManager.addToSecond(this, this.updateTimerView);
					break;
				case 4:
					_msg='我国今天的国运已结束。';
					break;
				default:
					break;
			}

			if (_msg) {
				ChatModule.getInstance().chat.appendMessage("<font color='#FF0000'>【系】</font><font color='#ffcc00'>" +
					_msg + '</font>', null, ChatType.COUNTRY_CHANNEL);
			}
		}

		public function updateTimerView():void {
			if (this._timerView) {
				this._timerView.update();
			}
		}

		public function removeTimerView():void {
			if (this._timerView) {		
				BroadcastModule.getInstance().countdownView.removeChildren(this._timerView);
				this._timerView=null;
			}
			LoopManager.removeFromSceond(this);
		}

		//请求服务端

		/**
		 * 取消
		 *
		 */
		public function cancel():void {
			sendSocketMessage(new m_personybc_cancel_tos);
		}

		/**
		 * 交镖车
		 *
		 */
		public function doRequestCommit(vo:NpcLinkVO=null):void {
			sendSocketMessage(new m_personybc_commit_tos);
		}

		/**
		 * 发布镖车
		 *
		 */
		public function publicFunc(type:int=0):void {
			var vo:m_personybc_public_tos=new m_personybc_public_tos;
			vo.type=type;
			sendSocketMessage(vo);
		}

		/**
		 * 发布国运确认
		 *
		 */
		public function personybcFactionFunc(vo:NpcLinkVO=null):void {
			if (this.personybcFactionView == null) {
				this.personybcFactionView=new PersonybcFactionView("发布国运");
			}
			WindowManager.getInstance().popUpWindow(this.personybcFactionView);
		}

		/**
		 * 发布国运
		 *
		 */
		public function personybcFactionConfirmFunc(_vo:m_personybc_faction_tos):void {
			sendSocketMessage(_vo);
		}

		public static function getInstance():PersonalYbcModule {
			if (instance == null) {
				instance=new PersonalYbcModule;
			}
			return instance;
		}
	}
}