package com.common.cursor.cursors
{
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;

	public class PickCursor extends BaseCursor
	{
		public function PickCursor()
		{
			super();
			setMouse("Mouse_pick");
		}
		
		override public function normalHandler():void{
		}
	}
}