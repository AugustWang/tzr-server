package modules.finery.views.strength {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
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
	import modules.finery.views.item.StarItem;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	
	import proto.line.m_refining_firing_toc;
	
	public class StrengthView extends UIComponent {
		public static const　NAME:String = "StrengthView";
		
		private var bg:UIComponent;
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var equipBox:EquipBox;
		private var materialBox:MaterialBox;
		private var needCountText:TextField;
		private var starItem:StarItem;
		private var punchBtn:Button;
		private var rightTopList:RightTopList;
		private var strengthShop:MaterialShopList;
		private var rightBottomList:RightBottomList;
		private var moneyErrorTF:TextField;
		private var addProRateText:TextInput;
		
		private var needMaterialCounts:Array = [1,1,5,25,1,5,25];
		private var strengthMeterialLevel:Object = {10401001:1,10401002:2};
		private var zhMeterialLevel:Object = ["初级","初级","高级"];
		private var materialTypeIds:Array = [10401001,10401001,10401002];
		private var selectedMaterals:Array;
		private var needMaterialTypeId:int;
		private var needMaterialCount:int;
		
		public function StrengthView() {
			super();
		}
		
		private var hasInit:Boolean = false;
		public function initUI():void {
			if(hasInit){
				return;
			}
			this.x = 2;
			this.y = 6;
			bg = ComponentUtil.createUIComponent(0,0,308,304);
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
			equipDesc.textColor = 0xffff00;
			equipDesc.filters=Style.textBlackFilter;
			equipDesc.x=(bg.width - equipDesc.width) * 0.5;
			
			equipBox=new EquipBox("装备",false);
			equipBox.addEventListener("EQUIP_BOX_CLICK",onEquipBoxClick);
			equipBox.x=(bg.width - equipBox.bg.width) * 0.5;
			equipBox.y=equipDesc.y + equipDesc.height + 5;
			bg.addChild(equipBox);
			
			starItem=new StarItem();
			starItem.x=(bg.width - starItem.width) * 0.5;
			starItem.y=equipBox.y + equipBox.bg.height;
			addChild(starItem);
			
			var proName:TextField = ComponentUtil.createTextField("属性加成：",35,starItem.y+25,null,80,20,this);
			addProRateText = ComponentUtil.createTextInput(proName.x+proName.width,proName.y,80,25,this);
			addProRateText.enabled = false;
			
			var middleDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xCDE644, null, null, null, null, null, TextFormatAlign.
				CENTER);
			middleDesc=ComponentUtil.createTextField("请放入强化石", 0, 167, middleDescFormat, 298, 26, bg);
			middleDesc.filters=Style.textBlackFilter;
			middleDesc.x=(bg.width - middleDesc.width) * 0.5;
			
			materialBox=new MaterialBox("材料",true);
			materialBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBox);
			materialBox.x=(bg.width - materialBox.width) * 0.5;
			materialBox.y=middleDesc.y + middleDesc.height + 5;
			
			needCountText = ComponentUtil.createTextField("X 1", materialBox.x+materialBox.width, materialBox.y + 7, null,150, 26, bg);
			needCountText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			moneyDesc=ComponentUtil.createTextField("", 20, materialBox.y + materialBox.height + 7, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("强化费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 20, moneyDesc.y + 18, null,
				150, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
			
			punchBtn=ComponentUtil.createButton("强化", bg.width - 120, moneyDesc.y - 2, 100, 25, bg);
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
			punchDesc.htmlText=HtmlUtil.font("强化说明\n", "#CCE741") + HtmlUtil.font("使用对应等级的【强化石】进行装备强化，将获得属性加成，进行低级强化后才能进行下一级的强化。",
				"#ffffff");
			punchDesc.filters=Style.textBlackFilter;
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			rightBottomList = new RightBottomList();
			strengthShop = new MaterialShopList();
			strengthShop.initUI(StoveMaterialFilter.strengthMaterial());
			var arr:Array = [{name:"强化石",reference:strengthShop}];
			rightBottomList.initUI(arr);
			addChild(rightBottomList);
			rightBottomList.x = rightTopList.x;
			rightBottomList.y = 220;
			rightBottomList.addEventListener("MATERIAL_ITEM_CLICK",onMateralListItemClick);
			hasInit=true;
		}
		
		private function onMateralListItemClick(event:ParamEvent):void{
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
		
		private function matchMaterial():void{
			if(equipBox.data){
				var equipVO:EquipVO = equipBox.data as EquipVO;
				var starts:int=equipBox.data.reinforce_result % 10;
				var startsLvl:int=int(String(equipBox.data.reinforce_result).charAt(0));
				if(startsLvl == 6 && starts == 6){
					errorTip("该装备已经强化到最高等级。");
					needCountText.htmlText = "";
					return;
				}
				var needMaterialLv:int = Math.ceil(startsLvl/3);
				if(startsLvl == 3 && starts == 6){
					needMaterialLv++;
				}
				if(startsLvl < 6 && starts == 6){
					startsLvl++;
				}
				needMaterialCount = needMaterialCounts[startsLvl];
				needMaterialTypeId = materialTypeIds[needMaterialLv];
				var num:int = PackManager.getInstance().getGoodsNumByTypeId(needMaterialTypeId);
				var color:String = "#ffff00";
				if(num < needMaterialCount){
					color = "#ff0000";
				}
				if(startsLvl <= 3){
					needCountText.htmlText = HtmlUtil.font("初级强化石 X "+needMaterialCount,color);
				}else{
					needCountText.htmlText = HtmlUtil.font("高级强化石 X "+needMaterialCount,color);
				}
				addProRateText.text = " "+equipVO.reinforce_rate+"%";
				updateMatchMaterial();
			}else{
				needCountText.text = "";
				addProRateText.text = "";
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
			starItem.data = data;
			starItem.x = (bg.width - starItem.width)*0.5;
			updateMoney();
			matchMaterial();
			checkSelect();
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
				var starlevel:int = int(equipBox.data.reinforce_result.toString().substr(0,1));
				if(starlevel == 0){
					starlevel++;
				}
				var money:int = StoveCostManager.eqiupStrengthCost(EquipVO(equipBox.data),starlevel);
				moneyDesc.htmlText=HtmlUtil.font("强化费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
				var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
				if( deMoney < 0 ){
					moneyErrorTF.htmlText = HtmlUtil.font("费用不足，缺"+DealConstant.silverToOtherString(-deMoney),"#ff0000");
				}else{
					moneyErrorTF.htmlText = "";
				}
			}else{
				moneyDesc.htmlText=HtmlUtil.font("强化费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
				moneyErrorTF.htmlText = "";
			}
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
			if(vo.succ){
				setMaterial(null);
				setValue(StoveEquipFilter.findTarget(vo.firing_list,vo.update_list));
			}
			Tips.getInstance().addTipsMsg(vo.reason);
			//BroadcastSelf.logger(vo.reason);
			equipBox.playCompleteEffec();
			equipBox.stopEffect();
			materialBox.stopEffect();
			update();
		}
		
		public function update():void{
			rightTopList.update();
			strengthShop.update(StoveMaterialFilter.strengthMaterial());
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
		
		private function onMouseClickHandler(event:MouseEvent):void {
			if(equipBox.data==null){
				errorTip("请放入需要强化的装备");
				return;
			}
			var starts:int=equipBox.data.reinforce_result % 10;
			var startsLvl:int=int(String(equipBox.data.reinforce_result).charAt(0));
			if(starts == StoveConstant.MAX_REINFORCE_LEVEL && startsLvl == StoveConstant.MAX_REINFORCE_STAR){
				errorTip("装备已经强化至最高，不需要再强化");
				return;
			}
			var equip:EquipVO =EquipVO(equipBox.data);
			if(materialBox.data==null){
				errorTip("请放入强化石");
				return;
			}
			var material:GeneralVO = GeneralVO(materialBox.data);
			var materialLevel:int = strengthMeterialLevel[material.typeId];
			var needMaterialLv:int = Math.ceil(startsLvl/3);
			if(needMaterialLv == 0){
				needMaterialLv = 1;
			}
			if(startsLvl == 3 && starts == 6){
				needMaterialLv++;
			}
			if(startsLvl < 6 && starts == 6){
				startsLvl++;
			}
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
			if(equip.bind == false  && hasBindMaterial()){
				Alert.show("由于您使用的材料存在“绑定”的材料，本操作将会绑定该装备，是否继续？","警告",doStrength,null,"确认","取消",null,true,true);
			}else{
				doStrength();
			}
		}
		
		private function hasBindMaterial():Boolean{
			for each(var obj:Object in selectedMaterals){
				if(obj.bind){
					return true;
				}
			}
			return false;
		}
		
		private function doNextStrength():void {
			if(equipBox.data.bind == false  && materialBox.data.bind == true){
				Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","警告",doStrength,null,"确认","取消",[],true,true);
			}else{
				doStrength();
			}
		}
		
		private function doStrength():void{
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
			var e:ParamEvent = new ParamEvent(StoveConstant.STRENGTH_BTN_CLICK,null,true);
			e.data = {equip:equipBox.data,materials:materials};
			dispatchEvent(e);
		}
		
	}
}