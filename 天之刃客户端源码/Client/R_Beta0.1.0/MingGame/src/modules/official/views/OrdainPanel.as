package modules.official.views
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
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.official.OfficialModule;
	
	public class OrdainPanel extends DragUIComponent
	{
		private var nameTxt:TextInput;
		public var officeId:int;
		public function OrdainPanel()
		{
			init();			
		}
		
		private static var instance:OrdainPanel;
		public static function getInstance():OrdainPanel{
			if(instance == null){
				instance = new OrdainPanel();
			}
			return instance;
		}
		
		private function init():void
		{
			this.width = 250;
			this.height = 100;
			this.showCloseButton = true;
			
			var txt:TextField = ComponentUtil.createTextField("请输入要任命的玩家名称：",15,25,null,200,NaN,this);
			txt.filters = [new GlowFilter(0x000000)];
			
			nameTxt = new TextInput();
			nameTxt.width = 155;
			nameTxt.height = 22;
			nameTxt.x = 20;
			nameTxt.y = 50;
			nameTxt.addEventListener(ComponentEvent.ENTER,onEnterHandler);
			addChild(nameTxt);
			
			var okBtn:Button = ComponentUtil.createButton("确定",180,48,50,26,this);
			okBtn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function show(x:Number=NaN,y:Number=NaN):void{
			WindowManager.getInstance().openDialog(this);
			if(isNaN(x) && isNaN(y)){
				WindowManager.getInstance().centerWindow(this);
			}	
			nameTxt.setFocus();
		}
		
		public function closeWindow():void{
			WindowManager.getInstance().closeDialog(this);
			instance.dispose();
			instance = null;
		}
		
		override protected function onCloseHandler(event:MouseEvent):void{
			closeWindow();
		}
		
		private function onEnterHandler(evt:ComponentEvent):void{
			ordian();
		}
		
		private function onClick(evt:Event):void{
			ordian();
		}
		
		private function ordian():void{
			var roleName:String = StringUtil.trim(nameTxt.text);
			OfficialModule.getInstance().appoint(roleName,officeId);
			nameTxt.text = "";
			closeWindow();
		}
	}
}