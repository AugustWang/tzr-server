package modules.bank.views
{
	import com.common.GlobalObjectManager;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.bank.BankConstant;
	import modules.bank.BankModule;
	import modules.broadcast.views.Tips;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	public class SalePanel extends BasePanel
	{
		private var _ybPriceTI:TextInput;
		private var _ybNumTI:TextInput;
		private var _payTI:TextInput;
		private var _sureBtn:Button;
//		private var _cancelBtn:Button;
		
		private var _priceTxt:TextField;
		private var _feeTxt:TextField;
		private var _totalTxt:TextField;
		
		
		private var _priceTxtIpt:TextInput;
		private var _numTxtIpt:TextInput;
		private var _moneyTxt:TextField;
		
		private var _moneyTxtIpt:TextInput;
		
		private var sumNum:int = 0;
		private var price:int=0;
		private var num:int =0;
		private var fee:int = 0;  //  price * num * 1% = fee 
		
		public function SalePanel()
		{
			super();
			this.width = 278;
			this.height = 198;//195;
			this.titleAlign = 2;
			this.title = "卖出元宝";
			
			initView();
			
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			if(_numTxtIpt)
			{
				_numTxtIpt.setFocus();
				_numTxtIpt.validateNow();
				
			}
		}
		
		private function initView():void
		{
			addContentBG(30,5);
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xAFE1EC);//Style.themeTextFormat;
			tf.align = "right";
			
			var numtxt:TextField = ComponentUtil.createTextField("卖      出：",16,22,tf,60,20,this);
			var ybpricetxt:TextField = ComponentUtil.createTextField("卖出单价：",16,50,tf,60,20,this);
			var paytxt:TextField = ComponentUtil.createTextField("可 获 得：",16,78,tf,60,20,this);
			
			_numTxtIpt = createinputtext(76,20,123,NaN,this);
			_numTxtIpt.maxChars = 8;
			_numTxtIpt.addEventListener(Event.CHANGE, onNumChange);
			
			_priceTxtIpt = createinputtext(76,47,123,NaN,this);
			_priceTxtIpt.maxChars = 5;
			_priceTxtIpt.addEventListener(Event.CHANGE, onPriceChange);
			
			
			
//			_moneyTxtIpt = createinputtext(88,76,144,NaN,this,false);
			_moneyTxt = ComponentUtil.createTextField("",76,78,Style.textFormat,180,40,this);
			_moneyTxt.wordWrap = _moneyTxt.multiline = true;
			_moneyTxt.mouseEnabled = true;
//			_moneyTxt.selectable = false ;
			_moneyTxt.addEventListener(MouseEvent.MOUSE_OVER, onShowTips);
			_moneyTxt.addEventListener(MouseEvent.MOUSE_OUT, onHideTips);
			
			//43  111   77
			
			var YBtxt:TextField = ComponentUtil.createTextField("元宝",200,22,Style.themeTextFormat,54,20,this);
			var Silvertxt:TextField = ComponentUtil.createTextField("两银子",200,50,Style.themeTextFormat,54,20,this);
			
			
			
			_sureBtn = ComponentUtil.createButton("卖出元宝",91,129,93,25,this);
			_sureBtn.addEventListener(MouseEvent.CLICK,sumitFunc);
			
//			_cancelBtn = ComponentUtil.createButton("取消",168,111,77,25,this);
//			_cancelBtn.addEventListener(MouseEvent.CLICK,onCancel);
			
			
			
		}
		
		public function setUnitPrice(value:int):void   // 文 转两
		{
			if(value>0)
			{
				price = value;
				_priceTxtIpt.text = int(price/100)+"";
				
				_priceTxtIpt.textField.mouseEnabled= _priceTxtIpt.textField.selectable= false;
			}
		}
		public function  setYBSumNum(YBNum:int):void
		{
			sumNum = YBNum;
			
		}
		
		
		private function onShowTips(e:MouseEvent):void
		{
			var str:String="";
//			var costMoney:int = price * num - price * num * BankConstant.FEERATE;
//			_moneyTxt.text = MoneyTransformUtil.silverToOtherString(costMoney); 
			
			if(price>0&&num>0)
			{
				str = "获得："+ MoneyTransformUtil.silverToOtherString(Number(price * num)) + "\n" +
					"扣手续费："+
					MoneyTransformUtil.silverToOtherString(price * num * BankConstant.FEERATE);
				ToolTipManager.getInstance().show(str); //,100,0,0,"goodsToolTip"
			}
			
		}
		private function onHideTips(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
			
		private function onNumChange(e:Event):void
		{
			if(_numTxtIpt.text == ""||_numTxtIpt.text == "0")
			{
				num = 0;
				
			}else{
				
				num = int(_numTxtIpt.text);
				if(BankModule.getInstance().selfSaleArr.length>=5 && num>sumNum)
				{
					num = sumNum;
					_numTxtIpt.text = num+"";
				}
			}
			
//			if(price >0)
			setMoneyTxt();
		}
		
		private function onPriceChange(e:Event):void
		{
			if(_priceTxtIpt.text == ""||_priceTxtIpt.text == "0")
			{
				price = 0;
			}else{
				
				price = int(_priceTxtIpt.text) * 100;
			}
			if(num>0)
				setMoneyTxt();
		}
		private function setMoneyTxt():void
		{
			var costMoney:Number = Number(price * num) - price * num * BankConstant.FEERATE;
			var YBnum:Number = Number(GlobalObjectManager.getInstance().user.attr.gold);
			var noenough:String = "";
			
			if(num>YBnum)
			{
				_sureBtn.enabled = false;
				noenough = "<font color='#f53f3c'>(元宝不足)</font>";
			}else
			{
				_sureBtn.enabled = true;
			}
			_moneyTxt.htmlText = MoneyTransformUtil.silverToOtherString(costMoney)+noenough; 
		}
		
		
		private function sumitFunc(e:MouseEvent):void
		{
//			BankModel.getInstance().submitFn(num,price);
			if(price==0||num==0)
			{
				
				Alert.show("数量或单价都不能为0","提示",null,null,"确定","",null,false);
				return;
			}
			
			if(sumNum==0)
				sumNum = num;
			BankModule.getInstance().saleHandler(price,num,sumNum);
		}
		
//		private function onCancel(e:MouseEvent):void
//		{
//			
//			this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
//		}
		
		private function createinputtext(x:int,y:int,width:int,height:int=NaN,parent:DisplayObjectContainer=null,mouseEnabled:Boolean=true):TextInput
		{
			var txtInput:TextInput = new TextInput();
			txtInput.restrict = "0-9";
			txtInput.x = x;
			txtInput.y = y;
			txtInput.width = width;
			if(txtInput)
				txtInput.height = height;
			
			txtInput.textField.mouseEnabled= txtInput.textField.selectable=mouseEnabled;
			addChild(txtInput);
			
			return txtInput;
		}
		
		public function clear():void
		{
			
			_priceTxtIpt.textField.mouseEnabled= _priceTxtIpt.textField.selectable= true;
			_sureBtn.enabled = true;
			_numTxtIpt.text = "";
			_priceTxtIpt.text = "";
			_moneyTxt.htmlText = "";
			price = 0;
			num = 0;
			sumNum=0;
		}
	}
}