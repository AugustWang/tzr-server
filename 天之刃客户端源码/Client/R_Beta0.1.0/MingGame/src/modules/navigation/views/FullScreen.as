package modules.navigation.views
{
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import modules.ModuleCommand;
	import modules.playerGuide.PlayerGuideModule;
	
	public class FullScreen extends Sprite
	{
		public function FullScreen()
		{
			super();
			initView();
		}
		
		private function initView():void 
		{
			var skin:Sprite=Style.getViewBg("f8");
			skin.buttonMode=true;
			this.addChild(skin);
			skin.addEventListener(MouseEvent.CLICK, fullScreen);
			Dispatch.register(ModuleCommand.STAGE_RESIZE, resize);
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			this.x = (GlobalObjectManager.GAME_WIDTH - 158 - this.width);
			this.y = 2;
		}
		
		private function onOver(e:Event):void 
		{
			ToolTipManager.getInstance().show("按F8可以切换全屏模式", 0);
		}
		
		private function onOut(e:Event):void 
		{
			ToolTipManager.getInstance().hide();
		}
		
		private function resize(obj:Object):void 
		{
			this.x = (obj.width - 158 - this.width);
			this.y = 2;
		}

		private function fullScreen( e:Event ):void {
			if ( PlayerGuideModule.getInstance().isMasking ) {
				//如果真正遮罩期间，则不能进行全屏切换
				return;
			}

			var screenState:int=GlobalObjectManager.getInstance().screenState;
			if ( screenState == 0 ) {
				ExternalInterface.call( "intoFullScreen" );
				GlobalObjectManager.getInstance().screenState=2;
			} else if ( screenState == 1 ) {
				ExternalInterface.call( "intoFullScreen" );
				GlobalObjectManager.getInstance().screenState=2;
			} else if ( screenState == 2 ) {
				ExternalInterface.call( "exitFullScreen" );
				GlobalObjectManager.getInstance().screenState=0;
			}
		}
	}
}