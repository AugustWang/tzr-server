package modules.finery.views.punch {
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
	
	import proto.line.m_refining_firing_toc;

	public class PunchView extends UIComponent {
		public static const　NAME:String = "PunchView";
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var equipBox:EquipBox;
		private var materialBox:MaterialBox;
		private var punchBtn:Button;
		private var rightTopList:RightTopList;
		private var kaikongfuShop:MaterialShopList;
		private var rightBottomList:RightBottomList;
		private var moneyErrorTF:TextField;
		private var successRateText:TextField;

		public function PunchView() {
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
			middleDesc=ComponentUtil.createTextField("请放入开孔锥", 0, 165, middleDescFormat, 298, 26, bg);
			middleDesc.filters=Style.textBlackFilter;
			middleDesc.x=(bg.width - middleDesc.width) * 0.5;
			
			successRateText=ComponentUtil.createTextField("", 0, middleDesc.y + 20, middleDescFormat,
				298, 20, bg);
			successRateText.textColor = 0x00ff00;
			successRateText.filters=Style.textBlackFilter;

			materialBox=new MaterialBox("锥");
			materialBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBox);
			materialBox.x=(bg.width - materialBox.width) * 0.5;
			materialBox.y=successRateText.y + successRateText.height;

			moneyDesc=ComponentUtil.createTextField("", 5, materialBox.y + materialBox.height -10, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("开孔费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 5, moneyDesc.y + 18, null,
				140, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
						
			punchBtn=ComponentUtil.createButton("开孔", bg.width - 120, moneyDesc.y - 2, 100, 25, bg);
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
			punchDesc.htmlText=HtmlUtil.font("开孔说明\n", "#CCE741") + HtmlUtil.font("从右侧列表中选择装备，点击开孔给装备开孔，每开一个孔需要【开孔锥】×1，开孔锥可以快速购买。",
				"#ffffff");
			punchDesc.filters=Style.textBlackFilter;
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			rightBottomList = new RightBottomList();
			kaikongfuShop = new MaterialShopList();
			kaikongfuShop.initUI(StoveMaterialFilter.punch());
			var arr:Array = [{name:"开孔锥",reference:kaikongfuShop}];
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
		}
		
		private function setValue(data:*):void{
			equipBox.data = data;
			changeOperateTip();
            updateMoney(equipBox.data);
			checkSelect();
			matchMaterial();
			var equipVO:EquipVO = data as EquipVO;
			if(equipVO && equipVO.punch_num < 6){
				var rateString:String = HtmlUtil.font(StoveConstant.punchRate[equipVO.punch_num],"#00ff00");
				successRateText.htmlText = "开孔成功率："+rateString;
			}else{
				successRateText.htmlText = ""
			}
		}
		
		/**
		 * 配置属性加强材料
		 */		
		private function matchMaterial():void{
			if(equipBox.data){
				var typeID:int = 0;
				if(equipBox.data.punch_num < 2){
					typeID=10600001;
				}else if(equipBox.data.punch_num < 4){
					typeID=10600002;
				}else if(equipBox.data.punch_num < 6){
					typeID=10600003;
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
			if(materialBox.data){
				rightBottomList.checkSelect([materialBox.data.typeId],[materialBox.data.bind]);
			}else{
				rightBottomList.checkSelect([],[]);
			}
		}
		
		private function updateMoney(data:*):void{
			if(data){
                var equip:EquipVO = EquipVO(data);
                if(equip.punch_num >= StoveConstant.MAX_PUNCH_NUMBER){
                    moneyDesc.htmlText=HtmlUtil.font("开孔费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
                }else{
					var money:int = StoveCostManager.openHoleCost(data);
                    moneyDesc.htmlText=HtmlUtil.font("开孔费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
					var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
					if( deMoney < 0 ){
						moneyErrorTF.htmlText = HtmlUtil.font("费用不足，缺"+DealConstant.silverToOtherString(-deMoney),"#ff0000");
					}else{
						moneyErrorTF.htmlText = "";
					}
                }
			}else{
				moneyDesc.htmlText=HtmlUtil.font("开孔费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
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
			kaikongfuShop.update(StoveMaterialFilter.punch());
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
		
		private var punchMeterialLevel:Object = {10600001:2,10600002:4,10600003:6};
		private function onMouseClickHandler(event:MouseEvent):void {
			if(equipBox.data==null){
				errorTip("请放入需要开孔的装备");
				return;
			}
			var equip:EquipVO =EquipVO(equipBox.data);
			if(equip.punch_num >= StoveConstant.MAX_PUNCH_NUMBER){
				errorTip("当前装备已经开满了" + StoveConstant.MAX_PUNCH_NUMBER.toString() + "孔");
				return ;
			}
			var curPunchLevel:int = 2;
			if(equip.punch_num < 2){
				curPunchLevel = 2;
			}else if(equip.punch_num >= 2 && equip.punch_num < 4){
				curPunchLevel = 4;
			}else if(equip.punch_num >= 4){
				curPunchLevel = 6;
			}else{
				curPunchLevel = 2;
			}
			if(materialBox.data == null){
				errorTip("请放入开孔锥");
				return;
			}
			var material:GeneralVO = GeneralVO(materialBox.data);
			var materialLevel:int = punchMeterialLevel[material.typeId];
			if(materialLevel < curPunchLevel){
				if(curPunchLevel == 2){
					errorTip("请放入【顽石锥】,【玄铁锥】或【金刚锥】");
				}else if(curPunchLevel == 4){
					errorTip("请放入【玄铁锥】或【金刚锥】");
				}else if(curPunchLevel == 6){
					errorTip("请放入【金刚锥】");
				}else{
					errorTip("请放入更高等级的开孔锥");
				}
				return;
			}
			if(moneyErrorTF.htmlText != ""){
				errorTip("操作失败，费用不足");
				return;
			}
			//是否需要弹窗提示完成装备操作之后变绑定
			if(equip.bind == false && material.bind == true){
				Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","警告",doPunch,null,"确认","取消",[],true,true);
			}else{
				doPunch();
			}
		}
		/**
		 * 改变操作提示
		 */		
		private function changeOperateTip():void{
			var equip:EquipVO =EquipVO(equipBox.data);
			var material:GeneralVO = GeneralVO(materialBox.data);
			if(equip){
				if(equip.punch_num >= StoveConstant.MAX_PUNCH_NUMBER){
					middleDesc.htmlText = "当前装备已经开满了" + StoveConstant.MAX_PUNCH_NUMBER.toString() + "孔";
					return ;
				}
				var curPunchLevel:int = 2;
				if(equip.punch_num < 2){
					curPunchLevel = 2;
				}else if(equip.punch_num >= 2 && equip.punch_num < 4){
					curPunchLevel = 4;
				}else if(equip.punch_num >= 4){
					curPunchLevel = 6;
				}else{
					curPunchLevel = 2;
				}
				var materialLevel:int = 0
				if(material){
					materialLevel = punchMeterialLevel[material.typeId];
				}
				if(materialLevel < curPunchLevel){
					if(curPunchLevel == 2){
						middleDesc.htmlText = "请放入【顽石锥】,【玄铁锥】或【金刚锥】";
					}else if(curPunchLevel == 4){
						middleDesc.htmlText = "请放入【玄铁锥】或【金刚锥】";
					}else if(curPunchLevel == 6){
						middleDesc.htmlText = "请放入【金刚锥】";
					}else{
						middleDesc.htmlText = "";
					}
				}else{
					middleDesc.htmlText = "";
				}	
			}else if(material == null){
				middleDesc.htmlText = "请放入开孔锥";
			}
		}
		
		private function doPunch():void{
			var e:ParamEvent = new ParamEvent(StoveConstant.PUNCH_BTN_CLICK,null,true);
			e.data = {equip:equipBox.data,material:materialBox.data};
			dispatchEvent(e);
		}
	}
}