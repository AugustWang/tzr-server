package modules.mypackage.views {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.components.alert.Alert;
	import com.components.cooling.CoolingManager;
	import com.managers.WindowManager;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.chat.ChatModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.operateMode.OperateMode;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.playerGuide.PlayerGuideModule;
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;

	public class PackTile extends Sprite {
		
		public static const HPADDING:int=3;
		public static const VPADDING:int=3;
		
		public var count:int = 40;
		public var rowCount:int=5;
		public var columnCount:int=8;
		protected var packId:int;
		public var owner:Sprite;

		protected var packItems:Array = [];
		protected var lockItems:Array = [];
		
		public function PackTile(packId:int) {
			this.packId=packId;
			addEventListener(DragItemEvent.DRAG_THREW, onDragThrew);
		}

		public function extensionTile(rowCount:int=5, columnCount:int=8,totalCount:int=40):void{
			this.rowCount=rowCount;
			this.columnCount=columnCount;
			this.count = totalCount;
			extensionItems();
		}

		protected function extensionItems():void {
			var currentCount:int = packItems.length - lockItems.length;
			var item:PackageItem
			if(count > currentCount){
				var createCount:int = count - currentCount;
				if(lockItems.length > 0){
					while(lockItems.length > 0){
						if(createCount <= 0){
							break;
						}
						item = lockItems.shift();
						item.enabled = true;
						createCount--;
					}
				}
				if(createCount > 0){
					var fullRowCount:int = Math.ceil(count/columnCount)*columnCount-count;
					var createAndLockCount:int = createCount + fullRowCount;
					var startIndex:int = packItems.length;
					for(var i:int=0;i < createAndLockCount ;i++){
						item = createItem(packId,startIndex+i);
						if(i >= createCount){
							item.enabled = false;
							lockItems.push(item);
						}
					}
				}
			}else if(count < currentCount){
				var deleteCount:int = currentCount-count;
				var realDeleteCount:int = deleteCount+lockItems.length;
				var lockCount:int = realDeleteCount%columnCount;
				realDeleteCount = Math.floor(realDeleteCount/columnCount)*columnCount;
				
				if(realDeleteCount > 0){
					if(lockItems.length > 0){
						while(lockItems.length > 0){
							if(realDeleteCount <= 0){
								break;
							}
							item = lockItems.pop();
							removeItem(item);
							realDeleteCount--;
						}
					}
					while(realDeleteCount > 0){
						item = packItems.pop();
						removeItem(item);
						realDeleteCount--
					}
				}
				if(lockCount > 0){
					var size:int = packItems.length;
					var n:int = 1;
					while(n <= lockCount){
						item = packItems[size-n];
						if(item && item.enabled){
							item.enabled = false;
							lockItems.unshift(item);
						}
						n++;
					}
				}
			}
		}
		
		protected function removeItem(item:PackageItem):void{
			if(item){
				item.removeEventListener(MouseEvent.MOUSE_DOWN, itemDownHandler);
				item.removeEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick);
				item.removeEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick);
				CoolingManager.getInstance().removeObserver(item);
				var index:int = packItems.indexOf(item);
				if(index != -1){
					packItems.splice(index,1);
				}
				if(item.parent){
					item.parent.removeChild(item);
				}
			}
		}
		
		protected function createItem(packId:int,index:int):PackageItem{
			var item:PackageItem=new PackageItem();
			item.index=index;
			item.packId=packId;
			var row:int=index / columnCount;
			var column:int=index % columnCount;
			item.x=4 + column * item.width + column * HPADDING;
			item.y=5 + row * item.height + row * VPADDING;
			item.addEventListener(MouseEvent.MOUSE_DOWN, itemDownHandler);
			item.doubleClickEnabled=true;
			item.addEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick);
			item.addEventListener(MouseEvent.CLICK,itemClickHandler);
			addChild(item);
			packItems.push(item);
			return item;
		}
		
		public function hasEmptyCount(count:int):Boolean{
			var items:Array = PackManager.getInstance().packItems;
			var size:int = items.length;
			var len:int = 1;
			while(len <= count){
				if(items[size-len]){
					return false;
				}
				len++;
			}
			return true;	
		}
		
		private var glowItems:Array;
		public function startGrowItems(count:int):void{
			stopGlowItems();
			glowItems = [];
			var size:int = packItems.length - lockItems.length;
			var len:int = 1;
			var packItem:PackageItem;
			while(len <= count){
				packItem = packItems[size-len] as PackageItem;
				if(packItem){
					glowItems.push(packItem);
					packItem.filters = FilterCommon.PACK_FILTERS;
				}
				len++;
			}
		}
		
		public function stopGlowItems():void{
			for each(var item:PackageItem in glowItems){
				item.filters = null;
			}
			glowItems = null;
		}
		
		protected function onDragThrew(event:DragItemEvent):void {
			var itemVo:BaseItemVO=event.dragData as BaseItemVO;
			PackageModule.getInstance().threwGoods(itemVo);
		}

		protected function itemDownHandler(event:MouseEvent):void {
			var item:PackageItem=event.currentTarget as PackageItem;
			var baseItemVO:BaseItemVO=item.data as BaseItemVO;
			if (baseItemVO == null)
				return;
			var status:int=baseItemVO.getItemStatus();
			if (baseItemVO.state == ItemConstant.LOCK && (status == BaseItemVO.STARTUP || status == BaseItemVO.NORMAL)) {
				if (OperateMode.getInstance().modeName == OperateMode.DEAL_MODE) {
					BroadcastSelf.logger("该物品已经被锁定!");
				}
				return;
			}
			if (OperateMode.getInstance().modeName == OperateMode.NORMAL_MODE || OperateMode.getInstance().modeName == OperateMode.FML_DEPOT_MODE) {
				if (event.shiftKey || CursorManager.getInstance().currentCursor == CursorName.SPLIT) {
					if(CursorManager.getInstance().currentCursor == CursorName.SPLIT){
						CursorManager.getInstance().enabledCursor = true;
						CursorManager.getInstance().hideCursor(CursorName.SPLIT);
					}
					PackageModule.getInstance().splitItemPanel(item);
					event.stopPropagation();
				}
				if (event.ctrlKey) {
					ChatModule.getInstance().showGoods(baseItemVO.oid);
				} else {
					DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.PACKAGE_ITEM, item.data);
				}
			} else if (OperateMode.getInstance().modeName == OperateMode.DEAL_MODE) {
				if (baseItemVO.bind) {
					BroadcastSelf.logger("该物品已被绑定不能交易!");
				} else {
					DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.PACKAGE_ITEM, item.data);
				}
			} else if (OperateMode.getInstance().modeName == OperateMode.BT_MODE) {
				if (baseItemVO.bind) {
//					BroadcastSelf.logger("该物品已被绑定不能出售!");
				} else {
					DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.PACKAGE_ITEM, item.data);
				}
			} else if (OperateMode.getInstance().modeName == OperateMode.FML_DEPOT_MODE) {
				if (baseItemVO.bind) {
					BroadcastSelf.logger("绑定物品不能放入门派仓库!");
				} else {
					DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.PACKAGE_ITEM, item.data);
				}

			}
		}

		private function itemClickHandler(event:MouseEvent):void{
			var item:PackageItem=event.currentTarget as PackageItem;
			item.hideTip();
			GoodsMenuBar.getInstance().show(item);	
		}
		
		protected function onItemDoubleClick(event:MouseEvent):void {
			var packageItem:PackageItem=event.currentTarget as PackageItem;
			var baseItemVO:BaseItemVO=packageItem.data as BaseItemVO;
			if (packageItem == null || baseItemVO == null)
				return;
			if (PackageModule.IN_SELL_MODE) {
				if (PackageModule.getInstance().isSellFull()) {
					BroadcastSelf.getInstance().appendMsg("卖出空间已满，请先卖出当前物品");
				} else {
					if (!packageItem.lock) {
						if (baseItemVO.sellType > 0) {
							if (baseItemVO.color > 1) {
								Alert.show("你确定卖出<font color='" + ItemConstant.COLOR_VALUES[baseItemVO.color] + "'>【" + baseItemVO.name + "】</font> x " + baseItemVO.num, "卖出提示", sureSell, null, "卖出", "取消", new Array(baseItemVO));
							} else {
								PackageModule.getInstance().insertToSell(baseItemVO);
							}
						} else {
							Alert.show("该物品不能卖出");
						}
					}
				}
			} else {
				if (baseItemVO.typeId == 12300135) {
					Alert.show("使用宠物经验葫芦后，当前出战宠物可获得葫芦中的经验。注意：宠物等级不可超过主人等级，超出经验上限的部分将被忽略！", "使用宠物经验药", PackageModule.getInstance().useGoods, null, "确定", "取消", [baseItemVO]);
				} else {
					PackageModule.getInstance().useGoods(baseItemVO);
				}
			}
		}

		private function sureSell(baseItemVO:BaseItemVO):void {
			PackageModule.getInstance().insertToSell(baseItemVO);
		}

		public function setLock(pos:int, lock:Boolean):void {
			var item:PackageItem=packItems[pos] as PackageItem;
			item.lock=lock;
		}

		public function getTileItem(pos:int):PackageItem {
			return packItems[pos];
		}
		
		public function getTileItems():Array{
			return packItems;
		}

		public function setGoods(items:Array):void {
			var size:int=packItems.length;
			for (var i:int=0; i < size; i++) {
				updateGoods(i, items[i]);
			}
		}

		public function updateGoods(pos:int, itemvo:BaseItemVO):void {
			var item:PackageItem=packItems[pos] as PackageItem;
			var tempData:Object=item.data;
			item.updateContent(itemvo);
			if (itemvo == null && item.lock) {
				item.lock=false;
			}
			if (itemvo) {
				var guideModel:PlayerGuideModule=PlayerGuideModule.getInstance();
				if (guideModel.currentType == PlayerGuideModule.BAG_WIDNOW && itemvo.typeId == guideModel.goodsTypeId) {
					var newX:int=item.x - 50;
					var newY:int=item.y + 110;
					guideModel.goodsId=itemvo.oid;
					guideModel.adjustTaskTipPos(newX, newY);
				}
			}
		}

		public function dispose():void {
			for each (var item:PackageItem in packItems) {
				CoolingManager.getInstance().removeObserver(item);
			}
		}
	}
}