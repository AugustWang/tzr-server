package modules.finery.views.compose {
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.finery.MaterialID;
	import modules.finery.StoveConstant;
	import modules.finery.StoveCostManager;
	import modules.finery.views.item.MaterialBox;
	import modules.finery.views.item.MaterialList;
	import modules.finery.views.item.RightList;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_goods;
	import proto.line.m_refining_firing_toc;
	
	public class ComposeView extends UIComponent {
		public static const　NAME:String = "ComposeView";
		public static const TEXTFORMAT_DEFAULT:TextFormat = new TextFormat("Tahoma", 12, 0xffcc00);
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var succDesc:TextInput;
		private var composeBtn:Button;
		private var clearBtn:Button;
		private var radioButtonGroup:RadioButtonGroup;
		private var radio_five_btn:RadioButton;
		private var radio_four_btn:RadioButton;
		private var radio_three_btn:RadioButton;
		private var materialBoxs:Array = [];
		private var composeMaterail:MaterialBox;
		private var rightList:RightList;
		
		public function ComposeView() {
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
			
			var titleTF:TextFormat = new TextFormat("Tahoma", 14, 0xFFFF00);
			var equipDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				CENTER);
			equipDesc=ComponentUtil.createTextField("请放入想合成材料", 78, 8, equipDescFormat, 200, 26, bg);
			equipDesc.textColor = 0xffff00;
			equipDesc.filters=Style.textBlackFilter;
			equipDesc.x=(bg.width - equipDesc.width) * 0.5;
			
			var kuangSprite:Sprite = new Sprite();
			bg.addChild(kuangSprite);
			kuangSprite.y = equipDesc.y + equipDesc.height + 5;
			for(var i:int=0;i<6;i++){
				var mBox:MaterialBox = new MaterialBox("",true);
				mBox.name = i.toString();
				mBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
				kuangSprite.addChild(mBox);
				materialBoxs.push(mBox);
			}
			LayoutUtil.layoutGrid(kuangSprite,3,20,10);
			kuangSprite.x = bg.width - kuangSprite.width >> 1;
			ComponentUtil.createTextField("合成产物",bg.width - 62 >> 1,kuangSprite.y+kuangSprite.height+5,titleTF,62,26,bg);
			
			composeMaterail = new MaterialBox("",true);
			composeMaterail.x = bg.width - composeMaterail.width >> 1;
			composeMaterail.y = kuangSprite.y+kuangSprite.height+35;
			bg.addChild(composeMaterail);
			
			var selectTxt:TextField = ComponentUtil.createTextField("请选择合成基数：",40,composeMaterail.y+composeMaterail.height+10,null,125,26,bg);
			
			radioButtonGroup = new RadioButtonGroup();
			radioButtonGroup.addEventListener(RadioButtonGroup.SELECTED_CHANGE,onSelectedChange);
			bg.addChild(radioButtonGroup);
			radioButtonGroup.direction = RadioButtonGroup.HORIZONTAL;
			radioButtonGroup.x = selectTxt.x;
			radioButtonGroup.y = selectTxt.y + selectTxt.height;
			radio_five_btn = new RadioButton("五合一");
			radio_five_btn.textFormat = TEXTFORMAT_DEFAULT;
			radio_five_btn.selected = true;
			
			radio_four_btn = new RadioButton("四合一");
			radio_four_btn.textFormat = TEXTFORMAT_DEFAULT;
			
			radio_three_btn = new RadioButton("三合一");
			radio_three_btn.textFormat = TEXTFORMAT_DEFAULT;
			
			radioButtonGroup.addItem(radio_five_btn);
			radioButtonGroup.addItem(radio_four_btn);
			radioButtonGroup.addItem(radio_three_btn);
			
			var desc:TextField = ComponentUtil.createTextField("合成成功率：",selectTxt.x,radioButtonGroup.y + 30,null,90,26,bg);
			succDesc = ComponentUtil.createTextInput(desc.x+desc.width,desc.y,100,25,bg);
			succDesc.textField.textColor = 0xffff00;
			succDesc.text = "100%"
			succDesc.enabled = false;
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y = 310; 
			line.width = bg.width;
			bg.addChild(line);
			
			composeBtn = ComponentUtil.createButton("合成",70,bg.height- 44,80,25,bg);
			composeBtn.name = "composeBtn";
			composeBtn.addEventListener(MouseEvent.CLICK,onComposeBtnClick);
			clearBtn = ComponentUtil.createButton("清空",composeBtn.x + composeBtn.width + 10,composeBtn.y,80,25,bg);
			clearBtn.addEventListener(MouseEvent.CLICK,onClearBtnClick);
			
			var materialList:MaterialList = new MaterialList(NAME);
			materialList.update();
			var arr:Array = [{name:"全部",reference:materialList},{name:"材料",reference:materialList},{name:"灵石",reference:materialList}]
			rightList = new RightList(arr);
			rightList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			this.addChild(rightList);
			rightList.x = bg.x + bg.width + 6;
			rightList.y = bg.y;
			hasInit=true;
		}
		
		private function onSelectedChange(event:Event):void{
			switch(radioButtonGroup.selectedIndex){
				case 0:succDesc.text = "100%";break;
				case 1:succDesc.text = "75%";break;
				case 2:succDesc.text = "50%";break;
			}
		}
		
		private function onClearBtnClick(event:MouseEvent):void{
			clean();
		}
		
		private function onEquipListItemClick(event:ParamEvent):void{
			event.stopPropagation();
			setMaterial(event.data)
		}
		
		private function setMaterial(data:*):void{
			var mBox:MaterialBox;
			for(var i:int=0; i< materialBoxs.length; i++){
				mBox = materialBoxs[i] as MaterialBox;
				if(mBox.data){
					if(mBox.data.oid == data.oid){
						return;
					}
				} 
			}
			for(i=0; i< materialBoxs.length; i++){
				mBox = materialBoxs[i] as MaterialBox;
				if(mBox.data == null){
					mBox.data = data;
					break;
				}
			}
			checkSelect();
		}
		
		private function checkSelect():void{
			var ids:Array = [];
			var typeIds:Array = [];
			var mBox:MaterialBox;
			for(var i:int=0; i< materialBoxs.length; i++){
				mBox = materialBoxs[i] as MaterialBox;
				if(mBox.data){
					ids.push(mBox.data.oid);
					typeIds.push(mBox.data.typeId);
				} 
			}
			rightList.checkSelect(ids);
			updateComposeGoods(typeIds);
		}
		
		private function onMaterialBoxClick(event:Event):void{
			event.stopPropagation();
			var mBox:MaterialBox = event.target as MaterialBox;
			mBox.data = null;
			checkSelect();
		}
		
		private function updateComposeGoods(ids:Array):void {
			if(ids && ids.length > 0){
				var isCommon:Boolean = true;
				var value1:int = 0;
				for each(var value2:int in ids){
					if(value1 !=0 && value1 != value2){
						isCommon = false;
						break;
					}else{
						value1 = value2;
					}
				}
				if(isCommon){
					composeMaterail.data = MaterialID.getInstance().getCompose(ids.shift());
				}else{
					composeMaterail.data = null;
				}
			}else{
				composeMaterail.data = null;
			}
		}
		
		private function clean(data:Boolean=true,effect:Boolean=true):void{
			for(var i:int=0; i< materialBoxs.length; i++){
				var mBox:MaterialBox = materialBoxs[i] as MaterialBox;
				if(data)mBox.data = null;
				if(effect)mBox.stopEffect();
			}
			if(data)checkSelect();
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
			Tips.getInstance().addTipsMsg(vo.reason);
			//BroadcastSelf.logger(vo.reason);
			if(vo.succ){
				clean();
				var good:p_goods;
				var newItem:BaseItemVO;
				for(var i:int=0; i < vo.new_list.length; i++){
					good = vo.new_list[i]
					newItem = ItemLocator.getInstance().getObject(good.typeid);
					newItem.copy(good);
					setMaterial(newItem);
				}
			}else{
				clean(false);
			}
			update();
		}
		
		public function update():void{
			rightList.update();
		}
		
		public function startEffect():void{
			for(var i:int=0; i< materialBoxs.length; i++){
				var mBox:MaterialBox = materialBoxs[i] as MaterialBox;
				if(mBox.data != null){
					mBox.playEffect();
				}
			}
		}
		
		public function reset():void{
			clean();
			update();
		}
		
		private function errorTip(str:String):void{
			Tips.getInstance().addTipsMsg(str);
			//BroadcastSelf.logger(str);
		}
		
		private function onComposeBtnClick(event:MouseEvent):void{
			var materials:Array = [];
			var type:int;
			for(var i:int = 0; i < materialBoxs.length; i++){
				var mBox:MaterialBox = materialBoxs[i] as MaterialBox;
				if(mBox.data != null){
					materials.push({data:mBox.data,num:mBox.data.num});
				}
			}
			switch(radioButtonGroup.selectedIndex){
				case 0:type=5;break;
				case 1:type=4;break;
				case 2:type=3;break;
			}
			if(materials.length==0){
				errorTip("请放入需要合成的材料");
				return;
			}
			//判断材料是否合法
			var diffMaterial:Boolean = false;
			var curMaterialTypeId:int = 0;
			var curMaterialNumber:int = 0;
			for each(var diffItemObj:Object in materials){
				var diffBaseItem:BaseItemVO = BaseItemVO(diffItemObj.data);
				if(curMaterialTypeId == 0){
					curMaterialTypeId = diffBaseItem.typeId;
				}
				if(diffMaterial == false && curMaterialTypeId != diffBaseItem.typeId){
					diffMaterial = true;
				}
				curMaterialNumber = curMaterialNumber + diffBaseItem.num;
			}
			if(diffMaterial){
				errorTip("存在不同的材料，不可以合成。");
				return;
			}
			if(curMaterialNumber < type){
				errorTip("合成材料数量不足，需要"+type+"个材料或选择其他合成基数。");
				return;
			}
			doCompose(materials,type);
		}
		
		private function doCompose(materials:Array,type:int):void{
			var e:ParamEvent = new ParamEvent(StoveConstant.COMPOSE_BTN_CLICK,null,true);
			e.data = {materials:materials,type:type};
			dispatchEvent(e);
		}
	}
}