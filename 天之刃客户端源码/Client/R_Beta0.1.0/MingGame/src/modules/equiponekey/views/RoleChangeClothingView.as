package modules.equiponekey.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.common.dragManager.IDragItem;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.chat.ChatModule;
	import modules.equiponekey.EquipOneKeyModule;
	import modules.equiponekey.views.items.ClothingEquipItem;
	import modules.equiponekey.views.items.ClothingItem;
	import modules.equiponekey.views.items.ClothingItemVO;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.EquipVO;
	import modules.roleStateG.RoleStateDateManager;
	
	import proto.common.p_equip_onekey_info;
	import proto.common.p_equip_onekey_simple;
	
	public class RoleChangeClothingView extends Sprite
	{
		public static const PADDING_TOP:int=8;
		public static const LEFT_X:int=10;
		public static const RIGHT_X:int=271;
		public static const V_PADDING:int=12;
		
		private var list:Array;
		private var hotKeyText:TextField;
		private var clothingCB:ComboBox;
		private var clothingItem:ClothingItem;
		public function RoleChangeClothingView()
		{
			setupUI();
			super();
		}
		
		private function setupUI():void
		{
			x=8;
			var backBg:Skin=Style.getPanelContentBg();
			backBg.setSize(321,385);
			addChild(backBg);

			var blackBg:UIComponent = ComponentUtil.createUIComponent(50,5,222,330);
			Style.setBorderSkin(blackBg);
			addChild(blackBg);
			
			for (var i:int=1; i <= 7; i++)
			{
				createEquipItem(i, LEFT_X, PADDING_TOP + (i - 1) * (36 + V_PADDING));
			}
			for (i=8; i <= 14; i++)
			{
				createEquipItem(i, RIGHT_X, PADDING_TOP + (i - 7 - 1) * (36 + V_PADDING));
			}
			
			var tf:TextFormat = new TextFormat("Tahoma", 14, 0xF6F5CD);
			tf.align = "center";
			tf.bold = true;
			var roleName:TextField=ComponentUtil.createTextField("一键换装设置",50,10,tf,220,25,this);
			
			tf = new TextFormat("Tahoma", 12, 0xACDC91);
			tf.align = "center";
			hotKeyText = ComponentUtil.createTextField("本套快捷键：Shift+5",50,35,tf,220,25,this);
			
			var lb:TextField = ComponentUtil.createTextField("请选择装备方案：",50,hotKeyText.y+hotKeyText.height+5,tf,220,25,this);
			
			clothingCB = new ComboBox();
			clothingCB.addEventListener(Event.CHANGE,onChanged);
			clothingCB.width = 120;
			clothingCB.height = 23;
			clothingCB.maxListHeight = 120;
			clothingCB.x = 100;
			clothingCB.y = lb.y + lb.height + 5;
			addChild(clothingCB);
			
			lb = ComponentUtil.createTextField("请穿上你想要保存的套装，并点击\"保存\"",60,clothingCB.y+clothingCB.height+10,null,205,45,this);
			lb.textColor = 0xACDC91;
			lb.wordWrap = true;
			lb.multiline = true;
				
			
			var readerBtn:Button = ComponentUtil.createButton("读取",85,175,65,28,this);
			readerBtn.setToolTip("读取当前身上装备",100);
			var takeoffBtn:Button = ComponentUtil.createButton("全卸",173,175,65,28,this);
			takeoffBtn.setToolTip("清除本套装备的信息",100);
			var reNameBtn:Button = ComponentUtil.createButton("命名",85,215,65,28,this);
			var saveBtn:Button = ComponentUtil.createButton("保存",173,215,65,28,this);
		
			clothingItem = new ClothingItem();
			clothingItem.x = 98;
			clothingItem.y = 260;
			addChild(clothingItem);
			
			var changeBtn:Button = ComponentUtil.createButton("换装",165,265,65,30,this);
			
			DragItemManager.instance.addEventListener(DragItemEvent.START_DRAG, onStartDrag);
			DragItemManager.instance.addEventListener(DragItemEvent.STOP_DRAG, onStopDrag);
			
			readerBtn.addEventListener(MouseEvent.CLICK,onReaderHandler);
			takeoffBtn.addEventListener(MouseEvent.CLICK,onTakeOffHandler);
			reNameBtn.addEventListener(MouseEvent.CLICK,onReNameHandler);
			saveBtn.addEventListener(MouseEvent.CLICK,onSaveHandler);
			changeBtn.addEventListener(MouseEvent.CLICK,onChangeHandler);
			addEventListener(DragItemEvent.DRAG_THREW,onThrewItemHandler);
		}
		
		public function updateEquipsName(suitId:int,newName:String):void{
			var dataProvider:Array = clothingCB.dataProvider;
			for each(var clothingItemVo:ClothingItemVO in dataProvider){
				if(clothingItemVo.suitId == suitId){
					if(clothingItemVo.name != newName){
						clothingItemVo.name = newName;
						clothingCB.invalidateItem(clothingItemVo);
						clothingItemVo.draw(true);
						if(clothingItem.data == clothingItemVo){
							clothingItem.data = clothingItemVo;
						}
						EquipOneKeyModule.getInstance().clothingNameChanged(clothingItemVo);
					}
					break;
				}
			}
		}
		
		public function setEquipOneKeyList(list:Array):void{
			this.list = list;
			var dataProvider:Array = [];
			for each(var info:p_equip_onekey_info in list){
				var clothingItemVo:ClothingItemVO = new ClothingItemVO();
				clothingItemVo.suitId = info.equips_id;
				clothingItemVo.name = info.equips_name;
				clothingItemVo.equips_list = info.equips_list;
				dataProvider.push(clothingItemVo);
			}
			clothingCB.labelField = "name";
			dataProvider.sortOn("suitId",Array.NUMERIC);
			clothingCB.dataProvider = dataProvider;
			clothingCB.selectedIndex = 0;
		}
		
		private function clearEquips():void{
			for(var i:int=1;i<=14;i++){
				var equipItem:ClothingEquipItem = getEquipItemByName(i);
				equipItem.disposeContent();
			}	
		}
		
		public function setEquipsInfo(equipsList:Array):void{
			clearEquips();
			for each(var equipVO:EquipVO in equipsList){
				putRoleEquip(equipVO.loadposition,equipVO);
			}
		}
		
		private function putRoleEquip(position:int, equip:EquipVO):void
		{
			var equipBox:ClothingEquipItem=getChildByName(position.toString())as ClothingEquipItem;
			if(equipBox){
				equipBox.data=equip;
			}
		}
		
		public function getEquipItemByName(index:int):ClothingEquipItem
		{
			return this.getChildByName(index.toString())as ClothingEquipItem
		}
		
		private function createEquipItem(pos:int, xValue:Number, yValue:Number):void
		{
			var equipItem:ClothingEquipItem=new ClothingEquipItem();
			equipItem.name=pos.toString();
			equipItem.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			equipItem.position=pos;
			equipItem.x=xValue;
			equipItem.y=yValue;
			addChild(equipItem);
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			var equipItem:ClothingEquipItem=event.currentTarget as ClothingEquipItem;
			if (event.ctrlKey && equipItem.data)
			{
				ChatModule.getInstance().showGoods(equipItem.data.oid);
			}
			else if (equipItem.data && !DragItemManager.isDragging())
			{
				DragItemManager.instance.startDragItem(this, equipItem.getContent(), DragConstant.CLOTHING_EQUIP_ITEM, equipItem.data);
			}
		}
		
		private function onStartDrag(event:DragItemEvent):void
		{
			if(event.itemName == DragConstant.PACKAGE_ITEM || event.itemName == DragConstant.CLOTHING_EQUIP_ITEM){
				var equipVO:EquipVO=event.dragData as EquipVO;
				if (equipVO){
					setFilter([new GlowFilter(0xffffff, 1, 6, 6, 4)], equipVO);
				}
			}
		}
		
		private function onStopDrag(event:DragItemEvent):void
		{
			if(event.itemName == DragConstant.PACKAGE_ITEM || event.itemName == DragConstant.CLOTHING_EQUIP_ITEM){
				var equipVO:EquipVO=event.dragData as EquipVO;
				if (equipVO){
					setFilter([], equipVO);
				}
			}
		}
		
		public function setFilter(filters:Array, equipVO:EquipVO):void
		{
			var pos:Array=ItemConstant.getPostionByPutWhere(equipVO.putWhere);
			for each (var position:int in pos)
			{
				if( position == 6 )continue;
				var equipItem:ClothingEquipItem=getChildByName((position + 1).toString())as ClothingEquipItem;
//				equipItem.filters=filters;
			}
		}
		
		private function onReaderHandler(event:MouseEvent):void{
			setEquipsInfo(RoleStateDateManager.equips);
		}
		
		private function onTakeOffHandler(event:MouseEvent):void{
			clearEquips();
		}
		
		private function onReNameHandler(event:MouseEvent):void{
			var selectedItem:ClothingItemVO = clothingCB.selectedItem as ClothingItemVO;
			if(selectedItem){
				ClothingReNameView.getInstance().show(reName,selectedItem);
			}
		}
		
		private function reName(clotingItemVO:ClothingItemVO,newName:String):void{
			var equipInfo:p_equip_onekey_info = new p_equip_onekey_info();
			equipInfo.equips_id = clotingItemVO.suitId;
			equipInfo.equips_name = newName;
			equipInfo.equips_id_list = [];
			var equips:Array = EquipOneKeyModule.getInstance().getEquipsById(equipInfo.equips_id);
			for each(var equipVO:EquipVO in equips){
				if(equipVO){
					var simple:p_equip_onekey_simple = new p_equip_onekey_simple();
					simple.equip_id = equipVO.oid;
					simple.slot_num = equipVO.loadposition;
					simple.equip_typeid = equipVO.typeId;
					equipInfo.equips_id_list.push(simple);
				}
			}
			EquipOneKeyModule.getInstance().saveEquips(equipInfo);
		}
		
		private function onSaveHandler(event:MouseEvent):void{
			var selectedItem:ClothingItemVO = clothingCB.selectedItem as ClothingItemVO;
			if(selectedItem){
				var equipInfo:p_equip_onekey_info = new p_equip_onekey_info();
				equipInfo.equips_id = selectedItem.suitId;
				equipInfo.equips_name = selectedItem.name;
				equipInfo.equips_id_list = [];
				var equips:Array = [];
				for(var i:int=1;i<=14;i++){
					var equipItem:ClothingEquipItem = getEquipItemByName(i);
					if(equipItem.data){
						var simple:p_equip_onekey_simple = new p_equip_onekey_simple();
						simple.equip_id = equipItem.data.oid;
						simple.slot_num = equipItem.position;
						simple.equip_typeid = equipItem.data.typeId;
						equipInfo.equips_id_list.push(simple);
					}
				}
				EquipOneKeyModule.getInstance().saveEquips(equipInfo);
			}
		}
		
		private function onChangeHandler(event:MouseEvent):void{
			var selectedItem:ClothingItemVO = clothingCB.selectedItem as ClothingItemVO;
			if(selectedItem){
				EquipOneKeyModule.getInstance().loadEquips(selectedItem.suitId);
			}
		}
		
		private function onThrewItemHandler(event:DragItemEvent):void{
			var dragItem:IDragItem = event.dragTarget.parent as IDragItem;
			if(dragItem){
				dragItem.disposeContent();
			}
		}
		
		private function onChanged(event:Event):void{
			var selectedItem:ClothingItemVO = clothingCB.selectedItem as ClothingItemVO;
			if(selectedItem){
				clothingItem.data = selectedItem;
				EquipOneKeyModule.getInstance().getEquipsInfo(selectedItem.suitId);
				hotKeyText.text = "本套快捷键：Shift+"+(clothingCB.selectedIndex+1);
			}
		}
	}
}