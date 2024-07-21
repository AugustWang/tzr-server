package modules.mypackage.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.common.dragManager.IDragItem;
	import com.components.alert.Alert;
	import com.components.cooling.CoolingManager;
	import com.components.cooling.ICooling;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import modules.ModuleCommand;
	import modules.deal.DealModule;
	import modules.family.FamilyDepotModule;
	import modules.forgeshop.ForgeshopModule;
	import modules.letter.LetterModule;
	import modules.mount.views.MountUpgradeItem;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.operateMode.OperateMode;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.system.SystemConfig;
	import modules.warehouse.WarehouseModule;

	public class PackageItem extends DragItem implements ICooling
	{
		public static const ITEM_SIZE:int = 36;
		public var index:int;
		public var packId:int;
		private var timer:Timer;
		private var _flickItemThing:Thing;
		public function PackageItem()
		{
			super(ITEM_SIZE);
			CoolingManager.getInstance().registerObserver(this);
			OperateMode.getInstance().addEventListener(Event.CHANGE,onModeChange);
		}
		
		public function startFlickItem():void{
			_flickItemThing = new Thing();
			_flickItemThing.load(GameConfig.OTHER_PATH + 'skillSelect.swf');
			_flickItemThing.x = -12;
			_flickItemThing.y = -12;
			this.addChild(_flickItemThing);
			_flickItemThing.play(5,true);
		}
		
		public function stopFlickItem():void{
			if(_flickItemThing != null){
				_flickItemThing.stop();
				if(_flickItemThing.parent)removeChild(_flickItemThing);
			}
		}
		
		private var bindmaskShape:MaskShape;
		private function onModeChange(event:Event):void{
			if(_lock)return;
			var baseItemVO:BaseItemVO = data as BaseItemVO;
			if(OperateMode.getInstance().modeName != OperateMode.NORMAL_MODE){
				if(!baseItemVO || !baseItemVO.bind)return;
				if(bindmaskShape == null){
					bindmaskShape = new MaskShape();
					bindmaskShape.x = bindmaskShape.y = 2;
				}
				bindmaskShape.draw(MaskShape.BINDABLE);
				addChild(bindmaskShape);
			}else if(bindmaskShape){
				bindmaskShape.remove();
			}
		}
		
		private var _enabled:Boolean = true;
		private var enabledIcon:Bitmap;
		public function set enabled(value:Boolean):void{
			_enabled = value;
			if(!_enabled){
				if(enabledIcon == null){
					enabledIcon = Style.getBitmap(GameConfig.T1_VIEWUI,"closeSkill");
					enabledIcon.x = enabledIcon.y = 4;
				}
				addChild(enabledIcon);
			}else if(enabledIcon){
				removeChild(enabledIcon);
			}
			mouseEnabled = _enabled;
		}
		
		public function get enabled():Boolean{
			return _enabled;	
		}
		
		protected var _lock:Boolean = false;
		public function set lock(value:Boolean):void{
			_lock = value;
			if(_lock){
				if(bindmaskShape == null){
					bindmaskShape = new MaskShape();
					bindmaskShape.x = bindmaskShape.y = 2;
				}
				bindmaskShape.draw(MaskShape.LOCK);
				addChild(bindmaskShape);
			}else if(bindmaskShape){
				bindmaskShape.remove();
			}
			var itemVO:BaseItemVO = data as BaseItemVO;
			if(itemVO){
				itemVO.state = _lock ? ItemConstant.LOCK : ItemConstant.NORMAL;
			}
			if(itemVO)
				if(itemVO.getItemStatus()!=BaseItemVO.PASS_DATE && itemVO.getItemStatus()!=BaseItemVO.UN_STARTUP)
					PackManager.getInstance().enabledDTButton(!lock);
		}
		
		public function get lock():Boolean{
			return _lock;
		}
		
		override public function allowAccept(itemVO:Object,name:String):Boolean{
			if(_enabled == false){
				return false;
			}
			if(OperateMode.getInstance().modeName == OperateMode.NORMAL_MODE){
				if(name == DragConstant.LETTER_ITEM){
					if(PackManager.getInstance().isBagFull()){
						Alert.show("背包已满，附加无法提取！","提示",null,null,"确定","取消",null,false);
						return false;
					}
				}
				if(name == DragConstant.SPLIT_ITEM || name == DragConstant.PACKAGE_ITEM || name == DragConstant.SELL_ITEM ||
				   name == DragConstant.LETTER_ITEM || name ==DragConstant.STOVE_ITEM|| name == DragConstant.FORGESHOP_ITEM || 
				   name == DragConstant.WAREHOUSE_ITEM || name == DragConstant.WRITE_ITEM_BACK || name == DragConstant.MOUNT_UPGRADE_ITEM){
					
					if( name ==DragConstant.STOVE_ITEM && _lock){
						return false;
					}
					
					var baseItemVO:BaseItemVO = itemVO as BaseItemVO;
					if(baseItemVO && baseItemVO.position == -1 && data){
						var curItem:BaseItemVO = data as BaseItemVO;
						return curItem.toCompare(baseItemVO);
					}
					return true;				
				}else if(name == DragConstant.EXTRAL_ITEM || name == DragConstant.EQUIP_ITEM){
					return data ? false : true; 
				}
				return false;
			}else if(OperateMode.getInstance().modeName == OperateMode.DEAL_MODE){

					return true;
			}else if(OperateMode.getInstance().modeName == OperateMode.BT_MODE){
				if(data)
				{
					var bt_item:BaseItemVO = data as BaseItemVO;
					var bt_itemVo:BaseItemVO = itemVO as BaseItemVO; 
					if(bt_item.oid == bt_itemVo.oid && bt_item.state == ItemConstant.LOCK)
						return true;
					return false;
				}else{
					return true;
				}
				
			}else if(OperateMode.getInstance().modeName == OperateMode.FML_DEPOT_MODE){
				return true;
			}
			
			return false;
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			super.createContent();
		}
		
		public function updateCount(num:int):void{
			if(content){
				content.updateCount(num);
			}	
		}
		
		override public function disposeContent():void{
			super.disposeContent();
			CoolingManager.getInstance().stopByCoolingID(coolingID);
			lock = false;
			buttonMode = useHandCursor = false;
		}
		
		public function updateContent(itemVO:BaseItemVO):void{
			if(itemVO == null){
				disposeContent();
				return;
			}
			if(data == null){
				data = itemVO;
			}else{
				setData(itemVO);
				content.updateContent(itemVO);
			}
			CoolingManager.getInstance().stopByCoolingID(coolingID);
			CoolingManager.getInstance().updateCooling(this);
			showTip();
			if(itemVO.state == ItemConstant.LOCK ){
				lock = true;
			}
			else if(itemVO.getItemStatus() != BaseItemVO.NORMAL && itemVO.getItemStatus()!=BaseItemVO.STARTUP)
			{
				lock = true;
				var times:int = 0;
				if(itemVO.getItemStatus() == BaseItemVO.UN_STARTUP)
				{
					times = itemVO.startTime-SystemConfig.serverTime  ;
				}
				if(times>0 && times<=3000)
				{
					timerStart(times);
				}
				else {
					timerStart();
				}
			}
			else{
				lock = false;
				if(itemVO.getItemStatus()==BaseItemVO.STARTUP && itemVO.timeoutData >0)
				{
					timerStart();
				}
				
			}
			onModeChange(null);
			buttonMode = useHandCursor = true;
		}
		
		private function timerStart(times:int=0):void
		{
			if(times>0)
		{
			if(!timer)
			{
					timer = new Timer(times,1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeComplet);
					timer.start();
					
				}
			}
			else if(!timer)
			{
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER,updataState);
				timer.start();
			}
		}
		private function timerStop():void
		{
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,updataState);
				timer = null;
			}
		}
		
		private function onTimeComplet(e:TimerEvent):void
		{
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeComplet);
				timer = null;
			}
			lock = false;
			onModeChange(null);
			
			
		}
		private function updataState(e:TimerEvent):void
		{
			var itemVO:BaseItemVO = data as BaseItemVO;
			var changeF:Boolean = false;                     //改变状态
			if(!itemVO || itemVO.timeoutData==0)
			{
				timerStop();
				return;
			}
			if(itemVO.getItemStatus() == BaseItemVO.NORMAL||itemVO.getItemStatus()==BaseItemVO.PASS_DATE)
			{
				timerStop();
			}
			if(itemVO.getItemStatus() != BaseItemVO.NORMAL && itemVO.getItemStatus()!=BaseItemVO.STARTUP)
			{
				if(!lock)
				{
					lock = true;
					changeF = true;
				}
			}
			if(changeF)
				onModeChange(null);
		}
		
		public function getName():String{
			var generalVO:GeneralVO = data as GeneralVO;
			if(generalVO && generalVO.effectType != 0){
				return generalVO.effectType.toString();
			}
			return "";
		}
		
		private var _coolingID:int;
		public function get coolingID():int{
			return _coolingID;
		}
		
		public function set coolingID(value:int):void{
			this._coolingID = value;
		}
		
		override public function getItemName():String{
			return DragConstant.PACKAGE_ITEM;
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:BaseItemVO = dragData as BaseItemVO;
			if(itemName == DragConstant.PACKAGE_ITEM){
				if(lock){
					PackManager.getInstance().updateGoods(tempData.bagid,tempData.position,tempData);
					return;
				}
				var currentPost:int = index + 1;
				if(currentPost == tempData.position && packId == tempData.bagid){ //启动拖拽，但是单击的是同一位置，不做任何操作
					setContent(item,tempData);
					CoolingManager.getInstance().updateCooling(this);
				}else{
					PackageModule.getInstance().swap(tempData.oid,currentPost,packId);
				}
			}else if(itemName ==  DragConstant.EQUIP_ITEM){
				var equipvo:EquipVO = tempData as EquipVO;
				PackageModule.getInstance().unLoadEquip(equipvo.oid,packId,index+1);
			}else if(itemName == DragConstant.LETTER_ITEM){
				LetterModule.getInstance().getLetterAccessory(tempData,packId,index+1);
			}else if(itemName == DragConstant.STALL_ITEM){
				tempData.unit_price = -1;
				DealModule.getInstance().getOut(tempData,packId,index+1);
			}else if(itemName == DragConstant.SPLIT_ITEM){
				currentPost = index + 1;
				var currentData:BaseItemVO = data as BaseItemVO;
				if(currentData && currentData.oid == tempData.oid){
					updateCount(currentData.num);
					return;
				}
				PackageModule.getInstance().divideGoods(tempData.oid,tempData.num,currentPost,packId);	
			}else if(itemName == DragConstant.FORGESHOP_ITEM){
				PackManager.getInstance().lockGoods(tempData,false);
				PackManager.getInstance().updateGoods(tempData.bagid,tempData.position,tempData);
				ForgeshopModule.getInstance().cleanGoods();
				if(ForgeshopModule.getInstance().isUpdateBoxHasData()){
					ForgeshopModule.getInstance().cleanUpdateGoods();
				}
				if(ForgeshopModule.getInstance().index() == 3){
					ForgeshopModule.getInstance().disposeEquipUpdate();
				}else if(ForgeshopModule.getInstance().index() == 1){
					ForgeshopModule.getInstance().dispseQulityData();
				}else if(ForgeshopModule.getInstance().index() == 0){
					ForgeshopModule.getInstance().disposeEquipCreateData();
				}else if(ForgeshopModule.getInstance().index() == 2){
					ForgeshopModule.getInstance().disposeSignNameData();
				}else if(ForgeshopModule.getInstance().index() == 4){
					ForgeshopModule.getInstance().disposeEquipRemoveData();
				}else if(ForgeshopModule.getInstance().index() == 5){
					ForgeshopModule.getInstance().disposeWuXingData();
				}
			}else if(itemName == DragConstant.MOUNT_UPGRADE_ITEM){
				PackManager.getInstance().lockGoods(tempData,false);
				tempData.state = 0;
				PackManager.getInstance().updateGoods(tempData.bagid,tempData.position,tempData);
				Dispatch.dispatch(ModuleCommand.MOUNT_UPGRADE_CLEAN);
			}else if(itemName == DragConstant.WAREHOUSE_ITEM){
				WarehouseModule.getInstance().takeOut(tempData.oid, index+1,packId);
			}else if(itemName == DragConstant.WRITE_ITEM_BACK){
				PackManager.getInstance().lockGoods(tempData, false);
				LetterModule.getInstance().disposeWriteAttach();
				LetterModule.getInstance().panel.letterWrite.money_txt.text = "";
			}else if(itemName == DragConstant.EXTRAL_ITEM){
				PackageModule.getInstance().unLoadExtralPack(int(dragData),packId,index+1);
			}else if(itemName == DragConstant.DEAL_ITEM){
				DealModule.getInstance().dealBackPackage(tempData);
				PackManager.getInstance().lockGoods(tempData,false);
			}else if(itemName == DragConstant.FMLDEPOT_ITEM){
				FamilyDepotModule.getInstance().openFMLget(tempData);
			} else if(itemName == DragConstant.SELL_ITEM) {
				PackageModule.getInstance().onDragOutSell(tempData);
				(dragTarget.parent as SellItem).unlock();
				(dragTarget.parent as IDragItem).disposeContent();
			}
		}			
	}
}