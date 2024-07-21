package modules.trading.views
{
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.mypackage.ItemConstant;
	import modules.trading.TradingModule;
	import modules.trading.views.item.TradingItem;
	import modules.trading.vo.TradingGoodVo;
	
	public class BuyTradingPanel extends DragUIComponent
	{
		
		/* 界面上的东东 */
		private var _nameTf:TextField; 
		private var tmp_goods:TradingItem;
		
		private var dec_text:TextField;
		
		private var numText:TextField;
		
		private var numStep:NumericStepper;
		
		private var totalCostText:TextField;
		
		private var errTip:TextField;
		
		public var buyButton:Button;
		
		/* 变量 */
		private var npcId:int;
		private var id:int;
		private var price:int;
		private var priceObjArr:Array;
		public var packe_num:int;
		private var price_id:int;
		
		private var maxNum:int;
		private var num:int;
		private var moneyType:int;
		private var money:String;
		private var _name:String;
		private var totalCost:String;
		
		public static var buySuccTip:String = "";
		
//		private var checkBind:CheckBox;
		
		public function BuyTradingPanel()
		{
			super();
			
			//			title = "回城卷    500铜";
			this.width = 228;//215;
			this.height = 111;//155;
			//			this.allowDrag = false;
			
			Style.setRectBorder(this);
			this.showCloseButton = true;
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 222;
			line.height = 2;
			line.x = 3;
			line.y = 28;
			addChild(line);
			
			init();
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAddStage);
		}
		
		override protected function onCloseHandler(event:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
		}
		
		private function onAddStage(e:Event):void
		{
			numStep.textFiled.setFocus();
			numStep.textFiled.validateNow();
			numStep.textFiled.textField.setSelection(0,1);
		}
		
		private function init():void
		{
			var tf:TextFormat = new TextFormat("Tahoma",15,0xffffff);
			_nameTf = ComponentUtil.createTextField("",8,6,tf,175,23,this);
			
			tmp_goods= new TradingItem();
			tmp_goods.x = 8;
			tmp_goods.y = 31;//35;
			tmp_goods.width =tmp_goods.height = 37;
			tmp_goods.toolTipOff();
			
			addChild(tmp_goods);
			
			
			var txtformat:TextFormat = new TextFormat("Tahoma",12,0xece8bb);
			//			dec_text = ComponentUtil.createTextField("", 45,35,txtformat,155,60,this), // new TextField();
			//			dec_text.multiline = true;
			//			dec_text.wordWrap = true;
			
			numText = ComponentUtil.createTextField("数量" ,46,35,txtformat,46,23,this); // new TextField();
			
			
			numStep = new NumericStepper();
			numStep.x = 83;
			numStep.y = 34;//82;
			numStep.textFiled.restrict = "0-9";
			//			numStep.bgSkin = Style.getInstance().numericStepperSkin;
			numStep.textFiled.maxChars=4;
			numStep.maxnum = 50;
			numStep.minnum = 1;
			numStep.stepSize = 1;
			numStep.textFiled.textField.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
			numStep.value = 1;
			numStep.width = 60;// 70;
			
			addChild(numStep);
			numStep.addEventListener(Event.CHANGE,onNumChange);
			numStep.addEventListener(KeyboardEvent.KEY_UP,onBuyEnter);
			
			
			
			//			numStep.addEventListener(KeyboardEvent.KEY_UP,onBuyEnter);
			
			
			
			totalCostText = ComponentUtil.createTextField("",144,35,txtformat,108,23,this); 
			
			errTip = ComponentUtil.createTextField("",8,72,null,145,34,this); // new TextField();
			
			
			
			
			buyButton = ComponentUtil.createButton("购买",158,80, 55,22, this); //new Button();
			Style.setRedBtnStyle(buyButton);
			
			buyButton.addEventListener(MouseEvent.CLICK,onBuyClick);
			
			
		}
		
		private function onBuyClick(evt:MouseEvent):void
		{
			
			buyHandler();
		}
		
		private function buyHandler():void
		{
			if(num<1)
			{
				Alert.show("请输入购买数量。","提示：",null,null,"确定","",null,false);
				return;
			}
			
//			if(TradingManager.IS_LOCK)
//			{
//				Tips.getInstance().addTipsMsg("价格变动中，请稍候再操作。");
//				return;
//			}
			
//			ShopModel.getInstance().buyGoods(id,num ,price_id, shop_id);
			
			buySuccTip = "<font color='#ffff00'>购买" + _name + "×" + num +
				"，花费" + totalCost + "</font>";
			
			TradingModule.getInstance().buy_tos(npcId,id,num);
			buyButton.enabled = false;
			
		}
		
		private function onBuyEnter(evt:KeyboardEvent):void
		{
			if(evt.keyCode == Keyboard.ENTER)
				buyHandler();
		}
		
		
		
		private function onNumChange(evt:Event):void
		{
			if(!numStep.value)//== NaN
			{
				numStep.value = 1;
				numStep.textFiled.setFocus();
				numStep.textFiled.validateNow();
				numStep.textFiled.textField.setSelection(0,1);
			}
			
			num = numStep.value;
			
			if(maxNum<num)
			{
				num = maxNum;
				numStep.value = num;
			}
			
			
			
			totalCost = "";
			
			totalCost = String(num*price)+ "文";
			//to do   totalcost
			
			
			setTotalCost("花费" + totalCost);
		}
		
//		private function onSelected(evt:Event):void
//		{
//			GlobalObjectManager.instance.user.attr.unbund = !checkBind.selected;
//			ShopModel.getInstance().changeUseGoldType(!checkBind.selected);
//		}
//		
		public function setGoodsVo(value:TradingGoodVo):void  //商品的 Vo 赋值  Object
		{
			if(!value)
				return;
			
			npcId = value.npcId;
			
			id = value.type_id;
			_name = value.name;//item_n_name
			maxNum = value.num;
			
			
			price = value.sale_price;
			
			numStep.value = 1;
			num = numStep.value;
			
			totalCost ="";
			totalCost = value.sale_price.toString() + "文";
			
			var color:String = ItemConstant.COLOR_VALUES[value.color];
			var goodname:String = HtmlUtil.font(HtmlUtil.bold(value.name),color,15);
			
			setTitle(goodname);//, money);
			
			setTotalCost("花费" + totalCost);// + money);
			
			//			setDecText(value.desc);
			
			setImage(value);
		}
		
		public function get goodsNum():int
		{
			return num; //*packe_num
		}
		public function get goodsName():String
		{
			return _name;
		}
		public function get cost():String
		{
			return totalCost;
		}
		
		private function setTitle(name:String):void //,value:String
		{
			_nameTf.htmlText =  name ;//+"  " +value;
			//			title = name +"  " +value;
			
		}
		
		private function setImage(obj:Object):void   // obj.url = 图片路径
		{
			if(obj)
			{
				tmp_goods.data = obj;
				
			}
		}
		
		private function setDecText(value:String,textformat:TextFormat=null):void
		{
			//			if(value)
			//				dec_text.text = value;
			//			if(textformat)
			//				dec_text.defaultTextFormat = textformat;
			//			else dec_text.defaultTextFormat = new TextFormat("Arial",12, 0xffffff);
		}
		
		private function setTotalCost(value:String = " 50文"):void
		{
			if(value)
				totalCostText.text = value;
			
			if(TradingModule.getInstance().getBeginBill())
			{
				
			}
			if(int(num*price)>TradingModule.getInstance().getCurrentBill())
			{
				errTip.htmlText = "<font color='#ff0000'> 商票余额不足，不能购买。</font>";
				buyButton.enabled = false;
			}else{
				errTip.htmlText = "";
				buyButton.enabled = true;
				
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if(tmp_goods)
				tmp_goods.dispose();
			
			if(numStep&&numStep.hasEventListener(Event.CHANGE))
			{
				numStep.removeEventListener(Event.CHANGE,onNumChange);
				numStep.removeEventListener(KeyboardEvent.KEY_UP,onBuyEnter);
				buyButton.removeEventListener(MouseEvent.CLICK,onBuyClick);
			}
			
			while(numChildren>0)
			{
				var obj:DisplayObject = getChildAt(0) as DisplayObject;
				
				removeChild(obj);
				obj = null;
			}
		}
		
		
		
	}
}