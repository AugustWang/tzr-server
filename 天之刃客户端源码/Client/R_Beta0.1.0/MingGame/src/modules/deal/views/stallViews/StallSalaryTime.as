package modules.deal.views.stallViews
{
	
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	
	public class StallSalaryTime extends Panel //UIComponent
	{
		private var txt1:TextField; //请选择雇佣时间：
									 
		                             //请输入延期时间：	
		
		private var txt2:TextField; //雇佣：
		
		                             //延期：
		
		private var timeInput:TextInput;  //
		
		private var txt3:TextField;   // 小时，消耗工资 XXX ；
		
		private var sureBtn:Button;   // 确定
		
		private var maxTime:int;      //小时　
		//变量 //
		private var salaryTime:int = 0;   //雇佣时间长度
		private var _costPhour:int = 1;   //
		private var continueEmploy:Boolean;
		private var textformat:TextFormat;
		
		public function StallSalaryTime()
		{
			super();
			this.width = 310;
			this.height = 125;//175;
			this.bgColor = 0xac3a3a;
			this.bgAlpha = 0.4;
			init();
			
			this.addEventListener(Event.ADDED_TO_STAGE,onfocus);
		}
		
		private function onfocus(e:Event):void
		{
			if(timeInput)
				timeInput.setFocus();
			
			
		}
		
		public function initSalary(salaryIng:Boolean):void
		{
			continueEmploy = salaryIng;
			if(salaryIng){
				txt1.text = "请输入延期时间：";
				txt2.text = "延期：";
			}else {
				txt1.text = "请输入雇佣时间：";
				txt2.text = "雇佣：";
			}
		}
		
		public function set cost_p_h(value:int ):void
		{
			_costPhour = value ;
		}
		
		private function init():void
		{
			textformat = new TextFormat("Tahoma",12,0xF6F5CD);
			
			txt1 = ComponentUtil.createTextField("请输入雇佣时间：",12,10,textformat,100,22,this); // new TextField();
			
			
			txt2 = ComponentUtil.createTextField("雇佣：",38,33,textformat,72,22,this); // new TextField();
			
			
			timeInput = new TextInput();
			timeInput.x = 67;
			timeInput.y = 33;// 63;
			timeInput.width = 64;
			timeInput.restrict = "0-9";
			timeInput.maxChars = 3;
			
			addChild(timeInput);
			//timeInput.addEventListener(TextEvent.TEXT_INPUT,onInputHandler);
			timeInput.addEventListener(Event.CHANGE, onInputChange);
			timeInput.addEventListener(KeyboardEvent.KEY_UP,onInputHandler);
			
			txt3 = ComponentUtil.createTextField("",135,33,textformat,140,22,this); //new TextField();
			
			txt3.htmlText = "小时，消耗工资 " +
				"<font color='#00ff00'>"+
                "两</font>";
			
			_costPhour = DealConstant.EMPLOY_P_HOUR;
			
			var txt:TextField = ComponentUtil.createTextField("雇佣店小二，最多只能雇佣24小时",12,58,Style.textFormat,195,22,this);
			
			sureBtn = ComponentUtil.createButton("确定",210,60,66,24,this); // new Button();
			
			sureBtn.addEventListener(MouseEvent.CLICK, onSureHandler);
			
		}
		
		private function onInputChange(e:Event):void
		{
			var remain_time:int=0;
			if(DealConstant.remain_time>0)
			{
				remain_time = Math.ceil(DealConstant.remain_time/3600);
				if(remain_time == 24)
				{
					
					return;
				}
			}
			maxTime = 24 - remain_time;
			if(timeInput.text.length == 1 && timeInput.text =="0")
			{
				timeInput.text ="1";
				time = 1;
			}else if(int(timeInput.text)>maxTime)
			{
				timeInput.text =maxTime.toString();
				time = maxTime;
			}
			else{
				time = int(timeInput.text);
			}
			
			
			setCostText();
			
			salaryTime = time;
		}
		
		private var time:int;
		private function onInputHandler(evt:KeyboardEvent):void
		{
			if(timeInput.text.length == 1 && timeInput.text =="0")
			{
				timeInput.text ="";
				time = 0;
			}else{
				time = int(timeInput.text);
			}
			
			
			setCostText();
			
			salaryTime = time;
		}
		
		private function setCostText():void//time:int
		{
			txt3.htmlText = "小时，消耗工资 " +
				"<font color='#00ff00'>" +
				DealConstant.silverToOtherString(time*_costPhour) + "</font>";
			
		}
		
		private function onSureHandler(evt:MouseEvent):void
		{
			//to do  确定
			if(salaryTime>0)
			{
				var totalsilver:int = GlobalObjectManager.getInstance().user.attr.silver 
					+ GlobalObjectManager.getInstance().user.attr.silver_bind;
				if(time*_costPhour > totalsilver)
				{
					Alert.show("银子不足。","提示：",null,null,"确定","取消",null,false);
					return;
				}
				DealModule.getInstance().requstSalaryTime(salaryTime,continueEmploy);
			}
		}
		
		
		
	}
}