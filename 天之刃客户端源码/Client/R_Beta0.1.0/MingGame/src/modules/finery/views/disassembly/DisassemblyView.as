package modules.finery.views.disassembly {
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
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_goods;
	import proto.line.m_refining_firing_toc;
	
	public class DisassemblyView extends UIComponent {
		public static const　NAME:String = "DisassemblyView";
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var equipBox:EquipBox;
		private var materialBoxA:MaterialBox;
		private var materialBoxB:MaterialBox;
		private var materialBoxC:MaterialBox;
		private var materialBoxD:MaterialBox;
		private var punchBtn:Button;
		private var materialBoxs:Array = [];
		private var rightTopList:RightTopList;
		private var chaixieShop:MaterialShopList;
		private var moneyErrorTF:TextField;
		
		public function DisassemblyView() {
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
			middleDesc=ComponentUtil.createTextField("请放入拆卸保护符", 0, 162, middleDescFormat, 298, 26, bg);
			middleDesc.htmlText =  HtmlUtil.font("拆卸成功率：","#CDE644") + HtmlUtil.font("40%", "#F53F3C") + HtmlUtil.font(" 放入拆卸保护符提高拆卸成功率","#CDE644");
			middleDesc.filters=Style.textBlackFilter;
			middleDesc.x=(bg.width - middleDesc.width) * 0.5;
			
			materialBoxA=new MaterialBox("符");
			materialBoxA.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBoxA);
			materialBoxA.x=bg.width*0.5 - materialBoxA.width*2 - 15;
			materialBoxA.y=middleDesc.y + middleDesc.height + 5;
			materialBoxB=new MaterialBox("符");
			materialBoxB.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBoxB);
			materialBoxB.x=bg.width*0.5 - materialBoxA.width - 5;
			materialBoxB.y=middleDesc.y + middleDesc.height + 5;
			materialBoxC=new MaterialBox("符");
			materialBoxC.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBoxC);
			materialBoxC.x=bg.width*0.5 + 5;
			materialBoxC.y=middleDesc.y + middleDesc.height + 5;
			materialBoxD=new MaterialBox("符");
			materialBoxD.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
			bg.addChild(materialBoxD);
			materialBoxD.x=bg.width*0.5 + materialBoxA.width + 15;
			materialBoxD.y=middleDesc.y + middleDesc.height + 5;
			materialBoxs = [materialBoxA,materialBoxB,materialBoxC,materialBoxD];
			
			moneyDesc=ComponentUtil.createTextField("", 20, materialBoxA.y + materialBoxA.height, null,
				140, 26, bg);
			moneyDesc.filters=Style.textBlackFilter;
			moneyDesc.htmlText=HtmlUtil.font("拆卸费用：", "#3CE44F") + HtmlUtil.font("", "#B0E2EB");
			
			moneyErrorTF=ComponentUtil.createTextField("", 20, moneyDesc.y + 20, null,
				140, 22, bg);
			moneyErrorTF.filters=Style.textBlackFilter;
			
			punchBtn=ComponentUtil.createButton("拆卸", bg.width - 120, moneyDesc.y - 2, 100, 25, bg);
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
			punchDesc.htmlText=HtmlUtil.font("拆卸说明\n", "#CCE741") + HtmlUtil.font("从右侧列表中选择 装备，点击“拆卸”按钮把已镶嵌的灵石拆下来，【拆卸保护符】数量会影响到成功率。",
				"#ffffff");
			punchDesc.filters=Style.textBlackFilter;
			
			rightTopList = new RightTopList(NAME);
			rightTopList.initUI();
			addChild(rightTopList);
			rightTopList.x = bg.x + bg.width + 2;
			rightTopList.y = bg.y;
			rightTopList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			
			var rightBottomList:RightBottomList = new RightBottomList();
			chaixieShop = new MaterialShopList();
			chaixieShop.initUI(StoveMaterialFilter.disassemblySymbol());
			chaixieShop.addEventListener("MATERIAL_ITEM_CLICK",onchaixieShopItemClick);
			var arr:Array = [{name:"拆卸符",reference:chaixieShop}];
			rightBottomList.initUI(arr);
			addChild(rightBottomList);
			rightBottomList.x = rightTopList.x;
			rightBottomList.y = 220;
			hasInit=true;
		}
		
		
		private function onchaixieShopItemClick(event:ParamEvent):void{
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
			var mBox:MaterialBox = event.target as MaterialBox;
			mBox.data = null;
			updatePercent();
		}
		
		private function setMaterial(data:*):void{
			for(var i:int = 0; i < materialBoxs.length; i++){
				var mBox:MaterialBox = MaterialBox(materialBoxs[i]);
				if(mBox.data == null){
					mBox.data = getOneSymbol();
					updatePercent();
					return;
				}
			}
		}
		
		private function getOneSymbol():BaseItemVO{
			var symbols:Array = PackManager.getInstance().getGoodsByType(10600013);
			for(var i:int = 0; i < symbols.length; i++){
				var item:BaseItemVO = BaseItemVO(symbols[i]);
				var num:int = item.num;
				for(var j:int = 0; j < materialBoxs.length; j++){
					var mBox:MaterialBox = MaterialBox(materialBoxs[j]);
					if(mBox.data != null && mBox.data.oid == item.oid){
						num--;
					}
				}
				if(num != 0){
					return item;
				}
			}
			return null;
		}
		
		private function setValue(data:*):void{
			equipBox.data = data;
			updateMoney(data);
			if(data){
				rightTopList.checkSelet(data.oid);
			}else{
				rightTopList.checkSelet(-1);
			}
		}
		
		private function updateMoney(data:*):void{
			if(data){
				var money:int = StoveCostManager.removeStoneCost(data);
				moneyDesc.htmlText=HtmlUtil.font("拆卸费用：", "#3CE44F") + HtmlUtil.font(DealConstant.silverToOtherString(money), "#B0E2EB");
				var deMoney:int = (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) - money;
				if( deMoney < 0 ){
					moneyErrorTF.htmlText = HtmlUtil.font("费用不足，缺"+DealConstant.silverToOtherString(-deMoney),"#ff0000");
				}else{
					moneyErrorTF.htmlText = "";
				}
			}else{
				moneyDesc.htmlText=HtmlUtil.font("拆卸费用：", "#3CE44F") + HtmlUtil.font("0", "#B0E2EB");
				moneyErrorTF.htmlText = "";
			}
		}
		
		private function updatePercent():void{
            //40 55 70 85 100
			var percent:int = 40;
            var sumMaterialNumber:int = 0;
			for(var i:int =0; i < materialBoxs.length; i++){
				var mBox:MaterialBox = materialBoxs[i] as MaterialBox;
				if(mBox.data != null){
                    sumMaterialNumber = sumMaterialNumber + 1;
				}
			}
            if(sumMaterialNumber == 1){
                percent = 55;
            }else if(sumMaterialNumber == 2){
                percent = 70;
            }else if(sumMaterialNumber == 3){
                percent = 85;
            }else if(sumMaterialNumber == 4){
                percent = 100;
            }else{
                percent = 40;
            }
			if(sumMaterialNumber == 0 || percent == 0){
				middleDesc.htmlText = HtmlUtil.font("拆卸成功率：","#CDE644") + HtmlUtil.font("40%", "#F53F3C") + HtmlUtil.font(" 放入拆卸保护符提高拆卸成功率","#CDE644");
			}else if(percent >= 100){
				middleDesc.htmlText = HtmlUtil.font("拆卸成功率：" + percent.toString() + "%","#3CE44F");
			}else{
				middleDesc.htmlText = HtmlUtil.font("拆卸成功率：","#CDE644") + HtmlUtil.font("" + percent.toString() + "%", "#F53F3C");
			}
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
            var msg:String = "";
			if(vo.succ){
                if(vo.reason_code == 1){
                    msg = "装备灵石拆卸失败，灵石被降级或销毁";
                }else{
                    msg = "装备灵石拆卸成功";
                    
                }
				setValue(StoveEquipFilter.findTarget(vo.firing_list,vo.update_list));
			}else{
                msg = vo.reason;
			}
            Tips.getInstance().addTipsMsg(msg);
            //BroadcastSelf.logger(msg);
            var goodsMsg:String = "装备拆卸获得：";
            for each(var goods:p_goods in vo.new_list) {
                goodsMsg=goodsMsg + HtmlUtil.font("【" + goods.name + "】x1", ItemConstant.COLOR_VALUES[goods.current_colour]);
            }
            if(vo.new_list != null && vo.new_list.length > 0){
                //BroadcastSelf.logger(goodsMsg);
            }
			equipBox.playCompleteEffec();
			equipBox.stopEffect();
			clean();
			update();
            updatePercent();
		}
		
		private function clean(data:Boolean=true,effect:Boolean=true):void{
			for(var i:int=0; i< materialBoxs.length; i++){
				var mBox:MaterialBox = materialBoxs[i] as MaterialBox;
				if(data)mBox.data = null;
				if(effect)mBox.stopEffect();
			}
			//if(data)checkSelect();
		}
		
		public function update():void{
			rightTopList.update();
			chaixieShop.update(StoveMaterialFilter.disassemblySymbol());
		}
		
		public function startEffect():void{
			equipBox.playEffect();
			for(var i:int =0; i < materialBoxs.length; i++){
				var mBox:MaterialBox = MaterialBox(materialBoxs[i]);
				if(mBox.data != null){
					mBox.playEffect();
				}
			}
		}
		
		public function reset():void{
			setValue(null);
			clean();
			update();
		}
		
		private function errorTip(str:String):void{
			Tips.getInstance().addTipsMsg(str);
			//BroadcastSelf.logger(str);
		}
		
		private function onMouseClickHandler(event:MouseEvent):void {
			if(equipBox.data==null){
				errorTip("请放入需要拆卸的装备");
				return;
			}
			var equip:EquipVO =EquipVO(equipBox.data);
			if(equip.stone_num <= 0){
				errorTip("此装备没有镶嵌灵石，不需要拆卸");
				return ;
			}
			var materials:Array = [];
			for(var i:int =0; i < materialBoxs.length; i++){
				var mBox:MaterialBox = MaterialBox(materialBoxs[i]);
				if(mBox.data != null){
					materials.push(mBox.data);
				}
			}
			if(moneyErrorTF.htmlText != ""){
				errorTip("操作失败，费用不足");
				return;
			}
			if(materials.length == 0){
				Alert.show("当前拆卸成功率为：<font color='0xff0000'>40%</font>，拆卸失败会导致装备销毁或灵石降级。放入【拆卸保护符】可提升成功率。确定要拆卸吗？","警告",doDisassembly,null,"确认","取消",[],true,true);
			}else{
				doDisassembly();
			}
		}
		
		private function doDisassembly():void{
			var e:ParamEvent = new ParamEvent(StoveConstant.DISASSEMBLY_BTN_CLICK,null,true);
			var materials:Array = [];
			for(var i:int =0; i < materialBoxs.length; i++){
				var mBox:MaterialBox = MaterialBox(materialBoxs[i]);
				if(mBox.data != null){
					materials.push(mBox.data);
				}
			}
			e.data = {equip:equipBox.data,materials:materials};
			dispatchEvent(e);
		}
	}
}