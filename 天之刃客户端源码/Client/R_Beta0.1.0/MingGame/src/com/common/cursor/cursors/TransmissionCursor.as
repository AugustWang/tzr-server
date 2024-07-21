package com.common.cursor.cursors
{
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;
	
	public class TransmissionCursor extends BaseCursor
	{
		public function TransmissionCursor()
		{
			super();
			setMouse("Mouse_transmission");
		}
		
		override public function normalHandler():void{
		}
	}
}