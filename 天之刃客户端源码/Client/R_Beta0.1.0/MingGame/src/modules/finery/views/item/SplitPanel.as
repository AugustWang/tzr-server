package modules.finery.views.item
{
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class SplitPanel extends DragUIComponent
	{
		private var titleField:TextField;
		private var textInput:TextInput;
		private var btn_ok:Button;
		private var btn_cancel:Button;
		public var maxSize:int;
		public var callBack:Function;
		public function SplitPanel()
		{
			super();
			init();
		}
		
		private function init():void{
			width = 200;
			height = 105;
			
			titleField = ComponentUtil.createTextField("请输入要拆分的数量",20,10,null,200,NaN,this);
			titleField.textColor = 0x3DEA42;
			titleField.selectable = false;
			titleField.mouseEnabled = false;
			
			textInput = new TextInput();
			textInput.text = "1";
			textInput.restrict = "[0-9]";
			textInput.maxChars = 2;
			textInput.addEventListener(Event.CHANGE,onChange);
			textInput.addEventListener(ComponentEvent.ENTER,onEnter);
			textInput.width = 160;
			textInput.x = 20;
			textInput.y = 35;
			
			btn_ok = ComponentUtil.createButton("确定",30,65,60,25,this,wrapperButton);
			btn_ok.addEventListener(MouseEvent.CLICK,onOKhandler);
			
			btn_cancel = ComponentUtil.createButton("取消",110,65,60,25,this,wrapperButton);
			btn_cancel.addEventListener(MouseEvent.CLICK,onCancelhandler);
			textInput.validateNow();
			textInput.textField.setSelection(0,1);
			addChild(textInput);
			
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(event:Event):void{
			textInput.setFocus();
		}
		
		private function onChange(event:Event):void{
			var size:int = parseInt(textInput.text);
			if(size > maxSize){
				textInput.text = maxSize.toString();
			}
			if(size == 0){
				textInput.text = "1";
			}
		}
		
		private function onEnter(event:ComponentEvent):void{
			onOKhandler();
		}
		
		private function onOKhandler(event:MouseEvent=null):void{
			if(textInput.text.length != 0){
				if(callBack != null){
					callBack.call(null,parseInt(textInput.text));
				}
			}
			onCancelhandler();			
		}
		
		private function onCancelhandler(event:MouseEvent=null):void{
			WindowManager.getInstance().closeDialog(this);
			callBack=null;
			textInput.text = "";
			unLoad();
		}
	}
}