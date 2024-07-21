package modules.forgeshop.views.items
{
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.forgeshop.ItemManager;
	import modules.shop.ShopModule;
	
	import proto.line.p_equip_build_goods;
	
	public class AttachItemRender extends UIComponent implements IDataRenderer{
		private var quantityTextField:TextField;//拥有数量
		private var expendTextField:TextField;//消耗数量
		public var checkBox:CheckBox;//复选框
		public var buyTxt:TextField;
		
		public function AttachItemRender(){
			checkBox = ComponentUtil.createCheckBox("",5,2,this);
			checkBox.name = "checkBox";
//			checkBox.width = 88;
			
			
			expendTextField = ComponentUtil.createTextField("",checkBox.x + checkBox.width ,checkBox.y,null,60,26);
			this.addChild(expendTextField);
			
			quantityTextField =  ComponentUtil.createTextField("",expendTextField.x + expendTextField.width,expendTextField.y,null,60,26);
			addChild(quantityTextField);
			
			buyTxt = ComponentUtil.createTextField("",quantityTextField.x + quantityTextField.width,quantityTextField.y,null,60,26,this);
			buyTxt.htmlText = "<font color='#00ff00'><a href='event:buy'><u>现在购买</u></a></font>";
			buyTxt.visible = false;
			buyTxt.mouseEnabled = true;
			buyTxt.addEventListener(TextEvent.LINK,onTextLinkHandler);
		}
		
		private var itemId:int;
		private function onTextLinkHandler(evt:TextEvent):void{
			if(evt.text == "buy"){
				ShopModule.getInstance().requestShopItem(30100,itemId,new Point(stage.mouseX-178, stage.mouseY-90),1);
			}
		}
		
		/**
		 *改变颜色 
		 * @param color
		 * 
		 */		
		public function changeTextColor(color:uint):void{
			var textFormat:TextFormat = new TextFormat("Tahoma",12,color,null,null,null,null,null,TextFormatAlign.CENTER);
			checkBox.textFormat = textFormat;
			expendTextField.setTextFormat(textFormat);
			quantityTextField.setTextFormat(textFormat);
		}
		
		//赋值
		public function setText(checkBoxText:String,expendTxt:int,quantityText:int):void{
			checkBox.text= checkBoxText;
			expendTextField.text = expendTxt+"";
			quantityTextField.text= quantityText+"";
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value; 
			
			var goods:p_equip_build_goods = value as p_equip_build_goods;
			
			if(goods != null){				
			    setText(goods.name,goods.needed_num,goods.current_num);
				checkBox.validateNow();
				
				
				if(goods.current_num >= 1){
					changeTextColor(0x00ff00);
				}else{
					changeTextColor(0xFF5151);
					buyTxt.visible = true;
				}
				itemId = goods.type_id;
				
				//四级以上的是不需要显示现在购买的字样的
				if(ItemManager.getInstance().arr.indexOf(goods.type_id) !=-1){
					buyTxt.visible = false;
				}
			}
			
		}
	}
}