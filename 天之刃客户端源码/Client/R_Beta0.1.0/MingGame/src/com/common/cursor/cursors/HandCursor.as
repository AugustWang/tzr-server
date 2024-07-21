package com.common.cursor.cursors
{
	import com.common.cursor.BaseCursor;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import modules.mypackage.views.PackageItem;
	
	public class HandCursor extends BaseCursor
	{
		public function HandCursor()
		{
			super();
			setMouse("Mouse_selectTarget");
		}
		
		override public function normalHandler():void{
		
		}
		
		override public function downHandler(event:MouseEvent):void{
			if(CursorManager.getInstance().currentCursor == CursorName.SPLIT){
				var clickTarget:PackageItem = event.target as PackageItem;
				if(clickTarget == null){
					CursorManager.getInstance().enabledCursor = true;
					CursorManager.getInstance().hideCursor(CursorName.SPLIT);
				}
			}
		}
	}
}