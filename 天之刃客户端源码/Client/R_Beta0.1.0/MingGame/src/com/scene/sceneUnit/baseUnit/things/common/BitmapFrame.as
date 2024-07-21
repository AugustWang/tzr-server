package com.scene.sceneUnit.baseUnit.things.common
{
	import flash.display.BitmapData;

	public class BitmapFrame
	{
		public var offsetX:int;
		public var offsetY:int;
		public var data:BitmapData;
		
		public function unload():void{
			data.dispose();
			data = null;
		}
	}
}