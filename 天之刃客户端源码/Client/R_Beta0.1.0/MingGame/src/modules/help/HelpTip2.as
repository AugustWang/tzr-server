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
	
	public class HelpTip2 extends Sprite
	{
		private var contentText:TextField;
		private var closeButton:UIComponent;
		private var timeOut:int;
		public function HelpTip2()
		{
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"playerGuideBg"));
			contentText = ComponentUtil.createTextField("",10,45,null,235,45,this);
			contentText.textColor = 0x000000;
			contentText.wordWrap = true;
			contentText.multiline = true;
			text = "到怪物附近按          可自动打怪。";
			closeButton = new UIComponent();
			closeButton.addEventListener(MouseEvent.CLICK,onCloseHandler);
			closeButton.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI);
			closeButton.x = width - 35;
			closeButton.y = 10;
			addChild(closeButton);
		
			var key2:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"keyZ");
			key2.x = 115;
			key2.y = 40;
			addChild(key2);
		}
		
		private function set text(value:String):void{
			contentText.text = "       "+value;	
		}
		
		private static var instance:HelpTip2;
		public static function getInstance():HelpTip2{
			if(instance == null){
				instance = new HelpTip2();
			}
			return instance;
		}
		
		public function show():void{
			LayerManager.uiLayer.addChild(this);
			x = GlobalObjectManager.GAME_WIDTH - 220 - this.width;
			y = 21;
			timeOut = setTimeout(onCloseHandler,10000,null);
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