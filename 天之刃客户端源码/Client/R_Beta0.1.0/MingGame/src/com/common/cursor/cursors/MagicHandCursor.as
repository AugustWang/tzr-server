package com.common.cursor.cursors {
	import com.common.cursor.BaseCursor;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;

	import flash.events.MouseEvent;

	public class MagicHandCursor extends BaseCursor {
		public function MagicHandCursor() {
			super();
			setMouse("Mouse_selectTarget");
		}

		override public function normalHandler():void {
		}

		override public function upHandler(event:MouseEvent):void {
			CursorManager.getInstance().enabledCursor=true;
			CursorManager.getInstance().hideCursor(CursorName.MAGIC_HAND);
		}
	}
}