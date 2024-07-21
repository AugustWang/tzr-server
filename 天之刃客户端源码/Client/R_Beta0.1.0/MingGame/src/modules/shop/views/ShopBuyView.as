package modules.shop.views
{
	import com.common.GlobalObjectManager;
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.NumericStepper;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.shop.ShopConstant;
	import modules.shop.ShopItem;
	import modules.shop.ShopModule;
	
	public class ShopBuyView extends DragUIComponent
	{
		private var _data:ShopItem;
		private var _num:int;
		
		private var numStep:NumericStepper;
		private var imgView:ShopItemImg;
		private var btnBuy:Button;
		private var numTxf:TextField;
		private var nameTxf:TextField;
		private var moneyTxf:TextField;
		private var checkBind:CheckBox;
		
		public function ShopBuyView()
		{
			super();
		}
		
		private static var instance:ShopBuyView;
		
		public static function getInstance():ShopBuyView{
			if (instance == null) {
				instance=new ShopBuyView();
			}
			return instance;
		}
		
		private function upView():void{
			width = 223;
			height = 109;
			Style.setRectBorder(this);
			
			if(!nameTxf){
				nameTxf = ComponentUtil.createTextField("",8,6,new TextFormat("Tahoma",20,0xffffff),175,23,this);
				nameTxf.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
				nameTxf.htmlText = HtmlUtil.font(HtmlUtil.bold(_data.name),_data.colour);
			}else{
				nameTxf.htmlText = HtmlUtil.font(HtmlUtil.bold(_data.name),_data.colour);
			}
			
			if(!imgView){
				imgView = new ShopItemImg();
				imgView.x = 10;
				imgView.y = 35;
				imgView.data = _data;
				addChild(imgView);
			}else{
				imgView.data = _data;
			}
			
			if(!numTxf){
				numTxf = ComponentUtil.createTextField("", 47, 45, null, 28, 20, this);
				numTxf.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
				numTxf.htmlText = "<font color='#F6F5CD'>数量</font>";
			}else{
				numTxf.htmlText = "<font color='#F6F5CD'>数量</font>";
			}
			
			if(!numStep){
				numStep = new NumericStepper();
				numStep.x = 75;
				numStep.y = 43;
				numStep.width = 60;
				numStep.height = 25;
				numStep.textFiled.textField.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
				numStep.textFiled.textField.text = "1";
				numStep.value = 1;
				numStep.maxnum = 200;
				numStep.minnum = 1;
				numStep.addEventListener(Event.CHANGE,onNumChange);
				numStep.addEventListener(KeyboardEvent.KEY_UP,onNumChange);
				numStep.textFiled.setFocus();
				numStep.textFiled.textField.setSelection(0,1);
				addChild(numStep);
				this._num = 1;
			}else{
				numStep.textFiled.setFocus();
				numStep.textFiled.textField.setSelection(0,1);
				numStep.value = 1;
				this._num = 1;
			}
			
			if(!moneyTxf){
				moneyTxf = ComponentUtil.createTextField("", 135, 45, null, 108, 20, this);
				moneyTxf.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
				moneyTxf.htmlText = "<font color='#F6F5CD'>" + _data.calcMoney(this._num) + "</font>";
			}else{
				moneyTxf.htmlText = "<font color='#F6F5CD'>" + _data.calcMoney(this._num) + "</font>";
			}
			
			if(!checkBind){
				checkBind = new CheckBox();
				checkBind.space = 2;
				checkBind.text = "优先使用绑定货币";
				checkBind.x = 10;
				checkBind.y = 78;
				checkBind.textFormat = new TextFormat("Tahoma",12,0xfaf106);
				checkBind.width = 120;
				GlobalObjectManager.getInstance().user.attr.unbund = false;
				ShopModule.getInstance().changeUseGoldType(false);
				checkBind.selected = true;
				addChild(checkBind);
			}
			
			if(!btnBuy){
				btnBuy = ComponentUtil.createButton(ShopConstant.BUY_BUTTON ,160,75,52,25,this)
				Style.setRedBtnStyle(btnBuy);
			}
		}
		
		private function upEventListener():void{
			numStep.addEventListener(Event.CHANGE,onNumChange);
			numStep.addEventListener(KeyboardEvent.KEY_DOWN,onBuyDown);
			btnBuy.addEventListener(MouseEvent.CLICK,onBuyClick);
			checkBind.addEventListener(Event.CHANGE,onSelected);
		}
		
		private function onNumChange(event:Event):void{
			if(!numStep.value){
				numStep.value = 1;
				numStep.stepSize = 1;
				numStep.textFiled.setFocus();
				numStep.textFiled.validateNow();
				numStep.textFiled.textField.setSelection(0,1);
			}
			moneyTxf.htmlText = "<font color='#F6F5CD'>"+ _data.calcMoney(numStep.value) + "</font>";
		}
		
		private function onBuyDown(event:KeyboardEvent):void{
			if(event.charCode == Keyboard.ENTER){
				buyGoods();
			}
		}
		
		private function onBuyClick(event:Event):void{
			buyGoods();
		}
		
		private function onSelected(event:Event):void{
			GlobalObjectManager.getInstance().user.attr.unbund = !checkBind.selected;
			ShopModule.getInstance().changeUseGoldType(!checkBind.selected);
		}
		
		private function buyGoods():void{
			ShopModule.getInstance().toBuyGoods(_data.id,numStep.value,_data.shopId);
			closeView();
		}
		
		override public function set data(vo:Object):void{
			this._data = vo as ShopItem;
			this._num = 1;
			upView();
			upEventListener();
			if(x == 0 && y == 0 && this.parent != null){
				x = (parent.width - width)/2;
				y = (parent.height - height)/2;
			}
			this.showCloseButton = true;
		}
		
		override protected function onCloseHandler(event:MouseEvent):void{
			closeView();
		}
		
		public function showView(useBind:Boolean=true):void{
			WindowManager.getInstance().popUpWindow(this, WindowManager.UNREMOVE);
			this.x = this.stage.mouseX -this.width+38;
			this.y = this.stage.mouseY -this.height+24;
			this.numStep.textFiled.setFocus();
			this.numStep.textFiled.textField.setSelection(0,this.numStep.textFiled.text.length);
			checkBind.selected = useBind;
		}
		
		public function closeView():void{
			if(!this.parent){
				return;
			}else{
				this.parent.removeChild(this);
				WindowManager.getInstance().removeWindow(this);	
			}
		}
	}
} 