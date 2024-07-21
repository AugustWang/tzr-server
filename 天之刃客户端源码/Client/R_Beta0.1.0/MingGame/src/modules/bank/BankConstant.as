package modules.bank
{
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.ToggleButton;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import flashx.textLayout.formats.TextAlign;
	
	import modules.bank.views.BankItRender;
	import modules.bank.views.BankItemRender;
	import modules.bank.views.BankList;
	import modules.bank.views.BankSaleItemRender;

	public class BankConstant
	{
		/*钱庄的排列   (家奇确认)
			左上  从高到低   左下 低到高
			右上  低到高     右下 高到低
		*/
		public static var OPEN_BANK_PANEL_TEST:int = 4444; 
		public static var OPEN_BANK_PANEL:String = "OPEN_BANK_PANEL";
		
		public static var PERSON:String = "PERSON";
		public static var MARKET:String = "MARKET";
		
		public static var BANK:String = "BANK";
		public static var BANK_INIT:String = "BANK_INIT";
		public static var BANK_SELL_REQUEST:String = "BANK_SELL_REQUEST";
		public static var BANK_BUY_REQUEST:String = "BANK_BUY_REQUEST";
		public static var BANK_SELL:String = "BANK_SELL";
		public static var BANK_BUY:String = "BANK_BUY";
		public static var BANK_UNDO:String = "BANK_UNDO";
		public static var BANK_ADD_SILVER:String = "BANK_ADD_SILVER";
		public static var BANK_ADD_GOLD:String = "BANK_ADD_GOLD";
		
		public static var BANK_TO_BUY:int = 0;
		public static var BANK_TO_SALE:int = 1;
		
		public static var FEERATE:Number = 0.02;
		
		public static var SELF_SALE:int = 1;
		public static var SELF_BUY:int = 2;
		public static var MARKET_SALE:int = 3;
		public static var MARKET_BUY:int = 4;
		
		public static var GOLD:String = "GOLD";
		public static var SILVER:String = "SILVER";
		public static var GOLD_SILVER:String = "GOLD_SILVER";
		
		public static var selfNameArr:Array =["个人委托","元宝单价","元宝数量","操作"];
		public static var martNameArr:Array = ["市场委托","元宝单价","元宝数量","操作"];
		
		public static function createBankList(xPos:int,yPos:int,listHeight:Number,showListHeader:Boolean,parent:DisplayObjectContainer=null,itemClickHandler:Function=null,listType:String="PERSON"):BankList
		{
			var bankList:BankList = new BankList(listType);
			
			bankList.showListHeader = showListHeader;
			if(listType == PERSON)
			{
				if(showListHeader)
				{
					bankList.itemRender = BankItemRender;
				}else
				{
					bankList.itemRender = BankSaleItemRender;
				}
			}else {
				
				bankList.itemRender = BankItRender;
			}
			bankList.verticalScrollPolicy = ScrollPolicy.OFF;
			bankList.itemHeight = 17;
			bankList.listWidth = 254;
			bankList.listHeight = listHeight;
			bankList.setupUI();
			bankList.x = xPos;
			bankList.y = yPos;
			parent.addChild(bankList);
			bankList.list.addEventListener(ItemEvent.ITEM_CLICK,itemClickHandler);
			return bankList;
		}
		
		public static function createTextField(text:String,xPos:int,yPos:int,width:int,height:int,textFormat:TextFormat=null,parent:DisplayObjectContainer=null,centerFlag:Boolean=true):TextField
		{
			var textField:TextField = new TextField();
			if(centerFlag)
			{
				textField.autoSize = TextAlign.CENTER;
			}
			textField.selectable = false;
			textField.defaultTextFormat = textFormat?textFormat:new TextFormat("Tahoma",12,0xFFFFFF);
			textField.text = text;
			textField.x = xPos;
			textField.y = yPos;
			textField.width = width;
			textField.height = height;
			if(parent)
				parent.addChild(textField);
			return textField;
		}
		
		
		
		public static function createSystemTextInput(xPos:int,yPos:int,width:int,height:int,textFormat:TextFormat=null,parent:DisplayObjectContainer=null):TextInput
		{
			var textInput:TextInput = new TextInput();
//			textInput.bgSkin = Style.getSkin("dealTipBg",GameConfig.T1_UI,new Rectangle(2,2,44,14));
			textInput.enabled = false;
			textInput.textField.defaultTextFormat = textFormat?textFormat:new TextFormat("Tahoma",12,0xFFFFFF);
			textInput.textField.autoSize = TextFormatAlign.CENTER;
			textInput.x = xPos;
			textInput.y = yPos;
			textInput.width = width;
			textInput.height = height;
			if(parent)
				parent.addChild(textInput);
			return textInput;
		}
		
		public static function createTextInput(xPos:int,yPos:int,width:Number,height:Number,parent:DisplayObjectContainer=null,restrict:String='0-9',maxChars:Number=4,enabled:Boolean=true):TextInput
		{
			var textInput:TextInput = new TextInput();
			textInput.enabled = enabled
			textInput.maxChars = maxChars;
			textInput.x = xPos;
			textInput.y = yPos;
			textInput.width = width;
			textInput.height = height;
			textInput.restrict = restrict;
			if(parent)
				parent.addChild(textInput);
			return textInput;
		}
		
		public static function createButton(label:String,xPos:Number,yPos:Number,width:Number,height:Number,handler:Function,parent:DisplayObjectContainer=null,isToggle:Boolean=false):*
		{
			var button:*
			if(!isToggle)
			{
				button = new Button();
			}else
			{
				button= new ToggleButton();
			}
			button.label = label;
			button.x = xPos;
			button.y = yPos;
			button.width = width;
			button.height = height;
			button.addEventListener(MouseEvent.CLICK,handler);
			if(parent)
				parent.addChild(button);
			return button
		}
		
		public static function wrapperParam(moduleName:String,method:String,vo:Object):Object
		{
			return {module:moduleName,method:method,vo:vo};
		}
		
		public static function wrapperUpdateObj(voType:int,source:Array):Object
		{
			var object:Object = new Object();
			object.voType = voType;
			object.source = source;
			return object;
		}
		
		public static function wrapperSendObj(moneyType:String,moneyNum:int):Object
		{
			var object:Object = new Object();
			object.moneyType = moneyType;
			object.moneyNum = moneyNum;
			return object;
		}
		
		public static function wrapperSendObject(moneyTyep:String,gold:int,silver:int):Object
		{
			var object:Object = new Object();
			object.moneyType = moneyTyep;
			object.gold = gold;
			object.silver = silver;
			return object;
		}
		
	}
}