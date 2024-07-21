package modules.finery.views.insert {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.finery.StoveConstant;
	import modules.finery.StoveCostManager;
	import modules.finery.StoveEquipFilter;
	import modules.finery.StoveMaterialFilter;
	import modules.finery.views.item.EquipBox;
	import modules.finery.views.item.MaterialBox;
	import modules.finery.views.item.MaterialShopList;
	import modules.finery.views.item.RightBottomList;
	import modules.finery.views.item.RightTopList;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	import proto.line.m_refining_firing_toc;
	
	public class InsertView extends UIComponent {
		public static const　NAME:String = "InsertView";
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var equipBox:EquipBox;
		private var stoneBox:MaterialBox;
		private var materialBox:MaterialBox;
		private var punchBtn:Button;
		private var rightTopList:RightTopList;
		private var lingshiShop:MaterialShopList;
		private var xiangqianShop:MaterialShopList;
		private var rightBottomList:RightBottomList;
		private var moneyErrorTF:TextField;
		
		public function InsertView() {
			super();
		}
		
		private var hasInit:Boolean = false;
		public function initUI():void {
			if(hasInit){
				return;
			}
			this.x = 2;
			this.y = 6;
			var bg:UIComponent = ComponentUtil.createUIComponent(0,0,308,304);
			Style.setBorderSkin(bg);
			var stoveBg:Bitmap = Style.getBitmap(GameConfig.STOVE_UI,"stoveBg");
			stoveBg.x = bg.width - stoveBg.width >> 1;
			stoveBg.y = bg.height - stoveBg.height >> 1;
			addChild(bg);
			bg.addChild(stoveBg);
			bg.x=0;
			bg.y=3;
			
			var equipDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				CENTER);
			equipDesc=ComponentUtil.createTextField("请从右侧列表中选择装备", 78, 8, equipDescFormat, 200, 26, bg);
			equipDesc.filters=Style.textBlackFilter;
			equipDesc.x=(bg.width - equipDesc.width) * 0.5;
			
			equipBox=new EquipBox();
			equipBox.addEventListener("EQUIP_BOX_CLICK",onEquipBoxClick);
			equipBox.x=(bg.width - equipBox.bg.width) * 0.5;
			equipBox.y=equipDesc.y + equipDesc.height + 5;
			bg.addChild(equipBox);
			
			var middleDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xCDE644, null, null, null, null, null, TextFormatAlign.
				CENTER);
			middleDesc=ComponentUtil.createTextField("请放入灵石和镶嵌符", 0, 162, middleDescFormat, 298, 26, bg);
			middleDesc.filters=Style.textBlackFilter;
			middleDesc.x=(bg.width - middleDesc.width) * 0.5;
			
			stoneBox=new MaterialBox("灵石");
			stoneBox.addEventListener("MATERIAL_BOX_CLICK",onStoneBoxClick);
			bg.addChild(stoneBox);
			stoneBox.x=bg.width*0.5 - stoneBox.width - 15;
			stoneBox.y=middleDesc.y + middleDesc.height + 5;
			
			materialBox=new MaterialBox("符");
			materialBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBox);
			materialBox.x=bg.width*0.5 + 15;
			materialBox.y=middleDesc.y + middleDesc.height + 5;
			
			moneyDesc=ComponentUtil.createTextField("", 20, materialBox.y + materialBox.height, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("镶嵌费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 20, moneyDesc.y + 20, null,
				140, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
			
			punchBtn=ComponentUtil.createButton("镶嵌", bg.width - 120, moneyDesc.y - 2, 100, 25, bg);
			punchBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			
			//说明的背景
			var punchDescbg:UIComponent=new UIComponent();
			addChild(punchDescbg);
			Style.setBorderSkin(punchDescbg);
			punchDescbg.width=bg.width;
			punchDescbg.height=79;
			punchDescbg.x=bg.x;
			punchDescbg.y=bg.y + bg.height + 2;
			
			var punchDescFormat:TextFormat = new TextFormat("Tahoma",12);
			punchDescFormat.leading = 5;
			var punchDesc:TextField=ComponentUtil.createTextField("", 5, 5, punchDescFormat, 295, 70, punchDescbg);
			punchDesc.wordWrap=true;
			punchDesc.multiline=true;
			punchDesc.htmlText=HtmlUtil.font("镶嵌说明\n", "#CCE741") + HtmlUtil.font("从右侧列表选择装备和灵石。点击“镶嵌”按钮把灵石镶嵌到装备上。",
				"#ffffff");
			punchDesc.filters=Style.textBlackFilter;
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			rightBottomList = new RightBottomList();
			lingshiShop = new MaterialShopList();
			lingshiShop.initUI(StoveMaterialFilter.insertStoneByEquip());
			lingshiShop.addEventListener("MATERIAL_ITEM_CLICK",onlingshiShopItemClick);
			xiangqianShop = new MaterialShopList();
			xiangqianShop.initUI(StoveMaterialFilter.insertSymbol());
			xiangqianShop.addEventListener("MATERIAL_ITEM_CLICK",onXiangqianShopItemClick);
			var arr:Array = [{name:"灵石",reference:lingshiShop},{name:"镶嵌符",reference:xiangqianShop}];
			rightBottomList.initUI(arr);
			addChild(rightBottomList);
			rightBottomList.x = rightTopList.x;
			rightBottomList.y = 220;
			hasInit=true;
		}
		
		private function onlingshiShopItemClick(event:ParamEvent):void{
			event.stopPropagation();
			setStone(event.data);
		}
		
		private function onXiangqianShopItemClick(event:ParamEvent):void{
			event.stopPropagation();
			setMaterial(event.data);
		}
		
		private function onEquipListItemClick(event:ParamEvent):void{
			event.stopPropagation();
			setValue(event.data);
		}
		
		private function onEquipBoxClick(event:Event):void{
			setValue(null);
		}
		
		private function onStoneBoxClick(event:Event):void{
			setStone(null);
		}
		
		private function onMaterialBoxClick(event:Event):void{
			setMaterial(null);
		}
		
		private function setMaterial(data:*):void{
			materialBox.data = data;
			checkSelect();
		}
		
		private function setStone(data:*):void{
			stoneBox.data = data;
			checkSelect();
		}
		
		private function setValue(data:*):void{
			equipBox.data = data;
			var putWhere:int = -1;
			if(equipBox.data){
				putWhere = EquipVO(equipBox.data).putWhere;
			}
			lingshiShop.update(StoveMaterialFilter.insertStoneByEquip(putWhere));
			updateMoney(data);
			checkSelect();
			matchMaterial();
		}
		
		private function matchMaterial():void{
			if(equipBox.data){
				var equip:EquipVO = EquipVO(equipBox.data);
				var typeID:int = 0;
				if(equip.punch_num - equip.stone_num > 0){
					if(equip.stone_num < 2){
						typeID=10600007;
					}else if(equip.stone_num < 4){
						typeID=10600008;
					}else if(equip.stone_num < 6){
						typeID=10600009;
					}
				}
				if(typeID != 0){
					var goods:Array = PackManager.getInstance().getGoodsByType(typeID);
					if(goods.length > 0){
						setMaterial(goods[0]);
					}
				}
			}
		}
		
		private function checkSelect():void{
			if(equipBox.data){
				rightTopList.checkSelet(equipBox.data.oid);
			}else{
				rightTopList.checkSelet(-1);
			}
			var ids:Array = [];
			var binds:Array = [];
			if(materialBox.data){
				ids.push(materialBox.data.typeId);
				binds.push(materialBox.data.bind);
			}
			if(stoneBox.data){
				ids.push(stoneBox.data.typeId);
				binds.push(stoneBox.data.bind);
			}
			rightBottomList.checkSelect(ids,binds);
		}
		
		private function updateMoney(data:*):void{
			if(data){
				var money:int = StoveCostManager.insertStoneCost(data);
				moneyDesc.htmlText=HtmlUtil.font("镶嵌费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
				var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
				if( deMoney < 0 ){
					moneyErrorTF.htmlText = HtmlUtil.font("费用不足，缺"+DealConstant.silverToOtherString(-deMoney),"#ff0000");
				}else{
					moneyErrorTF.htmlText = "";
				}
			}else{
				moneyDesc.htmlText=HtmlUtil.font("镶嵌费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
				moneyErrorTF.htmlText = "";
			}
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
			if(vo.succ){
				setMaterial(null);
				setStone(null);
				setValue(StoveEquipFilter.findTarget(vo.firing_list,vo.update_list));
				Tips.getInstance().addTipsMsg("装备镶嵌成功！");
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
				//BroadcastSelf.logger(vo.reason);
			}
			equipBox.playCompleteEffec();
			equipBox.stopEffect();
			materialBox.stopEffect();
			stoneBox.stopEffect();
			update();
		}
		
		public function update():void{
			rightTopList.update();
			var putWhere:int = -1;
			if(equipBox.data){
				putWhere = EquipVO(equipBox.data).putWhere;
			}
			lingshiShop.update(StoveMaterialFilter.insertStoneByEquip(putWhere));
			xiangqianShop.update(StoveMaterialFilter.insertSymbol());
			checkSelect();
		}
		
		public function startEffect():void{
			equipBox.playEffect();
			stoneBox.playEffect();
			materialBox.playEffect();
		}
		
		public function reset():void{
			setValue(null);
			setMaterial(null);
			setStone(null);
			update();
		}
		
		private function errorTip(str:String):void{
			Tips.getInstance().addTipsMsg(str);
			//BroadcastSelf.logger(str);
		}
		
		private var insertMeterialLevel:Object = {10600007:2,10600008:4,10600009:6};
		private function onMouseClickHandler(event:MouseEvent):void {
			if(equipBox.data==null){
				errorTip("请放入需要镶嵌的装备");
				return;
			}
			var equip:EquipVO =EquipVO(equipBox.data);
			if(equip.stone_num >= StoveConstant.MAX_PUNCH_NUMBER) {
				errorTip("装备已经镶嵌满灵石，不需要再镶嵌");
				return;
			}
			if(stoneBox.data==null){
				errorTip("请放入需要镶嵌的灵石");
				return;
			}
			var stone:StoneVO = StoneVO(stoneBox.data);
			if(materialBox.data == null){
				errorTip("请放入镶嵌符");
				return;
			}
			var curInsertLevel:int = 2;
			if(equip.stone_num < 2){
				curInsertLevel = 2;
			}else if(equip.stone_num >= 2 && equip.stone_num < 4){
				curInsertLevel = 4;
			}else if(equip.stone_num >= 4){
				curInsertLevel = 6;
			}else{
				curInsertLevel = 2;
			}
			var material:GeneralVO = GeneralVO(materialBox.data);
			var materialLevel:int = insertMeterialLevel[material.typeId];
			if(materialLevel < curInsertLevel){
				if(curInsertLevel == 2){
					errorTip("请放入【初级镶嵌符】");
				}else if(curInsertLevel == 4){
					errorTip("请放入【中级镶嵌符】");
				}else if(curInsertLevel == 6){
					errorTip("请放入【高级镶嵌符】");
				}else{
					errorTip("请放入更高等级的镶嵌符");
				}
				return;
			}
			if(moneyErrorTF.htmlText != ""){
				errorTip("操作失败，费用不足");
				return;
			}
			if(equip.bind == false && (stone.bind == true || material.bind == true)){
				Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","警告",doInsert,null,"确认","取消",null,true,true);
			}else{
				doInsert();
			}
		}
		
		private function doInsert():void{
			var e:ParamEvent = new ParamEvent(StoveConstant.INSERT_BTN_CLICK,null,true);
			e.data = {equip:equipBox.data,stone:stoneBox.data,material:materialBox.data};
			dispatchEvent(e);
		}
	}
}