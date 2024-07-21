package com.components
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	
	public class SortButton extends UIComponent
	{
		private var bitmap:Bitmap;
		
		public function SortButton()
		{
			super();
			Style.setSortBtnStyle(this);
			bitmap = new Bitmap();
			addChild(bitmap);
			clear();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			bitmap.x = width - 12;
			bitmap.y = ((height - 9) >> 1);
		}
		
		private var _desc:Boolean = false;
		public function set desc(value:Boolean):void{
			_desc = true;
			var sname:String = value ? "px_down":"px_up";
			bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_UI,sname);
		}
		
		public function get desc():Boolean{
			return _desc;
		}
		
		public function clear():void{
			if(bitmap){
				var sname:String = desc ? "gray_px_down":"gray_px_up";
				bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_UI,sname);
			}
		}
		
		
		
	}
}