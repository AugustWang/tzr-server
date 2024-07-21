package modules.finery.views.bind{
	import com.common.GlobalObjectManager;
	import com.components.HeaderBar;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.finery.FineryModule;
	import modules.finery.StoveConstant;
	import modules.finery.StoveCostManager;
	import modules.finery.StoveEquipFilter;
	import modules.finery.StoveMaterialFilter;
	import modules.finery.views.item.EquipBox;
	import modules.finery.views.item.MaterialBox;
	import modules.finery.views.item.MaterialShopList;
	import modules.finery.views.item.RightBottomList;
	import modules.finery.views.item.RightTopList;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_equip_bind_attr;
	import proto.line.m_refining_firing_toc;
	
	public class BindView extends UIComponent {
		public static const　NAME:String = "BindView";
		private static const XLZ_ID:int = 23100001;
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var equipBox:EquipBox;
		private var stoneBox:MaterialBox;
		private var materialBox:MaterialBox;
		
		private var rightTopList:RightTopList;
		private var xuelingShop:MaterialShopList;
		private var rightBottomList:RightBottomList;
		private var moneyErrorTF:TextField;
		private var attrInfo:TextField;
		
		private var bindBtn:Button;
		private var bindTip:TextField;
		
		public function BindView() {
			super();
		}
		
		private var hasInit:Boolean = false;
		public function initUI():void {
			if(hasInit){
				return;
			}
			this.x = 2;
			this.y = 6;
			var bg:UIComponent = ComponentUtil.createUIComponent(0,0,308,383);
			Style.setBorderSkin(bg);
			var stoveBg:Bitmap = Style.getBitmap(GameConfig.STOVE_UI,"stoveBg");
			stoveBg.x = bg.width - stoveBg.width >> 1;
			stoveBg.y = 20;
			addChild(bg);
			bg.addChild(stoveBg);
			bg.x=0;
			bg.y=3;
			
			var equipDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				CENTER);
			equipDesc=ComponentUtil.createTextField("请从右侧列表中选择装备", 78, 8, equipDescFormat, 200, 26, bg);
			equipDesc.textColor = 0xffff00;
			equipDesc.filters=Style.textBlackFilter;
			equipDesc.x=(bg.width - equipDesc.width) * 0.5;
			
			equipBox=new EquipBox("装备",false);
			equipBox.addEventListener("EQUIP_BOX_CLICK",onEquipBoxClick);
			equipBox.x=(bg.width - equipBox.bg.width) * 0.5;
			equipBox.y=equipDesc.y+23;
			bg.addChild(equipBox);
			
			var headerBar:HeaderBar = new HeaderBar();
			headerBar.width = 100;
			headerBar.height = 20;
			headerBar.y = equipBox.y;
			headerBar.addColumn("绑定属性",100);
			bg.addChild(headerBar);
				
			var attrBg:UIComponent = new UIComponent();
			attrBg.width = 142;
			attrBg.height = 128;
			attrBg.bgSkin = Style.getSkin("proBg",GameConfig.STOVE_UI,new Rectangle(10,10,120,104));
			bg.addChild(attrBg);
			attrBg.y=headerBar.y+headerBar.height;
			
			var attrInfoFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, false, null, null, null, null, TextFormatAlign.
				LEFT);
			attrInfoFormat.leading = 3;
			attrInfo = new TextField();
			attrInfo.defaultTextFormat =attrInfoFormat;
			attrInfo.filters = Style.textBlackFilter;
			attrInfo.x = 2;
			attrInfo.y = 10;
			attrInfo.width = 120;
			attrInfo.height = 110;
			attrInfo.wordWrap=true;
			attrInfo.multiline=true;
			attrBg.addChild(attrInfo);
			
			equipBox.x = (bg.width - equipBox.width - 130)*0.5;
			attrBg.x = equipBox.x + equipBox.width + 10;
			headerBar.x = attrBg.x+18;
			
			materialBox=new MaterialBox("材料",false,true);
			materialBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBox);
			materialBox.x=(bg.width - materialBox.width)*0.5+35;
			materialBox.y=190;
			
			moneyDesc=ComponentUtil.createTextField("", 20, materialBox.y + materialBox.height + 23, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("绑定费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 20, moneyDesc.y + 18, null,
				140, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
			
			var tipFormat:TextFormat=new TextFormat("Tahoma", 12, 0xd5f2f8, true, null, null, null, null, TextFormatAlign.
				CENTER);
			/*未绑定状态*/
			bindBtn=ComponentUtil.createButton("装备绑定", bg.width - 120, moneyDesc.y + 35, 100, 25, bg);
			bindTip=ComponentUtil.createTextField("需要月光石",bindBtn.x,bindBtn.y + 27,tipFormat,NaN,NaN,bg);
			bindTip.filters = Style.textBlackFilter;
			bindBtn.addEventListener(MouseEvent.CLICK, onBindBtnClick);
			
			bindBtn.x = (bg.width - bindBtn.width)*0.5;
			bindTip.x = (bg.width - bindTip.width)*0.5;
			
			checkBtnState();
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			rightBottomList = new RightBottomList();
			xuelingShop = new MaterialShopList();
			xuelingShop.initUI(StoveMaterialFilter.bindStone());
			xuelingShop.addEventListener("MATERIAL_ITEM_CLICK",onXuelingShopItemClick);
			
			var arr:Array = [{name:"月光石",reference:xuelingShop}];
			rightBottomList.initUI(arr);
			addChild(rightBottomList);
			rightBottomList.x = rightTopList.x;
			rightBottomList.y = 220;
			hasInit=true;
		}
		
		private function onXuelingShopItemClick(event:ParamEvent):void{
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
		
		private function onMaterialBoxClick(event:Event):void{
			setMaterial(null);
		}
		
		private function setMaterial(data:*):void{
			materialBox.data = data;
			updateMoney();
			checkSelect();
		}
		
		/**
		 * 放置月光石
		 */		
		private function setXLZ():void{
			var xlzs:Array = PackManager.getInstance().getGoodsByType(XLZ_ID);
			if(xlzs.length > 0){
				setMaterial(xlzs.shift());
			}
		}
		
		/**
		 * 配置属性加强材料
		 */		
		private function matchMaterial(value:Array):void{
			var typeID:int = StoveEquipFilter.findMaterial(value);
			if(typeID != 0){
				var goods:Array = PackManager.getInstance().getGoodsByType(typeID);
				if(goods.length > 0){
					setMaterial(goods[0]);
				}
			}
		}
		
		private function setValue(data:*):void{
			equipBox.data = data;
			if(data && !BaseItemVO(data).bind){
				setXLZ();
			}
			updateMoney();
			checkSelect();
			checkBtnState();
		}
		
		private function checkBtnState():void{
			equipIsBind(equipBox.data && equipBox.data.bind);
			createAttrInfo(equipBox.data && equipBox.data.bind);
		}
		
		private function equipIsBind(value:Boolean):void{
			bindBtn.label = value ? "修改绑定属性" : "装备绑定";
		}
		
		/**
		 *%% 1、主属性,2、力量,3、敏捷,4、智力,5、精神,6、体质,7、最大生命值,8、最大内力值,9、生命恢复速度,10、内力恢复速度,11、攻击速度,12、移动速度,
		 加成类型,1:绝对值，2：百分比,级加，加成值 
		 * @param value
		 * 
		 */		
		private var attrName:Array = ["","主属性","力量","敏捷","智力","精神","体质","最大生命值","最大内力值","生命恢复速度","内力恢复速度","攻击速度","移动速度"];
		private function sortByCode(a:p_equip_bind_attr,b:p_equip_bind_attr):Number{
			var aCode:int = a.attr_code;
			var bCode:int = b.attr_code;
			if(aCode < bCode){
				return -1;
			}
			if(aCode > bCode){
				return 1;
			}
			return 0;
		}
		
		private function createAttrInfo(value:Boolean):void{
			if(value){
				var s:String = "";
				var attrs:Array = equipBox.data.bind_arr;
				var l:int = attrs.length;
				var attrItem:p_equip_bind_attr;
				attrs.sort(sortByCode);
				for(var i:int = 0; i < l; i++){
					attrItem = attrs[i] as p_equip_bind_attr;
					s+=HtmlUtil.font(attrName[attrItem.attr_code] + " +" + attrItem.value + (attrItem.type == 1 ? "\n":"%\n"),"#0092FE");
				}
				attrInfo.htmlText = s;
			}else{
				attrInfo.htmlText = HtmlUtil.font("无绑定属性","#737373");
			}
		}
		
		private function createAttrUpInfo(oldValue:Array,newValue:Array):void{
			var s:String = "";
			oldValue.sort(sortByCode);
			newValue.sort(sortByCode);
			var l:int = newValue.length;
			var attrItem:p_equip_bind_attr;
			var oldAttrItem:p_equip_bind_attr;
			var color:String = "#0092FE";
			for(var i:int = 0; i < l; i++){
				attrItem = newValue[i] as p_equip_bind_attr;
				oldAttrItem = oldValue[i] as p_equip_bind_attr;
				attrItem.value > oldAttrItem.value ? color = "#00FF00" : color = "#0092FE";
				s+=HtmlUtil.font(attrName[attrItem.attr_code] + " +" + attrItem.value + (attrItem.type == 1 ? "\n":"%\n"),color);
			}
			attrInfo.htmlText = s;
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
			if(equipBox.data && materialBox.data){
				var money:int;
				if(!equipBox.data.bind && materialBox.data.typeId == 23100001){
					//middleDesc.htmlText = HtmlUtil.font("点击“绑定”按钮改变附加属性","#CDE644");
					money = StoveCostManager.eqiupBindCost(EquipVO(equipBox.data),true);
					moneyDesc.htmlText=HtmlUtil.font("绑定费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
				}
				if(equipBox.data.bind && materialBox.data.typeId == 23100001){
					//middleDesc.htmlText = HtmlUtil.font("点击“绑定”按钮改变附加属性","#CDE644");
					money = StoveCostManager.eqiupBindCost(EquipVO(equipBox.data),true,materialBox.data.color);
					moneyDesc.htmlText=HtmlUtil.font("绑定费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
				}
				if(equipBox.data.bind && materialBox.data.typeId != 23100001){
					//middleDesc.htmlText = HtmlUtil.font("点击“绑定”提升附加属性等级","#CDE644");
					money = StoveCostManager.eqiupBindCost(EquipVO(equipBox.data),false,materialBox.data.color)
					moneyDesc.htmlText=HtmlUtil.font("绑定费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
				}
				var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
				if( deMoney < 0 ){
					moneyErrorTF.htmlText = HtmlUtil.font("费用不足，缺"+DealConstant.silverToOtherString(-deMoney),"#ff0000");
				}else{
					moneyErrorTF.htmlText = "";
				}
			}else{
				moneyDesc.htmlText=HtmlUtil.font("绑定费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
				moneyErrorTF.htmlText = "";
			}
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
			if(vo.succ){
				var oldAttrs:Array;
				var newAttrs:Array;
				if(vo.op_type == StoveConstant.OP_TYPE_BIND_UP && equipBox.data){
					oldAttrs = equipBox.data.bind_arr;
				}
				var newEquip:EquipVO = StoveEquipFilter.findTarget(vo.firing_list,vo.update_list);
				if(newEquip){
					newAttrs = newEquip.bind_arr;
				}
				setValue(newEquip);
				setMaterial(null);
				update();
				if(vo.op_type == StoveConstant.OP_TYPE_BIND && vo.sub_op_type == StoveConstant.SUB_BIND_BIND){
					setXLZ();
					Tips.getInstance().addTipsMsg("装备绑定成功！");
					BroadcastSelf.logger("装备绑定成功！");
				}else if(vo.op_type == StoveConstant.OP_TYPE_BIND && vo.sub_op_type == StoveConstant.SUB_BIND_REBIND){
					setXLZ();
					Tips.getInstance().addTipsMsg("装备重新绑定成功！");
					BroadcastSelf.logger("装备重新绑定成功！");
				}else if(vo.op_type == StoveConstant.OP_TYPE_BIND_UP && vo.sub_op_type == StoveConstant.SUB_BIND_UP){
					Tips.getInstance().addTipsMsg(vo.reason);
					BroadcastSelf.logger(vo.reason);
					createAttrUpInfo(oldAttrs,newAttrs);
					matchMaterial(vo.firing_list);
				}else{
					Tips.getInstance().addTipsMsg("装备绑定成功！");
					BroadcastSelf.logger("装备绑定成功！");
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
			equipBox.playCompleteEffec();
			equipBox.stopEffect();
			materialBox.stopEffect();
		}
		
		public function update():void{
			rightTopList.update();
			xuelingShop.update(StoveMaterialFilter.bindStone());
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
			BroadcastSelf.logger(str);
		}
		
		private function onBindBtnClick(event:MouseEvent):void {
			if(equipBox.data==null){
				errorTip("请放入需要绑定的装备");
				return;
			}
			if(materialBox.data==null || (materialBox.data&&materialBox.data.typeId!=XLZ_ID)){
				errorTip("请放入月光石");
				return;
			}
			if(moneyErrorTF.htmlText != ""){
				errorTip("操作失败，费用不足");
				return;
			}
			doBind();
		}
		
		private function doBind():void{
			var e:ParamEvent = new ParamEvent(StoveConstant.BIND_BTN_CLICK,null,true);
			var type:int;
			if(equipBox.data == null || materialBox.data == null){
				return;
			}
			var equip:EquipVO = EquipVO(equipBox.data);
			if(!equip.bind && materialBox.data.typeId == 23100001){
				type = 1;
			}
			if(equip.bind && materialBox.data.typeId == 23100001){
				type = 2;
			}
			if(equip.bind && materialBox.data.typeId != 23100001){
				type = 3;
			}
			e.data = {equip:equipBox.data,material:materialBox.data,type:type};
			dispatchEvent(e);
		}
	}
}