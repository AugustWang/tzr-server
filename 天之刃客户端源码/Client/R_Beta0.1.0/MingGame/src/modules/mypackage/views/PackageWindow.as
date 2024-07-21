package modules.mypackage.views
{
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.operateMode.OperateMode;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.shop.ShopModule;
	import modules.vip.VipDataManager;
	import modules.vip.VipModule;
	import modules.warehouse.WarehouseModule;
	
	import proto.common.p_role_attr;

	/**
	 * 背包窗口
	 */ 
	public class PackageWindow extends BasePanel implements IPack
	{			
		private var tile:PackTile;
		private var backBG:UIComponent;
		private var centerSprite:Sprite;
		private var gold_btn:TextField;
		private var bind_goldBtn:TextField;
		private var silver_btn:TextField;
		private var copper_btn:TextField;
		
		private var gold_lb:TextField;
		private var bind_goldlb:TextField;
		private var silver_lb:TextField;
		private var bindsilver_lb:TextField;
		
		//摆摊
		private var btn_myShop:Button;
		//整理
		public var btn_cleanUp:Button;
		//仓库
		private var btnDepot:Button;
		//出售
		public var btn_split:Button;
		
		public var exItem2:ExtraPackItem;
		public var exItem3:ExtraPackItem;
		
		private var packId:int;
		private var extrals:Dictionary;
		
		private var stall_btn_type:int =0;
		private var baitan_glow:Boolean = false;
		public function PackageWindow(packId:int)
		{
			
			this.packId = packId;
			super("PackageWindow");
		}
		public function getItem(index:int):PackageItem
		{
			return this.tile.getTileItem(index)
		}
		override protected function init():void{
			width = 338;
			height = 424;
			addSmaillTitleBG();
			addImageTitle("title_pack");
			
			backBG = ComponentUtil.createUIComponent(6,0,326,218);
			Style.setBorderSkin(backBG);
			addChild(backBG);
			
			tile = new PackTile(packId);
			tile.x = 9;
			tile.y = 3;
			tile.owner = this;
			addChild(tile);	
			
			centerSprite = new Sprite();
			centerSprite.x = 10;
			centerSprite.y = tile.y+tile.height;
			addChild(centerSprite);
			
			extrals = new Dictionary();
			exItem2 = createExtralItem(PackManager.PACK_2,107,14,centerSprite);
			exItem3 = createExtralItem(PackManager.PACK_3,175,14,centerSprite);
			
			btn_myShop = new Button();
			btn_myShop.width = 65;
			btn_myShop.height = 25;
			btn_myShop.label = "随身商店";
			btn_myShop.y = 60;
			btn_myShop.x = 232;
			centerSprite.addChild(btn_myShop);
			btn_myShop.addEventListener(MouseEvent.CLICK, openMyShop);
			
			var fixEquipBtn:Button = new Button;
			fixEquipBtn.width = 100;
			fixEquipBtn.height = 25;
			fixEquipBtn.label = "修理全部装备";
			fixEquipBtn.x = 112;
			fixEquipBtn.y = 60;
			centerSprite.addChild(fixEquipBtn);
			fixEquipBtn.addEventListener(MouseEvent.CLICK, fixEquipBtnClickHandler);
			
			btn_cleanUp = new Button();
			btn_cleanUp.width = 65;
			btn_cleanUp.height = 25;
			btn_cleanUp.label = "整理";
			btn_cleanUp.x = 232;
			btn_cleanUp.y = 20;
			btn_cleanUp.addEventListener(MouseEvent.CLICK,onCleanHandler);
			centerSprite.addChild(btn_cleanUp);
			
			btn_split = new Button;
			btn_split.width = 65;
			btn_split.height = 25;
			btn_split.label = "拆分";
			btn_split.y = 20;
			btn_split.x = 25;
			centerSprite.addChild(btn_split);
			btn_split.addEventListener(MouseEvent.CLICK, splitHandler);
			
			btnDepot = new Button;
			btnDepot.width = 65;
			btnDepot.height = 25;
			btnDepot.label = "仓库";
			btnDepot.x = 25;
			btnDepot.y = 60;
			centerSprite.addChild(btnDepot);
			btnDepot.addEventListener(MouseEvent.CLICK, onOpenWareHouse);
			
			var back1:Skin = Style.getInstance().textInputSkin;
			back1.width = 310;
			back1.x = 5;
			back1.y = 90;
			centerSprite.addChild(back1);
			
			var back2:Skin = Style.getInstance().textInputSkin;
			back2.x = 5;
			back2.y = 118;
			back2.width = 310;
			centerSprite.addChild(back2);
			
			var tf:TextFormat = Style.themeTextFormat;
			gold_btn = ComponentUtil.createTextField("元    宝",10,92,tf,62,21,centerSprite,wrapper);
			bind_goldBtn = ComponentUtil.createTextField("绑定元宝",155,92,tf,62,21,centerSprite,wrapper);
			silver_btn = ComponentUtil.createTextField("银    子",10,120,tf,62,21,centerSprite,wrapper);
			copper_btn = ComponentUtil.createTextField("绑定银子",155,120,tf,62,21,centerSprite,wrapper);
			
			tf = Style.textFormat;
			gold_lb = ComponentUtil.createTextField("",60,92,tf,67,22,centerSprite,wrapper);
			bind_goldlb = ComponentUtil.createTextField("",210,92,tf,69,22,centerSprite,wrapper);
			silver_lb = ComponentUtil.createTextField("",60,120,tf,133,22,centerSprite,wrapper);
			bindsilver_lb = ComponentUtil.createTextField("",210,120,tf,133,22,centerSprite,wrapper);
			
			updateMoney();
			OperateMode.getInstance().addEventListener(Event.CHANGE,onModeChange);
			onModeChange(null);
			DragItemManager.instance.addEventListener(DragItemEvent.START_DRAG,onStartDrag);
			DragItemManager.instance.addEventListener(DragItemEvent.STOP_DRAG,onStopDrag);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			extensionPack(PackManager.MAIN_PACK_ROWS,PackManager.MAIN_PACK_COLUMNS,PackManager.MAIN_PACK_COUNT);
		}
		
		public function extensionPack(row:int,column:int,count:int=40):void{
			tile.extensionTile(row,column,count);
			height = tile.height+210;
			centerSprite.y = tile.y+tile.height;
			backBG.height = tile.height+12;
			backBG.validateNow();
		}
		
		private function openMyShop(event:MouseEvent):void{
			Dispatch.dispatch(ModuleCommand.OPEN_MY_SHOP);
		}
		
		private function fixEquipBtnClickHandler(evt:Event):void{
			if (VipModule.getInstance().getRoleVipLevel() >= 4) {
				PackageModule.getInstance().fixEquip(0, false);
				return;
			}
			var str:String = "";
			if (VipModule.getInstance().isVipExpire()) {
				str = "VIP2才能使用修理全部装备，你的VIP已过期，<font color='#00ff00'><a href='event:openVIP'><u>续期VIP</u></a></font>";
			} else if (VipModule.getInstance().getRoleVipLevel() < 2) {
				str = "VIP2才能使用修理全部装备，你还不是VIP2，<font color='#00ff00'><a href='event:openVIP'><u>成为VIP2</u></a></font>"
			}
			
			if (str != "") {
				var dialogId:String = Alert.show(str, "提示", null, null, "确定", "",null, false, true, null, openVIP);
				function openVIP():void
				{
					VipModule.getInstance().onOpenVipPannel();
					Alert.removeAlert(dialogId);
				}
			}
		}
		
		private function onBugPackageHandle(e:TextEvent):void{
			//扩展背包商店
			ShopModule.getInstance().requestShopItem(30100, 11300001, new Point(stage.mouseX-178, stage.mouseY-90));
		}
		
		private function onAddedToStage(event:Event):void{
			if(PackManager.getInstance().inited){
				var items:Array = PackManager.getInstance().getItemsByPackId(packId);
				setGoods(items);
			}else{
				getGoods();
			}
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function wrapper(txt:TextField):void{
			txt.mouseEnabled = true;
			txt.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			txt.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
		}
		
		private function onRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private function onRollOver(event:MouseEvent):void{	
			var tip:String = "";
			switch(event.currentTarget){
				case gold_btn: tip = "可以在商店中购买元宝道具，也可以在钱庄中卖出元宝获得银子。";break;
				case bind_goldBtn: tip = "可以在商店中购买元宝道具。";break;
				case silver_btn: tip = "可以在商店中购买银子道具，也可以在钱庄中购买元宝。";break;
				case copper_btn: tip = "可以在商店中购买银子道具。";break;
			}
			if(tip != ""){
				ToolTipManager.getInstance().show(tip,200);
			}
		}
		
		private function setRedBg(btn:Button):void{
			btn.textColor = 0xffcc00;
			btn.bgSkin = Style.getSkin("redBtn_skin",GameConfig.T1_UI,new Rectangle(4,4,42,13));	
		}
		
		private function onModeChange(event:Event):void{
			if(OperateMode.getInstance().modeName == OperateMode.NORMAL_MODE){
				btn_cleanUp.enabled = true;
			}else if(OperateMode.getInstance().modeName == OperateMode.DEAL_MODE || OperateMode.getInstance().modeName == OperateMode.BT_MODE){
				btn_cleanUp.enabled = false;
			}
		}
		
		private function onCleanHandler(event:MouseEvent):void{
			addDataLoading();
			PackageModule.getInstance().cleanPackage(packId);
		}
		
		private function onOpenWareHouse(event:MouseEvent):void
		{
			// 只有VIP才能使用远程仓库
			var str:String = "";
			var dialogId:String = "";
			var minLevel:int = VipDataManager.getInstance().getRemoteDepotMinLevel();
			if (VipModule.getInstance().isVipExpire()) {
				str = "VIP" + minLevel + "才能使用远程仓库，你的VIP已过期，<font color='#00ff00'><a href='event:openVIP'><u>续期VIP</u></a></font>";
				dialogId = Alert.show(str, "提示", null, null, "确定", "",null, false, true, null, openVIP);
				
				function openVIP():void
				{
					VipModule.getInstance().onOpenVipPannel();
					Alert.removeAlert(dialogId);
				}
				
				return;
			} else if (VipModule.getInstance().getRoleVipLevel() < minLevel) {
				str = "VIP" + minLevel + "才能使用远程仓库，你还不是VIP" + minLevel + "，<font color='#00ff00'><a href='event:openVIP'><u>成为VIP" + minLevel + "</u></a></font>";
				dialogId = Alert.show(str, "提示", null, null, "确定", "",null, false, true, null, openVIPIndex);
				
				function openVIPIndex():void
				{
					VipModule.getInstance().onOpenVipPannel(minLevel);
					Alert.removeAlert(dialogId);
				}
				
				return;
			}
			
			WarehouseModule.getInstance().openWareHouse(0);
		}
		
//		/**
//		 * 打开背包的出售界面 
//		 * @param e
//		 * 
//		 */		
//		public function openSellHandler(e:MouseEvent):void
//		{
//			var s:GoodsSellPanel=PackageModule.getInstance().sellPanel;
//			if(s==null||s.stage==null){
//				PackageModule.getInstance().showSellPanel();
//			}else if(s && s.stage){
//				PackageModule.getInstance().sellPanel.closeWindow();
//			}
//		}
		private function splitHandler(event:MouseEvent):void{
			if(CursorManager.getInstance().currentCursor != CursorName.SPLIT){
				CursorManager.getInstance().setCursor(CursorName.SPLIT);
				CursorManager.getInstance().enabledCursor = false;
			}else if(CursorManager.getInstance().currentCursor == CursorName.SPLIT){
				CursorManager.getInstance().enabledCursor = true;
				CursorManager.getInstance().hideCursor(CursorName.SPLIT);
			}
		}
		
		private function createExtralItem(id:int,x:int,y:int,parent:Sprite):ExtraPackItem{
			var item:ExtraPackItem = new ExtraPackItem();
			item.packId = id;
			item.x = x;
			item.y = y;
			//提示
			item.addEventListener(MouseEvent.ROLL_OVER,onShowTip);
			item.addEventListener(MouseEvent.ROLL_OUT,removeShowTip);
			item.addEventListener(MouseEvent.MOUSE_DOWN,onExtralMouseDown);
			extrals[id] = item;
			var desc:Object = PackManager.getInstance().extensionObj[id];
			if(desc){
				item.data = ItemLocator.getInstance().getObject(desc.typeId);
				item.typeId = item.data.typeId;
				item.count = desc.count;
			}
			parent.addChild(item);
			return item;
		}
		
		private function onShowTip(e:MouseEvent):void{
			var item:ExtraPackItem = e.currentTarget as ExtraPackItem;
			if(item && item.data){
				ToolTipManager.getInstance().show(item.data as BaseItemVO, 0, 0, 0, "targetToolTip");
			}
		}
		
		private function removeShowTip(e:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
			
		private function onExtralMouseDown(event:MouseEvent):void{
			var item:ExtraPackItem = event.currentTarget as ExtraPackItem;
			if(OperateMode.getInstance().modeName == OperateMode.NORMAL_MODE && item && item.data){
				var items:Array = PackManager.getInstance().getItemsByPackId(item.packId);
				DragItemManager.instance.startDragItem(this,item.getContent(),DragConstant.EXTRAL_ITEM,item.packId);
			}
		}
		
		public function updateMoney():void{
			var user:p_role_attr = GlobalObjectManager.getInstance().user.attr;
			gold_lb.text =  user.gold.toString();
			bind_goldlb.text = user.gold_bind.toString();
			silver_lb.text= MoneyTransformUtil.silverToOtherString(user.silver);
			bindsilver_lb.text=MoneyTransformUtil.silverToOtherString(user.silver_bind);
		}
		
		private function getGoods():void{
			addDataLoading();
			PackageModule.getInstance().getGoods(packId);
		}
	
		public function setGoods(items:Array):void{
			removeDataLoading();
			tile.setGoods(items);
		}
		
		public function addExtralItem(packId:int,typeId:int,count:int):void{
			var packItem:ExtraPackItem = extrals[packId];
			if(packItem){
				packItem.packId = packId;
				packItem.typeId = typeId;
				packItem.count = count;
				packItem.data = ItemLocator.getInstance().getObject(typeId);
			}
		}
		
		public function deleteExtralItem(packId:int):void{
			var packItem:ExtraPackItem = extrals[packId];
			if(packItem){
				packItem.disposeContent();
			}
		}
		
		public function updateGoods(pos:int,itemvo:BaseItemVO):void{
			tile.updateGoods(pos,itemvo);
		}
		
		public function setLock(pos:int,lock:Boolean):void{
			tile.setLock(pos,lock);
		}	
		
		
		public function baitanState(type:int):void{
//			if(type<0 || type>3)
//				return;
//			stall_btn_type = type;
//			if(type == 2){
//				btn_baitan.label = "收摊";
//			}else{
//				btn_baitan.label = "摆摊";
//			}
		}
		
		public function onStallHandler(evt:MouseEvent=null):void{
//			PackageModule.getInstance().openStallPanel(stall_btn_type);
		}
		
		private function onStartDrag(event:DragItemEvent):void{
			if(event.itemName == DragConstant.PACKAGE_ITEM){
				var generalVO:GeneralVO = event.dragData as GeneralVO;
				if(generalVO && generalVO.kind == ItemConstant.KIND_PACK){
				 	var extralItem:ExtraPackItem = getFreeExtralItem();
					if(extralItem){
						extralItem.filters = [new GlowFilter(0xffffff, 1, 6, 6, 4)];
					}
				}
			}else if(event.itemName == DragConstant.EXTRAL_ITEM){
				var item:ExtraPackItem = ExtraPackItem(event.dragTarget.parent);
				if(item && !tile.hasEmptyCount(item.count)){
					Tips.getInstance().addTipsMsg("请先将发光区域的背包物品取出");
				}
				tile.startGrowItems(item.count);
			}
		}
		
		private function onStopDrag(event:DragItemEvent):void{
			for each(var extralItem:ExtraPackItem in extrals){
				extralItem.filters = [];
			}
			tile.stopGlowItems();
		}
		
		private function getFreeExtralItem():ExtraPackItem{
			for(var i:int=2;i<=3;i++){
				var extralItem:ExtraPackItem = extrals[i];
				if(extralItem.data == null){
					return extralItem;
				}
			}
			return null;
		}
		
		override public function dispose():void{
			super.dispose();
			tile.dispose();
			DragItemManager.instance.removeEventListener(DragItemEvent.START_DRAG,onStartDrag);
			DragItemManager.instance.removeEventListener(DragItemEvent.STOP_DRAG,onStopDrag);
		}		
	}
}