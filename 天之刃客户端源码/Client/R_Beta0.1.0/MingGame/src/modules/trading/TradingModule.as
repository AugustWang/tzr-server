package modules.trading {
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;
	import modules.trading.tradingManager.TradingManager;
	import modules.trading.views.BuyTradingPanel;
	import modules.trading.views.DoubleTipView;
	import modules.trading.views.ExchangeTipPanel;
	import modules.trading.views.IntroduceWindow;
	import modules.trading.views.TradingShopView;
	import modules.trading.views.TradingsmallView;
	import modules.trading.vo.TradingGoodVo;
	
	import proto.line.m_trading_buy_toc;
	import proto.line.m_trading_buy_tos;
	import proto.line.m_trading_exchange_toc;
	import proto.line.m_trading_exchange_tos;
	import proto.line.m_trading_get_toc;
	import proto.line.m_trading_get_tos;
	import proto.line.m_trading_return_toc;
	import proto.line.m_trading_return_tos;
	import proto.line.m_trading_sale_toc;
	import proto.line.m_trading_sale_tos;
	import proto.line.m_trading_shop_toc;
	import proto.line.m_trading_shop_tos;
	import proto.line.m_trading_status_toc;
	import proto.line.m_trading_status_tos;

	public class TradingModule extends BaseModule {
		private var shopGoodsArr:Array = [];
		private var roleGoodArr:Array = [];
		private var haveRoleGood:Boolean = false;
		private var award:int;

		public function TradingModule() {
			super();
		}

		private static var instance:TradingModule;

		public static function getInstance():TradingModule {
			if (!instance) {
				instance = new TradingModule();

			}
			return instance;
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.TRADING_GET,getTrading_toc);
			addSocketListener(SocketCommand.TRADING_SHOP,tradingShopInit);
			addSocketListener(SocketCommand.TRADING_BUY,tradingBuyResult);
			addSocketListener(SocketCommand.TRADING_SALE,tradingSaleResult);
			addSocketListener(SocketCommand.TRADING_RETURN,tradingReturnResult);
			addSocketListener(SocketCommand.TRADING_EXCHANGE,tradingExchResult);
			addSocketListener(SocketCommand.TRADING_STATUS,tradingStatus);

			addMessageListener(NPCActionType.NA_46,getTrading_tos);
			addMessageListener(NPCActionType.NA_40,initTradingShop);
			addMessageListener(NPCActionType.NA_47,returnHandler);
			addMessageListener(NPCActionType.NA_14,openExchange);
			addMessageListener(NPCActionType.NA_48,openIntroduce);


			addMessageListener(ModuleCommand.ENTER_GAME,requestStatus);
		}


		private var _times:int;

		public function get times():int {
			return _times;
		}

		private function requestStatus():void {
			this.sendSocketMessage(new m_trading_status_tos);
		}

		private function tradingStatus(vo:m_trading_status_toc):void {
			//			vo.succ;vo.reason;
			//			vo.trading_status;//0 非商贸状态，  1商贸状态。
			//			vo.type; //1 不用处理， 2 需要处理
			//			vo.trading_times; //第几次商贸。
			//          vo.award_type     //  1 不绑定的银子， ， 2 得绑定银子 

			if (!vo.succ || vo.type == 1) {
				return;
			}
			if (vo.type == 2) {
				//处理。 不知道是啥东东
			}
			_times = vo.trading_times;

			if (vo.trading_status == 1) {
				beginBill = vo.base_bill;
				currentBill = vo.bill;
				MessageIconManager.getInstance().showShangmao(openIntroduce);
				award = vo.award_type;
				if (vo.role_goods.length > 0) {
					haveRoleGood = true;
					TradingManager.trading_goods_npcId = vo.npc_id;
				}

			} else {
				MessageIconManager.getInstance().removeShangMao();
				if (tradingView) {
					if (roleGoodArr.length > 0){
						tradingView.clearRoleItem(roleGoodArr.length);
					}
				}
				while (roleGoodArr.length > 0) {
					var obj:Object = roleGoodArr.shift();
					obj = null;
				}
				haveRoleGood = false;
				beginBill = 0;
			}
		}

		private var introduceView:IntroduceWindow;

		private function openIntroduce(npcLinkVO:NpcLinkVO=null):void {
			if (!introduceView) {
				introduceView = new IntroduceWindow();
				introduceView.x = 65;
				introduceView.y = 65;
			}
			WindowManager.getInstance().popUpWindow(introduceView);
		}

		public function closeIntroduce():void {
			if (introduceView) {
				WindowManager.getInstance().removeWindow(introduceView);
				introduceView.dispose();
				introduceView = null;
			}
		}


		private var tradingView:TradingShopView;

		private function initTradingShop(npcLinkVO:NpcLinkVO):void {
			var npcObj:Object = npcLinkVO.data;
			if (!tradingView) {
				tradingView = new TradingShopView();
				tradingView.x = 240;
				tradingView.y = 70;
				tradingView.addEventListener(CloseEvent.CLOSE,closeTradingView);
			}
			WindowManager.getInstance().openDistanceWindow(tradingView);
			WindowManager.getInstance().centerWindow(tradingView);
			getTradingShop_tos(npcObj.id);
		}

		public function closeTradings():void {
			closeTradingView();
			closesmallView();
		}

		public function closeTradingView(evt:CloseEvent = null):void {
			if (tradingView) {
				closeBuyPanle();
				WindowManager.getInstance().removeWindow(tradingView);
				tradingView.dispose();
				tradingView = null;
			}
		}

		private var smallview:TradingsmallView;

		public function showSmallview(isSmall:Boolean):void {
			if (isSmall) {
				if (!smallview) {
					smallview = new TradingsmallView();
					smallview.x = int(1002 - smallview.width) * 0.5;
					smallview.y = int(GlobalObjectManager.GAME_HEIGHT - smallview.height) * 0.5;
					smallview.addEventListener(CloseEvent.CLOSE,closesmallView);
				}
				//			smallview.
				WindowManager.getInstance().popUpWindow(smallview);

//				WindowManager.getInstance().removeWindow(tradingView);
				closeTradingView();

			} else {
				if (!tradingView) {
					tradingView = new TradingShopView();
					tradingView.x = 240;
					tradingView.y = 70;
					tradingView.addEventListener(CloseEvent.CLOSE,closeTradingView);
					closesmallView();
				}

				WindowManager.getInstance().popUpWindow(tradingView);
			}


			getTradingShop_tos(TradingManager.current_trading_npcId);

		}

		private function closesmallView(e:CloseEvent = null):void {
			if (smallview) {

				WindowManager.getInstance().removeWindow(smallview);
				smallview.dispose();
				smallview = null;
			}
		}


		/**
		 * 领取商票
		 * @param npcId
		 *
		 */
		public function getTrading_tos(npcLinkVO:NpcLinkVO):void {
			var npcObj:Object = npcLinkVO.data;

			var active_p:int = GlobalObjectManager.getInstance().user.attr.active_points; //attr.active_points
			
			if(GlobalObjectManager.getInstance().user.attr.level < 30){
				Tips.getInstance().addTipsMsg("英雄，请30级以后再来找我！");
				TradingManager.getInstance().setFailreson();
				return ;
			}
			if(GlobalObjectManager.getInstance().user.base.family_id == 0){
				Tips.getInstance().addTipsMsg("加入门派后才能领取商票！");
				TradingManager.getInstance().setFailreson();
				return ;
			}
			if (beginBill > 0) {
				Tips.getInstance().addTipsMsg("您上次的商贸还没完成");
				return;
			}
			if (active_p < 6) {
				Alert.show("您的活跃度未到<font color='#00ff00'>6点</font>，完成本次商贸将获得<font color='#00ff00'>绑定</font>银子。" + "（参加门派拉镖、门派BOSS和个人拉镖可提升活跃度）",
					"提示",yeshandler,null,"领票","取消");
				return;
			}
			function yeshandler():void {
				var vo:m_trading_get_tos = new m_trading_get_tos();
				vo.map_id = SceneDataManager.mapData.map_id;
				vo.npc_id = npcObj.id;
				sendSocketMessage(vo);

			}
			var vo:m_trading_get_tos = new m_trading_get_tos();
			vo.map_id = SceneDataManager.mapData.map_id;
			vo.npc_id = npcObj.id;

			sendSocketMessage(vo);
		}

		public function getBeginBill():int {
			return beginBill;
		}

		private var currentBill:int;
		private var beginBill:int;

		private function getTrading_toc(vo:m_trading_get_toc):void {
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
//				TradingManager.getInstance().setFailreson();
				return;
			}
			beginBill = vo.bill;
			award = vo.award_type;
			//Tips.getInstance().addTipsMsg("成功领取商票");
			BroadcastSelf.getInstance().appendMsg("<font color='#ffff00'>成功领取商票。</font>");
			_times = vo.trading_times;
			haveRoleGood = false;
			MessageIconManager.getInstance().showShangmao(openIntroduce);
			//			trace(vo.succ);
		}

		/**
		 * 商贸商店信息
		 * @param npcId
		 *
		 */
		public function getTradingShop_tos(npcId:int = 11100128):void {
			var vo:m_trading_shop_tos = new m_trading_shop_tos();
			vo.map_id = SceneDataManager.mapData.map_id;
			vo.npc_id = npcId;

			TradingManager.current_trading_npcId = npcId;

			sendSocketMessage(vo);
		}

		private function tradingShopInit(vo:m_trading_shop_toc):void {
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				//BroadcastSelf.logger(vo.reason);
				return;
			}


			shopGoodsArr = TradingManager.getInstance().transShopVoArr(vo.shop_goods);

			if (vo.role_goods.length == 0) {
				haveRoleGood = false;
				if (tradingView && roleGoodArr.length > 0) {
					tradingView.clearRoleItem(roleGoodArr.length)
				}
			}

			if (vo.role_goods.length > 0) {
				roleGoodArr = TradingManager.getInstance().transRoleVoArr(vo.role_goods);
				haveRoleGood = true;
			}

			if (tradingView) {
				tradingView.setShopItemDatas(shopGoodsArr);
				if (roleGoodArr.length > 0)
					tradingView.setItemDatas(roleGoodArr);
				tradingView.setBillData(vo.bill,vo.max_bill);
				currentBill = vo.bill;
				tradingView.setData(vo);
			}
			if (smallview) {
				smallview.setData(vo);
			}
		}

		private var buypanel:BuyTradingPanel;

		public function openBuyPanle(vo:TradingGoodVo):void {
			if (!vo) {
				return;
			}
			if (!buypanel) {
				buypanel = new BuyTradingPanel();
				buypanel.addEventListener(CloseEvent.CLOSE,closeBuyPanle);
					//				buypanel.x = 240+199;
					//				buypanel.y = 90+134;
			}

			buypanel.setGoodsVo(vo);

			WindowManager.getInstance().popUpWindow(buypanel);
			WindowManager.getInstance().centerWindow(buypanel);
			//			if(tradingView)
			//			{
			//				tradingView.addChild(buypanel);
			//			}

		}

		private function closeBuyPanle(evt:CloseEvent = null):void {
			if (buypanel) {
				buypanel.dispose();
				WindowManager.getInstance().removeWindow(buypanel);
				buypanel = null;
			}
		}

		/**
		 * 购买物品
		 * @param npcId
		 * @param goodsId
		 * @param num
		 *
		 */
		public function buy_tos(npcId:int,goodsId:int,num:int):void {
			if (TradingManager.IS_LOCK) {
				Tips.getInstance().addTipsMsg("商品数量变动中，请稍候再操作。");
				closeBuyPanle();
				return;
			}
			var vo:m_trading_buy_tos = new m_trading_buy_tos();
			vo.map_id = SceneDataManager.mapData.map_id;
			vo.npc_id = npcId;
			vo.type_id = goodsId;
			vo.number = num;

			sendSocketMessage(vo);
		}

		private function tradingBuyResult(vo:m_trading_buy_toc):void {
			closeBuyPanle();
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				BuyTradingPanel.buySuccTip = "";
				return;
			}

			BroadcastSelf.getInstance().appendMsg(BuyTradingPanel.buySuccTip);
			BuyTradingPanel.buySuccTip = "";

			shopGoodsArr = TradingManager.getInstance().transShopVoArr(vo.shop_goods);

			if (vo.role_goods.length > 0) //&& roleGoodArr.length==0
			{
				TradingManager.trading_goods_npcId = TradingManager.current_trading_npcId;
				roleGoodArr = TradingManager.getInstance().transRoleVoArr(vo.role_goods);
				haveRoleGood = true;
			}

			if (tradingView) {
				tradingView.setShopItemDatas(shopGoodsArr);
				if (roleGoodArr.length > 0)
					tradingView.setItemDatas(roleGoodArr);
				currentBill = vo.bill;
				tradingView.setBillData(vo.bill);
			}
		}

		/**
		 * 卖出物品
		 * @param npcId
		 *
		 */
		public function sale_tos(npcId:int):void {
			if (TradingManager.IS_LOCK) {
				Tips.getInstance().addTipsMsg("商品数量变动中，请稍候再操作");
				return;
			}
			if (getBeginBill() == 0) {
				Tips.getInstance().addTipsMsg("没有商票，不能出售物品，请先到夏原吉领取商票");
				return;
			}
			var vo:m_trading_sale_tos = new m_trading_sale_tos();
			vo.map_id = SceneDataManager.mapData.map_id;
			vo.npc_id = npcId;

			sendSocketMessage(vo);
		}

		private var salesSuccTip:String;

		private function tradingSaleResult(vo:m_trading_sale_toc):void {
			salesSuccTip = "";
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				//				Alert.show(vo.reason,"提示",null,null,"确定","",null,false);
				return;
			}

			if (roleGoodArr.length > 0) {
				for (var i:int = 0;i < roleGoodArr.length;i++) {
					var goodVo:TradingGoodVo = roleGoodArr[i] as TradingGoodVo;
					var getMoney:String = goodVo.sale_price * goodVo.num + "文";
					salesSuccTip += "<font color='#ffff00'>卖出" + goodVo.name + "×" + goodVo.num + "，获得" + getMoney + "</font> \n";
				}
				tradingView.clearRoleItem(roleGoodArr.length);
				BroadcastSelf.logger(salesSuccTip);
			}

			while (roleGoodArr.length > 0) {
				var obj:Object = roleGoodArr.pop();
				obj = null;
			}
			haveRoleGood = false;
			roleGoodArr.length = 0;
			currentBill = vo.bill;
			tradingView.setBillData(vo.bill);

			//			SystemConfig.serverTime   秒数  判断时间是不是星期天。

		}

		private var doubleView:DoubleTipView;

		private function returnHandler(npcLinkVO:NpcLinkVO):void {
			var npcObj:Object = npcLinkVO.data;

			if (beginBill == 0) {
				Tips.getInstance().addTipsMsg("你没有可交还的商票");
				//BroadcastSelf.logger("<font color='#ffff00'>你没有可交还的商票。</font>");
				return;
			}
			if (haveRoleGood) {
				Tips.getInstance().addTipsMsg("您还有商贸商品没有出售，无法交还商票");
				//BroadcastSelf.logger("<font color='#ffff00'>您还有商贸商品没有出售，无法交还商票</font>");
				return;
			}
			var bind:String = "不";
			if (award == 2)
				bind = "";
			var getbill:int = currentBill - beginBill;
			if (getbill < 0)
				getbill = 0;
			TradingManager.current_trading_npcId = npcObj.id;

			if (!TradingManager.getInstance().isWeekDate())
				Alert.show("此时交还商票将获得" + bind + "绑定银子" + getbill + "文。","提示",yeshandler,null,"确定","取消",null);
			else {

				if (!doubleView) {
					doubleView = new DoubleTipView();

					doubleView.addEventListener(CloseEvent.CLOSE,closedoubleView);
				}
				doubleView.setGetBill(getbill,award);
				WindowManager.getInstance().popUpWindow(doubleView);
				WindowManager.getInstance().centerWindow(doubleView);

			}
			function yeshandler():void {
				return_tos(npcObj.id);
			}

		}

		public function closedoubleView(evt:CloseEvent = null):void {
			if (doubleView) {
				WindowManager.getInstance().removeWindow(doubleView);
				doubleView.dispose();
				doubleView = null;
			}
		}


		public function return_tos(npcId:int,type:int = 1,useBook:Boolean = false):void {
			var vo:m_trading_return_tos = new m_trading_return_tos();
			vo.map_id = SceneDataManager.mapData.map_id;
			vo.npc_id = npcId;
			vo.type = type; // 1 普通交还，    2 使用宝典
			if (useBook) {
				vo.type_id = TradingManager.BOOK_TYPE;
			}
			sendSocketMessage(vo);
		}

		private function tradingReturnResult(vo:m_trading_return_toc):void {
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				if (doubleView) {
					doubleView.setBtnEnabled();
				}

			} else {
				//				vo.family_contribution;vo.family_money;vo.silver;vo.trading_times;vo.type;
				MessageIconManager.getInstance().removeShangMao();
				if (doubleView) {
					closedoubleView();
				}
				//完成商贸后，右下角加上收益的提示：扣除商票成功，获得银子***文。

				var str:String = "<font color='#ffff00'>扣除商票成功，获得银子" + vo.silver + "文";
				if (vo.award_type == 2)
					str = "<font color='#ffff00'>扣除商票成功，获得绑定银子" + vo.silver + "文";
				//				Tips.getInstance().addTipsMsg(str);
				BroadcastSelf.logger(str);
				currentBill = 0;
				beginBill = 0;
				award = 1;
			}
		}

		private var exchangeView:ExchangeTipPanel;

		private function openExchange(npcLinkVO:NpcLinkVO):void {
			var npcObj:Object = npcLinkVO.data;

			if (!exchangeView) {
				exchangeView = new ExchangeTipPanel();
				exchangeView.x = 365;
				exchangeView.y = 192;
				exchangeView.addEventListener(CloseEvent.CLOSE,closeexchangeView);
			}
			exchangeView.npcID = npcObj.id;
			WindowManager.getInstance().popUpWindow(exchangeView);

			//			WindowManager.getInstance().centerWindow(exchangeView);

		}

		public function closeexchangeView(evt:CloseEvent = null):void {
			if (exchangeView) {
				WindowManager.getInstance().removeWindow(exchangeView);
				exchangeView.dispose();
				exchangeView = null;
			}
		}

		public function exchange_tos(contribution:int,npcId:int):void {
			var vo:m_trading_exchange_tos = new m_trading_exchange_tos();
			vo.family_contribution = contribution;
			vo.map_id = SceneDataManager.mapData.map_id;
			vo.npc_id = npcId;
			sendSocketMessage(vo);
		}

		private function tradingExchResult(vo:m_trading_exchange_toc):void {
			if (!vo.succ) {
				//				BroadcastSelf.logger(vo.reason);
				if (exchangeView) {
					exchangeView.setBtnEnabled();
				}
				Tips.getInstance().addTipsMsg(vo.reason);
			} else {
				if (exchangeView) {
					closeexchangeView();
				}
			}
		}


		public function getShopArr():Array {

			return shopGoodsArr;
		}

		public function getRoleArr():Array {

			return roleGoodArr;
		}

		public function getCurrentBill():int {
			return currentBill;
		}

	}
}

