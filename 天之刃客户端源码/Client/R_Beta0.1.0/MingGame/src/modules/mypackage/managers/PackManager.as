package modules.mypackage.managers {
	import com.common.GlobalObjectManager;
	import com.components.cooling.CoolingManager;
	import com.events.WindowEvent;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import modules.ModuleCommand;
	import modules.deal.DealModule;
	import modules.mount.views.MountRenewalPanel;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.operateMode.OperateMode;
	import modules.mypackage.views.PackageItem;
	import modules.mypackage.views.PackageWindow;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	import modules.pet.PetDataManager;
	import modules.playerGuide.GuideConstant;
	import modules.system.SystemConfig;
	
	import proto.common.p_pet;
	import proto.common.p_role;

	/**
	 * 背包管理器
	 * @author Administrator
	 *
	 */
	public class PackManager extends EventDispatcher {
		
		public var inited:Boolean=false;
		public static const PACK_1:int=1; //背包1
		public static const PACK_2:int=2; //背包2
		public static const PACK_3:int=3; //背包3
		
		public static var MAIN_PACK_ROWS:int = 5;
		public static var MAIN_PACK_COLUMNS:int = 8;
		public static var MAIN_PACK_COUNT:int = 40;

		public var packWindow:PackageWindow;
		public var extensionObj:Object;
		public var packItems:Array;

		public function PackManager() {
			extensionObj = new Object();
		}

		private static var instance:PackManager;
		public static function getInstance():PackManager {
			if (instance == null) {
				instance=new PackManager();
			}
			return instance;
		}

		/**
		 * 根据packId弹出背包窗口
		 * @param packId
		 * @param x
		 * @param y
		 */
		public function popUpWindow(packId:int, x:Number=NaN, y:Number=NaN, remove:Boolean=true):void {
			if (packWindow == null && packId == PACK_1) {
				packWindow=new PackageWindow(packId);
				packWindow.addEventListener(WindowEvent.CLOSEED, onCloseHandler);
				packWindow.addEventListener(WindowEvent.OPEN, onOpenHandler);
			}
			var mode:String=remove ? WindowManager.REMOVE : WindowManager.UNREMOVE;
			WindowManager.getInstance().popUpWindow(packWindow, mode);
			if (packId == PACK_1) {
				if (!isNaN(x) && !isNaN(y)) {
					packWindow.x=x;
					packWindow.y=y;
				}else{
					packWindow.x=600;
					packWindow.y=GlobalObjectManager.GAME_HEIGHT-packWindow.height >> 1;
				}
				DealModule.getInstance().requestStallState();
			}
		}

		public function isPopUp(packId:int=1):Boolean {
			return packWindow ? packWindow.parent : false;
		}

		public function extensionPack(packId:int,rows:int,columns:int,count:int):void {
			MAIN_PACK_COUNT = count;
			MAIN_PACK_ROWS = rows;
			MAIN_PACK_COLUMNS = columns;
			if (packWindow) {
				packWindow.extensionPack(rows,columns,count);
			}
			if(packItems){
				packItems.length = count;
			}
		}
		
		public function addExtralItem(packId:int,typeId:int,count:int):void{
			extensionObj[packId] = {typeId:typeId,count:count};
			if(packWindow){
				packWindow.addExtralItem(packId,typeId,count);
			}
		}
		
		public function deletedExtralItem(packId:int):void{
			delete extensionObj[packId]
			if(packWindow){
				packWindow.deleteExtralItem(packId);
			}
		}
		
		private function onOpenHandler(event:WindowEvent):void {
			Dispatch.dispatch(GuideConstant.OPEN_PACK_PANEL);
		}

		private function onCloseHandler(event:WindowEvent):void {
			Dispatch.dispatch(GuideConstant.CLOSE_PACK_PANEL);
		}

		/**
		 * 更新金钱
		 */
		public function updateMoney():void {
			if (packWindow) {
				packWindow.updateMoney();
			}
			MountRenewalPanel.getInstance().updateMoney();
		}

		public function openBTWindow():void {
			if (packWindow) {
				packWindow.onStallHandler();
			}
		}

		public function setBtButtonFilter(type:int):void {
			if (packWindow) {
				packWindow.baitanState(type);
			}
		}

		public function enabledDTButton(value:Boolean):void {
			if (packWindow) {
				if (OperateMode.getInstance().modeName == OperateMode.DEAL_MODE || OperateMode.getInstance().modeName == OperateMode.BT_MODE) {
					packWindow.btn_cleanUp.enabled=false;
				} else {
					packWindow.btn_cleanUp.enabled=value;
				}
			}
		}

		/**
		 * 设置对应背包的物品 列表
		 */
		public function setGoods(packId:int, items:Array):void {
			packItems = items;
			if (packWindow) {
				packWindow.setGoods(items);
			}
			if (!inited) {
				inited=true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		/**
		 * 更新某个背包的某个位置的物品
		 */
		public function updateGoods(packId:int, pos:int, item:BaseItemVO):void {
			var items:Array = getItemsByPackId(packId);
			if (items == null)
				return;
			var deleteId:int=-1;
			if (item && item.num == 0) {
				deleteId=item.oid;
				item=null;
			}
			if (item == null) {
				var distoryItem:BaseItemVO=items[pos - 1];
				if (distoryItem && distoryItem.oid != deleteId && deleteId != -1) {
					return;
				}
			}
			items[pos - 1]=item;
			if (item) {
				PackageModule.getInstance().itemChanged(item);
			} else if (distoryItem) {
				PackageModule.getInstance().itemChanged(distoryItem);
			}
			if (packWindow) {
				packWindow.updateGoods(pos - 1, item);
			}
			Dispatch.dispatch(ModuleCommand.PACKAGE_UPDATE_GOODS);
		}

		/**
		 * 删除物品
		 */
		public function removeGoods(itemId:int, packId:int=-1):void {
			var item:BaseItemVO = getItemById(itemId);
			if (item) {
				updateGoods(item.bagid,item.position,null);
			}
		}

		/**
		 * 锁定目标对象的格子，但不会更新目标对象
		 */
		public function lockGoods(vo:BaseItemVO, locked:Boolean):void {
			if (vo) {
				if (packWindow) {
					packWindow.setLock(vo.position - 1, locked);
				}
			}
		}

		public function getItem(itemId:int):PackageItem {
			var array:Array=this.getGoodsByType(itemId)
			if (array.length > 0) {
				var vo:BaseItemVO=array[0]
				return packWindow.getItem(vo.position)
			}
			return null;
		}
				
		public function getEquip():Array{
			var equips:Array = [];
			for each (var item:BaseItemVO in packItems) {
				if (item is EquipVO) {
					equips.push(item);
				}
			}
			return equips;
		}
		
		public function getStone():Array{
			var stones:Array = [];
			for each (var item:BaseItemVO in packItems) {
				if (item is StoneVO) {
					stones.push(item);
				}
			}
			return stones;
		}
		
		/**
		 * 通过ID获取实例VO
		 */
		public function getItemById(itemId:int):BaseItemVO {
			if (itemId != 0){	
				for each (var item:BaseItemVO in packItems) {
					if (item && item.oid == itemId) {
						return item;
					}
				}
			}
			return null;
		}

		public function getFirstItemOfWeapon():BaseItemVO {
			//武器的类型
			var kindArray:Array=[ 101, 102, 103, 104 ];
				for each ( var item:BaseItemVO in packItems ) {
					for each ( var kind:int in kindArray ) {
						if ( item && item.kind == kind ) {
							return item;
					}
				}
			}
			return null;
		}

		public function getItemByKind(kind:int):Array {
			if (kind == 0)return null;
			var result:Array=[];
			for each (var item:BaseItemVO in packItems) {
				if (item && item.kind == kind) {
					result.push(item);
				}
			}
			return result;
		}

		/**
		 * 通过背包ID及位置获取实例VO
		 */
		public function getItemByPos(packID:int, pos:int):BaseItemVO {
			if (packID == 0 || pos == 0)
				return null;
			for each (var item:BaseItemVO in packItems) {
				if (item && item.position == pos)
					return item;
			}
			return null;
		}

		/**
		 * 根据typeid获取背包内的物品数量
		 */
		public function getGoodsNumByTypeId(typeId:int):int {
			var totalNum:int=0;
			for each (var item:BaseItemVO in packItems) {
				if (item && item.typeId == typeId){
					totalNum+=item.num;
				}
			}
			return totalNum;
		}
		
		/**
		 * 根据typeid获取背包内是否绑定的物品数量
		 */		
		public function getBindGoodsNunByTypeId(typeId:int,isBind:Boolean):int{
			var totalNum:int=0;
			for each (var item:BaseItemVO in packItems) {
				if (item && item.typeId == typeId && item.bind==isBind){
					totalNum+=item.num;
				}
			}
			return totalNum;
		}

		/**
		 * 通过背包ID获取物品集合
		 */
		public function getItemsByPackId(packId:int):Array {
			if (packItems == null) {
				packItems = new Array(MAIN_PACK_COUNT);
			}
			return packItems;
		}

		/**
		 * 通过类型获取物品
		 */
		public function getGoodsByType(type:int):Array {
			var goods:Array=[];
			for each (var tempItem:BaseItemVO in packItems) {
				if (tempItem && tempItem.typeId == type) {
					goods.push(tempItem);
				}
			}
			return goods;
		}
		/**
		 * 通过类型获取物品
		 */
		public function getGoodsByTypeAndBind(type:int,bind:Boolean):Array {
			var goods:Array=[];
			for each (var tempItem:BaseItemVO in packItems) {
				if (tempItem && tempItem.typeId == type && tempItem.bind == bind) {
					goods.push(tempItem);
				}
			}
			return goods;
		}
		
		public function getGoodsVOByType(type:int):BaseItemVO {
			for each (var tempItem:BaseItemVO in packItems) {
				if (tempItem && tempItem.typeId == type) {
					return tempItem;
				}
			}
			return null;
		}

		/**
		 * 判断背包是否为空
		 */
		public function isBagEmpty():Boolean {
			return !isBagFull();
		}

		/**
		 *  是否是满的
		 */
		public function isBagFull():Boolean {
			var size:int = packItems.length;
			for(var i:int=0;i<size;i++){
				if(!packItems[i]){
					return false;
				}
			}
			return true;
		}

		public function getGoodsByEffectType(types:Array):BaseItemVO {
			for each (var tempItem:Object in packItems) {
				var generalVO:GeneralVO = tempItem as GeneralVO;
				if (generalVO && types.indexOf(generalVO.effectType) != -1) {
					return generalVO;
				}
			}
			return null;
		}

		public function getGoodsListByEffectType(types:Array):Array {
			var goodsList:Array = [];
			for each (var tempItem:Object in packItems) {
				var generalVO:GeneralVO = tempItem as GeneralVO;
				if (generalVO && types.indexOf(generalVO.effectType) != -1) {
					goodsList.push(generalVO);
				}
			}
			return goodsList;
		}
		
		public function getGoodsByTypeIds(types:Array):BaseItemVO {
			for each (var tempItem:BaseItemVO in packItems) {
				if (tempItem && types.indexOf(tempItem.typeId) != -1) {
					return tempItem;
				}
			}
			return null;
		}
		
		/**
		 * 根据效果类型获取该物品在背包中的数量
		 */
		public function getGooodsCountByEffectType(effectType:int):int {
			var totalCount:int=0;
			for each (var tempItem:Object in packItems) {
				var g:GeneralVO=tempItem as GeneralVO;
				if (g && g.effectType == effectType) {
					totalCount+=g.num;
				}
			}
			return totalCount;
		}

		/**
		 * 自动恢复
		 */
		public function autoResume():void {
			var user:p_role=GlobalObjectManager.getInstance().user;
			var isCooling:Boolean;
			var itemVO:BaseItemVO;
			if (SystemConfig.autoUseHP) {
				var hp:Number=user.fight.hp / user.base.max_hp;
				if (hp < SystemConfig.hp) {
					isCooling=CoolingManager.getInstance().isCoolingByName(ItemConstant.EFFECT_HP.toString()) || CoolingManager.getInstance().isCoolingByName(ItemConstant.EFFECT_SUPER_HP.toString());
					if (isCooling == false) {
						var hpGoodsList:Array = getGoodsListByEffectType([ItemConstant.EFFECT_HP, ItemConstant.EFFECT_SUPER_HP]);
						if(hpGoodsList.length > 0){
							hpGoodsList.sortOn("typeId");
							if(SystemConfig.hpUseBitToBig){
								itemVO = hpGoodsList.shift();
							}else{
								itemVO = hpGoodsList.pop();
							}
						}
						if (itemVO) {
							PackageModule.getInstance().useGoods(itemVO, true);
						} else {
							if (SystemConfig.autobuyMP) {
								PackageModule.getInstance().buyGoods(0);
							} else {
								goBack();
							}
						}
					}
				}
			}
			if (SystemConfig.autoUseMP) {
				var mp:Number=user.fight.mp / user.base.max_mp;
				if (mp < SystemConfig.mp) {
					isCooling=CoolingManager.getInstance().isCoolingByName(ItemConstant.EFFECT_MP.toString()) || CoolingManager.getInstance().isCoolingByName(ItemConstant.EFFECT_SUPER_MP.toString());
					if (isCooling == false) {
						var mpGoodsList:Array = getGoodsListByEffectType([ItemConstant.EFFECT_MP, ItemConstant.EFFECT_SUPER_MP]);
						if(mpGoodsList.length > 0){
							mpGoodsList.sortOn("typeId");
							if(SystemConfig.mpUseBitToBig){
								itemVO = mpGoodsList.shift();
							}else{
								itemVO = mpGoodsList.pop();
							}
						}
						if (itemVO) {
							PackageModule.getInstance().useGoods(itemVO, true);
						} else {
							if (SystemConfig.autobuyMP) {
								PackageModule.getInstance().buyGoods(1);
							}
						}
					}
				}
			}
			if (SystemConfig.autoUsePet && SystemConfig.open) {
				var pet:p_pet=PetDataManager.thePet;
				if (pet != null && PetDataManager.isBattle == true) {
					var petHP:Number=pet.hp / pet.max_hp;
					if (petHP < SystemConfig.pet) {
						isCooling=CoolingManager.getInstance().isCoolingByName(ItemConstant.EFFECT_PET_HP.toString());
						if (isCooling == false) {
							var petGoodsList:Array = getGoodsListByEffectType([ItemConstant.EFFECT_MP, ItemConstant.EFFECT_SUPER_MP]);
							if(petGoodsList.length > 0){
								petGoodsList.sortOn("typeId");
								if(SystemConfig.petUseBitToBig){
									itemVO = petGoodsList.shift();
								}else{
									itemVO = petGoodsList.pop();
								}
							}
							if (itemVO) {
								PackageModule.getInstance().useGoods(itemVO, true);
							} else {
								if (SystemConfig.autobuyMP) {
									PackageModule.getInstance().buyGoods(2);
								}
							}
						}
					}
				}
			}
		}
		
		public function goBack():void {
			if (SystemConfig.autobuyHC) {
				var hc:BaseItemVO=getGoodsByEffectType([ItemConstant.EFFECT_RETURN]);
				if (hc) {
					PackageModule.getInstance().useGoods(hc, true);
				}
			}
		}
	}
}