package modules.family.views
{
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class InviteFamilyYBCPanel extends BasePanel
	{
		private var textInput:TextInput;
		public var sendFunc:Function;
		public function InviteFamilyYBCPanel()
		{
			super();
		}
		
		override protected function init():void{
			this.title = "邀请门派成员";
			
			width = 400;
			height = 200;
			
			var bg:UIComponent=new UIComponent();
			bg.x=9;
			bg.width=this.width - 18;
			bg.height=163;
			Style.setBorderSkin(bg);
			addChild(bg);
			
			ComponentUtil.createTextField("你正在召集门派成员，还可以在下面输入一段话：",18,7,null,300,25,this);
			
			textInput = new TextInput();
			textInput.x = 20;
			textInput.y = 37;
			textInput.width = 360;
			textInput.height = 22;
			textInput.maxChars = 30;
			addChild(textInput);
			
			var tip:TextField = ComponentUtil.createTextField("",18,65,null,360,60,this);
			tip.textColor = 0xffff00;
			tip.wordWrap = true;
			tip.multiline = true;
			tip.text = "热情提示：如果门派成员接受你的邀请会直接传送到这里，请你耐心等待。你还可以在门派聊天群里和你的帮众进行沟通。";
		
			var sendBtn:Button = ComponentUtil.createButton("发送",35,125,65,26,this);
			sendBtn.addEventListener(MouseEvent.CLICK,onSendHandler);
			var cancelBtn:Button = ComponentUtil.createButton("取消",300,125,65,26,this);
			cancelBtn.addEventListener(MouseEvent.CLICK,onCancelHandler);
		}
		
		private function onSendHandler(event:MouseEvent):void{
			var content:String = StringUtil.trim(textInput.text);
			if(sendFunc != null){
				sendFunc.apply(null,[content]);
			}
			onCancelHandler(null);
		}
		
		private function onCancelHandler(event:MouseEvent):void{
			textInput.text = "";
			closeWindow();
		}
	}
}