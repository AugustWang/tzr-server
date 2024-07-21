package modules.mypackage.views
{
	import com.components.components.DragUIComponent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.PackageModule;

	public class PursuePanel extends DragUIComponent
	{
		private var titleField:TextField;
		private var textInput:TextInput;
		private var btn_ok:Button;
		private var btn_cancel:Button;
		public var goodsId:int;
		public function PursuePanel()
		{
			super();
			init();
		}
		
		private function init():void{
			width = 220;
			height = 120;

			var tf:TextFormat = Style.textFormat;
			tf.bold = true;
			tf.size = 14;
			tf.align = "center";
			titleField = ComponentUtil.createTextField("追踪符",20,10,tf,180,NaN,this);
			titleField.textColor = 0x3DEA42;
			titleField.selectable = false;
			titleField.mouseEnabled = false;
			
			ComponentUtil.createTextField("请输入要追踪的玩家名：",20,30,null,200,NaN,this)
				
			textInput = new TextInput();
			textInput.maxChars = 7;
			textInput.addEventListener(ComponentEvent.ENTER,onEnter);
			textInput.width = 180;
			textInput.x = 20;
			textInput.y = 55;
			
			btn_ok = ComponentUtil.createButton("确定",45,85,60,25,this,wrapperButton);
			btn_ok.addEventListener(MouseEvent.CLICK,onOKhandler);
			
			btn_cancel = ComponentUtil.createButton("取消",115,85,60,25,this,wrapperButton);
			btn_cancel.addEventListener(MouseEvent.CLICK,onCancelhandler);
			textInput.validateNow();
			textInput.textField.setSelection(0,1);
			addChild(textInput);
		
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(event:Event):void{
			textInput.setFocus();
		}
		
		private function onEnter(event:ComponentEvent):void{
			onOKhandler();
		}
		
		private function onOKhandler(event:MouseEvent=null):void{
			var userName:String = StringUtil.trim(textInput.text);
			if(userName.length != 0){
				PackageModule.getInstance().useItemTrace(goodsId,userName);
				onCancelhandler();		
			}	
		}
		
		private function onCancelhandler(event:MouseEvent=null):void{
			if (this.parent) {
				this.parent.removeChild(this);
			}
			textInput.text = "";
			unLoad();
		}
		
		override public function unLoad():void{
			super.unLoad();
			WindowManager.getInstance().removeWindow(this);
		}
	}
}