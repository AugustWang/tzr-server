package modules.official.views
{
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.components.BasePanel;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	import modules.official.OfficialModule;
	
	public class ContributePanel extends BasePanel
	{
		private var dingInput:TextInput;
		private var liangInput:TextInput;
		private var wenInput:TextInput;
		
		public var closeFunc:Function;
		
		public function ContributePanel()
		{
			super();
			this.title = "国库捐赠";
			
			width = 280;
			height = 215;
			
			var desc:TextField = ComponentUtil.createTextField("",15,10,null,256,120,this);
			desc.wordWrap = true;
			desc.multiline = true;
			desc.text = "     国库捐款，取之于民，用之于民，库银将全部用于改善国民福利的，增强国家实力。比如发布国家任务，修筑国战相关设施等。\n\n\n请输入您想要捐赠的银子数目：";
			
			dingInput = createTextInput(15,110,87,20,5);
			ComponentUtil.createTextField("锭",102,110,null,22,23,this);
			
			liangInput = createTextInput(119,110,50,20,2);
			ComponentUtil.createTextField("两",169,110,null,22,23,this);
			
			wenInput = createTextInput(186,110,50,20,2);
			ComponentUtil.createTextField("文",236,110,null,22,23,this); 
			
			var surebtn:Button = ComponentUtil.createButton("确定",110,150,70,26,this); 
			surebtn.addEventListener(MouseEvent.CLICK, onSureHandler);
			
			var cancelbtn:Button = ComponentUtil.createButton("取消",200,150,70,26,this); 
			cancelbtn.addEventListener(MouseEvent.CLICK, onCancelHandler);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void{
			dingInput.setFocus();
		}
		
		private function createTextInput(x:int,y:int,w:int,h:int,maxChars:int):TextInput{
			var input:TextInput = new TextInput();
			input.x = x;
			input.y = y;
			input.width = w;
			input.height = h;
			input.restrict = "0-9";
			input.maxChars = maxChars;
			addChild(input);
			return input;
		}
		
		private function wrapper(txt:TextField):void{
			txt.filters = [new GlowFilter(0x000000,1,3,3,3)];
		}
		
		private function onSureHandler(event:MouseEvent):void{
			var gold:Number = Number(dingInput.text);
			var sliver:Number = Number(liangInput.text);
			var wen:Number = Number(wenInput.text);
			var money:Number = MoneyTransformUtil.otherToSilver(gold,sliver,wen);
			OfficialModule.getInstance().donate(money);
		}
		
		private function onCancelHandler(event:MouseEvent):void{
			closeWindow();
		}
		
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow(save);
			if(closeFunc != null){
				closeFunc.apply(null);
			}
		}
		
		public function clear():void{
			dingInput.text = "";
			liangInput.text = "";
			wenInput.text = "";
		}
	}
}