package modules.educate.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.educate.EducateConstant;
	import modules.educate.EducateModule;
	
	import proto.line.p_educate_role_info;
	
	public class PkTransformPanel extends BasePanel
	{
		private var text:TextField;
		private var textInput:TextInput;
		private var transButton:Button;
		private var cancelButton:Button;
		private var expText:TextField;
		private var backBg:Sprite;
		public function PkTransformPanel()
		{
			super("");
			width = 280;
			height = 170;
			this.title = "师德值洗红名"
			
			backBg=Style.getBlackSprite(264,127);
			backBg.x = 9;
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			text = ComponentUtil.createTextField("",12,5,null,260,NaN,this);
			text.wordWrap = true;
			text.multiline = true;
			ComponentUtil.createTextField("请输入师德值",37,50,null,NaN,NaN,this);
			textInput = new TextInput();
			textInput.x = 122;
			textInput.y = 50;
			textInput.width = 80;
			textInput.restrict  = "[0-9]";
			textInput.addEventListener(Event.CHANGE,onTextChanged);
			addChild(textInput);
			
			expText = ComponentUtil.createTextField("",30,75,null,200,NaN,this);
			transButton = ComponentUtil.createButton("确定",100,100,66,25,this);
			cancelButton =ComponentUtil.createButton("取消",190,100,66,25,this);
			transButton.addEventListener(MouseEvent.CLICK,onTransPkHandler);
			cancelButton.addEventListener(MouseEvent.CLICK,onCancelHandler);
		}
		
		private var info:p_educate_role_info;
		public function setEducateInfo(info:p_educate_role_info):void{
			this.info = info;
			initView();
		}
		
		private function initView():void{
			var html:String = "     ";
			html += HtmlUtil.font(info.name,"#ffff00")+"，你已累积师德值" +
				"("+info.moral_values+"/"+EducateConstant.TOL_VALUES[info.title]+")，"+
				HtmlUtil.font("10点","#00ff00")+"师德值可清除"+HtmlUtil.font("1点","#00ff00")+"PK值。";
			textInput.maxChars = (String(info.moral_values)).length;
			text.htmlText = html;	
			textInput.text = "0";
			if(GlobalObjectManager.getInstance().user.base.pk_points > 0){
				expText.htmlText = "（可换取PK值"+HtmlUtil.font("0","#ffff00")+"点）";
			}else{
				expText.htmlText = "（你的PK值已为0，不需要清除）";
			}
		}
		
		private function onTextChanged(event:Event):void{
			if(GlobalObjectManager.getInstance().user.base.pk_points == 0)return;
			var value:int = int(StringUtil.trim(textInput.text));
			var total:int = info.moral_values;
			total = Math.min(info.moral_values,total);
			if(value > total){
				textInput.text = total.toString();
				value = total;
			}
			expText.htmlText = "（可换取PK值"+HtmlUtil.font(String(int(value/10)),"#ffff00")+"点）";
		}
		
		private function onTransPkHandler(event:MouseEvent):void{
			var value:Number = Number(textInput.text);
			if(value > 0){
				EducateModule.getInstance().valueToPk(value);
			}
		}
		
		public var closeFunc:Function;
		private function onCancelHandler(event:MouseEvent):void{
			closeWindow(false);
			if(closeFunc != null){
				closeFunc.apply(null);
			}
		}
	}
}