package modules.friend.views.part
{
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.friend.FriendsModule;
	
	public class AddFriendPanel extends DragUIComponent
	{
		private var nameTxt:TextInput;
		public function AddFriendPanel()
		{
			super();
			init();			
		}
		
		private static var instance:AddFriendPanel;
		public static function getInstance():AddFriendPanel{
			if(instance == null){
				instance = new AddFriendPanel();
			}
			return instance;
		}
		
		private function init():void
		{
			this.width = 250;
			this.height = 100;
			
			showCloseButton = true;
			
			var txt:TextField = ComponentUtil.createTextField("请输入玩家名称：",15,25,null,NaN,NaN,this);
			txt.textColor = 0x3DEA42;
			
			nameTxt = new TextInput();
			nameTxt.width = 155;
			nameTxt.height = 22;
			nameTxt.x = 20;
			nameTxt.y = 50;
			nameTxt.addEventListener(ComponentEvent.ENTER,onEnterHandler);
			addChild(nameTxt);
			
			var okBtn:Button = ComponentUtil.createButton("确定",180,48,50,26,this,wrapperButton);
			okBtn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function show(x:Number=NaN,y:Number=NaN):void{
			WindowManager.getInstance().popUpWindow(this,WindowManager.UNREMOVE);
			if(isNaN(x) && isNaN(y)){
				WindowManager.getInstance().centerWindow(this);
			}	
			nameTxt.setFocus();
		}
		
		public function closeWindow():void{
			WindowManager.getInstance().removeWindow(this);
			instance.dispose();
			instance = null;
		}
		
		override protected function onCloseHandler(event:MouseEvent):void{
			closeWindow();
		}
		
		private function onEnterHandler(evt:ComponentEvent):void{
			addFriend();
		}
		
		private function onClick(evt:Event):void{
			addFriend();
		}
		
		private function addFriend():void{
			var friendName:String = StringUtil.trim(nameTxt.text);
			FriendsModule.getInstance().requestFriend(nameTxt.text);
			nameTxt.text = "";
			closeWindow();
		}
	}
}