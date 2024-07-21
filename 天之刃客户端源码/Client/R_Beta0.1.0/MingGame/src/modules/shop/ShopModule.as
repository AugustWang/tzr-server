package modules.shop
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.ViewLoader;
	import com.managers.Dispatch;
	import com.managers.MusicManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.geom.Point;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.finery.FineryModule;
	import modules.forgeshop.ForgeshopModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.shop.views.MyShopPanel;
	import modules.shop.views.ShopBuyView;
	import modules.shop.views.ShopNpcPanel;
	import modules.shop.views.ShopPanel;
	import modules.skillTree.SkillTreeModule;
	import modules.system.SystemConfig;
	
	import proto.line.m_role2_unbund_change_tos;
	import proto.line.m_shop_all_goods_toc;
	import proto.line.m_shop_all_goods_tos;
	import proto.line.m_shop_buy_back_toc;
	import proto.line.m_shop_buy_back_tos;
	import proto.line.m_shop_buy_toc;
	import proto.line.m_shop_buy_tos;
	import proto.line.m_shop_item_toc;
	import proto.line.m_shop_item_tos;
	import proto.line.m_shop_npc_toc;
	import proto.line.m_shop_npc_tos;
	import proto.line.m_shop_sale_toc;
	import proto.line.m_shop_sale_tos;
	import proto.line.m_shop_search_toc;
	import proto.line.m_shop_search_tos;
	import proto.line.p_shop_goods_info;
	import proto.line.p_shop_sale_goods;
	
	public class ShopModule extends BaseModule
	{
		private var shopPanel:ShopPanel;
		private var myShopPanel:MyShopPanel;
		private var shopNpcPanel:ShopNpcPanel;
		
		private var skillShop:Boolean=false;
		private var _buyNum:int=0;
		private var _buyItem:int=0;
		private var _buyShop:int=0;
		private var _buyFlag:Boolean=false;
		private var _saleGoodNum:int=0;
		private var _saleGoodName:String="";
		public var _useBind:Boolean = true;
		private var _itemBuyX:int=0;
		private var _itemBuyY:int=0;
		//是否是铁匠铺直接刚买的物品
		private var isComeFromTie:Boolean=false;
		//是否是天工炉
		private var isSkillTree:Boolean=false;
		private var isStove:Boolean=false;
		private var _alertStr:String;
		
		public function ShopModule()
		{
			super();
		}
		
		private static var instance:ShopModule;
		public static function getInstance():ShopModule {
			if (instance == null) {
				instance=new ShopModule();
			}
			return instance;
		}
	
		override protected function initListeners():void {
			this.addSocketListener(SocketCommand.SHOP_ALL_GOODS, setShopGoods);
			this.addSocketListener(SocketCommand.SHOP_BUY, buyGoods);
			this.addSocketListener(SocketCommand.SHOP_NPC, setNPCShopTypes);
			this.addSocketListener(SocketCommand.SHOP_SALE, saleGoods);
			this.addSocketListener(SocketCommand.SHOP_ITEM, shopItem);
			this.addSocketListener(SocketCommand.SHOP_BUY_BACK,setBuyBackGoods);
			this.addSocketListener(SocketCommand.SHOP_SEARCH,setSearchGoods);

			this.addMessageListener(NPCActionType.NA_2, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_3, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_30, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_32, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_38, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_58, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_76, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_33, openNPCPanel);
			this.addMessageListener(NPCActionType.NA_49, openNPCPanel);
			this.addMessageListener(ModuleCommand.PACKAGE_MONEY_CHANGE,updateMoney);
			this.addMessageListener(ModuleCommand.OPEN_SHOP_PANEL, openShopPanel);
			this.addMessageListener(ModuleCommand.OPEN_MY_SHOP,openMyShop);
			this.addMessageListener(ModuleCommand.SHOP_OPEN_PET_SHOP, openPetShop);
			this.addMessageListener(ModuleCommand.SHOP_BUY_GOODS.toString(), autoBuyGoods);
		}
		/**
		 * 打开商店窗口 
		 * @param tabIndex
		 * 
		 */		
		private function openShopPanel(tabIndex:int=-1):void{
			if(!ViewLoader.hasLoaded(GameConfig.SHOP_UI)){
				ViewLoader.load(GameConfig.SHOP_UI,openShopPanel,[tabIndex]);
				return;
			}	
			if(shopPanel == null){
				shopPanel = new ShopPanel();
				WindowManager.getInstance().centerWindow(shopPanel);
			}
			if(tabIndex != -1){
				shopPanel.selectedIndex(tabIndex);
			}
			shopPanel.open();
		}
		/**
		 * 打开NPC商店窗口 
		 * @param npc
		 * 
		 */		
		private function openNPCPanel(npc:NpcLinkVO):void{
			var npcShopTypes:Array = ShopDataManager.getInstance().getNPCShopTypes(npc.npcID);
			if (npcShopTypes == null) {
				getNPCShopTypes(npc.npcID);
				if (npc.dispatchMessage == "NPCAction_38") {
					skillShop=true;
				}
			}else{
				if (shopNpcPanel == null){
					shopNpcPanel=new ShopNpcPanel();
				}
				shopNpcPanel.npc = npc.npcID;
				shopNpcPanel.data= npcShopTypes;
				if (npc.dispatchMessage == "NPCAction_38") {
					shopNpcPanel.setSelect(GlobalObjectManager.getInstance().user.attr.category - 1);
				}
				shopNpcPanel.open();
			}
		}
		
		/**
		 * 打开随身商店 
		 */		
		private function openMyShop():void{
			if(myShopPanel == null){
				myShopPanel = new MyShopPanel();
			}
			var packPanel:BasePanel = PackManager.getInstance().packWindow;
			myShopPanel.y = packPanel.y;
			myShopPanel.x = packPanel.x - myShopPanel.width;
			if(packPanel.x - myShopPanel.width < 0){
				myShopPanel.x = packPanel.x + packPanel.width;
			}
			myShopPanel.open();
		}
		/**
		 * 更新金钱 
		 * 
		 */		
		private function updateMoney():void{
			if(shopPanel){
				shopPanel.updateGold();
			}
		}
	
		public function openOnSaleShop():void {
			openShopPanel(0);
		}
		
		public function openPetShop(value:Object=null):void {
			openShopPanel(4);
		}
		
		public function openFashionShop():void {
			openShopPanel(5);
		}
		
		/**
		 * 获取商店物品 
		 * @param shop_id
		 * @param shop_npc
		 * 
		 */		
		public function getShopGoods(shop_id:int, shop_npc:int=0):void {
			var vo:m_shop_all_goods_tos = new m_shop_all_goods_tos();
			vo.shop_id = shop_id;
			vo.npc_id = shop_npc;
			sendSocketMessage(vo);
		}
		/**
		 * 商店物品返回 
		 * @param vo
		 * 
		 */		
		private function setShopGoods(vo:m_shop_all_goods_toc):void {
			var items:Array = new Array();
			for each (var goods:p_shop_goods_info in vo.all_goods) {
				var itemVO:ShopItem = new ShopItem();
				itemVO.data = goods;
				itemVO.shopId = vo.shop_id;
				itemVO.npcId = vo.npc_id;
				items.push(itemVO);
			}
			ShopDataManager.getInstance().setShopDatas(vo.shop_id,items);
			if (vo.npc_id > 0) {
				if(vo.npc_id == MyShopPanel.MY_SHOP_NPC_ID){
					myShopPanel.openShopView(vo.shop_id);
				}else{
					shopNpcPanel.openShopView(vo.shop_id);
				}
			} else if(shopPanel){
				if(vo.shop_id != ShopConstant.TYPE_ON_RUSH){
					shopPanel.updateDataProvider();
				}else{
					dispatch(ModuleCommand.RUSH_GOODS_UPDATE);
				}
			}
		}
		/**
		 * 购回物品 
		 * @param goodsId
		 * 
		 */		
		public function buyBackGoods(goodsId:int,op_type:int=2):void{
			var vo:m_shop_buy_back_tos = new m_shop_buy_back_tos();
			vo.goods_id = goodsId;
			vo.op_type = op_type;
			sendSocketMessage(vo);
		}
		/**
		 * 购回物品返回 
		 * @param vo
		 * 
		 */		
		public function setBuyBackGoods(vo:m_shop_buy_back_toc):void{
			if(vo.succ){
				if(vo.op_type == 2){
					var backItemVO:BaseItemVO = ShopDataManager.getInstance().getBuyBackItem(vo.goods_id);
					ShopDataManager.getInstance().removeBuyBackItem(backItemVO);
					var msg:String = "成功回购";
					msg+=HtmlUtil.font("【"+backItemVO.name+"】",ItemConstant.COLOR_VALUES[backItemVO.color],14);
					if(backItemVO.num > 1){
						msg+="x"+backItemVO.num;
					}
					if(backItemVO is EquipVO){
						msg+="，扣除"+MoneyTransformUtil.silverToOtherString(EquipVO(backItemVO).getSellPrice()*backItemVO.num)+"银子";
					}else{
						msg+="，扣除"+MoneyTransformUtil.silverToOtherString(backItemVO.sellPrice*backItemVO.num)+"银子";
					}
					Tips.getInstance().addTipsMsg(msg);
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 获取NPC商店的所有类型
		 * @param npc_id
		 * 
		 */		
		public function getNPCShopTypes(npc_id:int):void {
			var vo:m_shop_npc_tos = new m_shop_npc_tos();
			vo.npc_id = npc_id;
			sendSocketMessage(vo);
		}
		/**
		 * 获取NPC商店的所有类型返回
		 * @param vo
		 * 
		 */		
		private function setNPCShopTypes(vo:m_shop_npc_toc):void {
			if(vo.shops && vo.shops.length > 0){
				ShopDataManager.getInstance().setNPCShopTypes(vo.npc_id,vo.shops);
			}
			if(vo.npc_id == MyShopPanel.MY_SHOP_NPC_ID){
				myShopPanel.data = vo.shops;
			}else{
				if (shopNpcPanel == null){
					shopNpcPanel=new ShopNpcPanel();
				}
				shopNpcPanel.npc = vo.npc_id;
				shopNpcPanel.data= vo.shops;
				if (skillShop) {
					skillShop = false;
					shopNpcPanel.setSelect(GlobalObjectManager.getInstance().user.attr.category - 1);
				}
				shopNpcPanel.open();
			}
		}
		
		private function buyGoods(vo:m_shop_buy_toc):void {
			var msg:String=new String();
			if (vo.succ) {
				if (isComeFromTie) {
					isComeFromTie=false;
					var index:int=ForgeshopModule.getInstance().index();
					if (index == 0) {
						ForgeshopModule.getInstance().requestCurrentMaterialList(0);
					} else if (index == 1) {
						ForgeshopModule.getInstance().requestEquipChangeMaterial(0);
					} else if (index == 3) {
						ForgeshopModule.getInstance().requestEquipUpdateMaterial(0);
					}
				}
				if (isStove) {
					isStove=false;
					FineryModule.getInstance().updateMaterial();
				}
				if (isSkillTree) {
					isSkillTree=false;
					SkillTreeModule.getInstance().updateFromShop();
				}
				if (vo.goods) {
					this.dispatch(ModuleCommand.BUY_ADD_ITEM, vo.goods);
				}
				// 通知角色模块修改钱
				if (vo.property) {
					var silver:int=vo.property[0];
					var silver_bind:int=vo.property[1];
					var gold:int=vo.property[2];
					var gold_bind:int=vo.property[3];
					GlobalObjectManager.getInstance().user.attr.silver=silver;
					GlobalObjectManager.getInstance().user.attr.silver_bind=silver_bind;
					GlobalObjectManager.getInstance().user.attr.gold=gold;
					GlobalObjectManager.getInstance().user.attr.gold_bind=gold_bind;
					Dispatch.dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
				}
				if (this._buyShop == 0) {
					for each (var item1:ShopItem in ShopDataManager.getInstance().searchResults) {
						if (item1.id == this._buyItem) {
							msg=item1.name + msg;
							break;
						}
					}
				} else {
					var item2:ShopItem = ShopDataManager.getInstance().getItem(_buyItem,_buyShop);
					if(item2){
						item2.num-=this._buyNum;
						msg=item2.name + msg;
					}
					msg=ShopConstant.SUCCESS_BUY + this._buyNum + ShopConstant.A + msg;
				}
			} else {
				msg=vo.reason;
			}
			switch (vo.error_code) {
				case 1: //不绑定元宝不足
					//_alertStr =  Alert.show("您的不绑定元宝不足！ <font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
					_alertStr=Alert.show("您的不绑定元宝不足！", "提示", openPay, null, "快速充值", "取消", null, true, true, null, null);
					break;
				case 2: //不绑定元宝不足
				case 3: //元宝不足
					//_alertStr =  Alert.show("您的元宝不足！ <font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
					_alertStr=Alert.show("您的元宝不足！", "提示", openPay, null, "快速充值", "取消", null, true, true, null, null);
					break;
				case 4: //不绑定银子不足
					Tips.getInstance().addTipsMsg("您的不绑定银子不足！");
					break;
				case 5: //绑定银子不足
					Tips.getInstance().addTipsMsg("您的绑定银子不足！");
					break;
				case 6: //银子不足
					Tips.getInstance().addTipsMsg("您的银子不足！");
					break;
				default:
					Tips.getInstance().addTipsMsg(msg);
					break;
			}
			this._buyFlag=false;
		}

		private function openPay():void {
			Alert.removeAlert(_alertStr);
			Dispatch.dispatch(ModuleCommand.OPEN_PAY_HANDLER);
		}
	
		public function toSaleGoods(id:int, typeid:int, pos:int, num:int, name:String):void {
			var goods:p_shop_sale_goods=new p_shop_sale_goods();
			goods.id=id;
			goods.type_id=typeid;
			goods.position=pos;
			goods.number=num;
			var vo:m_shop_sale_tos=new m_shop_sale_tos();
			vo.goods=[goods];
			this.sendSocketMessage(vo);
			this._saleGoodNum=num;
			this._saleGoodName=name;
		}
		
		private function saleGoods(vo:m_shop_sale_toc):void {
			if (!vo.succ) {
				BroadcastSelf.logger("出售失败，原因：" + vo.reason);
				return;
			}
			if (vo.property.length > 0) {
				var silver:int=vo.property[0];
				var silverBind:int=vo.property[1];
				var gold:int=vo.property[2];
				GlobalObjectManager.getInstance().user.attr.silver=silver;
				GlobalObjectManager.getInstance().user.attr.silver_bind=silverBind;
				GlobalObjectManager.getInstance().user.attr.gold=gold;
				dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
				for each(var goodsId:int in vo.ids){
					var itemVO:BaseItemVO = PackManager.getInstance().getItemById(goodsId);
					if(itemVO){
						PackManager.getInstance().updateGoods(itemVO.bagid,itemVO.position,null);
						var price:Number = itemVO.sellPrice*itemVO.num;
						if(itemVO is EquipVO){
							price = EquipVO(itemVO).getSellPrice();
						}
						var msg:String = "成功出售";
						if(itemVO.num > 1){
							msg+=HtmlUtil.font("【" + itemVO.name + "】",ItemConstant.COLOR_VALUES[itemVO.color],14) + "×" + itemVO.num + "，获得" + MoneyTransformUtil.silverToOtherString(price)+"银子"
						}else{
							msg+=HtmlUtil.font("【" + itemVO.name + "】",ItemConstant.COLOR_VALUES[itemVO.color],14) + "，获得" + MoneyTransformUtil.silverToOtherString(price)+"银子";
						}
						Tips.getInstance().addTipsMsg(msg);
						BroadcastSelf.logger(msg);
						ShopDataManager.getInstance().addBuyBackItem(itemVO);
					}
				}
				MusicManager.playSound(MusicManager.SELLGOODS);
			}
		}
		
		public function searchGoods(goodsIds:Array, npc_id:int=0):void {
			var vo:m_shop_search_tos=new m_shop_search_tos;
			if (goodsIds != null && goodsIds.length > 0) {
				vo.npc_id=npc_id;
				vo.search_goods_id=goodsIds;
				this.sendSocketMessage(vo);
			}
		}
		
		private function setSearchGoods(vo:m_shop_search_toc):void {
			var searchGoods:Array = new Array();
			for each (var goods:p_shop_goods_info in vo.search_all_goods) {
				var item:ShopItem=new ShopItem();
				item.data=goods;
				searchGoods.push(item);
			}
			ShopDataManager.getInstance().searchResults = searchGoods;
			shopPanel.updateSearchResult();
			
		}
		
		private function shopItem(vo:m_shop_item_toc):void {
			if (!vo.succ) {
				BroadcastSelf.logger("获取商品信息失败，原因：" + vo.reason);
				return;
			} else {
				var item:ShopItem=new ShopItem();
				item.data=vo.goods
				item.shopId=vo.shop_id
				
				var buyView:ShopBuyView=ShopBuyView.getInstance();
				buyView.data=item;
				buyView.showView(_useBind);
				buyView.x=this._itemBuyX;
				buyView.y=this._itemBuyY;
			}
		}
		
		/**
		 * formType 0不处理 1铁匠 2天工
		 */
		public function requestShopItem(shopId:int, itemTypeId:int, point:Point, formType:int=0,useBind:Boolean=true):void {
			switch (formType) {
				case 1:
					isComeFromTie=true;
					break;
				case 2:
					isStove=true;
					break;
				case 3:
					isSkillTree=true;
					break;
			}
			var vo:m_shop_item_tos=new m_shop_item_tos();
			vo.shop_id=shopId;
			vo.item_type_id=itemTypeId;
			this._itemBuyX=point.x;
			this._itemBuyY=point.y;
			this._useBind = useBind;
			this.sendSocketMessage(vo);
		}
		
		public function toBuyGoods(id:int, num:int, shop_id:int, price_id:int=1):void {
			if (!this._buyFlag) {
				var vo:m_shop_buy_tos = new m_shop_buy_tos();
				vo.goods_id=id;
				vo.goods_num=num;
				vo.price_id=price_id;
				vo.shop_id=shop_id;
				sendSocketMessage(vo);
				_buyShop = shop_id;
				_buyNum = num;
				_buyItem = id;
				this._buyFlag=true;
			}
		}
		
		/**
		 * 自动买药 
		 * @param hpmp
		 * 
		 */		
		private function autoBuyGoods(hpmp:int):void {
			var num:int=0;
			var itemID:int;
			var isBagNotFull:Boolean;
			var shopDataManager:ShopDataManager = ShopDataManager.getInstance();
			switch (hpmp) {
				case 0: //hp
					itemID=SystemConfig.buyHPTypeId;
					if (shopDataManager.getItemByNPCID(itemID, 0) == null) {
						getShopGoods(ShopConstant.FAST_SHOP, 0);
						return;
					} else {
						isBagNotFull=PackManager.getInstance().isBagEmpty();
						if (isBagNotFull == true) {
							var hp:ShopItem=shopDataManager.getItemByNPCID(itemID, 0);
							num=checkBuyNum(itemID, hp.priceType, hp.money);
							if (num == 0) {
								PackManager.getInstance().goBack();
							} else {
								toBuyGoods(SystemConfig.buyHPTypeId, num, hp.shopId);
							}
						}
					}
					break;
				case 1: //mp
					itemID=SystemConfig.buyMPTypeId;
					if (shopDataManager.getItemByNPCID(itemID, 0) == null) {
						getShopGoods(ShopConstant.FAST_SHOP, 0);
						return;
					} else {
						isBagNotFull=PackManager.getInstance().isBagEmpty();
						if (isBagNotFull == true) {
							var mp:ShopItem=shopDataManager.getItemByNPCID(itemID, 0);
							num=checkBuyNum(itemID, mp.priceType, mp.money);
							if (num == 0) {
								PackManager.getInstance().goBack();
							} else {
								toBuyGoods(SystemConfig.buyMPTypeId, num, mp.shopId);
							}
						}
					}
					break;
				case 2: //宠物
					itemID=SystemConfig.buyPetDrugTypeId;
					if (shopDataManager.getItemByNPCID(itemID, 0) == null) {
						getShopGoods(ShopConstant.FAST_SHOP, 0);
						return;
					} else {
						isBagNotFull=PackManager.getInstance().isBagEmpty();
						if (isBagNotFull == true) {
							var petDrug:ShopItem=shopDataManager.getItemByNPCID(itemID, 0);
							num=checkBuyNum(itemID, petDrug.priceType, petDrug.money);
							if (num == 0) {
								PackManager.getInstance().goBack();
							} else {
								toBuyGoods(SystemConfig.buyPetDrugTypeId, num, petDrug.shopId);
							}
						}
					}
					break;
				default:
					break;
			}
		}
		
		public function changeUseGoldType(selected:Boolean):void {
			var vo:m_role2_unbund_change_tos = new m_role2_unbund_change_tos();
			vo.unbund=selected;
			sendSocketMessage(vo);
		}
		
		/**
		 * 检查可购数量 
		 * 如果购买的是“护心丸”、“续命丸”、“九花玉露”、“上清玉露”，每次购买1瓶
		 */		
		private function checkBuyNum(itemID:int, priceType:int, price:int):int {
			var money:int=0;
			if (GlobalObjectManager.getInstance().user.attr.unbund) {
				if (priceType == ShopConstant.SILVER_TYPE) {
					money=GlobalObjectManager.getInstance().user.attr.silver;
				} else if (priceType == ShopConstant.GOLD_TYPE) {
					money=GlobalObjectManager.getInstance().user.attr.gold;
				}
			} else {
				if (priceType == ShopConstant.SILVER_TYPE) {
					money=GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind;
				} else if (priceType == ShopConstant.GOLD_TYPE) {
					money=GlobalObjectManager.getInstance().user.attr.gold + GlobalObjectManager.getInstance().user.attr.gold_bind;
				}
			}
			var num:int=int(money / price);
			if (num >= 20) {
				num=20;
			} else if (num >= 10) {
				num=10;
			} else if (num >= 5) {
				num=5;
			} else if (num >= 1) {
				num=1;
			}
			if (num > 0) { 
				if (itemID == 11500001 || itemID == 11500002 || itemID == 11700001 || itemID == 11700002) {
					return 1;
				}
			}
			return num;
		}
	}
}