package modules.finery.views.refine {
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
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
	
	import modules.broadcast.views.Tips;
	import modules.finery.StoveConstant;
	import modules.finery.views.item.MaterialBox;
	import modules.finery.views.item.MaterialList;
	import modules.finery.views.item.RightList;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_goods;
	import proto.line.m_refining_firing_toc;
	
	public class RefineView extends UIComponent {
		public static const　NAME:String = "RefineView";
		public static const TEXTFORMAT_DEFAULT:TextFormat = new TextFormat("Tahoma", 12, 0xffcc00);
		
		private var equipDesc:TextField;
		private var middleDesc:TextField;
		private var moneyDesc:TextField;
		private var succDesc:TextField;
		private var composeBtn:Button;
		private var clearBtn:Button;
		private var radioButtonGroup:RadioButtonGroup;
		private var radio_five_btn:RadioButton;
		private var radio_four_btn:RadioButton;
		private var radio_three_btn:RadioButton;
		private var materialBoxs:Array = [];
		private var rightList:RightList;
		
		public function RefineView() {
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
			
			var equipDescFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				CENTER);
			equipDesc=ComponentUtil.createTextField("请从右侧列表中选择炼制材料", 78, 8, equipDescFormat, 200, 26, bg);
			equipDesc.filters=Style.textBlackFilter;
			equipDesc.x=(bg.width - equipDesc.width) * 0.5;
			
			var kuangSprite:Sprite = new Sprite();
			bg.addChild(kuangSprite);
			kuangSprite.x = 10;
			kuangSprite.y = equipDesc.y + equipDesc.height + 5;
			for(var i:int=0;i<9;i++){
				var mBox:MaterialBox = new MaterialBox("",true);
				mBox.name = i.toString();
				mBox.addEventListener("MATERIAL_BOX_CLICK",onMaterialBoxClick);
				kuangSprite.addChild(mBox);
				materialBoxs.push(mBox);
			}
			LayoutUtil.layoutGrid(kuangSprite,3,5,5);
			
			//var selectTxt:TextField = ComponentUtil.createTextField("请选择合成基数：",kuangSprite.x + kuangSprite.width,kuangSprite.y,null,125,26,bg);
			
			composeBtn = ComponentUtil.createButton("炼制",140,bg.height- 35,60,25,bg);
			composeBtn.name = "composeBtn";
			composeBtn.addEventListener(MouseEvent.CLICK,onComposeBtnClick);
			clearBtn = ComponentUtil.createButton("清空",composeBtn.x + composeBtn.width + 10,composeBtn.y,60,25,bg);
			clearBtn.addEventListener(MouseEvent.CLICK,onClearBtnClick);
			
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
			punchDesc.wordWrap=true
			punchDesc.multiline=true;
			punchDesc.htmlText=HtmlUtil.font("炼制说明\n", "#CCE741") + HtmlUtil.font("从右侧列表选择需要炼制的配方，配方所需材料数量达到后点击“炼制”获得新的物品。",
				"#ffffff");
			punchDesc.filters=Style.textBlackFilter;
			
			var materialList:MaterialList = new MaterialList(NAME);
			materialList.update();
			var arr:Array = [{name:"全部",reference:materialList},{name:"材料",reference:materialList},{name:"灵石",reference:materialList},{name:"装备",reference:materialList}]
			rightList = new RightList(arr);
			rightList.addEventListener("EQUIP_ITEM_CLICK",onEquipListItemClick);
			this.addChild(rightList);
			rightList.x = bg.x + bg.width + 2;
			rightList.y = bg.y;
			hasInit = true;
		}
		
		private function onClearBtnClick(event:MouseEvent):void{
			clean();
		}
		
		private function onEquipListItemClick(event:ParamEvent):void{
			event.stopPropagation();
			setMaterial(event.data);
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
			var mBox:MaterialBox;
			for(var i:int=0; i< materialBoxs.length; i++){
				mBox = materialBoxs[i] as MaterialBox;
				if(mBox.data){
					ids.push(mBox.data.oid);
				} 
			}
			rightList.checkSelect(ids);
		}
		
		private function onMaterialBoxClick(event:Event):void{
			event.stopPropagation();
			var mBox:MaterialBox = event.target as MaterialBox;
			mBox.data = null;
			checkSelect();
		}
		
		private function onMouseClickHandler(event:MouseEvent):void {
			
		}
		
		private function clean(data:Boolean=true,effect:Boolean=true):void{
			for(var i:int=0; i< materialBoxs.length; i++){
				var mBox:MaterialBox = materialBoxs[i] as MaterialBox;
				if(data)mBox.data = null;
				if(effect)mBox.stopEffect();
			}
			checkSelect();
		}
		
		public function callBack(vo:m_refining_firing_toc):void{
            var msg:String = "";
			if(vo.succ){
				if(vo.reason_code == 1){
                    msg = vo.reason;
                }else{
                    msg = "炼制成功，获得";
                    for each(var goods:p_goods in vo.new_list) {
                        msg=msg + HtmlUtil.font("【" + goods.name + "】", ItemConstant.COLOR_VALUES[goods.current_colour],14) + "x" + goods.current_num.toString();
                    }
					clean();
					var good:p_goods;
					var newItem:BaseItemVO;
					for(var i:int=0; i < vo.new_list.length; i++){
						good = vo.new_list[i]
						newItem = ItemLocator.getInstance().getObject(good.typeid);
						newItem.copy(good);
						setMaterial(newItem);
					}
                }
				
			}else{
                msg = vo.reason;
				clean(false);
			}
            Tips.getInstance().addTipsMsg(msg);
            //BroadcastSelf.logger(msg);
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
					materials.push(mBox.data);
				}
			}
			if(materials.length==0){
				errorTip("请放入需要炼制的材料");
				return;
			}
			doRefine(materials,type);
		}
		
		private function doRefine(materials:Array,type:int):void{
			var e:ParamEvent = new ParamEvent(StoveConstant.REFINE_BTN_CLICK,null,true);
			e.data = {materials:materials,type:type};
			dispatchEvent(e);
		}
	}
}