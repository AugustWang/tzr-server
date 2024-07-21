package com.common.cursor.cursors
{
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;
	
	import flash.events.MouseEvent;

	public class AttrackCursor extends BaseCursor
	{
		public function AttrackCursor()
		{
			super();
			setMouse("Mouse_attack");
		}
		
		override public function normalHandler():void{
			
		}
	}
}