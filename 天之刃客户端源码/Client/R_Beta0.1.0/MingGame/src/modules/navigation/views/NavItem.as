package modules.navigation.views
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class NavItem extends Sprite
	{
		public var normal:String;
		public var over:String;
		public var tip:String;
		private var normalBitmapData:BitmapData;
		private var overBitmapData:BitmapData;
		private var bitmap:Bitmap;
		public function NavItem()
		{
			mouseChildren = false;
			bitmap = new Bitmap();
			addChild(bitmap);
			addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			normal();
		}
		
		private function onRollOver(event:MouseEvent):void{
			over();
			if(tip){
				ToolTipManager.getInstance().show(tip,0);
			}
		}
		
		private function onRollOut(event:MouseEvent):void{
			normal();
			ToolTipManager.getInstance().hide();
		}
		
		private function normal():void{
			if(normalBitmapData == null){
				normalBitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,normal);
			}
			bitmap.bitmapData = normalBitmapData;		
		}
		
		private function over():void{
			if(overBitmapData == null){
				overBitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,over);
			}
			bitmap.bitmapData = overBitmapData;				
		}
		
	}
}