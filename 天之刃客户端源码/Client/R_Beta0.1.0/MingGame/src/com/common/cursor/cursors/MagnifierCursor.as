package com.common.cursor.cursors
{	
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;

	public class MagnifierCursor extends BaseCursor
	{
		public function MagnifierCursor()
		{
			super();
			setMouse("Mouse_magnifier");
		}
		
		override public function normalHandler():void{
		}
	}
}