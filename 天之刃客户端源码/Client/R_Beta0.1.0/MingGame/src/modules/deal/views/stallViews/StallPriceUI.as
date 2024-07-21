package modules.deal.views.stallViews
{
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopItem;

//	import modules.shop.views.ShopGoodsItem;
//	import modules.shop.vo.GoodsVo;
	
	public class StallPriceUI extends DragUIComponent
	{
		
		// 273 56
		private var goodsItem:GoodsImage;
		private var goodsName:TextField; // "商品：大力丸";
		private var pleaseInputTxt:TextField; // "输入单价："
		private var dingInput:TextInput;      //　几多　锭
		private var dingTxt:TextField;        //　单位　锭
		private var liangInput:TextInput;      //　几多　两
		private var liangTxt:TextField;        //　单位　两
		private var wenInput:TextInput;      //　几多　文
		private var wenTxt:TextField;        //　单位　文
		private var goldInput:TextInput;
		private var goldBtn:RadioButton;
		private var silverBtn:RadioButton;
		
		private var textformat:TextFormat;
		
		private var surebtn:Button;
		private var cancelbtn:Button;
		
		////////////////　变量　//////////// 
		private var bsItemVo:BaseItemVO;   //把售价弄进去，再传参。 弄回背包时 把里面的 unit_price属性 = null，或 -1
		private var goodsVo:ShopItem;
		
		private var _price:int;
		public var pos:int;
		public var state:int;
		
		
		public function StallPriceUI()
		{
			super();//325 188
			
			this.width = 279;//310;
			this.height = 140;//191;
			this.showCloseButton = true;
			this.alpha = 1;
			init();
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			
		}
		
		private function onAdded(e:Event):void
		{
			goldBtn.selected = true;
			goldInput.setFocus();
			goldInput.validateNow();
			goldInput.text = "";
		}
		
		private function init():void
		{
			textformat = new TextFormat("Tahoma",12,0xece8bb);//0xffffff	
			
			goodsItem = new GoodsImage();
			goodsItem.x = 13;//50;
			goodsItem.y = 9;//46;
			addChild(goodsItem);
			goodsItem.addEventListener(MouseEvent.ROLL_OVER, showImgTips);
			goodsItem.addEventListener(MouseEvent.ROLL_OUT, hideImgTips);
			
			goodsName = ComponentUtil.createTextField("商品：大力丸", 63, 9, textformat, 150, 20, this); /// new TextField();
			pleaseInputTxt = ComponentUtil.createTextField("输入单价：", 63, 29, textformat, 100, 20, this); // new TextField();
			
			goldBtn = new RadioButton("元宝：");
			goldBtn.textFormat = textformat;
			goldBtn.x = 8;
			goldBtn.y = 53;
			addChild(goldBtn);
			goldBtn.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			silverBtn = new RadioButton("银两：");
			silverBtn.textFormat = textformat;
			silverBtn.x = 8;
			silverBtn.y = 79;
			addChild(silverBtn);
			silverBtn.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			goldInput = new TextInput();
			goldInput.x = 67;
			goldInput.y = 51;
			goldInput.width = 203;
			goldInput.restrict = "0-9";
			goldInput.maxChars = 6;
			addChild(goldInput);
			goldInput.addEventListener(MouseEvent.CLICK, onTxtChange);
			
			dingInput = new TextInput();
			dingInput.x = 67;//88
			dingInput.y = 77;
			dingInput.width = 50;
			//			dingInput.height = 20;
			dingInput.restrict = "0-9";
			dingInput.maxChars = 5;      //6位的话，转成"文" 可能超 int 型了。 
			addChild(dingInput);
			dingInput.addEventListener(MouseEvent.CLICK, onTxtChange);
			
			dingTxt = ComponentUtil.createTextField("锭",118,77,textformat,22,23,this); // new TextField();
			
			
			liangInput = new TextInput();
			liangInput.x = 135;//161;                    //+22
			liangInput.y = 77;
			liangInput.width = 50;
			//			liangInput.height = 20;
			liangInput.restrict = "0-9";
			liangInput.maxChars = 2;
			addChild(liangInput);
			liangInput.addEventListener(MouseEvent.CLICK, onTxtChange);
			
			liangTxt = ComponentUtil.createTextField("两",185,77,textformat,22,23,this); // new TextField();
			
			
			
			wenInput = new TextInput();
			wenInput.x = 203;//234;
			wenInput.y = 77;
			wenInput.width = 50;
			//			wenInput.height = 20;
			wenInput.restrict = "0-9";
			wenInput.maxChars = 2;
			addChild(wenInput);
			wenInput.addEventListener(MouseEvent.CLICK, onTxtChange);
			
			wenTxt = ComponentUtil.createTextField("文",255,77,textformat,22,23,this); //new TextField();
			
			
			surebtn = ComponentUtil.createButton("确定",52,111,60,22,this,Style.setRedBtnStyle); // new Button();
			surebtn.addEventListener(MouseEvent.CLICK, onSureHandler);
			
			cancelbtn = ComponentUtil.createButton("取消",160,111,60,22,this,Style.setRedBtnStyle); // new Button();
			cancelbtn.addEventListener(MouseEvent.CLICK, onCancelHandler);
			
		}
		
		private function showImgTips(e:Event):void
		{
			if (bsItemVo)
				ToolTipManager.getInstance().show(bsItemVo, 0, 0, 0, "targetToolTip");
		}
		
		private function hideImgTips(e:Event):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		private function onTxtChange(evt:Event):void
		{
			var target:TextInput = evt.currentTarget as TextInput;
			if (target == dingInput || target == liangInput || target == wenInput) {
				silverBtn.selected = true;
				goldBtn.selected = false;
				goldInput.text = "";
			}
			
			if (target == goldInput) {
				silverBtn.selected = false;
				goldBtn.selected = true;
				dingInput.text = "";
				liangInput.text = "";
				wenInput.text = "";
			}
		}
		
		private function onMouseClick(evt:MouseEvent):void
		{
			var target:RadioButton = evt.currentTarget as RadioButton;
			if (target == goldBtn) {
				silverBtn.selected = false;
				goldInput.setFocus();
				liangInput.text = "";
				dingInput.text = "";
				wenInput.text = "";
			}
			
			if (target == silverBtn) {
				goldBtn.selected = false;
				liangInput.setFocus();
				goldInput.text = "";
			}
		}
		
		override protected function onCloseHandler(event:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
		}
		
		private function onSureHandler(evt:MouseEvent):void
		{
			var priceType:int;
			
			if (silverBtn.selected == true) {
				var ding:int;
				var liang:int;
				var wen:int;
				if(dingInput.text=="")
					ding = 0;
				else 
					ding = int(dingInput.text);
				
				
				if(liangInput.text=="")
					liang = 0;
				else 
					liang = int(liangInput.text);
				
				if(wenInput.text=="")
					wen = 0;
				else 
					wen = int(wenInput.text);		
					
				_price = DealConstant.otherToSilver(ding,liang,wen);
				priceType = DealConstant.STALL_PRICE_TYPE_SILVER
			} else {
				if (goldInput.text == "") {
					_price = 0;
				} else {
					_price = int(goldInput.text);
				}
				priceType = DealConstant.STALL_PRCIE_TYPE_GOLD;
			}
			
			if(_price ==0)
			{
				Alert.show("请输入价格。","提示：",null,null,"确定","",null,false);
				return;
			}
			
			DealModule.getInstance().setStallPrice(pos, _price, priceType, bsItemVo , state);
			
		}
		private function onCancelHandler(evt:MouseEvent):void
		{
			//to do 取消　把该物品放回背包原位
			if(DealModule.getInstance()._handleStallPanel)
			{
				DealModule.getInstance()._handleStallPanel.sendToPackage(pos);
			}
			else if(DealModule.getInstance()._stallPanel){
				DealModule.getInstance()._stallPanel.sendToPackage(pos);
			}
//			DealConstant.price_arr[pos] = null;
			DealModule.getInstance().priceUiCancel();
			
			
		}
		
		
		/**
		 * 赋给数据，　显示图片 
		 * @param value
		 * 
		 */		
		public function set itemData(value:BaseItemVO):void
		{
			if(!value)
				return;
			bsItemVo = value;
			
			setGoodsName(value.name);
			
			goodsItem.setImageContent(value, value.path);
		}
		
		private function setGoodsName(value:String):void
		{
			if(!value)
				return;
			goodsName.text = "商品：" + value;
			
//			goodsName.setTextFormat(textformat);
		}
		
		
		//返回背包
		//PackManager.getInstance().updateGoods(BaseItemVO.bagid,BaseItemVO.position,BaseItemVO);
		//摊面少了对应的　pos 上的物品。
	}
}