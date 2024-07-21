package modules.mypackage
{
	
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.dragManager.DragItemManager;
	import com.common.effect.ZoomEffect;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.components.cooling.CoolingManager;
	import com.managers.Dispatch;
	import com.managers.MusicManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.net.connection.Connection;
	import com.scene.WorldManager;
	import com.scene.tile.Pt;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.buff.BuffModule;
	import modules.collect.CollectModule;
	import modules.deal.DealConstant;
	import modules.family.FamilyYBCModule;
	import modules.flowers.FlowerModule;
	import modules.greenHand.GreenHandModule;
	import modules.mount.views.MountRenewalPanel;
	import modules.mypackage.managers.ItemLinkManager;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.operateMode.OperateMode;
	import modules.mypackage.views.BugExpackView;
	import modules.mypackage.views.GoodsSellPanel;
	import modules.mypackage.views.PackageItem;
	import modules.mypackage.views.PackageWindow;
	import modules.mypackage.views.PursuePanel;
	import modules.mypackage.views.SplitItemPanel;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	import modules.navigation.NavigationModule;
	import modules.needfire.NeedfieModule;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.personalybc.PersonalYbcModule;
	import modules.pet.PetModule;
	import modules.playerGuide.GuideConstant;
	import modules.playerGuide.PlayerGuideModule;
	import modules.rank.view.RankEquipToolTip;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.views.details.RoleMyMountView;
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;
	import modules.warehouse.WarehouseModule;
	
	import proto.common.p_goods;
	import proto.line.*;
	
	public class PackageModule extends BaseModule
	{
		private var useGoodsEnabled:Boolean=true;
		private var enabledDesc:String;
		private var packManager:PackManager;
		
		public function PackageModule()
		{
			
		}
		
		private static var instance:PackageModule;
		public static function getInstance():PackageModule
		{
			if (instance == null)
			{
				instance=new PackageModule();
			}
			return instance;
		}
		
		override protected function initListeners():void{
			packManager = PackManager.getInstance();
			addMessageListener(ModuleCommand.BUY_ADD_ITEM,createItems);
			addMessageListener(ModuleCommand.LETTER_GET_ACCESSORY,createItem);
			addMessageListener(ModuleCommand.PICK_UP_GOODS,createItem);
			addMessageListener(ModuleCommand.OPEN_PACK_PANEL,openPackWindow);
			addMessageListener(ModuleCommand.OPEN_PACK_PANEL_WHEN_NOT_POP_UP,openPackWindowWhenNotPopUp);
			addMessageListener(ModuleCommand.PACKAGE_MONEY_CHANGE,packManager.updateMoney);
			addMessageListener(ModuleCommand.DEAL_ITEM_CHANGE,updatePackageItem);
			addMessageListener(ModuleCommand.GOODS_INIT,initGoods);
			addMessageListener(ModuleCommand.MP_HP_CHANGED,packManager.autoResume);
			addMessageListener(ModuleCommand.USEGOODS_ENABLE,setUseGoodsEnabled);
			addMessageListener(ModuleCommand.MOUNT_UP_FAR_RUN, mouseUpFarRun);
			
			addMessageListener(NPCActionType.NA_59, onFixAll);
			
			addMessageListener(NPCActionType.NA_37, onFixAll);
			addMessageListener(NPCActionType.NA_36, onFixAll);
			addSocketListener(SocketCommand.EQUIP_LOAD,setUseEquip);
			addSocketListener(SocketCommand.EQUIP_UNLOAD,setunLoadEquip);
			addSocketListener(SocketCommand.EQUIP_MOUNTUP,mountUpBack);
			addSocketListener(SocketCommand.EQUIP_MOUNTDOWN,mountDownBack);
			addSocketListener(SocketCommand.EQUIP_SWAP,equipswap);
			addSocketListener(SocketCommand.ITEM_USE,setUseItem);
			addSocketListener(SocketCommand.GOODS_INBAG_LIST,setItems);
			addSocketListener(SocketCommand.GOODS_INFO,setInfo);
			addSocketListener(SocketCommand.GOODS_SWAP,setSwap);
			addSocketListener(SocketCommand.GOODS_DESTROY,setDestory);
			addSocketListener(SocketCommand.GOODS_DIVIDE,setDivideGoods);
			addSocketListener(SocketCommand.GOODS_UPDATE,updateGoods);
			addSocketListener(SocketCommand.GOODS_TIDY,goodsTidy);
			addSocketListener(SocketCommand.EQUIP_ENDURANCE_CHANGE,updateEquipEndurance);
			addSocketListener(SocketCommand.ITEM_NEW_EXTEND_BAG,newExtralPack);
			addSocketListener(SocketCommand.ITEM_SHRINK_BAG,deleteExtralPack);
			addSocketListener(SocketCommand.EQUIP_FIX,setEquipFix);
			addSocketListener(SocketCommand.GOODS_SHOW_GOODS,setShowGoods);
			addSocketListener(SocketCommand.ITEM_TRACE,setItemTrace);
			addSocketListener(SocketCommand.EQUIP_MOUNT_RENEWAL,doMountRenewalToc);
			addSocketListener(SocketCommand.ITEM_BATCH_SELL, doBatchSell);
		}
		private function mouseUpFarRun():void{
			if(PersonalYbcModule.getInstance().doingYBC==false&&FamilyYBCModule.getInstance().showYbcArrow==false){
				if(GlobalObjectManager.getInstance().isMount==false){
					mountUp();
				}
			}
		}
		private function onFixAll(vo:NpcLinkVO=null):void
		{
			if(CursorManager.getInstance().currentCursor == CursorName.HAMMER){
				CursorManager.getInstance().hideCursor(CursorName.HAMMER);
			}
			fixEquip(0,false);
		}
		
		private function setUseGoodsEnabled(data:Object):void{
			useGoodsEnabled=data.enabled;
			enabledDesc=data.desc;
		}
		
		private function initGoods(data:Object):void{
			var array:Array = data as Array;
			for each (var pbagContent:p_bag_content in array){
				if(pbagContent.bag_id == PackManager.PACK_1){
					packManager.extensionPack(pbagContent.bag_id,pbagContent.rows,pbagContent.columns,pbagContent.grid_number);
					pushItems(pbagContent.bag_id, pbagContent.goods,PackManager.MAIN_PACK_COUNT);
				}else{
					packManager.addExtralItem(pbagContent.bag_id,pbagContent.typeid,pbagContent.grid_number);
				}
			}
		}
		
		private function updatePackageItem(obj:Object):void
		{
			var sendArr:Array=obj.send;
			var returnArr:Array=obj.riturn;
			for (var i:int=0; i < sendArr.length; i++)
			{
				var sendOid:int=sendArr[i].oid;
				var sendBagid:int=sendArr[i].bagid
				packManager.removeGoods(sendOid, sendBagid);
			}
			for (var k:int=0; k < returnArr.length; k++)
			{
				var returnPosition:int=returnArr[k].position
				var returnBagid:int=returnArr[k].bagid
				var baseItem:BaseItemVO=returnArr[k].baseItemVO
				packManager.updateGoods(returnBagid, returnPosition, baseItem);
			}
		}
		
		/**
		 * 背包没打开时才触发
		 */
		private var packWindow:PackageWindow;
		private function openPackWindowWhenNotPopUp(point:Point=null):void{
			packWindow = packManager.packWindow;
			if(!packWindow || !WindowManager.getInstance().isPopUp(packWindow)){
				openPackWindow(point)
			}
		}
		
		public function openPackWindow(point:Point=null):void{
			if (point){
				packManager.popUpWindow(PackManager.PACK_1, point.x, point.y);
			}else{
				packManager.popUpWindow(PackManager.PACK_1, NaN, NaN);
				NavigationModule.getInstance().stopBagFlick();
			}
		}
		
		public function openBTWindow():void{
			packManager.popUpWindow(PackManager.PACK_1, NaN, NaN, false);
			packManager.openBTWindow();
		}
		
		public function getBaseItemVO(vo:p_goods):BaseItemVO{
			return ItemConstant.wrapperItemVO(vo);
		}
		
		private function newExtralPack(toc:m_item_new_extend_bag_toc):void{
			packManager.extensionPack(toc.bagid, toc.main_rows, toc.main_columns,toc.main_grid_number);
			packManager.addExtralItem(toc.bagid,toc.typeid,toc.grid_number);
		}
		
		private function deleteExtralPack(toc:m_item_shrink_bag_toc):void{
			if (toc.succ){
				var item:BaseItemVO=getBaseItemVO(toc.item);
				packManager.updateGoods(item.bagid, item.position, item);
				packManager.extensionPack(toc.bagid,toc.rows,toc.columns,toc.grid_number);
				packManager.deletedExtralItem(toc.bagid);
			}else{
				BroadcastSelf.logger(toc.reason);
			}
		}
		
		/**
		 *打开扩展背包 
		 * 
		 */	
		//购买扩展背包界面
		private var exPack:BugExpackView;
		public function openExPack():void{
			if(exPack==null){
				exPack=new BugExpackView();
			}
			exPack.open();
		}
		
		private function updateEquipEndurance(vo:m_equip_endurance_change_toc):void{
			updateEquipsEndurace(vo.equip_list);
		}
		
		private function updateEquipsEndurace(equips:Array, isfix:Boolean=false):void
		{
			for each (var equip:p_equip_endurance_info in equips)
			{
				var equipVO:EquipVO=packManager.getItemById(equip.equip_id)as EquipVO;
				if (equipVO)
				{
					equipVO.current_endurance=equip.num;
					equipVO.endurance=equip.max_num;
					packManager.updateGoods(equipVO.bagid, equipVO.position, equipVO);
					if (isfix)
					{
						BroadcastSelf.logger("恭喜你【" + equipVO.name + "】修理成功！");
					}
					continue;
				}
				equipVO=RoleStateDateManager.getEquipById(equip.equip_id);
				if (equipVO)
				{
					equipVO.current_endurance=equip.num;
					equipVO.endurance=equip.max_num;
					this.dispatch(ModuleCommand.EQUIP_ENDURACE_CHANGED,equip);//TODO 人物状态模块需要处理此消息
					if (isfix)
					{
						BroadcastSelf.logger("恭喜你【" + equipVO.name + "】修理成功！");
					}
					continue;
				}
			}
		}
		
		private function goodsTidy(data:Object):void
		{
			var vo:m_goods_tidy_toc=data as m_goods_tidy_toc;
			//只是整理主背包
			pushItems(vo.bagid, vo.goods, PackManager.MAIN_PACK_COUNT);
		}
		
		private function setEquipFix(data:Object):void
		{
			var vo:m_equip_fix_toc=data as m_equip_fix_toc;
			if (vo.succ)
			{
				var useMoney:Number=GlobalObjectManager.getInstance().user.attr.silver - vo.silver;
				useMoney=useMoney + GlobalObjectManager.getInstance().user.attr.silver_bind - vo.bind_silver;
				GlobalObjectManager.getInstance().user.attr.silver=vo.silver;
				GlobalObjectManager.getInstance().user.attr.silver_bind=vo.bind_silver;
				packManager.updateMoney();
				updateEquipsEndurace(vo.equip_list, true);
				BroadcastSelf.logger("本次修理一共花费银子" + MoneyTransformUtil.silverToOtherString(useMoney));
			}
			else
			{
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private var inSellVo:Dictionary = new Dictionary;
		private var inSellNum:int = 0;
		
		public function isSellFull():Boolean
		{
			return inSellNum >= PackManager.MAIN_PACK_COUNT;
		}
		
		public function sellAllInSell():void
		{
			var vo:m_item_batch_sell_tos = new m_item_batch_sell_tos;
			var arr:Array = new Array;
			for each(var baseVO:BaseItemVO in inSellVo) 
			{
				arr.push(baseVO.oid);
			}
			vo.id_list = arr;
			sendSocketMessage(vo);
		}
		
		public function updateSellPanel():void
		{
			var silver:int = 0;
			var silverBind:int = 0;
			for each (var baseVO:BaseItemVO in this.inSellVo) {
				if (baseVO.sellType == 1) {
					if (baseVO is EquipVO) {
						if (baseVO.bind) {
							silverBind += (baseVO as EquipVO).getSellPrice();
						} else {
							silver += (baseVO as EquipVO).getSellPrice();
						}
					} else {
						if (baseVO.bind) {
							silverBind += baseVO.sellPrice * baseVO.num;
						} else {
							silver += baseVO.sellPrice * baseVO.num;
						}
					}
				}
			}
			
			var silverStr:String = DealConstant.silverToOtherHtml(silver);
			var silverBindStr:String = DealConstant.silverToOtherHtml(silverBind);
			if (silverStr == '') {
				silverStr = "0文";
			} 
			if (silverBindStr == '') {
				silverStr = "0文";
			}
			this.sellPanel.update(silverStr, silverBindStr);
		}
		
		public var sellPanel:GoodsSellPanel;
		public function showSellPanel():void{
			if (sellPanel == null) {
				sellPanel = new GoodsSellPanel;
			}
			WindowManager.getInstance().popUpWindow(sellPanel);
			var packW:BasePanel = packManager.packWindow;
			if (sellPanel.visible) {
				lockAllCannotSellGoods();
			} else {
				unlockAllCannotSellGoods();
			}
			sellPanel.y = packW.y = 92;
			packW.x = 275;
			sellPanel.x = packW.width+packW.x;
		}
		
		/**
		 * 准备用来支持双击物品，东西就到了右边的卖出面板 
		 */		
		public static var IN_SELL_MODE:Boolean = false;
		private function lockAllCannotSellGoods():void
		{
			IN_SELL_MODE = true;
			var arr:Array = packManager.getItemsByPackId(PackManager.PACK_1);
			for each (var vo:BaseItemVO in arr)
			{
				if (vo != null) {
					if (vo.sellType == 0) {
						packManager.lockGoods(vo, true);
					}
				}
			}
			
			if(PackManager.PACK_2)
			{
				var arr2:Array = packManager.getItemsByPackId(PackManager.PACK_2);
				for each (var vo2:BaseItemVO in arr2)
				{
					if (vo2 != null) {
						if (vo2.sellType == 0) {
							packManager.lockGoods(vo2, true);
						}
					}
				}
			}
			
			if(PackManager.PACK_3)
			{
				var arr3:Array = packManager.getItemsByPackId(PackManager.PACK_3);
				for each (var vo3:BaseItemVO in arr3)
				{
					if (vo3 != null) {
						if (vo3.sellType == 0) {
							packManager.lockGoods(vo3, true);
						}
					}
				}
			}	
		}
		
		
		public function insertToSell(baseItemVO:BaseItemVO):void
		{
			this.packManager.lockGoods(baseItemVO, true);
			this.sellPanel.push(baseItemVO);
		}
		
		private function unlockAllCannotSellGoods():void
		{
			IN_SELL_MODE = false;
			
			var arr:Array = packManager.getItemsByPackId(PackManager.PACK_1);
			for each (var vo:BaseItemVO in arr)
			{
				if (vo != null) {
					if (vo.sellType == 0) {
						packManager.lockGoods(vo, false);
					}
				}
			}
			
			if(PackManager.PACK_2)
			{
				var arr2:Array = packManager.getItemsByPackId(PackManager.PACK_2);
				for each (var vo2:BaseItemVO in arr2)
				{
					if (vo2 != null) {
						if (vo2.sellType == 0) {
							packManager.lockGoods(vo2, false);
						}
					}
				}
			}
			
			if(PackManager.PACK_3)
			{
				var arr3:Array = packManager.getItemsByPackId(PackManager.PACK_3);
				for each (var vo3:BaseItemVO in arr3)
				{
					if (vo3 != null) {
						if (vo3.sellType == 0) {
							packManager.lockGoods(vo3, false);
						}
					}
				}
			}
			
			
		}
		
		
		/**
		 * 拖进出售面板 
		 * @param baseItemVo
		 * 
		 */		
		public function onDragInSell(baseItemVo:BaseItemVO):void
		{
			packManager.lockGoods(baseItemVo, true);
			inSellVo[baseItemVo] = baseItemVo;
			updateSellPanel();
			inSellNum++;
		}
		
		private function doBatchSell(data:Object):void
		{
			var vo:m_item_batch_sell_toc = data as m_item_batch_sell_toc;
			if (vo.succ) {
				for each (var baseItemVO:BaseItemVO in inSellVo) {
					packManager.lockGoods(baseItemVO, false);
				}
				for each (var baseItemVO2:BaseItemVO in inSellVo) {
					packManager.removeGoods(baseItemVO2.oid);
				}
				IN_SELL_MODE = false;
				WindowManager.getInstance().removeWindow(this.sellPanel);
				inSellNum = 0;
				this.inSellVo = new Dictionary;
				updateSellPanel();
				var silverStr:String = DealConstant.silverToOtherString(vo.silver);
				var silverBindStr:String = DealConstant.silverToOtherString(vo.bind_silver);
				BroadcastSelf.getInstance().appendMsg("本次售出物品共获得：\n不绑定银子 " + 
					silverStr + "， 绑定银子 " + silverBindStr);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		public function cancelSell():void
		{
			for each (var vo:BaseItemVO in inSellVo) {
				packManager.lockGoods(vo, false);
				delete inSellVo[vo];
			}
			unlockAllCannotSellGoods();
			inSellNum = 0;
		}
		
		/**
		 * 拖出出售面板 
		 * 
		 */		
		public function onDragOutSell(baseItemVo:BaseItemVO):void
		{
			packManager.lockGoods(baseItemVo, false);
			delete inSellVo[baseItemVo];
			updateSellPanel();
			inSellNum--;
		}
		
		private function setunLoadEquip(data:Object):void
		{
			var vo:m_equip_unload_toc=data as m_equip_unload_toc;
			if (vo.succ)
			{
				this.dispatch(ModuleCommand.EQUIP_UNLOAD,vo.equip);//TODO 需要人物模块处理此消息
				var equipVo:EquipVO=RoleStateDateManager.getEquipById(vo.equip.id);
				var newItemVO:BaseItemVO=getBaseItemVO(vo.equip);
				packManager.updateGoods(newItemVO.bagid, newItemVO.position, newItemVO);
				BroadcastSelf.logger("成功卸掉" + newItemVO.name);
				MountRenewalPanel.getInstance().closePanel();
			}
			else
			{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		private function updateGoods(data:Object):void
		{
			var toc:m_goods_update_toc=data as m_goods_update_toc;
			var goods:Array=toc.goods;
			for each (var goodsVO:p_goods in goods)
			{
				if (goodsVO)
				{
					var baseItemVO:BaseItemVO=getBaseItemVO(goodsVO);
					if (baseItemVO.bagid != 0)
					{
						if( baseItemVO.bagid>5 && baseItemVO.bagid<10 && goodsVO.current_num==0 ){
							//删除仓库里面的物品
							WarehouseModule.getInstance().deleteGoods(goodsVO);
						}
						var newGoods:Boolean = packManager.getItemById(baseItemVO.oid) == null;
						packManager.updateGoods(baseItemVO.bagid, baseItemVO.position, baseItemVO);
						sendToHotBox(baseItemVO);
						if(newGoods){
							zoomTo(baseItemVO.path);
						}
					}
				}
			}
		}
		
		/**
		 * 获取数据集合到背包(返回)
		 */
		private function setItems(data:Object):void{
			var goods_toc:m_goods_inbag_list_toc=data as m_goods_inbag_list_toc;
			pushItems(goods_toc.bagid, goods_toc.goods, PackManager.MAIN_PACK_COUNT);
		}
		
		private function pushItems(bagId:int, goods:Array, count:int):void{
			var items:Array=new Array(count);
			for each (var goodsVO:p_goods in goods){
				var baseItemVO:BaseItemVO=getBaseItemVO(goodsVO);
				items[baseItemVO.position - 1]=baseItemVO;
			}
			packManager.setGoods(bagId, items);
		}
		
		/**
		 * 获取详细信息(返回)
		 */
		private function setInfo(data:Object):void
		{
			var goodsInfo:m_goods_info_toc=data as m_goods_info_toc;
			if(goodsInfo.succ){
				var info:BaseItemVO=getBaseItemVO(goodsInfo.info);
				if (goodsInfo.type == 1){
					RankEquipToolTip.getInstance().show(info);
				}
			}else{
				Tips.getInstance().addTipsMsg("该道具不存在：已经被使用或者出售！");
			}
		}
		
		/**
		 * 销毁项目(返回)
		 */
		private function setDestory(data:Object):void
		{
			var destory_toc:m_goods_destroy_toc=data as m_goods_destroy_toc;
			if (destory_toc.succ)
			{
				MusicManager.playSound(MusicManager.DISPOSE);
				var temp_item:BaseItemVO = PackManager.getInstance().getItemById(destory_toc.id);
				if(temp_item)
				{
					var color:String = ItemConstant.COLOR_VALUES[temp_item.color];
					BroadcastSelf.logger("成功丢弃"+ HtmlUtil.font("【"+ temp_item.name + "】x "+temp_item.num,color) );
				}
				
				
				packManager.removeGoods(destory_toc.id);
//				RoleStateModel.getInstance().removeEquipById(destory_toc.id);
			}
			else
			{
				BroadcastSelf.logger(destory_toc.reason);
			}
		}
		
		/**
		 * 使用物品(返回)
		 */
		private function setUseItem(data:Object):void
		{
			var generalVo:m_item_use_toc=data as m_item_use_toc;
			if (generalVo.succ)
			{
				var baseItem:BaseItemVO=packManager.getItemById(generalVo.itemid);
				if (baseItem)
				{
					baseItem.num=generalVo.rest;
					packManager.updateGoods(baseItem.bagid, baseItem.position, baseItem);
					var generalVO:GeneralVO=baseItem as GeneralVO;
					var cdTime:int=0;
					if (generalVO)
					{
						cdTime=ItemConstant.getCDS(generalVO.effectType);
					}
					
					if (cdTime > 0)
					{
						CoolingManager.getInstance().startCooling(generalVO.effectType.toString(), cdTime);
					}
					
					if (generalVO && generalVO.effectType == ItemConstant.EFFECT_EXP){
						var bei:Number=ItemConstant.EXP_TIP[generalVO.name];
						BroadcastSelf.logger("成功使用【" + generalVO.name + "】，" + bei + "倍经验效果增加1个小时，");
						return ;
					}
					if(generalVO && generalVO.effectType == ItemConstant.EFFECT_HCL){
						PersonalYbcModule.getInstance().view.setHCLNum();
					}
					if(generalVO && generalVO.effectType == ItemConstant.EFFECT_ADD_DRUNK_BUF){
						NeedfieModule.getInstance().checkDrink();
					}
//					if(NavigationModel.getInstance().isShow && generalVO.effectType == ItemConstant.EFFECT_HP){
//						TaskModule.getInstance().tipsView.remove();	
//						NavigationModel.getInstance().isShow = false; 
//					}
				}
				if(PlayerGuideModule.getInstance().goodsId == generalVo.itemid){
					Dispatch.dispatch(GuideConstant.REMOVE_TASK_GUIDE);
				}
			}
			if (generalVo.reason.length > 0)
			{
				BroadcastSelf.logger(generalVo.reason.join("\n"));
			}
		}
		
		/**
		 *上马(返回) 
		 */		
		private function mountUpBack(data:Object):void{
			var m_equip:m_equip_mountup_toc = data as m_equip_mountup_toc;
			if (!m_equip.succ){
				BroadcastSelf.logger(m_equip.reason);
			}
		}
		
		/**
		 *下马(返回) 
		 */		
		private function mountDownBack(data:Object):void{
			var vo:m_equip_mountdown_toc = data as m_equip_mountdown_toc;
			if (!vo.succ){
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		/**
		 * 使用武器(返回)
		 */
		private function setUseEquip(data:Object):void
		{
			var m_equip:m_equip_load_toc=data as m_equip_load_toc;
			if (m_equip.succ)
			{
				var equipVo:EquipVO;
				var equipVo1:EquipVO;
				equipVo=packManager.getItemById(m_equip.equip1.id)as EquipVO;
				equipVo.copy(m_equip.equip1);
				equipVo1=getBaseItemVO(m_equip.equip2)as EquipVO;
				this.dispatch(ModuleCommand.EQUIP_CHANGED,m_equip.equip1)//TODO 人物模块需要处理此消息
				packManager.updateGoods(m_equip.equip2.bagid, m_equip.equip2.bagposition, equipVo1);
				MusicManager.playSound(MusicManager.CHANGEEQUIP);
				if( equipVo.kind == ItemConstant.KIND_EQUIP_MOUNT ){
					BroadcastSelf.logger("成功穿上了" + equipVo.name);
				}
				if(PlayerGuideModule.getInstance().goodsId == equipVo.oid){
					Dispatch.dispatch(GuideConstant.REMOVE_TASK_GUIDE);
				}
			}
			else
			{
				BroadcastSelf.logger(m_equip.reason);
				equipVo=getBaseItemVO(m_equip.equip1)as EquipVO;
				if (equipVo)
				{
					packManager.updateGoods(equipVo.bagid, equipVo.position, equipVo);
				}
			}
		}
		
		/**
		 * 物品位置交换返回
		 */
		private function setSwap(data:Object):void
		{
			var goods_toc:m_goods_swap_toc=data as m_goods_swap_toc;
			if (!goods_toc.succ)
			{
				BroadcastSelf.logger(goods_toc.reason);
				return ;
			}
			var baseItemVO1:BaseItemVO=getBaseItemVO(goods_toc.goods1);
			var baseItemVO2:BaseItemVO=getBaseItemVO(goods_toc.goods2);
			packManager.updateGoods(goods_toc.goods1.bagid, goods_toc.goods1.bagposition, baseItemVO1);
			packManager.updateGoods(goods_toc.goods2.bagid, goods_toc.goods2.bagposition, baseItemVO2);
		}
		
		private function equipswap(data:Object):void
		{
			var equiptoc:m_equip_swap_toc=data as m_equip_swap_toc;
			if (!equiptoc.succ)
			{
				BroadcastSelf.logger(equiptoc.reason);
				return ;
			}
			var equipVO1:EquipVO=getBaseItemVO(equiptoc.equip1)as EquipVO;
			var equipVO2:EquipVO=getBaseItemVO(equiptoc.equip2)as EquipVO;
		}
		
		private function setDivideGoods(data:Object):void
		{
			var goodsdivideVo:m_goods_divide_toc=data as m_goods_divide_toc;
			if (goodsdivideVo.succ)
			{
				var goodVO1:BaseItemVO=getBaseItemVO(goodsdivideVo.goods1);
				var goodVO2:BaseItemVO=getBaseItemVO(goodsdivideVo.goods2);
				packManager.updateGoods(goodVO1.bagid, goodVO1.position, goodVO1);
				packManager.updateGoods(goodVO2.bagid, goodVO2.position, goodVO2);
			}
			else
			{
				goodVO1=getBaseItemVO(goodsdivideVo.goods1);
				packManager.updateGoods(goodVO1.bagid, goodVO1.position, goodVO1);
			}
		}
		
		private function createItems(goodItems:Array):void
		{
			for each (var goods:p_goods in goodItems)
			{
				createItem(goods);
			}
		}
		
		private var zoomEffect:ZoomEffect = new ZoomEffect();
		private function createItem(goods:p_goods):void
		{
			if (goods)
			{
				var goodsVO:BaseItemVO=getBaseItemVO(goods);
				packManager.updateGoods(goodsVO.bagid, goodsVO.position, goodsVO);
				sendToHotBox(goodsVO);
				zoomTo(goodsVO.path);
			}
		}
		
		private function zoomTo(path:String):void{
			var bag:Sprite = NavigationModule.getInstance().navBar.bag;
			var targetPt:Point = new Point(bag.x + 25,bag.y + 25);
			targetPt = bag.parent.localToGlobal(targetPt);
			var cx:int = GlobalObjectManager.GAME_WIDTH*0.5;
			var cy:int = GlobalObjectManager.GAME_HEIGHT-200;
			zoomEffect.zoomTo(path,cx+100,cy-100,targetPt.x,targetPt.y,cx,cy,0,0,20);
		}
		
		public function sendToHotBox(itemVO:BaseItemVO):void
		{
			if (itemVO && (itemVO.name == ItemConstant.SMALL_MP || itemVO.name == ItemConstant.SMALL_HP || itemVO.kind == ItemConstant.KIND_EQUIP_MOUNT))
			{
				NavigationModule.getInstance().addItemToEnd(itemVO);
			}
		}
		
		public function fixEquip(equipId:int, fixtype:Boolean=true):void
		{
			var vo:m_equip_fix_tos=new m_equip_fix_tos();
			vo.fix_type=fixtype;
			vo.equip_id=equipId;
			this.sendSocketMessage(vo);
		}
		
		public function swapRoleItem(itemId:int, pos:int):void
		{
			var vo:m_equip_swap_tos=new m_equip_swap_tos();
			vo.equipid1=itemId;
			vo.position2=pos;
			this.sendSocketMessage(vo);
		}
		/**
		 * 坐骑过程，自动弹出续期操作界面 
		 * @param mountVO
		 * 
		 */		
		public function doMountRenewalTos(mountVO:EquipVO,opType:int = 1,renewalType:int = 0,mountPos:int = 1):void{
			var vo:m_equip_mount_renewal_tos = new m_equip_mount_renewal_tos;
			vo.op_type = opType;
			vo.mount_type_id = mountVO.typeId;
			vo.mount_id = mountVO.oid;
			vo.renewal_type = renewalType;
			vo.mount_pos = mountPos;
			this.sendSocketMessage(vo);
		}
		private function doMountRenewalToc(data:Object):void{
			var vo:m_equip_mount_renewal_toc = data as m_equip_mount_renewal_toc;
			if(vo.op_type == 1){//查询
				if(vo.succ){
					MountRenewalPanel.getInstance().openPanel(vo);
				}else{
					Tips.getInstance().addTipsMsg(vo.reason);
				}
			}else if(vo.op_type == 2){//续期
				if(vo.succ){
					MountRenewalPanel.getInstance().openPanel(vo);
					var mountVO:BaseItemVO = ItemConstant.wrapperItemVO(vo.mount);
					if(vo.mount_pos == 1){
						//更新背包的坐骑信息
						packManager.updateGoods(mountVO.bagid,mountVO.position,mountVO);
					}
					if(vo.mount_pos == 2){
						//更新人物界面的坐骑信息
						if(GlobalObjectManager.getInstance().user.attr.equips != null
							&& GlobalObjectManager.getInstance().user.attr.equips.length > 0){
							var roleCurMount:p_goods = null;
							for( var i:int = 0; i <  GlobalObjectManager.getInstance().user.attr.equips.length; i++ ){
								roleCurMount = GlobalObjectManager.getInstance().user.attr.equips[i] as p_goods;
								if(roleCurMount.loadposition == RoleMyMountView.MOUNT_POS
									&& roleCurMount.typeid == vo.mount.typeid
									&& roleCurMount.type == vo.mount.type
									&& roleCurMount.id == vo.mount.id){
									GlobalObjectManager.getInstance().user.attr.equips[i] = vo.mount;
									break;
								}
							}
							this.dispatch(ModuleCommand.MOUNT_RENEWAL);//TODO 事件已经发出，场景还没有处理
						}
					}
					if(vo.renewal_type == 9){
						Tips.getInstance().addTipsMsg("恭喜你，【" +mountVO.name+ "】续期成功，有效期为：永久");
						BroadcastSelf.logger("<font color='#3BE450'>坐骑续期成功，扣除费用： " + vo.op_fee.toString() + " 元宝，有效期为：永久</font>");
					}else{
						Tips.getInstance().addTipsMsg("恭喜你，【" +mountVO.name+ "】续期成功，有效期为：" +　DateFormatUtil.formatPassDate(mountVO.timeoutData));
						BroadcastSelf.logger("<font color='#3BE450'>坐骑续期成功，扣除费用： " + vo.op_fee.toString() + " 元宝，" +
							"有效期为：" +　DateFormatUtil.formatPassDate(mountVO.timeoutData) + "</font>");
					}
				}else{
					Tips.getInstance().addTipsMsg(vo.reason);
				}
			}
		}
		/**
		 *装备马
		 */	
		public function useMount(mountVO:EquipVO):void{
			RoleStateDateManager.choosePositionToPut(mountVO);
		}
		
		/**
		 * 坐骑热键
		 */		
		public function mountFromHotKey():void{
			var mountID:int = GlobalObjectManager.getInstance().getMountID();
			if( GlobalObjectManager.getInstance().isMount ){
				mountDown( mountID );
			}else{
				if( GlobalObjectManager.getInstance().getMountID() == -1 ){
					BroadcastSelf.logger("坐骑界面中找不到任何坐骑");
					return;
				}else if(OperateMode.getInstance().modeName == OperateMode.BT_MODE){
					BroadcastSelf.logger("摆摊中，无法驾驭坐骑，请先按“K”收摊");
					return;
				}else{
					mountUp( mountID );
				}
			}
		}
		
		//add by handing @2011.4.20 16.47
		private var lastTime:int=0;
		
		//updata by handing @2011.4.20 16.47
		public function mountUp(mountid:int=0):void
		{
			mountid = GlobalObjectManager.getInstance().getMountID();
			if( CollectModule.getInstance().isCollectIng ){
				BroadcastSelf.getInstance().appendMsg("采集中，无法驾驭坐骑");
				return;
			}
			if( GlobalObjectManager.getInstance().getMountID() != -1 ){
				var phase:int = getTimer() - lastTime;
				if(phase > 500)
				{
					//记录下这个时间
					lastTime = getTimer();
					
					//可以发送请求给后台了
					var vo:m_equip_mountup_tos = new m_equip_mountup_tos();
					vo.mountid = mountid;
					this.sendSocketMessage(vo);
				}
			}
		}
		
		//updata by handing @2011.4.20 16.47
		public function mountDown(mountid:int=0, bagid:int=0, position:int=0):void
		{
			if( GlobalObjectManager.getInstance().getMountID() != -1 ){
				if (GlobalObjectManager.getInstance().user.attr.skin.mounts > 0) {
					var phase:int = getTimer() - lastTime;
					if(phase > 500)
					{
						//记录时间
						lastTime = getTimer();
						
						//可以发送请求给后台了
						var vo:m_equip_mountdown_tos = new m_equip_mountdown_tos();
						if(mountid == 0){
							mountid = GlobalObjectManager.getInstance().getMountID();
						}
						vo.mountid = mountid;
						vo.bagid = 0;
						vo.position = 0;
						this.sendSocketMessage(vo);
					}
				}
			}
		}
		
		public function useItem(itemId:int, usenum:int=1, effectId:int=0):void{
			var vo:m_item_use_tos=new m_item_use_tos();
			vo.itemid=itemId;
			vo.usenum=usenum;
			vo.effect_id=effectId;
			this.sendSocketMessage(vo);
		}
		
		public function useEquip(equipId:int, equipPosition:int):void
		{
			var vo:m_equip_load_tos=new m_equip_load_tos();
			vo.equipid=equipId;
			vo.equip_slot_num=equipPosition;
			this.sendSocketMessage(vo);
		}
		
		public function destoryGoods(goodsId:int):void
		{
			var vo:m_goods_destroy_tos=new m_goods_destroy_tos();
			vo.id=goodsId;
			this.sendSocketMessage(vo);
		}
		
		public function swap(itemId:int, position:int, bagId:int):void
		{
			var vo:m_goods_swap_tos=new m_goods_swap_tos();
			vo.id1=itemId;
			vo.bagid2=bagId;
			vo.position2=position;
			this.sendSocketMessage(vo);
		}
		
		
		public function getGoodsInfo(goodsId:int,roleId:int,type:int=0):void
		{
			var vo:m_goods_info_tos=new m_goods_info_tos();
			vo.type=type;
			vo.id=goodsId;
			vo.target_id = roleId;
			this.sendSocketMessage(vo);
		}
		
		public function getGoods(bagId:int):void
		{
			var vo:m_goods_inbag_list_tos=new m_goods_inbag_list_tos();
			vo.bagid=bagId;
			this.sendSocketMessage(vo);
		}
		
		public function divideGoods(itemId:int, num:int, pos:int, bagid:int):void
		{
			var vo:m_goods_divide_tos=new m_goods_divide_tos();
			vo.id=itemId;
			vo.num=num;
			vo.bagposition=pos;
			vo.bagid=bagid;
			this.sendSocketMessage(vo);
		}
		
		public function unLoadEquip(equipId:int, bagid:int=0, position:int=0):void
		{
			if (OperateMode.getInstance().modeName == OperateMode.DEAL_MODE)
			{
				DragItemManager.instance.cancel();
				BroadcastSelf.logger("交易物品时不能卸载装备");
			}
			else if (OperateMode.getInstance().modeName == OperateMode.BT_MODE)
			{
				DragItemManager.instance.cancel();
				BroadcastSelf.logger("摆摊时不能卸载装备");
			}
			else
			{
				var vo:m_equip_unload_tos=new m_equip_unload_tos();
				vo.equipid=equipId;
				vo.bagid=bagid;
				vo.position=position;
				this.sendSocketMessage(vo);
			}
		}
		
		public function itemChanged(item:BaseItemVO):void
		{
			NavigationModule.getInstance().goodsCountChange(item.typeId);
			var generalVO:GeneralVO = item as GeneralVO;
			if(generalVO && generalVO.effectType == ItemConstant.EFFECT_HCL){
				PersonalYbcModule.getInstance().view.setHCLNum();
			}
			if(generalVO && generalVO.typeId == 11600006){
				dispatch(ModuleCommand.MOUNT_TOKEN_CHANHE);
			}
			if(generalVO && (generalVO.typeId == 12300134 || generalVO.typeId >= 12300118 && generalVO.typeId <= 12300123 
				|| generalVO.typeId >= 10305101 && generalVO.typeId <= 10305330)){
					PetModule.getInstance().mediator.updatePetViewItemNum(generalVO.typeId);
			}
		}
		
		public function cleanPackage(packId:int):void
		{
			var vo:m_goods_tidy_tos=new m_goods_tidy_tos();
			vo.bagid=packId;
			this.sendSocketMessage(vo);
		}
		
		public function unLoadExtralPack(destoryPackId:int, bagId:int, position:int):void
		{
			var vo:m_item_shrink_bag_tos=new m_item_shrink_bag_tos();
			vo.bagid=destoryPackId;
			vo.bag=bagId;
			vo.position=position;
			this.sendSocketMessage(vo);
		}
		
		public function useHCL():Boolean{
			var hcl:BaseItemVO = packManager.getGoodsByEffectType([ItemConstant.EFFECT_HCL]);
			if(hcl){
				useItem(hcl.oid);
				return true;
			}else{
				//ShopModel.getInstance().initwindow(null, 1);
				Tips.getInstance().addTipsMsg("背包里没有换车令，可在高级商店购买获得。");
				return false
			}
		}
		
		public function useTSP( $mountid:int ):Boolean{
			if(packManager.getGoodsNumByTypeId(11600006) > 0){
				var vo:m_equip_mount_changecolor_tos = new m_equip_mount_changecolor_tos();
				vo.mountid = $mountid;
				sendSocketMessage(vo);
				return true;
			}else{
				Tips.getInstance().addTipsMsg("背包里没有坐骑提速牌，可在随身商店购买获得。");
				return false;
			}
		}
		
		public function useLaba(itemVO:GeneralVO):void{
			if(itemVO){
				useItem(itemVO.oid);
			}
		}
		
		public function useGoods(itemVO:BaseItemVO, autoUse:Boolean=false):void
		{
			if (!useGoodsEnabled)
			{
				BroadcastSelf.logger(enabledDesc);
				return ;
			}
			if (itemVO == null)
				return ;
			var status:int = GlobalObjectManager.getInstance().user.base.status
			if (status == 1)
			{
				BroadcastSelf.logger("角色已处于死亡状态！");
				return ;
			}else if(status == 6){
				BroadcastSelf.logger("训练中，不能使用物品。");
				return;
			}
			var itemStatus:int = itemVO.getItemStatus();
			if(itemStatus == BaseItemVO.PASS_DATE){
				if(itemVO is EquipVO && itemVO.kind == ItemConstant.KIND_EQUIP_MOUNT){
					//坐骑已经过程，需要自动弹出续期操作界面
					doMountRenewalTos(itemVO as EquipVO);
					return;
				}else{
					BroadcastSelf.logger("该物品已过期，无法使用!");
					return;
				}
			}else if(itemStatus == BaseItemVO.UN_STARTUP){
				BroadcastSelf.logger("本物品将于"+DateFormatUtil.format(itemVO.startTime)+"启用，暂时无法使用!");
				return;
			}
			var generalVO:GeneralVO=itemVO as GeneralVO;
			if (OperateMode.getInstance().modeName == OperateMode.NORMAL_MODE)
			{
				if (itemVO is StoneVO )
				{
					BroadcastSelf.logger("该物品不能直接使用!");
					return ;
				}
				if( itemVO.state == ItemConstant.LOCK)
				{
					BroadcastSelf.logger("该物品放在摊位上，不能使用。");
					return;
				}
				if (itemVO.kind == ItemConstant.KIND_BOOK && generalVO && generalVO.effectType == 0)
				{
					this.dispatch(ModuleCommand.SKILL_LEARN_FROM_BOOK,itemVO.typeId);//TODO 技能树模块需要处理此消息
					return ;
				}
				// 宠物技能书
				if (itemVO.kind == ItemConstant.KIND_BOOK && generalVO && generalVO.effectType == 101)
				{
					this.dispatch(ModuleCommand.OPEN_PET_SKILL);
					return ;
				}
				// 提悟符打开提悟界面，暂时这样实现。。。
				if (itemVO.typeId == 12300121 || itemVO.typeId == 12300122 || itemVO.typeId == 12300123) {
					this.dispatch(ModuleCommand.OPEN_PET_SAVVY);
					return;
				}
				if (itemVO.typeId == 12300139) {//宠物蛋：神宠蛋
					var eggVO:m_pet_egg_use_tos=new m_pet_egg_use_tos;
					eggVO.goods_id=itemVO.oid;
					Connection.getInstance().sendMessage(eggVO);
					return;
				}
				if (itemVO is EquipVO)
				{
					if (!itemVO.bind && itemVO.use_bind == 1)
					{
						Alert.show("本装备初次使用后将会被绑定，是否确定使用？", "温馨提示", yesHandler, null, "使用", "取消");
					}
					else
					{
						if( itemVO.kind == ItemConstant.KIND_EQUIP_MOUNT ){
							useMount(itemVO as EquipVO);
						}else{
							RoleStateDateManager.choosePositionToPut(itemVO as EquipVO);
						}
					}
					function yesHandler():void
					{
						if( itemVO.kind == ItemConstant.KIND_EQUIP_MOUNT ){
							useMount(itemVO as EquipVO);
						}else{
							RoleStateDateManager.choosePositionToPut(itemVO as EquipVO);
						}
					}
				}
				else
				{
					if (generalVO && generalVO.effectType != 0){
						if (CoolingManager.getInstance().isCoolingByName(generalVO.effectType.toString())){
							if (!autoUse){
								BroadcastSelf.logger("物品正在冷却中");
							}
							return ;
						}
					}
					if(generalVO.typeId==12300134){//宠物训练牌
						this.dispatch(ModuleCommand.OPEN_PET_FEED);
						return;
					}
					var allItemLinkType:Array = ItemLocator.getInstance().getAllItemLinkType();
					if (generalVO && allItemLinkType && allItemLinkType.indexOf(generalVO.effectType.toString()) != -1) {
						ItemLinkManager.getInstance().judgeByEffectType(generalVO);
						return;
					}
					if (generalVO && generalVO.effectType == 0 && generalVO.kind != ItemConstant.KIND_PACK){
						BroadcastSelf.logger("该物品不能直接使用!");
						return ;
					}else if (generalVO && generalVO.effectType == ItemConstant.EFFECT_EXP){
						var bei:Number=ItemConstant.EXP_TIP[generalVO.name];
						var msg:String=BuffModule.checkEXPBuff(bei);
						var energy:int = GlobalObjectManager.getInstance().user.fight.energy;
						if(energy < 300){
							Alert.show("当前的精力值为"+energy+"点，是否使用经验符？","提示",function okHandler():void{
								useHandler();
							});
							return;
						}
						if (msg != ""){
							Alert.show(msg, "温馨提示", useHandler);
							return ;
						}
					}else if(generalVO.effectType == ItemConstant.EFFECT_HCL){
						BroadcastSelf.logger("不能在背包直接使用换车令!");
						return;
					}else if(generalVO.effectType == ItemConstant.EFFECT_MOUNT_UPGRADE){
						BroadcastSelf.logger("不能在背包直接使用坐骑提速牌!");
						return;
					}else if(generalVO && generalVO.effectType == ItemConstant.EFFECT_XISHUIDAN){
						Alert.show("使用后将会清除所有已学技能，并返还技能点数。你确定使用？", "温馨提示", useHandler);
						return;
					}else if(generalVO && generalVO.effectType == ItemConstant.EFFECT_YIJINWAN){
						Alert.show("使用后将清除所有已分配属性点，并返还可分配属性点。确定使用？", "温馨提示", useHandler);
						return;
					}else if(generalVO && generalVO.effectType == ItemConstant.EFFECT_ENDURANCE){
						CursorManager.getInstance().setCursor(CursorName.ENDURANCE, generalVO);
						return ;
					}else if(generalVO && generalVO.effectType == ItemConstant.EFFECT_FAMILY_CMD){
						if(SceneDataManager.mapData.map_id == 10400){
							BroadcastSelf.logger("讨伐敌营副本地图内，无法使用【门派令】");
						}else if(SceneDataManager.mapData.map_id == 10500){
							BroadcastSelf.logger("大明宝藏地图内，无法使用【门派令】");
						}else if(SceneDataManager.mapData.map_id == 10600){
							BroadcastSelf.logger("师徒副本地图内，无法使用【门派令】");
						}else{
							Alert.show("使用后召集帮众到身边。确定使用？", "温馨提示", useHandler);
						}
						return;
					}else if(generalVO && generalVO.typeId == ItemConstant.EFFECT_LABA){
						this.dispatch(ModuleCommand.HORN_USE_GOODS,generalVO);
						return;
					}else if(generalVO && generalVO.effectType == ItemConstant.EFFECT_TREASURY){
						GreenHandModule.getInstance().openTreasuryWindow();
						return;
					}else if(generalVO&& generalVO.effectType == ItemConstant.EFFECT_FLOWER){
						FlowerModule.getInstance().sendToWhowView(itemVO);
						return;
					}else if(generalVO&& generalVO.effectType == ItemConstant.EFFECT_ZHUIZONG_LING){
						showItemTrace(generalVO.oid);
						return;
					}else if(generalVO&& generalVO.effectType == ItemConstant.EFFECT_TRANSFORM_MAP){
						this.dispatch(ModuleCommand.OPEN_SMALL_SCENE, true);
						return;
					}else if (generalVO && generalVO.effectType == ItemConstant.EFFECT_KING_TOKEN) {
						Alert.show("使用后召集国民到身边。确定使用？", "温馨提示", useHandler);
						return;
					}else if(generalVO && generalVO.effectType == ItemConstant.EFFECT_BIAN_SHEN){
						CursorManager.getInstance().setCursor(CursorName.MAGIC_HAND, generalVO);
						CursorManager.getInstance().enabledCursor = false;
						return ;
					}else if (generalVO && generalVO.effectType == ItemConstant.EFFECT_EDUCATE_FB_MEMBER) {
						this.dispatch(ModuleCommand.USE_EDUCATE_FB_MEMBER_ITEM,generalVO);
						return;
					}else if (generalVO && generalVO.effectType == ItemConstant.EFFECT_EDUCATE_FB_LEADER) {
						this.dispatch(ModuleCommand.USE_EDUCATE_FB_LEADER_ITEM,generalVO);
						return;
					}else if (generalVO && generalVO.effectType == ItemConstant.EFFECT_ADD_DRUNK_BUF){
						var msgTip:String = BuffModule.checkDrunkBuff(ItemConstant.DRUNK_BUF[generalVO.color]);
						if (msgTip != ""){
							Alert.show(msgTip, "温馨提示", useHandler);
							return ;
						}
					}
					function useHandler():void
					{
						useItem(itemVO.oid);
					}
					useItem(itemVO.oid);
				}
			}
			else if (OperateMode.getInstance().modeName == OperateMode.DEAL_MODE)
			{
				if (!autoUse)
				{
					BroadcastSelf.logger("交易物品时不能使用物品");
				}
			}
			else if (OperateMode.getInstance().modeName == OperateMode.BT_MODE)
			{
				if (!autoUse)
				{
					BroadcastSelf.logger("摆摊时不能使用物品");
				}
			}
		}
		
		public function buyGoods(goodsType:int):void{
			this.dispatch(ModuleCommand.SHOP_BUY_GOODS,goodsType);
		}
		
		public function openStallPanel(stallingType:int):void{
			this.dispatch(ModuleCommand.OPEN_STALL_PANEL,stallingType);
		}
		
		private function setShowGoods(data:Object):void{
			var vo:m_goods_show_goods_toc = data as m_goods_show_goods_toc;
			if(!vo.succ){
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private var pursuePanel:PursuePanel;
		private function showItemTrace(goodsId:int):void{
			if(pursuePanel == null){
				pursuePanel = new PursuePanel();
			}
			pursuePanel.goodsId = goodsId;
			WindowManager.getInstance().popUpWindow(pursuePanel);
			WindowManager.getInstance().centerWindow(pursuePanel);
		}
		
		public function useTrace(targetName:String):void{
			var baseItemVo:BaseItemVO = packManager.getGoodsByEffectType([ItemConstant.EFFECT_ZHUIZONG_LING]);
			if(baseItemVo){
				useItemTrace(baseItemVo.oid,targetName);
			}else{
				Tips.getInstance().addTipsMsg("背包里没有追踪令，可在商店购买获得。");
			}
		}
		
		public function useItemTrace(goodsId:int,targetName:String):void{
			if(targetName == GlobalObjectManager.getInstance().user.attr.role_name){
				Tips.getInstance().addTipsMsg("不能对自己进行追踪！");
				return;
			}
			var vo:m_item_trace_tos = new m_item_trace_tos();
			vo.goods_id = goodsId;
			vo.target_name = targetName;
			this.sendSocketMessage(vo);
		}
		
		private var copyStr:String;//添加点击复制链接
		private function setItemTrace(data:Object):void{
			var vo:m_item_trace_toc = data as m_item_trace_toc;
			if(vo.succ){
				var targetNationId:int = int(vo.target_mapid.toString().substr(1,1));
				var cuntryName:String = WorldManager.getMapName(vo.target_mapid);
				var nationName:String = GameConstant.getNation(targetNationId);
				var pos:String = cuntryName+HtmlUtil.font("["+vo.target_tx+","+vo.target_ty+"]","#FFFF00");
				var msg:String = "你追踪的"+HtmlUtil.font("["+vo.target_name+"]","#3BE450")+"玩家的当前位置："+pos;
				BroadcastSelf.logger("成功使用【追踪符】×1");
				BroadcastSelf.logger(msg);
				var can:Boolean = SceneDataManager.isSubMap() || SceneDataManager.isRobKingMap || !SceneDataManager.isInHomeCountry;
				var clickCopy:String="<font color='#00FF00'><a href='event:link;'><u>点击复制</u></a></font>";//添加链接文本
				if(!can){
					if(GlobalObjectManager.getInstance().user.base.faction_id == targetNationId){
						copyStr="你追踪的["+vo.target_name+"]玩家的当前位置："+cuntryName+"["+vo.target_tx+","+vo.target_ty+"]。传送过去，需要消耗【传送卷】一个。";
						msg = msg.concat("\n传送过去，需要消耗【传送卷】一个。")+clickCopy;;//添加链接文本
						Alert.show(msg, "追踪符", PathUtil.carry,PathUtil.goto,"传送过去","自动寻路", [vo.target_mapid,new Pt(vo.target_tx,0,vo.target_ty)], true, true, new Point(335,150), linkToCopy);					
					}else{
						copyStr="你追踪的["+vo.target_name+"]玩家的当前位置："+cuntryName+"["+vo.target_tx+","+vo.target_ty+"]，目标所在位置无法传送和寻路。";
						msg = msg.concat("，目标所在位置无法传送和寻路。")+clickCopy;
						Alert.show(msg, "追踪符", null, null, "确定", "", null, false, false, new Point(335,150), linkToCopy);
					}
				}else{
					copyStr="你追踪的["+vo.target_name+"]玩家的当前位置："+cuntryName+"["+vo.target_tx+","+vo.target_ty+"]，你所在位置无法传送和寻路。";
					msg = msg.concat("，你所在位置无法传送和寻路。")+clickCopy;
					Alert.show(msg, "追踪符", null, null, "确定", "", null, false, false, new Point(335,150), linkToCopy);
				}
				
				var itemVO:GeneralVO = packManager.getItemById(vo.goods_id) as GeneralVO;
				if(itemVO){
					itemVO.num = vo.goods_num;
				 	packManager.updateGoods(itemVO.bagid,itemVO.position,itemVO);
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		private function linkToCopy(e:TextEvent):void
		{
			if(copyStr){
				System.setClipboard(copyStr);
				Tips.getInstance().addTipsMsg("复制成功！");
			}
		}
		
		/**
		 * 拆分 
		 */		
		private var splitPanel:SplitItemPanel;
		public function splitItemPanel(item:PackageItem):void {
			var baseItemVO:BaseItemVO=item.data as BaseItemVO;
			if (baseItemVO && baseItemVO.num > 1) {
				splitPanel=new SplitItemPanel();
				splitPanel.x=packManager.packWindow.x + 100;
				splitPanel.y=packManager.packWindow.y + 200;
				splitPanel.packageItem=item;
				WindowManager.getInstance().openDialog(splitPanel);
			} else {
				Tips.getInstance().addTipsMsg("物品数量不够!");
			}
		}
		/**
		 * 丢弃 
		 * @param itemVo
		 * 
		 */		
		public function threwGoods(itemVo:BaseItemVO):void {
			var equipVO:EquipVO=itemVo as EquipVO;
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 10) {
				if (equipVO && equipVO.putWhere != ItemConstant.PUT_ADORN && equipVO.putWhere != ItemConstant.PUT_MOUNT && equipVO.putWhere != ItemConstant.PUT_FASHION) {
					if (equipVO.color == ItemConstant.COLOR_GRAY && equipVO.punch_num == 0 && equipVO.reinforce_rate == 0) {
						PackageModule.getInstance().destoryGoods(equipVO.oid);
						return;
					}
					if (equipVO.color == ItemConstant.COLOR_GREEN && equipVO.punch_num == 0 && equipVO.reinforce_rate == 0 && equipVO.quality != 5) {
						PackageModule.getInstance().destoryGoods(equipVO.oid);
						return;
					}
				}
			}
			var color:String=ItemConstant.COLOR_VALUES[itemVo.color];
			if (itemVo.name == "商票") {
				Alert.show("丢弃" + HtmlUtil.font("【" + itemVo.name + "】", color) + "将扣除一次商贸机会，本次商贸失败。", "警告", desctoryGoods);
				return;
			}
			if (itemVo.typeId == 10100022 && SceneDataManager.mapData.map_id == 10600) {
				Alert.show("丢弃" + HtmlUtil.font("【" + itemVo.name + "】", color) + "将无法召唤最终副本BOSS。", "警告", desctoryGoods);
				return;
			}
			if (equipVO && equipVO.putWhere == ItemConstant.PUT_MOUNT && SystemConfig.serverTime > equipVO.timeoutData) {
				Alert.show("你是否确定要丢弃" + HtmlUtil.font("【" + itemVo.name + "】", color) + "?", "警告", desctoryGoods, mountRenewal, "确定", "坐骑续期");
				return;
			}
			Alert.show("你是否确定要丢弃" + HtmlUtil.font("【" + itemVo.name + "】", color) + "?", "警告", desctoryGoods);
			function desctoryGoods():void {
				PackageModule.getInstance().destoryGoods(itemVo.oid);
			}
			function mountRenewal():void {
				PackageModule.getInstance().doMountRenewalTos(equipVO, 1, 0, 1);
			}
		}
	}
}