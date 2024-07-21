package modules.bank.views
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.bank.BankConstant;
	import modules.bank.BankModule;
	
	public class BankPanel extends BasePanel
	{
		public static const BANKPANEL:String = "BANKPANEL";
		public function BankPanel()
		{
			super(BANKPANEL);
		}
		
		private var _timer:Timer;
		override protected function init():void
		{
			this.width = 548;//560;//538//533;
			this.height = 400;//425;
			
			title = "货币交易所";
			addContentBG(5,5);
			
			_timer = new Timer(15000);
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			if(_moneyNumTI)
			{
				_moneyNumTI.setFocus();
				_moneyNumTI.validateNow();
				_moneyNumTI.textField.setSelection(0,1);
			}
		}
		
		private var _personSaleBankList:BankList;
		private var _personBuyBankList:BankList;
		private var _marketSaleBankList:BankList;
		private var _marketBuyBankList:BankList;
		private var _selfSaleArr:Array;
		private var _selfBuyArr:Array;
		private var _marketSaleArr:Array;
		private var _marketBuyArr:Array;
		
		private var _moneyNumTF:TextField;
		private var _moneyNumTI:TextInput;
		private var _unitPriceTF:TextField;
		private var _unitPriceTI:TextInput;
		private var _moneyTF1:TextField;
		private var _moneyTF2:TextField;
		private var _moneyTF3:TextField;
		private var _sumPriceTF:TextField;
		private var _sumPriceTI:TextInput;
		private var _feeTF:TextField;
		private var _feeTI:TextInput;
		private var _submitBtn:Button;
		
		private var _buyBtn:Button;
		private var _saleBtn:Button;
		private var _tipsForBankTF:TextField;
	
		private var _selfBg:UIComponent;
		private var _marketBbg:UIComponent;  // buy bg 
		private var _marketSbg:UIComponent;  // sale bg
		private var _formBg:UIComponent;
		
		private var line:Bitmap;
		private var desc_txt:TextField;
		
		private var preIndex:int = 0;
		
		public function setupUI():void
		{
			
			_selfBg = ComponentUtil.createUIComponent(8,7,270,256);//13,4,254,205
			Style.setBorderSkin(_selfBg);
			addChild(_selfBg);
			
			line = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.x = 2;//9;
			line.y = 120;
			line.width = 248;//251;
			line.height = 2;
			_selfBg.addChild(line);
			line.visible = false ;
			
			var $textFormat:TextFormat = new TextFormat();
			$textFormat.color = 0xcce644;
			$textFormat.font = "Tahoma";
			$textFormat.leading = 8;
			desc_txt = ComponentUtil.createTextField("可以直接点击右边的挂单进行交易",33,112,$textFormat,190,22,_selfBg);
			desc_txt.visible = false;
			
			_formBg = ComponentUtil.createUIComponent(_selfBg.x,_selfBg.y + _selfBg.height +3,_selfBg.width,80);//new UIComponent();
			Style.setBorderSkin(_formBg);
			addChild(_formBg);
			
			_saleBtn = ComponentUtil.createButton("卖出元宝",30,230,92,25,this);
			_saleBtn.addEventListener(MouseEvent.CLICK, salseFun);
			
			_buyBtn = ComponentUtil.createButton("买入元宝",142,230,92,25,this);
			_buyBtn.addEventListener(MouseEvent.CLICK, buyFun);
			
			
			var tips:String = "市场交易为玩家自发行为，价格会出现较大波动，交易双方风险自负。\n钱庄提供交易市场，仅收取2%手续费。"
			_tipsForBankTF = new TextField();
			_tipsForBankTF.multiline = true; 
			_tipsForBankTF.wordWrap = true;
			_tipsForBankTF.selectable = false;
			
			_tipsForBankTF.defaultTextFormat=$textFormat;
			_tipsForBankTF.x = 4;
			_tipsForBankTF.y = 10;
			_tipsForBankTF.width = 239;
			_tipsForBankTF.height = 80;
			_tipsForBankTF.text = tips;
			_formBg.addChild(_tipsForBankTF);
			
//  -------------------------------------market----------------------------------------//
			
			_marketBbg = ComponentUtil.createUIComponent(279,_selfBg.y,262,168);//new UIComponent();
			Style.setBorderSkin(_marketBbg);
			addChild(_marketBbg);
			
			_marketSbg = ComponentUtil.createUIComponent(279,_selfBg.y +_marketBbg.height +3,262,168);//new UIComponent();
			Style.setBorderSkin(_marketSbg);
			addChild(_marketSbg);
			
			_timer.addEventListener(TimerEvent.TIMER,reFreshDataFn);
			_timer.start();
			_personSaleBankList = BankConstant.createBankList(11,7,90,true,this,itemClickFn);
			_personBuyBankList = BankConstant.createBankList(11,127,90,false,this,itemClickFn);
			_marketSaleBankList = BankConstant.createBankList(283,7,128,true,this,itemClickFn,BankConstant.MARKET);
			_marketBuyBankList = BankConstant.createBankList(283,177,128,false,this,itemClickFn,BankConstant.MARKET);
			
			
			_personSaleBankList.list.dataProvider = _selfSaleArr;
			_personBuyBankList.list.dataProvider = _selfBuyArr;
			_marketSaleBankList.list.dataProvider = _marketSaleArr;
			_marketBuyBankList.list.dataProvider = _marketBuyArr;
			
			if(_selfSaleArr.length>0 || _selfBuyArr.length>0)
			{
				line.visible = true ;
				desc_txt.visible = false;
			}else{
				
				desc_txt.visible = true;
				
				line.visible = false ;
			}
			
		}
		
		
		private var _saleCancelFn:Function;
		private var _buyCancelFn:Function;
		private var _buyFn:Function;
		private var _saleFn:Function;
		private var _submitFn:Function;
		private var _itemClickFn:Function;
		private var _reFreshDataFn:Function;
		private var _salseFunc:Function;
		private var _buyFunc:Function;
		
		
		public function set saleCancelFn(fn:Function):void
		{
			_saleCancelFn = fn;
		}
		
		public function get saleCancelFn():Function
		{
			return _saleCancelFn;
		}
		
		public function set buyCancelFn(fn:Function):void
		{
			_buyCancelFn = fn;
		}
		
		public function get buyCancelFn():Function
		{
			return _buyCancelFn;
		}
		
		
		public function set buyFn(fn:Function):void
		{
			_buyFn = fn;
		}
		
		public function get buyFn():Function
		{
			return _buyFn;
		}
		
		public function set saleFn(fn:Function):void
		{
			_saleFn = fn;
		}
		
		public function get saleFn():Function
		{
			return _saleFn;
		}
		
		public function set submitFn(fn:Function):void
		{
			_submitFn = fn
		}
		
		public function get submitFn():Function
		{
			return _submitFn;
		}
		
		public function set salseFunc(func:Function):void
		{
			_salseFunc = func;
		}
		
		public function get salseFunc():Function
		{
			return _salseFunc;
		}
		
		
		private function salseFun(evt:MouseEvent):void
		{
			BankModule.getInstance().popUpSalePanel();
		}
		private function buyFun(evt:MouseEvent):void
		{
			BankModule.getInstance().popUpBuyPanel();
		}
			
		
		public function set buyFunc(func:Function):void
		{
			_buyFunc = func
		}
		
		public function get buyFunc():Function
		{
			return _buyFunc;
		}
		
		public function set itemClickFn(fn:Function):void
		{
			_itemClickFn = fn;
		}
		
		public function get itemClickFn():Function
		{
			return _itemClickFn;
		}
		
		public function set reFreshDataFn(fn:Function):void
		{
			_reFreshDataFn = fn
		}
		
		public function get reFreshDataFn():Function
		{
			return _reFreshDataFn;
		}
		
		public function get num():int
		{
			return int(_moneyNumTI.text)
		}
		
		public function get unitPrice():int
		{
			return int(_unitPriceTI.text) * 100;
		}
		
		
		public function setDataSource(value1:Array,value2:Array,value3:Array,value4:Array):void
		{
			_selfSaleArr = wrapperSelfSaleArr(value1);
			_selfBuyArr = wrapperSelfBuyArr(value2);
//			BankModel.getInstance().selfBuyArr = value1;//_selfBuyArr;
//			BankModel.getInstance().selfSaleArr = value2;//_selfSaleArr;
			
			_marketSaleArr = wrapperMarketSaleArr(value3);
			_marketBuyArr = wrapperMarketBuyArr(value4);
			
			if(line)
			{
				if(BankModule.getInstance().selfBuyArr.length>0 || BankModule.getInstance().selfSaleArr.length)
				{
					
					line.visible = true ;
					desc_txt.visible = false;
					
				}else{
					
					line.visible =false  ;
					desc_txt.visible = true;
				}
			}
		}
		
		public function reFreshDataSource(value1:Array,value2:Array,value3:Array,value4:Array):void
		{
			if(!_timer.hasEventListener(TimerEvent.TIMER))
			{
				_timer.addEventListener(TimerEvent.TIMER,reFreshDataFn);
			}
			_timer.start();
			_personSaleBankList.list.dataProvider = wrapperSelfSaleArr(value1);
			_personBuyBankList.list.dataProvider = wrapperSelfBuyArr(value2);
			_marketSaleBankList.list.dataProvider = wrapperMarketSaleArr(value3);			
			_marketBuyBankList.list.dataProvider = wrapperMarketBuyArr(value4);
			
			_personSaleBankList.list.validateNow();
			_personBuyBankList.list.validateNow();
			_marketSaleBankList.list.validateNow();
			_marketBuyBankList.list.validateNow();
			
			if(line)
			{
				if(_personSaleBankList.list.dataProvider.length>0 || _personBuyBankList.list.dataProvider.length)
				{
					line.visible = true ;
					desc_txt.visible = false;
					
				}else{
					
					line.visible =false  ;
					desc_txt.visible = true;
				}
			}
			
		}
		
		private function wrapperSelfSaleArr(value:Array):Array
		{
			var sourceArr:Array = [];
			for(var i:int=0;i<value.length;i++)
			{
				var object:Object = new Object();
				object.id = i;
				object.name = "卖"+ (i+1);//"出售价"+ (value.length-i);
				object.operate = "<U>撤单</U>"; //<B></B>
				object.callBackHandler = saleCancelFn;
				object.sheet = value[i];
				sourceArr.push(object);
			}
			return sourceArr;
		}
		
		private function wrapperSelfBuyArr(value:Array):Array
		{
			var sourceArr:Array = [];
			for(var i:int=0;i<value.length;i++)
			{
				var object:Object = new Object();
				object.id = i;
				object.name ="买"+ (i+1); //"求购价"+ (i+1);
				object.operate = "<U>撤单</U>";
				object.callBackHandler = buyCancelFn;
				object.sheet = value[i];
				sourceArr.push(object);
			}
			return sourceArr;
		}
		
		private function wrapperMarketSaleArr(value:Array):Array
		{
			var sourceArr:Array = [];
			for(var i:int=0;i<value.length;i++)
			{
				var object:Object = new Object();
				object.id = i;
				object.name = "出售价"+ (value.length-i);//卖
				object.operate = "<U>买入</U>";// <B></B> 购买
				object.callBackHandler = buyFn;
				object.sheet = value[i];
				sourceArr.push(object);
			}
			return sourceArr;
		}
		
		private function wrapperMarketBuyArr(value:Array):Array
		{
			var sourceArr:Array = [];
			for(var i:int=0;i<value.length;i++)
			{
				var object:Object = new Object();
				object.id = i;
				object.name = "求购价"+ (i+1);//买
				object.operate = "<U>卖出</U>"; //出售
				object.callBackHandler = saleFn;
				object.sheet = value[i];
				sourceArr.push(object);
			}
			return sourceArr;
		}
		
		public function updateDataSource(obj:Object):void
		{
			switch(obj.voType)
			{
				case BankConstant.SELF_SALE:
						_personSaleBankList.list.dataProvider = wrapperSelfSaleArr(obj.source);
						break;
				case BankConstant.SELF_BUY:
						_personBuyBankList.list.dataProvider = wrapperSelfBuyArr(obj.source);
						break;
				case BankConstant.MARKET_SALE:
						_marketSaleBankList.list.dataProvider = wrapperMarketSaleArr(obj.source);			
						break;
				case BankConstant.MARKET_BUY:
						_marketBuyBankList.list.dataProvider = wrapperMarketBuyArr(obj.source);
						break
				default:break;
			}
			if(line)
			{
				if(_personSaleBankList.list.dataProvider.length>0 || _personBuyBankList.list.dataProvider.length)
				{
					line.visible = true ;
					desc_txt.visible = false;
					
				}else{
					
					line.visible =false  ;
					desc_txt.visible = true;
				}
			}
		}
		
		private var _failTipTF:TextField;
		public function setFailTip(value:String):void
		{
			if(!failTipTF)
			{
				var textFormat:TextFormat = new TextFormat(null,12,0xFF0000);
				failTipTF = BankConstant.createTextField(value,22,_feeTI.y+22,130,38,textFormat,this,false);
				failTipTF.wordWrap = true;
				failTipTF.multiline = true;
			}else
			{
				failTipTF.text = value;
			}
		}
		
		public function set failTipTF(value:TextField):void
		{
			_failTipTF = value
		}
		
		public function get failTipTF():TextField
		{
			return _failTipTF;
		}
		
		private function resetText():void
		{
			if(_failTipTF)
			{
				_failTipTF.text = ''
			}
			_moneyNumTI.text = '1';
			_unitPriceTI.text = '';
			_sumPriceTI.text = '';
			_feeTI.text = '';
			_moneyNumTI.setFocus();
			_moneyNumTI.validateNow();
			_moneyNumTI.textField.setSelection(0,1);
		}
		
		private function clear():void
		{
			if(_failTipTF)
			{
				_failTipTF.text = ''
			}
//			_moneyNumTI.text = '1';
//			_unitPriceTI.text = '';
//			_sumPriceTI.text = '';
//			_feeTI.text = '';
//			
			var salePanel:SalePanel = BankModule.getInstance().salePanel
			if(salePanel)
			{
				salePanel.closeWindow();				
			}
			
			var buyPanel:BuyPanel = BankModule.getInstance().buyPanel;
			if(buyPanel)
			{
				buyPanel.closeWindow();
			}
		}
		
		override protected function closeHandler(event:CloseEvent=null):void
		{
			super.closeHandler();
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER,reFreshDataFn);
			clear();
		}
	}
}