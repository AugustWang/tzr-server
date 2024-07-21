package modules.help
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class HelpTip extends Sprite
	{
		private var contentText:TextField;
		private var closeButton:UIComponent;
		private var key2:Bitmap;
		private var timeOut:int;
		public function HelpTip()
		{
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"playerGuideBg"));
			contentText = ComponentUtil.createTextField("",10,45,null,235,45,this);
			contentText.textColor = 0x000000;
			contentText.wordWrap = true;
			contentText.multiline = true;
			text = "将鼠标移到怪物身上，点击左键可进行攻击。";
			closeButton = new UIComponent();
			closeButton.addEventListener(MouseEvent.CLICK,onCloseHandler);
			closeButton.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI);
			closeButton.x = width - 35;
			closeButton.y = 10;
			addChild(closeButton);
			key2 = Style.getBitmap(GameConfig.T1_VIEWUI,"keyA");
			key2.x = 26;
			key2.y = 35;
			addChild(key2);
			
		}
		
		private function set text(value:String):void{
			contentText.text = "          "+value;	
		}
		
		private static var instance:HelpTip;
		public static function getInstance():HelpTip{
			if(instance == null){
				instance = new HelpTip();
			}
			return instance;
		}
		
		private function show():void{
			LayerManager.uiLayer.addChild(this);
			x = 600;
			x = GlobalObjectManager.GAME_WIDTH - 220 - this.width;
			timeOut = setTimeout(onCloseHandler,10000,null);
		}
		
		public function showMsg(msg:String):void{
			key2.visible = false;
			contentText.text = "  "+msg;
			show();
		}
		
		private function onCloseHandler(event:MouseEvent):void{
			clearTimeout(timeOut);
			instance = null;
			if(parent){
				parent.removeChild(this);
			}
		}
	}
}