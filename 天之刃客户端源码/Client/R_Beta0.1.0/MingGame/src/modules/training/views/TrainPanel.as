package modules.training.views
{
	import com.components.BasePanel;
	import com.components.alert.Prompt;
	import com.globals.GameParameters;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.JSUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.shop.ShopConstant;
	import modules.training.TrainConstant;
	import modules.training.TrainModule;
	
	public class TrainPanel extends BasePanel
	{
		private var _inputX:TextInput;  // 训练 X 小时
		private var _hourTF:TextField;  // "小时"
		private var _pointTF:TextField; //训练点数：
		private var _beginBtn:Button;   // "开始训练"
		private var _costTimeTF:TextField;  // 共计训练 60 * X 分钟
		private var _remainPointTF:TextField;  // "剩余训练点数";
		private var _noEnoughPointTF:TextField; // "训练点数不足" + "?"
		private var _getTrainPointTF:TextField;  // "获得训练点数";
		
		private var _train_desc:TextField;          //训练营介绍
		private var _descContent:TextField ; //介绍内容
		
		private var _tip:TextField;          //
		private var _tipContent:TextField;   
		
		private var _remainPoint:int;  //剩余点数，总共多少点。
		private var _costPoint:int;
		private var _time:int = 1;
		
		private var fillBtn:Button;
		private var timer:Timer;
		
		public function TrainPanel()
		{
			this.width = 324;
			this.height = 294;
			
			title = "闭关修炼";
			addEventListener(Event.ADDED_TO_STAGE,onAddtoStage);
		}
		
		private function onAddtoStage(e:Event):void
		{
			if(_inputX)
			{
				_inputX.setFocus();
				_inputX.validateNow();
				_inputX.textField.setSelection(0,_inputX.text.length);
			}
		}
		
		override protected function init():void
		{	
			var newBg:UIComponent = new UIComponent();
			addChild(newBg);
			newBg.x=7;
			newBg.width=310;
			newBg.height=257;
			Style.setNewBorderBgSkin(newBg);
			
			var trainTF:TextField = createTextField(TrainConstant.TRAIN,18,10,40,21,false);//训练
			addChild(trainTF);
			
			_inputX = new TextInput();
			_inputX.x = 56;
			_inputX.y = 10;
			_inputX.width = 40;
			_inputX.height = 21;
			_inputX.maxChars = 2;
			_inputX.restrict = "0-9";
			_inputX.text = "1";
			addChild(_inputX);
			_inputX.addEventListener(Event.CHANGE, onInputChange);
			
			_hourTF = createTextField(TrainConstant.HOUR,99,10,35,21,false);
			addChild(_hourTF);
			
			_costPoint = TrainConstant.costP_hour();
			_pointTF = createTextField("",139,10,130,22,false);//训练点数：
			_pointTF.htmlText = TrainConstant.TRAIN_POINT + "："+_costPoint.toString();
			addChild(_pointTF);
			
			_beginBtn = new Button();
			_beginBtn.x = 240;
			_beginBtn.y = 10;
			_beginBtn.width = 62;
			_beginBtn.height = 22;
			
			_beginBtn.label = TrainConstant.BEGIN_TRAIN ;
			addChild(_beginBtn);
			_beginBtn.addEventListener(MouseEvent.CLICK, beginTrain);
			
			_costTimeTF = createTextField("",18,48,138,21,false);//"共计训练 " + "60 *"+ X + "分钟";
			addChild(_costTimeTF);
			_costTimeTF.htmlText = TrainConstant.TOTAL_TRAIN + "60 分钟";
			
			//"剩余训练点数" + rmainPoint;
			_remainPointTF = createTextField("",155,48,146,21,false); //TrainConstant.REMAIN_POINT +"：0"
			addChild(_remainPointTF);
			
			_noEnoughPointTF = createTextField(TrainConstant.IS_NOT_ENOUGH + "？",18,82,105,21,false);
			addChild(_noEnoughPointTF);
			
			_getTrainPointTF = createTextField("",125,82,106,21,false);
			_getTrainPointTF.htmlText = "<font color='#ffff00'><u><a href= 'event:getPoint'>" +
				 TrainConstant.GET_TRAIN_POINT +"</a></u></font>";
			addChild(_getTrainPointTF);
			_getTrainPointTF.addEventListener(TextEvent.LINK,onOpenGetPoint);
			
			
			fillBtn = ComponentUtil.createButton(ShopConstant.FILL_BUTTON,234,80,66,25,this,null,addFillListen);
			fillBtn.textColor = 0xffff00;
			//			Style.setDeepRedBtnStyle(fillBtn);
			Style.setRedButtonStyle(fillBtn);
			timer = new Timer(400);
			timer.addEventListener(TimerEvent.TIMER,onflash);
			timer.start();
			
			_train_desc = createTextField("",20,160-40,106,22,false);
			_train_desc.htmlText = TrainConstant.TRAIN_DESC;
			addChild(_train_desc);
			//20  160
			_descContent = createTextField("",20,182-40,290,40,false);
			_descContent.wordWrap = true;
			_descContent.multiline = true;
			_descContent.htmlText = TrainConstant.DESC_CONTENT;
			addChild(_descContent);
			
			_tip = createTextField("",20,182,290,22,false); 
			_tip.htmlText = TrainConstant.TIP_DESC;
			addChild(_tip);
			
			_tipContent = createTextField("",20,204,290,40,false); 
			_tipContent.wordWrap = true;
			_tipContent.multiline = true;
			_tipContent.htmlText = TrainConstant.TIP_CONTENT;
			addChild(_tipContent);
			
		}
		
		private function onflash(e:TimerEvent):void
		{
			var count:int = timer.currentCount;
			if(count%2==0)
			{
				fillBtn.textColor = 0xFFFF00;
			}else{
				
				fillBtn.textColor = 0xFF9600;  //FFFF00
			}
		}
		private function addFillListen(btn:Button):void
		{
			btn.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			btn.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			btn.addEventListener(MouseEvent.CLICK,onFillHandler);
		}
		
		private function onMouseOver(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().show("充值比例 1：10");
		}
		private function onMouseOut(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		private function onFillHandler(evt:MouseEvent):void
		{
			JSUtil.openPaySite();	
		}
		
		
		private var _trainYBUI:TrainYBUI;
		private function onOpenGetPoint(e:TextEvent):void
		{
			
			
			if(!_trainYBUI)
			{
				_trainYBUI = new TrainYBUI();
				_trainYBUI.x = this.x+10;
				_trainYBUI.y = this.y + 95;
				
				WindowManager.getInstance().openDialog(_trainYBUI,false);
				
				_trainYBUI.addEventListener(CloseEvent.CLOSE, onCloseYBUI);
			}
//			if(!WindowManager.getInstance().isPopUp(_trainYBUI))
//				WindowManager.getInstance().popUpWindow(_trainYBUI);
			
			_trainYBUI.setNeedPoint(_costPoint - _remainPoint);
			
		}
		
		public function closeYBUI():void
		{
			onCloseYBUI();
		}
		
		private function onCloseYBUI(e:CloseEvent = null):void
		{
			if(_trainYBUI)
			{
				WindowManager.getInstance().closeDialog(_trainYBUI);
				_trainYBUI.dispose();
//				if(WindowManager.getInstance().isPopUp(_trainYBUI))
//					WindowManager.getInstance().removeWindow(_trainYBUI);
				_trainYBUI = null;
			}
		}
		
//		override protected function closeHandler(event:CloseEvent=null):void
//		{
//			
//		}
		
		public function initData(point:int):void
		{
			_remainPoint = point;
			_remainPointTF.htmlText = TrainConstant.REMAIN_POINT + "：<font color='#ffff00'>"+_remainPoint+"</font>";
			
			setCostText();
			
		}
		public function addPoint(addPoint:int):void
		{
			_remainPoint += addPoint;
			_remainPointTF.htmlText = TrainConstant.REMAIN_POINT + "：<font color='#ffff00'>"+_remainPoint+"</font>";
			setCostText();
		}
		
		
		private function onInputChange(e:Event):void
		{
			var inputNum:int;
			if(_inputX.text == ""||_inputX.text == "0")
			{
				
				inputNum = 1;
				_inputX.text = "1";
				
				_inputX.validateNow();
				_inputX.textField.setSelection(0,1);
				
			}else{
				inputNum = int(_inputX.text);
				if(inputNum > 24)
				{
					inputNum = 24;
					_inputX.text = "24";
				}
			}
			
			_time = inputNum;
			_costPoint = _time * TrainConstant.costP_hour();//TrainConstant.COST_PER_HOUR;
			
			setCostText();
			
//			salaryTime = time;
		}
		
		private function setCostText():void
		{
			_costTimeTF.htmlText = TrainConstant.TOTAL_TRAIN + "<font color='#ffff00'>"+ String(60*_time) +"</font> 分钟"
				
			if(_costPoint<=_remainPoint)
			{
				_pointTF.htmlText = TrainConstant.TRAIN_POINT + "：<font color='#0bf80a'>" + _costPoint +"</font>";
				_beginBtn.enabled = true;
				
//				_getTrainPointTF.visible = false;
			}else{
				_pointTF.htmlText = TrainConstant.TRAIN_POINT + "：<font color='#84151b'>" + _costPoint +"</font>";
				
//				_pointTF.text +=  "<font color='#ff0000'>" + _costPoint +"</font>";
				_beginBtn.enabled = false;
//				_getTrainPointTF.visible = true;
			}
		}
		
		private function beginTrain(e:MouseEvent):void
		{
			if(_costPoint>_remainPoint)
			{
				Prompt.show("训练点不足！","提示：",null,null,"确定","",null,false);
				return;
			}
			
			TrainModule.getInstance().startTrain(_time);
		}
		
		private function createTextField(text:String,x:int,y:int,width:int,height:int,selectable:Boolean,textFormat:TextFormat=null):TextField
		{
			var textField:TextField = new TextField();
			textField.x = x;
			textField.y = y;
			textField.width = width;
			textField.height = height;
			textField.selectable = selectable;
			if(textFormat!=null)
			{
				textField.defaultTextFormat = textFormat;
			}else
			{
				textField.defaultTextFormat = getDefaultFormat();
			}
			textField.text = text;
			return textField;
		}
		
		private function getDefaultFormat():TextFormat
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Verdana";
			textFormat.size = 12;
			textFormat.color = 0xece8bb;
			return textFormat;
		}
		
		override public function dispose():void
		{
			super.dispose();
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,onflash);
				timer = null;
			}
		}
		
	}
}