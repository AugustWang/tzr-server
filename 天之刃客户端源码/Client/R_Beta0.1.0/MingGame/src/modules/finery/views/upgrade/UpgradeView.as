package modules.finery.views.upgrade {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
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
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	
	import proto.line.m_refining_firing_toc;
	
	public class UpgradeView extends UIComponent {
		public static const　NAME:String = "UpgradeView";
		
		private var equipBox:EquipBox;
		private var upgradeBox:EquipBox;
		private var materialCombox:ComboBox;
		private var materialBox:MaterialBox;
		
		private var shengjifuShop:MaterialShopList;
		private var rightTopList:RightTopList;
		private var rightBottomList:RightBottomList;
		private var moneyDesc:TextField;
		private var middleDesc:TextField;
		private var moneyErrorTF:TextField;
		private var equipDesc:TextField;
		
		private var equipTip:TextField;
		private var upgradeTip:TextField;
		
		private var upgradeBtn:Button;
		
		//当前装备符下拉选择列表数据
		private var curUpgradeSymbols:Array = [];
		
		public function UpgradeView() {
			super();
		}
		
		private var hasInit:Boolean = false;
		public function initUI():void {
			if(hasInit){
				return;
			}
			this.x = 2;
			this.y = 2;
			var bg:UIComponent = ComponentUtil.createUIComponent(0,0,308,304);
			Style.setBorderSkin(bg);
			var stoveBg:Bitmap = Style.getBitmap(GameConfig.STOVE_UI,"stoveBg");
			stoveBg.x = bg.width - stoveBg.width >> 1;
			stoveBg.y = bg.height - stoveBg.height >> 1;
			addChild(bg);
			bg.addChild(stoveBg);
			bg.x=0;
			bg.y=3;
			
			var equipDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.CENTER);
			equipDesc=ComponentUtil.createTextField("请从右侧列表中选择装备", 78, 8, equipDescFormat, 200, 26, bg);
			equipDesc.filters=Style.textBlackFilter;
			equipDesc.x=(bg.width - equipDesc.width) * 0.5;
			
			equipBox=new EquipBox("装备",false);
			equipBox.addEventListener("EQUIP_BOX_CLICK",onEquipBoxClick);
			equipBox.x=(bg.width - equipBox.bg.width) * 0.5 - 85;
			equipBox.y=equipDesc.y + equipDesc.height + 5;
			bg.addChild(equipBox);
			
			var tf:TextFormat=new TextFormat("Tahoma", 12, 0xCDE644, null, null, null, null, null, TextFormatAlign.CENTER);
			
			equipTip=ComponentUtil.createTextField("", equipBox.x - 20, equipBox.y + equipBox.height + 5, tf, 100, 26, bg);
			
			
			curUpgradeSymbols = StoveConstant.upgradeSymbols;
			materialCombox=new ComboBox();
			materialCombox.labelField="name";
			materialCombox.width=95;
			materialCombox.height=23;
			materialCombox.x=(bg.width - materialCombox.width) * 0.5;
			materialCombox.y=equipBox.y + 25;
			materialCombox.maxListHeight=200;
			materialCombox.addEventListener(Event.CHANGE, onMaterialComboxChange);
			materialCombox.dataProvider = curUpgradeSymbols;;
			materialCombox.selectedIndex = 0;
			bg.addChild(materialCombox); 
			
			upgradeBox=new EquipBox("装备",false);
			upgradeBox.x=(bg.width - equipBox.bg.width) * 0.5 + 85;
			upgradeBox.y=equipDesc.y + equipDesc.height + 5;
			bg.addChild(upgradeBox);
			
			upgradeTip = ComponentUtil.createTextField("", upgradeBox.x - 20, upgradeBox.y + upgradeBox.height + 5, tf, 100, 26, bg);
			
			
			middleDesc=ComponentUtil.createTextField("请放入装备符", 0, 162, tf, 298, 26, bg);
			middleDesc.filters=Style.textBlackFilter;
			middleDesc.x=(bg.width - middleDesc.width) * 0.5;
			
			materialBox=new MaterialBox("符");
			materialBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBox);
			materialBox.x=(bg.width - materialBox.width) * 0.5;
			materialBox.y=middleDesc.y + middleDesc.height + 5;
			
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
			var punchDesc:TextField=ComponentUtil.createTextField("",5, 5, punchDescFormat, 295, 70, punchDescbg);
			punchDesc.wordWrap=true;
			punchDesc.multiline=true;
			punchDesc.htmlText=HtmlUtil.font("装备升级\n", "#CCE741") + HtmlUtil.font("使用装备符可将装备升级到相应等级，装备符可在大明英雄副本掉落。",
				"#ffffff");
			punchDesc.filters=Style.textBlackFilter;
			
			moneyDesc=ComponentUtil.createTextField("", 20, materialBox.y + materialBox.height + 15, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("升级费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 20, moneyDesc.y + 15, null,
				140, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
			
			upgradeBtn=ComponentUtil.createButton("升级", bg.width - 120, moneyDesc.y - 2, 100, 25, bg);
			upgradeBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			rightBottomList = new RightBottomList();
			shengjifuShop = new MaterialShopList();
			shengjifuShop.initUI(StoveMaterialFilter.upgrade());
			shengjifuShop.addEventListener("MATERIAL_ITEM_CLICK",onShengjifuShopItemClick);
			var arr:Array = [{name:"装备符",reference:shengjifuShop}];
			rightBottomList.initUI(arr);
			addChild(rightBottomList);
			rightBottomList.x = rightTopList.x;
			rightBottomList.y = 216;
			hasInit=true;
		}
		
		private function onMaterialComboxChange(event:Event):void{
			var typeID:int = this.curUpgradeSymbols[materialCombox.selectedIndex].id;
			if(equipBox.data && typeID != 0){
				var goods:Array = PackManager.getInstance().getGoodsByType(typeID);
				if(goods.length > 0){
					setMaterial(goods[0]);
				}else{
					setMaterial(null);
				}
				getUpgradeNext();
			}
		}
		
		private function onMouseClickHandler(event:MouseEvent):void{
			if(equipBox.data==null){
				errorTip("请放入需要升级的装备");
				return;
			}
			var curComboxObj:Object = this.curUpgradeSymbols[materialCombox.selectedIndex];
			if(curComboxObj == null){
				errorTip("请选择装备符");
				return;
			}
			if(upgradeBox.data == null){
				errorTip("请重新选择装备符");
				return;
			}
			var money:int = StoveCostManager.equipUpgradeCost(EquipVO(upgradeBox.data));
			//计算升级费用
			var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
			if( deMoney < 0 ){
				errorTip("银子不足，无法升级");
				return;
			}
			if(materialBox.data == null){
				errorTip("请放入" +　curComboxObj.name);
				return;
			}
			if(materialBox.data.typeId != curComboxObj.id){
				errorTip("请放入" +　curComboxObj.name);
				return;
			}
			if(upgradeBox.data.level > GlobalObjectManager.getInstance().user.attr.level){
				Alert.show("你当前的无法使用升级后的装备，是否继续升级装备？","警告",doYesUpgrade,null,"确认","取消",null,true,true);
			}else{
				doYesUpgrade();
			}
			
		}
		private function doYesUpgrade():void{
			if(materialBox.data.bind == true && equipBox.data.bind == false){
				//绑定提示
				Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","警告",doUpgrade,null,"确认","取消",null,true,true);
			}else{
				doUpgrade();
			}
		}
		
		private function onShengjifuShopItemClick(event:ParamEvent):void{
			event.stopPropagation();
			setMaterial(event.data);
			var curComboxObj:Object = this.curUpgradeSymbols[materialCombox.selectedIndex];
			if(curComboxObj.id != event.data.typeId){
				//重置下拉选择框
				for(var i:int = 0; i < curUpgradeSymbols.length; i++){
					if(event.data.typeId == curUpgradeSymbols[i].id){
						materialCombox.selectedIndex = i;
						materialCombox.selectedItem = curUpgradeSymbols[i];
						getUpgradeNext();
						return;
					}
				}
			}
			
		}
		
		private function onEquipListItemClick(event:ParamEvent):void{
			event.stopPropagation();
			setValue(event.data);
		}
		
		private function onEquipBoxClick(event:Event):void{
			setValue(null);
		}
		
		private function onMaterialBoxClick(event:Event):void{
			setMaterial(null);
		}
		
		private function setMaterial(data:*):void{
			materialBox.data = data;
			updateMoney();
			checkSelect();
			updateAllTip();
		}
		
		/**
		 * 配置属性加强材料
		 */		
		private function matchMaterial():void{
			if(equipBox.data){
				var level:int = equipBox.data.level;
				for(var i:int = 0; i < curUpgradeSymbols.length; i++){
					if(level < curUpgradeSymbols[i].level){
						materialCombox.selectedIndex = i;
						materialCombox.selectedItem = curUpgradeSymbols[i];
						var typeID:int = curUpgradeSymbols[i].id
						if(typeID != 0){
							var goods:Array = PackManager.getInstance().getGoodsByType(typeID);
							if(goods.length > 0){
								setMaterial(goods[0]);
							}
						}
						return;
					}
				}
			}
		}
		
		private function setValue(data:*):void{
			equipBox.data = data;
			//修改升级符下拉框显示
			if(equipBox.data){
				var equipLevel:int = equipBox.data.level;
				if(equipLevel <= 0){
					equipLevel = 10;
				}else{
					equipLevel = int(equipLevel / 10) * 10;
				}
				curUpgradeSymbols = [];
				for each(var obj:Object in StoveConstant.upgradeSymbols){
					if(obj.level != equipLevel){
						curUpgradeSymbols.push(obj);
					}
				}
				materialCombox.dataProvider = curUpgradeSymbols;
				materialCombox.validateNow();
			}
			setMaterial(null);
			setNextValue(null);
			updateMoney();
			checkSelect();
			matchMaterial();
			getUpgradeNext();
			updateAllTip();
		}
		/**
		 * 更新装备升级相关描述提示
		 */		
		private function updateAllTip():void{
			if(equipBox.data){
				if(GlobalObjectManager.getInstance().user.attr.level >= equipBox.data.level){
					equipTip.htmlText = HtmlUtil.font(String(equipBox.data.level)+"级", "#3BE450") + HtmlUtil.font(" 装备", "#3BE450");
				}else{
					equipTip.htmlText = HtmlUtil.font(String(equipBox.data.level)+"级", "#F53F3C") + HtmlUtil.font(" 装备", "#3BE450");
				}
			}else{
				equipTip.htmlText = "";
			}
			if(upgradeBox.data){
				if(GlobalObjectManager.getInstance().user.attr.level >= upgradeBox.data.level){
					upgradeTip.htmlText = HtmlUtil.font(String(upgradeBox.data.level)+"级", "#3BE450") + HtmlUtil.font(" 装备", "#3BE450");
				}else{
					upgradeTip.htmlText = HtmlUtil.font(String(upgradeBox.data.level)+"级", "#F53F3C") + HtmlUtil.font(" 装备", "#3BE450");
				}
			}else{
				upgradeTip.htmlText = "";
			}
			if(equipBox.data && upgradeBox.data){
				var curComboxObj:Object = this.curUpgradeSymbols[materialCombox.selectedIndex];
				if(materialBox.data){
					middleDesc.htmlText=HtmlUtil.font(curComboxObj.name, "#3BE450");
				}else{
					middleDesc.htmlText=HtmlUtil.font("请放入 " + curComboxObj.name, "#F53F3C");
				}
			}else{
				middleDesc.htmlText="请放入装备符";
			}
		}
		private function setNextValue(data:*):void{
			upgradeBox.data = data;
			updateMoney();
			updateAllTip();
		}
		
		private function checkSelect():void{
			if(equipBox.data){
				rightTopList.checkSelet(equipBox.data.oid);
			}else{
				rightTopList.checkSelet(-1);
			}
			if(materialBox.data){
				rightBottomList.checkSelect([materialBox.data.typeId],[materialBox.data.bind]);
			}else{
				rightBottomList.checkSelect([],[]);
			}
		}
		
		private function updateMoney():void{
			if(equipBox.data && upgradeBox.data){
				var money:int = StoveCostManager.equipUpgradeCost(EquipVO(upgradeBox.data));
				//计算升级费用
				var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
				if( deMoney < 0 ){
					moneyDesc.htmlText=HtmlUtil.font("升级费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
					moneyErrorTF.htmlText = HtmlUtil.font("费用不足，缺"+DealConstant.silverToOtherString(-deMoney),"#ff0000");
				}else{
					moneyDesc.htmlText=HtmlUtil.font("升级费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#3BE450");
					moneyErrorTF.htmlText = "";
				}
			}else{
				moneyDesc.htmlText=HtmlUtil.font("升级费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
				moneyErrorTF.htmlText = "";
			}
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
			if(vo.sub_op_type == StoveConstant.SUB_UPGRADE_NEXT){//查询
				if(vo.succ){
					var next:BaseItemVO = ItemLocator.getInstance().getObject(vo.new_list[0].typeid);
					next.copy(vo.new_list[0])
					setNextValue(next);
				}else{
					setNextValue(null);
					errorTip(vo.reason);
				}
				upgradeBox.stopEffect();
			}else{
				if(vo.succ){
					setValue(StoveEquipFilter.findTarget(vo.firing_list,vo.update_list));
					equipBox.playCompleteEffec();
				}
				errorTip(vo.reason);
			}
			materialBox.stopEffect();
			equipBox.stopEffect();
			upgradeBox.stopEffect();
			update();
		}
		
		public function update():void{
			rightTopList.update();
			shengjifuShop.update(StoveMaterialFilter.upgrade());
			checkSelect();
		}
		
		public function startEffect():void{
			equipBox.playEffect();
			materialBox.playEffect();
		}
		
		public function reset():void{
			setValue(null);
			setMaterial(null);
			update();
		}
		
		private function errorTip(str:String):void{
			Tips.getInstance().addTipsMsg(str);
			//BroadcastSelf.logger(str);
		}
		
		private function getUpgradeNext():void{
			var e:ParamEvent = new ParamEvent(StoveConstant.UPGRADE_NEXT,null,true);
			if(equipBox.data == null){
				return;
			}
			var material:GeneralVO = new GeneralVO();
			material.typeId = this.curUpgradeSymbols[materialCombox.selectedIndex].id;
			e.data = {equip:equipBox.data,material:material};
			dispatchEvent(e);
			upgradeBox.playEffect();
		}
		
		private function doUpgrade():void{
			var e:ParamEvent = new ParamEvent(StoveConstant.UPGRADE_BTN_CLICK,null,true);
			if(equipBox.data == null || materialBox.data == null){
				return;
			}
			e.data = {equip:equipBox.data,material:materialBox.data};
			dispatchEvent(e);
			startEffect();
		}
	}
}