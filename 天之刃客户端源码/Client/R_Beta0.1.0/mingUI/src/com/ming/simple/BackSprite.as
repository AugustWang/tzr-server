package com.ming.simple
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * 用于只有背景图的容器 
	 */	
	public class BackSprite extends Sprite
	{
		private var bg:DisplayObject;
		public function BackSprite()
		{
			
		}
		
		public function setBitmapClass(clazz:Class):void{
			var dis:DisplayObject = new clazz(0,0);
			setDisplayObject(dis);
		}
		public function setDisplayClass(clazz:Class):void{
			var dis:DisplayObject = new clazz();
			setDisplayObject(dis);
		}
		public function setDisplayObject(dis:DisplayObject):void{
			bg = dis;
			addChildAt(bg,0);
		}
		
		public function dispose():void{
			var bitmap:Bitmap = bg as Bitmap;
			if(bitmap){
				bitmap.bitmapData.dispose();
			}
		}
	}
}