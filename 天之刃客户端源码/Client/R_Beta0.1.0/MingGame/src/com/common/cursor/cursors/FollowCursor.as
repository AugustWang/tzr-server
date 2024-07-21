package com.common.cursor.cursors
{
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;
	
	public class FollowCursor extends BaseCursor
	{
		public function FollowCursor()
		{
			super();
			setMouse("Mouse_follow");
		}
		
		override public function normalHandler():void{
			mc.play();
		}
	}
}