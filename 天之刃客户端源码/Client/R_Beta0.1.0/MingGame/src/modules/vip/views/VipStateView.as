package modules.vip.views
{
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import modules.vip.VipModule;
	
	public class VipStateView extends Sprite
	{
		private var vipIcon:Array = ["vip0", "vip1", "vip2", "vip3"];
		private var _vipIcon:Bitmap;
		
		public function VipStateView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			x = 105;
			y = 2;
			var vipBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"roleVIP");
			vipBg.width = 30;
			addChild(vipBg);
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			_vipIcon = new Bitmap();
			_vipIcon.x = 2;
			addChild(_vipIcon);
			addEventListener(MouseEvent.CLICK, onOpenVipPanel)
		}
		
		private function onOpenVipPanel(e:Event):void
		{
			VipModule.getInstance().onOpenVipPannel();
		}
		
		public function setData(vipLevel:int):void
		{
			_vipIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,vipIcon[vipLevel]);
		}
	}
}