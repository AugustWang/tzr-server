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
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	import modules.official.OfficialModule;
	
	public class KingMujuanPanel extends BasePanel
	{
		private var dingInput:TextInput;
		private var liangInput:TextInput;
		private var wenInput:TextInput;
		
		private var desc:TextField;
		
		public var closeFunc:Function;
		
		private var bg:UIComponent;
		public function KingMujuanPanel()
		{
			super();
			this.title = "国王募捐";
			
			width = 280;
			height = 215;
			
			bg = ComponentUtil.createUIComponent(7,5,266,147);
			Style.setBorderSkin(bg);
			bg.mouseEnabled = false;
			addChild(bg);
			
			desc = ComponentUtil.createTextField("",5,10,null,256,120,bg);
			desc.wordWrap = true;
			desc.multiline = true;
						
			dingInput = createTextInput(5,110,87,20,5);
			ComponentUtil.createTextField("锭",92,110,null,22,23,bg);
			
			liangInput = createTextInput(109,110,50,20,2);
			ComponentUtil.createTextField("两",159,110,null,22,23,bg);
			
			wenInput = createTextInput(176,110,50,20,2);
			ComponentUtil.createTextField("文",226,110,null,22,23,bg); 
			
			var surebtn:Button = ComponentUtil.createButton("确定",110,155,70,26,this); 
			surebtn.addEventListener(MouseEvent.CLICK, onSureHandler);
			
			var cancelbtn:Button = ComponentUtil.createButton("取消",200,155,70,26,this); 
			cancelbtn.addEventListener(MouseEvent.CLICK, onCancelHandler);
			
			initView("哥依然很飘逸");
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void{
			dingInput.setFocus();
		}
		
		public function initView(kingName:String):void{
			desc.htmlText = "     为了改善国民福利的，增强国家实力。国王"+HtmlUtil.font("【"+kingName+"】","#00FF00")+"向全体国民募捐，\n\n\n\n您可以输入想要捐赠的银子数目：";
		}
		
		private function createTextInput(x:int,y:int,w:int,h:int,maxChars:int):TextInput{
			var input:TextInput = new TextInput();
			input.x = x;
			input.y = y;
			input.width = w;
			input.height = h;
			input.restrict = "0-9";
			input.maxChars = maxChars;
			bg.addChild(input);
			return input;
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