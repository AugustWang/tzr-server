package modules.forgeshop.views.items
{
	import com.managers.WindowManager;
	import com.ming.core.IDataRenderer;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.forgeshop.ItemManager;
	import modules.shop.views.ShopBuyView;
	import modules.shop.ShopModule;
	
	import proto.line.p_equip_build_goods;
	
	public class MaterialItemRender extends UIComponent implements IDataRenderer{
		private var nameTextField:TextField;
		private var needTextField:TextField;
		private var quantityTextField:TextField;
		private var buyTxt:TextField;
		private var buyItemPanel:ShopBuyView;
		/**
		* 打造需要材料 
		 * 
		 */		
		public function MaterialItemRender(){
			//需要材料
			nameTextField = createTextField(1,10,88);
			addChild(nameTextField);
			//需要数量
			needTextField = createTextField(nameTextField.x + nameTextField.width,nameTextField.y,60);
			addChild(needTextField);
			//拥有数量
			quantityTextField = createTextField(needTextField.x + needTextField.width,needTextField.y,60);
			addChild(quantityTextField);
			
			buyTxt = createTextField(quantityTextField.x + quantityTextField.width,quantityTextField.y,60);
			this.addChild(buyTxt);
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
		
		private function onCloseHandler(evt:CloseEvent):void{
			WindowManager.getInstance().removeWindow(buyItemPanel);
		}
		
		public function createTextField(xValue:Number = NaN, yValue:Number = NaN,wValue:Number = NaN):TextField{
			var txt:TextField = new TextField();
			txt.width = wValue;
			txt.x = xValue;
			txt.height = 26;
			txt.mouseEnabled = false;
			txt.selectable = false;
			return txt;
		}
		
		/**
		 *如果数量不够改变文本 
		 * @param format
		 * 
		 */		
		public function changeTextColor(color:uint):void{
			var textFormate:TextFormat = new TextFormat("Tahoma",12,color,null,null,null,null,null,TextFormatAlign.CENTER);
			nameTextField.setTextFormat(textFormate);
			needTextField.setTextFormat(textFormate);
			quantityTextField.setTextFormat(textFormate);
			
		}
		/**
		 *赋值 
		 * @param nameText
		 * @param neededText
		 * @param quantityText
		 * 
		 */		
		public function setText(nameText:String,neededText:String,quantityText:String):void{
			nameTextField.text= nameText;
			needTextField.text= neededText;
			quantityTextField.text= quantityText;
		}
		
		
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value; 
			var goods:p_equip_build_goods = value as p_equip_build_goods;
			
			if(goods != null){
			   setText(goods.name,"" + goods.needed_num,"" + goods.current_num);
			   
			   if(goods.needed_num <=  goods.current_num ){
				   changeTextColor(0x00ff00);
				   buyTxt.visible = false;
			   }else{
				   changeTextColor(0xFF5151);
				   buyTxt.visible = true;
				   itemId = goods.type_id;
			   }
			   
			   //四级以上的是不需要显示现在购买的字样的
			   if(ItemManager.getInstance().arr.indexOf(goods.type_id) !=-1){
				   buyTxt.visible = false;
			   }
			}
		}
	}
}