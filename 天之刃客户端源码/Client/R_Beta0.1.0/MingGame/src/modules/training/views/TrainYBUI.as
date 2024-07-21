package modules.training.views
{
	import com.common.GlobalObjectManager;
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.training.TrainConstant;
	import modules.training.TrainModule;
	
	public class TrainYBUI extends DragUIComponent
	{
		private var needTxt:TextField;
		private var yesBtn:Button;
		private var noBtn:Button;
		
		/////////
		private var nameTf:TextField;
		private var duihuan_tf:TextField;
		private var tipTf:TextField;
		private var buyButton:Button;
		private var numStep:NumericStepper;
		private var exchagePointTf:TextField;
		private var costTF:TextField;
		
		private var needYB:int;
		private var _needPoint:int;
		
		public function TrainYBUI()
		{
			super();
			
			this.width = 228;//310;
			this.height = 110;//191;
			Style.setRectBorder(this);
			this.showCloseButton = true;
			
			var closeBtn:UIComponent = new UIComponent();
			closeBtn.x = 199;// 282;
			closeBtn.y = 2;//6;
			
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 222;
			line.height = 2;
			line.x = 3;
			line.y = 28;
			addChild(line);
			
			init();
		}
		override protected function onCloseHandler(event:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
		}
		
		private function init():void
		{
			
			var tf:TextFormat = new TextFormat("Tahoma",14,0xF6F5CD);
			nameTf = ComponentUtil.createTextField(TrainConstant.EXCHANGE_TRAIN_POINT,8,4,tf,175,23,this);
			
			var txtformat:TextFormat = Style.textFormat;//new TextFormat("Tahoma",12,0xffffff);
			duihuan_tf = ComponentUtil.createTextField(TrainConstant.EXCHANGE_BTN,8,30,txtformat,66,22,this);
			
			numStep = new NumericStepper();
			numStep.x = 42;
			numStep.y = 30;//82;
			//			numStep.bgSkin = Style.getInstance().numericStepperSkin;
			numStep.maxnum = 10000;
			numStep.minnum = 1;
			numStep.stepSize = 1;
			numStep.textFiled.textField.defaultTextFormat = txtformat;
			numStep.value = 1;
			numStep.width = 78;// 70;
			
			addChild(numStep);
			numStep.addEventListener(Event.CHANGE,onNumChange);
			numStep.addEventListener(KeyboardEvent.KEY_UP,onBuyEnter);
			
			
			
			exchagePointTf = ComponentUtil.createTextField("元宝",126,30,txtformat,175,22,this);
			
			costTF = ComponentUtil.createTextField("",8,55,txtformat,175,22,this);
			costTF.htmlText = "兑换10点训练点";
			
			
			tipTf =  ComponentUtil.createTextField("",8,80,txtformat,175,22,this);
//			tipTf.htmlText = "<font color='#ff0000'>元宝不足。<font>";
			
			buyButton = ComponentUtil.createButton("兑换",158,80, 55,22, this); //new Button();
			Style.setRedBtnStyle(buyButton);
			
			buyButton.addEventListener(MouseEvent.CLICK,onBuyClick);
			
//			needYB = 1;
//			checkYbEnough();
		}
		
		private function onNumChange(evt:Event):void
		{
			if(!numStep.value)//== NaN
			{
				numStep.value = 1;
				numStep.stepSize = 1;
				numStep.textFiled.setFocus();
				numStep.textFiled.validateNow();
				numStep.textFiled.textField.setSelection(0,1);
			}
			needYB = numStep.value;//int((numStep.value-1)/10)+1;
			_needPoint = int(numStep.value)*10;
			
			checkYbEnough();
//			setTotalCost(ShopConstant.COST + totalCost);
		}
		
		private function onBuyEnter(evt:KeyboardEvent):void
		{
			if(evt.keyCode == Keyboard.ENTER)
				buyHandler();
		}
		
		private function checkYbEnough():void
		{
			var totalYB:int = GlobalObjectManager.getInstance().user.attr.gold + GlobalObjectManager.getInstance().user.attr.gold_bind;
			
			costTF.htmlText = "兑换" + _needPoint + "点训练点";
			
			if(needYB > totalYB)
			{
				tipTf.htmlText = "<font color='#ff0000'>你的元宝不足，不够兑换</font>";
				buyButton.enabled = false;
				
			}else{
				tipTf.text = "";
				buyButton.enabled = true;
			}
		}
		
		private function buyHandler():void
		{
			var totalYB:int = GlobalObjectManager.getInstance().user.attr.gold + GlobalObjectManager.getInstance().user.attr.gold_bind;
			//			this.parent.removeChild(this);
			if(needYB > totalYB)
			{
				var str:String = "<font color='#ff0000'>你的元宝不足，不够兑换</font>";
				BroadcastSelf.logger(str);
			}else{
				TrainModule.getInstance().exchangePoint(_needPoint);
			}
			
			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			this.dispatchEvent(evt);
		}
		
		/*1）不足，右下角红色提示：你的元宝不足，不够兑换
2）足够，扣取元宝，兑换成功，『训练』界面的Z增加，Y变成蓝色。
*/	
		private function onBuyClick(e:MouseEvent):void
		{
			buyHandler();
		}
		
		private function onNoHandler(e:MouseEvent):void
		{
			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			this.dispatchEvent(evt);
//			this.dispose();
		}
		
		//目前需要补充356点训练点数，确定补充训练点数吗？
		public function setNeedPoint(needPoint:int):void
		{
			
			if(needPoint <=0)
			{
				needYB = 1;
				onaddToStage(1);
				
			}else{
				needYB = int((needPoint-1)/10+1);
				onaddToStage(needYB);
			}
			
			
//			_needPoint = needPoint;	
//			needYB = int( needPoint/100 +1);
			
			
			
		}
		
		private function onaddToStage(num:int):void
		{
			_needPoint = num*10;
			checkYbEnough();
			numStep.value = num;
			numStep.textFiled.setFocus();
			numStep.textFiled.validateNow();
			numStep.textFiled.textField.setSelection(0,numStep.textFiled.text.length);
		}
		
		
		private function closeHandler(evt:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
		}
		
		
	}
}


