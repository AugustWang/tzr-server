package com.common.cursor.cursors {
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;

	public class CollectCursor extends BaseCursor {
		public function CollectCursor() {
			super();
			setMouse("Mouse_chuTou");
		}

		override public function normalHandler():void {
		}
	}
}