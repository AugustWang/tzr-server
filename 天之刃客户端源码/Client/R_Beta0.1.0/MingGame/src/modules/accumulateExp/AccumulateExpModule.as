package modules.accumulateExp
{
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.events.ParamEvent;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.net.SocketCommand;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.BaseModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.duplicate.views.DuplicateNPCPanel;
	import modules.duplicate.vo.ContentVO;
	import modules.duplicate.vo.TalkContentVO;
	import modules.duplicate.vo.TalkVO;
	import modules.vip.VipModule;
	
	import proto.common.p_accumulate_exp_info;
	import proto.line.m_accumulate_exp_fetch_toc;
	import proto.line.m_accumulate_exp_fetch_tos;
	import proto.line.m_accumulate_exp_info_toc;
	import proto.line.m_accumulate_exp_info_tos;
	import proto.line.m_accumulate_exp_list_toc;
	import proto.line.m_accumulate_exp_list_tos;
	import proto.line.m_accumulate_exp_notify_toc;
	import proto.line.m_accumulate_exp_refresh_toc;
	import proto.line.m_accumulate_exp_refresh_tos;
	
	public class AccumulateExpModule extends BaseModule
	{
		private static var _instance:AccumulateExpModule;
		
		private var _npcPanel:DuplicateNPCPanel;
		
		/**
		 * 常量定义
		 */	
		public static const ACCMULATE_TYPE_PERSON_YBC:String = "1";
		public static const ACCMULATE_TYPE_FAMILY_YBC:String = "2";
		public static const ACCMULATE_TYPE_PROTECT_FACTION:String = "3";
		public static const ACCMULATE_TYPE_SPY:String = "4";
		public static const AUTO_MISSION:String = "auto_mission";
		
		//幸运石方式刷新经验
		public static const ACCUMULATE_REFRESH_TYPE_ITEM:int = 1;
		//元宝方式刷新经验
		public static const ACCUMULATE_REFRESH_TYPE_GOLD:int = 2;
		
		public function AccumulateExpModule()
		{
			super();
		}
		
		public static function getInstace():AccumulateExpModule 
		{
			if (!_instance) {
				_instance = new AccumulateExpModule();
			}
			return _instance;
		}
		
		override protected function initListeners():void
		{
//			addSocketListener(SocketCommand.ACCUMULATE_EXP_FETCH, doFetchBack);
//			addSocketListener(SocketCommand.ACCUMULATE_EXP_INFO, doInfoBack);
//			addSocketListener(SocketCommand.ACCUMULATE_EXP_LIST, doListBack);
//			addSocketListener(SocketCommand.ACCUMULATE_EXP_NOTIFY, doNotifyBack);
//			addSocketListener(SocketCommand.ACCUMULATE_EXP_REFRESH, doRefreshBack);
		}
		
		
		/**
		 * 领取奖励的服务端返回处理
		 */
		private function doFetchBack(data:m_accumulate_exp_fetch_toc):void
		{
			if (data.succ) {
				Tips.getInstance().addTipsMsg("成功领取累积经验:" + data.exp);
			} else {
				Tips.getInstance().addTipsMsg(data.reason);
			}
			requestList();
		}
		
		/**
		 * 处理刷新经验的结果
		 */
		private function doRefreshBack(data:m_accumulate_exp_refresh_toc):void
		{
			if (data.succ) {
				if (data.result) {
					if (data.gold > 0) {
						BroadcastSelf.getInstance().appendMsg("提升累积经验成功，消耗" + data.gold + "元宝");
					} else if (data.gold < 0) {
						BroadcastSelf.getInstance().appendMsg("成功提升经验，VIP免费");
					} else {
						BroadcastSelf.getInstance().appendMsg("提升累积经验成功，消耗幸运石x1");		
					} 
					// 刷新界面,暂时先实现为直接请求服务器，之后优化
					var vo:m_accumulate_exp_info_tos = new m_accumulate_exp_info_tos;
					vo.id = data.id;
					this.sendSocketMessage(vo);
				} else {
					if (data.gold > 0) {
						BroadcastSelf.getInstance().appendMsg("提升累积经验失败，消耗" + data.gold + "元宝");
					} else {
						BroadcastSelf.getInstance().appendMsg("提升累积经验失败，消耗幸运石x1");						
					}
				}
			} else {
				BroadcastSelf.getInstance().appendMsg(data.reason);
			}
		}
		
		/**
		 * 处理玩家的累积经验列表
		 */
		private function doListBack(data:m_accumulate_exp_list_toc):void
		{
			WindowManager.getInstance().openDistanceWindow(this._npcPanel);
			WindowManager.getInstance().centerWindow(this._npcPanel);
			
			var talkVO:TalkVO = new TalkVO();
			talkVO.name = "累积经验管理员";
			talkVO.talks = new Vector.<TalkContentVO>();
			
			//显示的内容由前端负责过滤
			var talk:TalkContentVO = new TalkContentVO();
			talk.contents = new Vector.<ContentVO>();
			talk.type = DuplicateNPCPanel.FINISH;
			talk.data = 0;
			
			var content:ContentVO = new ContentVO();
			content.type = DuplicateNPCPanel.CONTENT;
			content.text = "高明：\n  错过了日常任务？ 没关系，再次完成任务后可到我这里领取到累积的经验。";
			talk.contents.push(content);
				
			// 过滤掉那些天数为0的，为0表示当前还不满足领取经验
			var list:Array = new Array;
			list.length = 0;
			for (var i:String in data.list) {
				var acc:p_accumulate_exp_info = data.list[i];
				if (acc.status > 1) {
					var content2:ContentVO = new ContentVO();
					content2.type = DuplicateNPCPanel.LINK;
					content2.text = getItemLinkText(acc.id);
					content2.linkType = DuplicateNPCPanel.OTHER;
					content2.data = String(acc.id);
					talk.contents.push(content2);
					list.push(data.list[i]);
				} 
			}
			
			releaseBtn();
			this.expList = list;
			if (this.expList.length < 1) {
				WindowManager.getInstance().removeWindow(this._view);
				//ICON重构				MessageIconManager.removeAccumulateItem();
				this._view = null;
				
				if (this.accCenterIcon) {
					WindowManager.getInstance().removeWindow(this.accCenterIcon);
					this.accCenterIcon = null;
				}
			}
			
			talkVO.talks.push(talk);
			this._npcPanel.talkVO = talkVO;
			//this._npcPanel.wrapperTalk(talk);
		}
		
		private function releaseBtn():void 
		{
			if (btnGold) {
				btnGold.parent.removeChild(btnGold);
				if (btnGold.hasEventListener(MouseEvent.CLICK)) {
					btnGold.removeEventListener(MouseEvent.CLICK, requestRefreshUseGold);
				}
				btnGold.dispose();
				btnGold = null;
			}
			if (fetchBtn) {
				fetchBtn.parent.removeChild(fetchBtn);
				if (fetchBtn.hasEventListener(MouseEvent.CLICK)) {
					fetchBtn.removeEventListener(MouseEvent.CLICK, requestFetch);
				}
				fetchBtn.dispose();
				fetchBtn = null;
			}
			if (textGold) {
				textGold.parent.removeChild(textGold);
				textGold = null;
			}
			if (textTip) {
				textTip.parent.removeChild(textTip);
				textTip = null;
			}
			if (textNpc) {
				textNpc.parent.removeChild(textNpc);
				if (textNpc.hasEventListener(TextEvent.LINK)) {
					textNpc.removeEventListener(TextEvent.LINK, onTextNPCClick);
				}
				textNpc = null;
			}
			if (vipTip) {
				vipTip.parent.removeChild(vipTip);
				vipTip = null;
			}
		}
		
		private function getItemLinkText(id:int):String
		{
			switch (id) {
				case 1:
					return "个人拉镖累积经验";
					break;
				case 2:
					return "门派拉镖累积经验";
					break;
				case 3:
					return "守卫国土累积经验";
					break;
				case 4:
					return "刺探累积经验";
					break;
				default:
					return "";
					break;
			}
			return "";
		}
		
		private var btnGold:Button;
		private var fetchBtn:Button;
		private var textGold:TextField;
		private var textTip:TextField;
		// 打开具体的累积经验面板时如果玩家需要先完成任务，则给出对应任务NPC的位置
		private var textNpc:TextField;
		private var vipTip:TextField;
		
		/**
		 * 处理返回某个累积经验的信息
		 */
		private function doInfoBack(data:m_accumulate_exp_info_toc):void
		{
			if (data.info.id == 1) {
				this._npcPanel.title = "个人拉镖累积经验";
			} else if (data.info.id == 2) {
				this._npcPanel.title = "门派拉镖累积经验";
			} else if (data.info.id == 3) {
				this._npcPanel.title = "守卫国土累积经验";
			} else if (data.info.id == 4) {
				this._npcPanel.title = "刺探任务累积经验";
			}
			
			var talk:TalkContentVO = new TalkContentVO();
			talk.contents = new Vector.<ContentVO>();
			talk.type = DuplicateNPCPanel.GO_BACK_REFRESH;
			talk.data = 0;
			
			var expColor:String = new String;
			var nextExpColor:String = new String;
			if (data.info.rate == 10) {
				expColor = "#FFFFFF";
			} else if (data.info.rate == 15 || data.info.rate == 23) {
				expColor = "#12cc95";
			} else if (data.info.rate == 35 || data.info.rate == 52) {
				expColor = "#0d79ff";
			} else if (data.info.rate == 75) {
				expColor = "#fe00e9";
			} else if (data.info.rate == 100) {
				expColor = "#ff7e00";
			}
			
			var content:ContentVO = new ContentVO();
			content.type = DuplicateNPCPanel.CONTENT;
			content.text = "高明：\n    ";
			if (data.info.status == 2) {
				content.text += "  需再次完成任务才可领取累积经验。 \n\n";
			} else {
				content.text += "你已连续" + data.info.day + "天未完成此任务，累积任务次数" + (data.info.times_per_day * data.info.day) + "：\n\n";
			}
			content.text += "    可领经验：" + "<font color='" + expColor + "'>" + data.info.exp + "</font>\n";
			
			if (data.info.rate == 10 || data.info.rate == 15) {
				nextExpColor = "#12cc95";
			} else if (data.info.rate == 23 || data.info.rate == 35) {
				nextExpColor = "#0d79ff";
			} else if (data.info.rate == 52) {
				nextExpColor = "#fe00e9";
			} else if (data.info.rate == 75) {
				nextExpColor = "#ff7e00";
			}
			if (data.info.max_exp > data.info.exp) {
				content.text += "    可提升至：" + "<font color='" + nextExpColor + "'>" + data.info.next_exp + "</font>\n";
			}
			content.text += "    (最高可获得<font color='#ff7e00'>" + data.info.max_exp + "</font>经验)\n";
			
			talk.contents.push(content);
			
			this._npcPanel.wrapperTalk(talk);
			releaseBtn();
			
			btnGold = ComponentUtil.createButton("元宝提升", 32, 170, 80, 25, this._npcPanel);
			textGold = ComponentUtil.createTextField("("+ data.info.need_gold + "元宝)", 40, 200, null, 80, 25, this._npcPanel);
			if (data.info.exp == data.info.max_exp || data.info.status == 2) {
				// 已经提升到最大百分比了
				btnGold.enabled = false;
			} else {
				btnGold.addEventListener(MouseEvent.CLICK, requestRefreshUseGold);
				btnGold.data = {"needGold":data.info.need_gold, "id":data.info.id};
			}
			
			vipTip = ComponentUtil.createTextField("VIP可免费提升累积经验3次且一定成功", 30, 225, null, 208, 40, this._npcPanel);
			
			//领取按钮
			fetchBtn = ComponentUtil.createButton("领取", 100, 270, 60, 25, this._npcPanel);
			fetchBtn.data = {"id":data.info.id};
			fetchBtn.addEventListener(MouseEvent.CLICK, requestFetch);
			
			if (data.info.status == 2) {
				fetchBtn.enabled = false;
			}
			
			if (data.info.status == 2) {
				var npcID:String = getAccNpcID(data.info.id);
				var NpcName:String = getAccNpcName(data.info.id);
				var tf:TextFormat = new TextFormat('Tahoma', 12, 0x00FF00);
				tf.underline = true;
				textNpc = ComponentUtil.createTextField("", 118, 50, tf, 220, 60, this._npcPanel);
				textNpc.htmlText = "寻路到<a href='event:" + npcID 
					+ "'>" + NpcName + "</a>";
				textNpc.mouseEnabled = true;
				textNpc.selectable = true;
				textNpc.addEventListener(TextEvent.LINK, onTextNPCClick);
			}
		}
		
		private function onTextNPCClick(e:TextEvent):void
		{
			PathUtil.findNpcAndOpen(e.text);
		}
		
		private function getAccNpcName(id:int):String
		{
			switch(id) {
				case 1:
					return "京城-张将军";
					break;
				case 2:
					return "京城-史可法";
					break;
				case 3:
					return "边城-沐英";
					break;
				case 4:
					return "京城-冯胜";
					break;
			}
			return "";
		}
		
		private function getAccNpcID(id:int):String
		{
			switch(id) {
				case 1:
					return "1" + GlobalObjectManager.getInstance().user.base.faction_id + "100102";
					break;
				case 2:
					return "1" + GlobalObjectManager.getInstance().user.base.faction_id + "100128";
					break;
				case 3:
					return "1" + GlobalObjectManager.getInstance().user.base.faction_id + "105100";
					break;
				case 4:
					return "1" + GlobalObjectManager.getInstance().user.base.faction_id + "100105";
					break;
			}
			return "";
		}
		
		/**
		 * 领取累积经验
		 */
		private function requestFetch(e:Event):void
		{
			var btn:Button = e.currentTarget as Button;
			var id:int = btn.data.id;
			var vo:m_accumulate_exp_fetch_tos = new m_accumulate_exp_fetch_tos;
			vo.id = id;
			this.sendSocketMessage(vo);
		}
		
		/**
		 * 使用道具方式提升经验
		 */
		private function useItemRefresh(e:Event):void
		{
			var btn:Button = e.currentTarget as Button;
			var id:int = btn.data.id;
			var vo:m_accumulate_exp_refresh_tos  = new m_accumulate_exp_refresh_tos;
			vo.id = id;
			vo.type = ACCUMULATE_REFRESH_TYPE_ITEM;
			this.sendSocketMessage(vo);
		}
		
		public function hasAcc():Boolean
		{
			return this.expList.length > 0;
		}
		
		public function hasExpByID(id:int):Boolean
		{
			switch(id) {
				case 1:
					return hasPersonYbcExp();
					break;
				case 2:
					return hasFamilyYbcExp();
					break;
				case 3:
					return hasProtectFactionExp();
					break;
				case 4:
					return hasSpyExp();
					break;
				default:
					break;
			}
			return false;
		}
		
		public function getPersonYbcExp():p_accumulate_exp_info
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 1) {
					return acc;
				}
			}
			return null;
		}
		
		public function getFamilyYbcExp():p_accumulate_exp_info
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 2) {
					return acc;
				}
			}
			return null;
		}
		
		public function getProtectFactionExp():p_accumulate_exp_info
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 3) {
					return acc;
				}
			}
			return null;
		}
		
		public function getSpyExp():p_accumulate_exp_info
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 4) {
					return acc;
				}
			}
			return null;
		}
		
		/**
		 * 外部接口：判断是否有个人拉镖累积经验可以领取
		 */
		public function hasPersonYbcExp():Boolean
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 1 && acc.status > 1) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 外部接口：判断是否有门派拉镖累积经验可以领取
		 */
		public function hasFamilyYbcExp():Boolean
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 2 && acc.status > 1) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 外部接口：判断是否有守卫国土累积经验可以领取
		 */
		public function hasProtectFactionExp():Boolean
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 3 && acc.status > 1) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 外部接口：判断是否有刺探累积经验可以领取
		 */
		public function hasSpyExp():Boolean
		{
			for each (var acc:p_accumulate_exp_info in this.expList) {
				if (acc.id == 4 && acc.status > 1) {
					return true;
				}
			}
			return false;
		}
		
		private var accCenterIcon:AccumulateExpIcon;
		
		/**
		 * 保存当前可以领取的累积经验列表
		 * p_accumulate_exp_info
		 */
		private var expList:Array;
		
		/**
		 * 后端主动通知玩家有离线经验可以领取
		 */
		private function doNotifyBack(data:m_accumulate_exp_notify_toc):void
		{
			this.expList = data.list;
			for each(var acc:p_accumulate_exp_info in this.expList) {
				if (acc.status > 1) {
					if (!accCenterIcon) {
						accCenterIcon = new AccumulateExpIcon;
						accCenterIcon.tip = "你有大量的累积经验可以领取，点击查看！";	
					}
					WindowManager.getInstance().popUpWindow(accCenterIcon);
					WindowManager.getInstance().centerWindow(accCenterIcon);
					accCenterIcon.y += 170;
					break;
				}
			}
		}
		
		/**
		 * 是否已累积经验可以领取
		 */
		public function hasExpToGet():Boolean
		{
			for each(var acc:p_accumulate_exp_info in this.expList) {
				if (acc.status == 3) {
					return true;
				}
			}
			return false;
		}
		
		private var _view:AccumulateExpView;
		
		/**
		 * 点击场景中部的提示按钮，显示列表
		 */
		public function showAccumulateView():void
		{
			if (accCenterIcon) {
				WindowManager.getInstance().removeWindow(accCenterIcon);
				accCenterIcon = null;
			}
			if (!this._view) {
				this._view = new AccumulateExpView("accumulateExpView");
			}
			WindowManager.getInstance().popUpWindow(this._view);
			WindowManager.getInstance().centerWindow(this._view);
			this._view.update();
		}
		
		/**
		 * 点击了NPC：京城知事
		 * 请求后端返回玩家累积经验列表
		 */
		public function clickNpc():void
		{
			if (!this._npcPanel) {
				this._npcPanel = new DuplicateNPCPanel();
				this._npcPanel.addEventListener(DuplicateNPCPanel.OTHER, onOther);
				//点击任意累积经验信息面板的返回时，都重新请求数据
				this._npcPanel.addEventListener(DuplicateNPCPanel.GO_BACK_REFRESH, getList);
			}
			// 请求数据
			requestList();
		}
		
		/**
		 * 使用元宝刷新经验
		 * @param needGold 需要多少元宝
		 */
		private function requestRefreshUseGold(e:Event):void
		{
			var btn:Button = e.currentTarget as Button;
			var needGold:int = btn.data.needGold;
			var id:int = btn.data.id;
			if (GlobalObjectManager.getInstance().user.attr.gold_bind < needGold && 
				GlobalObjectManager.getInstance().user.attr.gold < needGold &&
				VipModule.getInstance().getAccuExpTimes() <= 0) {
				Tips.getInstance().addTipsMsg("你的元宝不足" + needGold + "元宝");
				return;
			}
			// 请求服务端
			var vo:m_accumulate_exp_refresh_tos  = new m_accumulate_exp_refresh_tos;
			vo.id = id;
			vo.type = ACCUMULATE_REFRESH_TYPE_GOLD;
			//this.sendSocketMessage(vo);
		}
		
		/**
		 * 点击返回时重新请求面板数据
		 */
		private function getList(e:Event):void
		{
			requestList();
		}
		
		
		/**
		 * 其它链接事件 
		 * @param event
		 * 
		 */		
		private function onOther(event:ParamEvent):void
		{
			var vo:m_accumulate_exp_info_tos = new m_accumulate_exp_info_tos;
			if(event.data == ACCMULATE_TYPE_PERSON_YBC) {
				//个人拉镖累积经验
				vo.id = int(ACCMULATE_TYPE_PERSON_YBC);
				this.sendSocketMessage(vo);
			} else if (event.data == ACCMULATE_TYPE_FAMILY_YBC) {
				// 门派拉镖累积经验
				vo.id = int(ACCMULATE_TYPE_FAMILY_YBC);
				this.sendSocketMessage(vo);
			} else if (event.data == ACCMULATE_TYPE_PROTECT_FACTION) {
				// 守卫国土累积经验
				vo.id = int(ACCMULATE_TYPE_PROTECT_FACTION);
				this.sendSocketMessage(vo);
			} else if (event.data == ACCMULATE_TYPE_SPY) {
				// 刺探累积经验
				vo.id = int(ACCMULATE_TYPE_SPY);
				this.sendSocketMessage(vo);
			}
		}
		
		/**
		 * 点击NPC面板时请求玩家累积经验列表
		 */
		private function requestList():void
		{
			//this.sendSocketMessage(new m_accumulate_exp_list_tos);
		}
	}
}