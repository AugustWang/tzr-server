package com.common.cursor.cursors {
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;

	public class ButtonMoveCursor extends BaseCursor {
		public function ButtonMoveCursor() {
			super();
			setMouse("Mouse_buttonMode");
		}

		override public function normalHandler():void {
		}
	}
}