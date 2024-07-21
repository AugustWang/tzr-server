package modules.finery.views.exalt {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.HeaderBar;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
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
	
	import proto.common.p_equip_bind_attr;
	import proto.line.m_refining_firing_toc;
	
	public class ExaltView extends UIComponent {
		public static const　NAME:String = "ExaltView";
		private static const XLZ_ID:int = 23100001;
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var equipBox:EquipBox;
		private var stoneBox:MaterialBox;
		private var materialBox:MaterialBox;
		private var fujiacailiaoShop:MaterialShopList;
		private var rightTopList:RightTopList;
		private var rightBottomList:RightBottomList;
		private var moneyErrorTF:TextField;
		private var attrInfo:TextField;
		private var upAttrInfo:TextField;
		private var needCountText:TextField;
		private var upgradeBtn:Button;
		
		private var needMaterialCounts:Array = [1,1,5,25,1,5,25];
		private var strengthMeterialLevel:Object = {10410006:1,10410007:2};
		private var zhMeterialLevel:Object = ["初级","初级","高级"];
		private var materialTypeIds:Array = [10410006,10410006,10410007];
		private var selectedMaterals:Array;
		private var needMaterialTypeId:int;
		private var needMaterialCount:int;
		
		public function ExaltView() {
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
			equipBox.y=equipDesc.y + equipDesc.height + 5;
			bg.addChild(equipBox);
			
			var headerBar:HeaderBar = new HeaderBar();
			headerBar.width = 210;
			headerBar.height = 20;
			headerBar.y = equipBox.y+equipBox.height+10;
			headerBar.x = bg.width - headerBar.width >> 1;
			headerBar.addColumn("附加属性",90);
			headerBar.addColumn("可提升至（最大值）",120);
			bg.addChild(headerBar);
			
			var attrBg:UIComponent = new UIComponent();
			attrBg.width = 276;
			attrBg.height = 120;
			attrBg.bgSkin = Style.getSkin("proBg",GameConfig.STOVE_UI,new Rectangle(10,10,120,104));
			bg.addChild(attrBg);
			attrBg.x = bg.width - attrBg.width >> 1;
			attrBg.y=headerBar.y+headerBar.height+1;
			
			var attrInfoFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, false, null, null, null, null, TextFormatAlign.
				LEFT);
			attrInfoFormat.leading = 3;
			attrInfo = new TextField();
			attrInfo.defaultTextFormat =attrInfoFormat;
			attrInfo.filters = Style.textBlackFilter;
			attrInfo.x = 17;
			attrInfo.y = 5;
			attrInfo.width = 236;
			attrInfo.height = 110;
			attrInfo.wordWrap=true;
			attrInfo.multiline=true;
			attrInfo.addEventListener(TextEvent.LINK,linkHandler);
			attrBg.addChild(attrInfo);
			
			upAttrInfo = new TextField();
			upAttrInfo.defaultTextFormat =attrInfoFormat;
			upAttrInfo.filters = Style.textBlackFilter;
			upAttrInfo.x = 170;
			upAttrInfo.y = 5;
			upAttrInfo.width = 80;
			upAttrInfo.height = 110;
			upAttrInfo.wordWrap=true;
			upAttrInfo.multiline=true;
			upAttrInfo.selectable = false;
			attrBg.addChild(upAttrInfo); 
			
			
			materialBox=new MaterialBox("材料",true,false);
			materialBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBox);
			materialBox.x=15;
			materialBox.y=290;
			
			needCountText = ComponentUtil.createTextField("X 1", materialBox.x+materialBox.width, materialBox.y + 7, null,150, 26, bg);
			needCountText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			moneyDesc=ComponentUtil.createTextField("", 15, materialBox.y + materialBox.height+5, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("绑定费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 20, moneyDesc.y + 18, null,
				140, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
			
			var tipFormat:TextFormat=new TextFormat("Tahoma", 12, 0xd5f2f8, true, null, null, null, null, TextFormatAlign.
				CENTER);
		
			upgradeBtn=ComponentUtil.createButton("提升绑定属性", bg.width - 120, materialBox.y,100, 25, bg);
			upgradeBtn.addEventListener(MouseEvent.CLICK, onUpgradeBtnClick);
			
			checkBtnState();
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			rightBottomList = new RightBottomList();
			fujiacailiaoShop = new MaterialShopList();
			fujiacailiaoShop.initUI(StoveMaterialFilter.bindMaterial());
			fujiacailiaoShop.addEventListener("MATERIAL_ITEM_CLICK",onFujiacailiaoShopItemClick);
			var arr:Array = [{name:"精血石",reference:fujiacailiaoShop}];
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
		
		private function onFujiacailiaoShopItemClick(event:ParamEvent):void{
			event.stopPropagation();
			var itemVO:BaseItemVO = event.data as BaseItemVO;
			if(itemVO){
				if(hasselectMaterial(itemVO.typeId,itemVO.bind))return;
				if(needMaterialTypeId != itemVO.typeId){
					selectedMaterals = null;
					addselectMaterials(itemVO.typeId,itemVO.bind);
					setMaterial(itemVO);
				}else{
					var boxMaterialVO:BaseItemVO = materialBox.data as BaseItemVO;
					if(boxMaterialVO && boxMaterialVO.typeId == needMaterialTypeId){
						if(boxMaterialVO.num < needMaterialCount){
							var goodsCount:int = PackManager.getInstance().getBindGoodsNunByTypeId(itemVO.typeId,itemVO.bind);
							boxMaterialVO.num += goodsCount;
							materialBox.updateCount(boxMaterialVO.num);
							addselectMaterials(itemVO.typeId,itemVO.bind);
							checkSelect();
						}else{
							selectedMaterals = null;
							goodsCount = PackManager.getInstance().getBindGoodsNunByTypeId(itemVO.typeId,itemVO.bind);
							boxMaterialVO.num = goodsCount;
							materialBox.updateCount(boxMaterialVO.num);
							addselectMaterials(itemVO.typeId,itemVO.bind);
							checkSelect();
						}
					}else{
						selectedMaterals = null;
						var materialItemVO:BaseItemVO = ItemLocator.getInstance().getObject(itemVO.typeId);
						materialItemVO.bind = itemVO.bind;
						materialItemVO.num = PackManager.getInstance().getBindGoodsNunByTypeId(itemVO.typeId,itemVO.bind);
						addselectMaterials(itemVO.typeId,itemVO.bind);
						setMaterial(materialItemVO);
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
			selectedMaterals = null;
			setMaterial(null);
		}
		
		private function setMaterial(data:*):void{
			materialBox.data = data;
			updateMoney();
			checkSelect();
		}
		
		/**
		 * 放置血灵珠
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
		private function matchMaterial():void{
			if(equipBox.data){
				var equipVO:EquipVO = equipBox.data as EquipVO;
				var exaltLevel:int = getExaltLevel();
				if(exaltLevel == 6){
					errorTip("该装备已经提升到了最高等级。");
					return;
				}
				needMaterialCount = needMaterialCounts[exaltLevel];
				needMaterialTypeId = materialTypeIds[Math.ceil(exaltLevel/3)];
				var num:int = PackManager.getInstance().getGoodsNumByTypeId(needMaterialTypeId);
				var color:String = "#ffff00";
				if(num < needMaterialCount){
					color = "#ff0000";
				}
				if(exaltLevel <= 3){
					needCountText.htmlText = HtmlUtil.font("初级精血石 X "+needMaterialCount,color);
				}else{
					needCountText.htmlText = HtmlUtil.font("高级精血石 X "+needMaterialCount,color);
				}
				updateMatchMaterial();
			}else{
				needCountText.text = "";
			}
		}
		
		private function updateMatchMaterial():void{
			if(equipBox.data){
				selectedMaterals = null;
				var bindCount:int = PackManager.getInstance().getBindGoodsNunByTypeId(needMaterialTypeId,true);
				if(bindCount > 0){
					addselectMaterials(needMaterialTypeId,true);
				}
				if(bindCount < needMaterialCount){
					var unBindCount:int = PackManager.getInstance().getBindGoodsNunByTypeId(needMaterialTypeId,false);
					if(unBindCount > 0){
						addselectMaterials(needMaterialTypeId,false);
					}
				}
				if(bindCount + unBindCount > 0){
					var materialItemVO:BaseItemVO = ItemLocator.getInstance().getObject(needMaterialTypeId);
					if(bindCount+unBindCount >= needMaterialCount){
						materialItemVO.num = needMaterialCount;
					}else if(bindCount+unBindCount < needMaterialCount){
						materialItemVO.num =  bindCount + unBindCount;
					}
					if(bindCount > 0){
						materialItemVO.bind = true;
					}
					setMaterial(materialItemVO);
				}
			}
		}
		
		private function addselectMaterials(typeId:int,bind:Boolean):void{
			if(selectedMaterals == null){
				selectedMaterals = [];
			}	
			if(!hasselectMaterial(typeId,bind)){
				selectedMaterals.push({typeId:typeId,bind:bind});
			}
		}
		
		private function hasselectMaterial(typeId:int,bind:Boolean):Boolean{
			var flag:Boolean = false;
			for each(var obj:Object in selectedMaterals){
				if(obj.typeId == typeId && obj.bind == bind){
					flag = true;
				}
			}
			return flag;
		}
		
		private function setValue(data:*):void{
			equipBox.data = data;
			updateMoney();
			matchMaterial();
			checkSelect();
			checkBtnState();
		}
		
		private function checkBtnState():void{
			createAttrInfo(equipBox.data && equipBox.data.bind);
			equipIsBind(equipBox.data && equipBox.data.bind);
		}
		
		private function equipIsBind(value:Boolean):void{
			if(!value && equipBox.data){
				attrInfo.htmlText = "此装备还未"+HtmlUtil.link(HtmlUtil.font("绑定","#00ff00"),"goBind",true)+"，需要绑定后才能提升属性";		
			}
		}
		
		private function getExaltLevel():int{
			var equipVO:EquipVO = equipBox.data as EquipVO;
			var level:int = 1;
			if(equipVO){
				var levels:Array = [];
				var attrs:Array = equipVO.bind_arr;
				var l:int = attrs.length;
				var attrItem:p_equip_bind_attr;
				for(var i:int = 0; i < l; i++){
					attrItem = attrs[i] as p_equip_bind_attr;
					levels.push(attrItem.attr_level);
				}
				levels.sort(Array.NUMERIC);
				if(levels.length > 0){
					level = levels[0];
				}
			}
			return level;
		}
		/**
		 *%% 1、主属性,2、力量,3、敏捷,4、智力,5、精神,6、体质,7、最大生命值,8、最大内力值,9、生命恢复速度,10、内力恢复速度,11、攻击速度,12、移动速度,
		 加成类型,1:绝对值，2：百分比,级加，加成值 
		 * @param value
		 * 
		 */		
		private var attrName:Array = ["","主属性","力量","敏捷","智力","精神","体质","最大生命值","最大内力值","生命恢复速度","内力恢复速度","攻击速度","移动速度"];
		private var attrProName:Array = ["","","power","agile","brain","spirit","vitality","blood","magic","blood_resume_speed","magic_resume_speed","attack_speed","move_speed"];
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
				var equipVO:EquipVO = equipBox.data as EquipVO;
				var endValue:String = "";
				for(var i:int = 0; i < l; i++){
					attrItem = attrs[i] as p_equip_bind_attr;
					if(equipVO.add_property.hasOwnProperty(attrProName[attrItem.attr_code]) && attrItem.attr_level <= 7){
						if(attrItem.attr_level < 7){
							endValue += StoveConstant.ADD_PROPERTIES[attrItem.attr_code][attrItem.attr_level];
						}else{
							endValue += equipVO.add_property[attrProName[attrItem.attr_code]];
						}
						endValue += HtmlUtil.font(" ("+StoveConstant.ADD_PROPERTIES[attrItem.attr_code][6]+")","#00ff00");
					}
					endValue += "\n";
					s+=HtmlUtil.font(attrName[attrItem.attr_code],"#ffffff") + HtmlUtil.font(" +" + attrItem.value + (attrItem.type == 1 ? "\n":"%\n"),"#ffff00");
				}
				attrInfo.htmlText = s;
				upAttrInfo.htmlText = endValue;
			}else{
				attrInfo.htmlText = "";
				upAttrInfo.htmlText = "";
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
			var equipVO:EquipVO = equipBox.data as EquipVO;
			var endValue:String = "";
			for(var i:int = 0; i < l; i++){
				attrItem = newValue[i] as p_equip_bind_attr;
				oldAttrItem = oldValue[i] as p_equip_bind_attr;
				attrItem.value > oldAttrItem.value ? color = "#00FF00" : color = "#0092FE";
				if(equipVO.add_property.hasOwnProperty(attrProName[attrItem.attr_code]) && attrItem.attr_level <= 7){
					if(attrItem.attr_level < 7){
						endValue += StoveConstant.ADD_PROPERTIES[attrItem.attr_code][attrItem.attr_level];
					}else{
						endValue += equipVO.add_property[attrProName[attrItem.attr_code]];
					}
					endValue += HtmlUtil.font(" ("+StoveConstant.ADD_PROPERTIES[attrItem.attr_code][6]+")","#00ff00");
				}
				endValue += "\n";
				s+=HtmlUtil.font(attrName[attrItem.attr_code] + " +" + attrItem.value + (attrItem.type == 1 ? "":"%"),color)+"\n";
			}
			upAttrInfo.htmlText = endValue;
			attrInfo.htmlText = s;
		}
		
		private function checkSelect():void{
			if(equipBox.data){
				rightTopList.checkSelet(equipBox.data.oid);
			}else{
				rightTopList.checkSelet(-1);
			}
			if(materialBox.data){
				var ids:Array = [];
				var binds:Array = [];
				for each(var obj:Object in selectedMaterals){
					ids.push(obj.typeId);
					binds.push(obj.bind);
				}
				rightBottomList.checkSelect(ids,binds);
			}else{
				rightBottomList.checkSelect([],[]);
			}
		}
		
		private function updateMoney():void{
			if(equipBox.data && materialBox.data){
				var exaltLevel:int = getExaltLevel();
				var money:int = StoveCostManager.eqiupBindCost(EquipVO(equipBox.data),false,exaltLevel)
				moneyDesc.htmlText=HtmlUtil.font("绑定费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
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
				if(vo.op_type == StoveConstant.OP_TYPE_BIND_UP && vo.sub_op_type == StoveConstant.SUB_BIND_UP){
					Tips.getInstance().addTipsMsg(vo.reason);
					//BroadcastSelf.logger(vo.reason);
					createAttrUpInfo(oldAttrs,newAttrs);
					matchMaterial();
				}else{
					Tips.getInstance().addTipsMsg("装备绑定成功！");
					//BroadcastSelf.logger("装备绑定成功！");
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
				//BroadcastSelf.logger(vo.reason);
			}
			equipBox.playCompleteEffec();
			equipBox.stopEffect();
			materialBox.stopEffect();
		}
		
		public function update():void{
			rightTopList.update();
			fujiacailiaoShop.update(StoveMaterialFilter.bindMaterial());
			matchMaterial();
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

		private function linkHandler(event:TextEvent):void{
			Dispatch.dispatch(ModuleCommand.OPEN_EQUIP_BIND);	
		}
		
		private function onUpgradeBtnClick(event:MouseEvent):void{
			if(equipBox.data==null){
				errorTip("请放入需要绑定的装备");
				return;
			}
			var exaltLevel:int = getExaltLevel();
			if(exaltLevel == 6){
				errorTip("该装备已经提升到了最高等级。");
				return;
			}
			if(materialBox.data==null){
				errorTip("请放入精血石");
				return;
			}
			var level:int = getExaltLevel();
			var material:GeneralVO = GeneralVO(materialBox.data);
			var materialLevel:int = strengthMeterialLevel[material.typeId];
			var needMaterialLv:int = Math.ceil(level/3);
			needMaterialLv = Math.min(needMaterialLv,2);
			if(materialLevel != needMaterialLv){
				errorTip("请放入【"+zhMeterialLevel[needMaterialLv]+"级强化石】");
				return;
			}
			if(needMaterialCount > material.num){
				errorTip("强化石数量不足！");
				return;
			}
			if(moneyErrorTF.htmlText != ""){
				errorTip("操作失败，费用不足");
				return;
			}
			doBind();
		}
		
		private function doBind():void{
			var count:int = 0;
			var materials:Array = [];
			for each(var obj:Object in selectedMaterals){
				var goodsList:Array = PackManager.getInstance().getGoodsByTypeAndBind(obj.typeId,obj.bind);
				for each(var goods:BaseItemVO in goodsList){
					if(count+goods.num >= needMaterialCount){
						materials.push({data:goods,num:needMaterialCount-count});
						break;
					}else{
						materials.push({data:goods,num:goods.num});
					}
					count+=goods.num;
				}
			}
			var e:ParamEvent = new ParamEvent(StoveConstant.BIND_BTN_CLICK,null,true);
			e.data = {equip:equipBox.data,materials:materials,type:3};
			dispatchEvent(e);
		}
	}
}