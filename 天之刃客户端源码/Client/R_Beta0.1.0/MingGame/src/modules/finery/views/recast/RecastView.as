package modules.finery.views.recast{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
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
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	
	import proto.line.m_refining_firing_toc;
	
	public class RecastView extends UIComponent {
		public static const　NAME:String = "RecastView";
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var equipBox:EquipBox;
		private var materialBox:MaterialBox;
		private var recastBtn:Button;
		private var rightTopList:RightTopList;
		private var recastShop:MaterialShopList;
		private var rightBottomList:RightBottomList;
		private var moneyErrorTF:TextField;
		private var recastStepBar:ProgressBar;
		private var addProRateText:TextInput;
		
		public function RecastView() {
			
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
			
			equipBox=new EquipBox("装备",false);
			equipBox.addEventListener("EQUIP_BOX_CLICK",onEquipBoxClick);
			equipBox.x=(bg.width - equipBox.bg.width) * 0.5;
			equipBox.y=equipDesc.y + equipDesc.height + 5;
			bg.addChild(equipBox);
			
			var stepDesc:TextField = ComponentUtil.createTextField("重铸进度：",35,equipBox.y+equipBox.height+5,null,80,20,this);
			recastStepBar = ComponentUtil.createProcessBar(stepDesc.x+stepDesc.width,stepDesc.y+4,Style.getSkin("expBarBg", GameConfig.T1_UI,new Rectangle(4,4,141,4)),Style.getBitmap(GameConfig.T1_UI, "expBar"),140,12,this);
			
			stepDesc = ComponentUtil.createTextField("属性加成：",35,stepDesc.y+22,null,80,20,this);
			addProRateText = ComponentUtil.createTextInput(stepDesc.x+stepDesc.width,stepDesc.y,80,25,this);
			addProRateText.enabled = false;
			
			var middleDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xCDE644, null, null, null, null, null, TextFormatAlign.
				CENTER);
			middleDesc=ComponentUtil.createTextField("请放入重塑石", 0, 175, middleDescFormat, 298, 26, bg);
			middleDesc.filters=Style.textBlackFilter;
			middleDesc.x=(bg.width - middleDesc.width) * 0.5;
			
			materialBox=new MaterialBox("石");
			materialBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBox);
			materialBox.x=(bg.width - materialBox.width) * 0.5;
			materialBox.y=middleDesc.y + middleDesc.height;
			
			moneyDesc=ComponentUtil.createTextField("", 20, materialBox.y + materialBox.height + 5, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("重铸费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 20, moneyDesc.y + 20, null,
				140, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
			
			recastBtn=ComponentUtil.createButton("重铸", bg.width - 120, moneyDesc.y - 2, 100, 25, bg);
			recastBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			
			//说明的背景
			var recastDescbg:UIComponent=new UIComponent();
			addChild(recastDescbg);
			Style.setBorderSkin(recastDescbg);
			recastDescbg.width=bg.width;
			recastDescbg.height=79;
			recastDescbg.x=bg.x;
			recastDescbg.y=bg.y + bg.height + 2;
			
			var recastDescFormat:TextFormat = new TextFormat("Tahoma",12);
			recastDescFormat.leading = 5;
			var recastDesc:TextField=ComponentUtil.createTextField("", 5, 5, recastDescFormat, 295, 70, recastDescbg);
			recastDesc.wordWrap=true;
			recastDesc.multiline=true;
			recastDesc.htmlText=HtmlUtil.font("重铸说明\n", "#CCE741") + HtmlUtil.font("重铸需要重塑石，越高级的重塑石提升的效果越好。从右侧列表中选择装备，点击重铸给装备重铸。",
				"#ffffff");
			recastDesc.filters=Style.textBlackFilter;
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			rightBottomList = new RightBottomList();
			recastShop = new MaterialShopList();
			recastShop.initUI(StoveMaterialFilter.recastStones());
			var arr:Array = [{name:"重塑石",reference:recastShop}];
			rightBottomList.initUI(arr);
			addChild(rightBottomList);
			rightBottomList.x = rightTopList.x;
			rightBottomList.y = 220;
			rightBottomList.addEventListener("MATERIAL_ITEM_CLICK",onMateralListItemClick);
			hasInit=true;
		}
		
		private function onMateralListItemClick(event:ParamEvent):void{
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
			checkSelect();
			changeOperateTip();
			updateMoney();
		}
		
		private function setValue(data:*):void{
			equipBox.data = data;
			changeOperateTip();
			checkSelect();
//			matchMaterial();
			updateMoney();
			calculateStep(data);
		}
		
		/**
		 * 配置属性加强材料
		 */		
		private function matchMaterial():void{
			var equipVO:EquipVO = equipBox.data as EquipVO;
			if(equipVO){
				if(equipVO.quality == 5 && equipVO.sub_quality == 6){
					return;
				}
				var typeID:int = 0;
				var needLevelStone:int = getNeedMaterialLevel(equipVO);
				if(needLevelStone <= 6){
					var goods:BaseItemVO = PackManager.getInstance().getGoodsByTypeIds(recastTypeIds.slice(needLevelStone-1));
					if(goods){
						setMaterial(goods);
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
			if(materialBox.data){
				rightBottomList.checkSelect([materialBox.data.typeId],[materialBox.data.bind]);
			}else{
				rightBottomList.checkSelect([],[]);
			}
		}
		
		private function updateMoney():void{
			if(equipBox.data && materialBox.data){
				var equip:EquipVO = EquipVO(equipBox.data);
				var generalVO:GeneralVO = materialBox.data as GeneralVO;
				var money:int = StoveCostManager.equipRecastCost(equip,recastTypeIds.indexOf(generalVO.typeId)+1);
				moneyDesc.htmlText=HtmlUtil.font("重铸费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
				var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
				if( deMoney < 0 ){
					moneyErrorTF.htmlText = HtmlUtil.font("费用不足，缺"+DealConstant.silverToOtherString(-deMoney),"#ff0000");
				}else{
					moneyErrorTF.htmlText = "";
				}
			}else{
				moneyDesc.htmlText=HtmlUtil.font("重铸费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
				moneyErrorTF.htmlText = "";
			}
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
			if(vo.succ){
				setMaterial(null);
				setValue(StoveEquipFilter.findTarget(vo.firing_list,vo.update_list));
				update();
				Tips.getInstance().addTipsMsg(vo.reason);
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
			recastShop.update(StoveMaterialFilter.recastStones());
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
		
		private var chinese:Array = [null,"一","二","三","四","五","六"];
		private var recastTypeIds:Array = [10404001,10404002,10404003,10404004,10404005,10404006];
		private function onMouseClickHandler(event:MouseEvent):void {
			if(equipBox.data==null){
				errorTip("请放入需要重铸的装备");
				return;
			}
			var equip:EquipVO = EquipVO(equipBox.data);
			if(equip.quality == 5 && equip.sub_quality == 6){
				errorTip("当前装备的品质已经达到最高级别了");
				return;
			}
			if(materialBox.data == null){
				errorTip("请放入重铸石");
				return;
			}
			var material:GeneralVO = GeneralVO(materialBox.data);
			var materialLevel:int = material.color;
			var needLevelStone:int = getNeedMaterialLevel(equip);
			if(needLevelStone <= 5 && materialLevel != needLevelStone){
				errorTip("请放入"+chinese[needLevelStone]+"品重塑石");
				return;
			}
			if(moneyErrorTF.htmlText != ""){
				errorTip("操作失败，费用不足");
				return;
			}
			//是否需要弹窗提示完成装备操作之后变绑定
			if(equip.bind == false && material.bind == true){
				Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","警告",doRecast,null,"确认","取消",[],true,true);
			}else{
				doRecast();
			}
		}
		/**
		 * 改变操作提示
		 */		
		private function changeOperateTip():void{
			var equip:EquipVO =EquipVO(equipBox.data);
			var material:GeneralVO = GeneralVO(materialBox.data);
			if(equip){
				if(equip.quality == 5 && equip.sub_quality == 6){
					middleDesc.htmlText = "当前装备的品质已经达到最高级别了";
					return;
				}
				var materialLevel:int = 0;
				if(material){
					materialLevel = material.color;
				}
				var needLevelStone:int = getNeedMaterialLevel(equip);
				if( materialLevel != needLevelStone){
					middleDesc.htmlText = "请放入"+chinese[needLevelStone]+"品重塑石";
					return;
				}else{
					middleDesc.htmlText = "";
				}	
			}else if(material == null){
				middleDesc.htmlText = "请放入重塑石";
			}
		}
		
		private function getNeedMaterialLevel(equip:EquipVO):int{
			var qualityValue:int = (equip.quality-1)*6+equip.sub_quality;
			var needLv:int = qualityValue%5 == 0 ? qualityValue/5+1 : Math.ceil(qualityValue/5); 
			return Math.min(needLv,6);
		}
		
		private function calculateStep(equip:EquipVO):void{
			if(equip){
				var qualityValue:int = 0;
				if(equip.quality_rate > 0){
					qualityValue = (equip.quality-1)*6+equip.sub_quality;
				}
				recastStepBar.value = qualityValue/30;
				addProRateText.text = equip.quality_rate+"%";
			}else{
				recastStepBar.value = 0;
				addProRateText.text = "";
			}
		}
		
		private function doRecast():void{
			var e:ParamEvent = new ParamEvent(StoveConstant.RECAST_BTN_CLICK,null,true);
			e.data = {equip:equipBox.data,material:materialBox.data};
			dispatchEvent(e);
		}
	}
}