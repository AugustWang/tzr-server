package com.common.cursor.cursors {
	import com.common.cursor.BaseCursor;
	import com.globals.GameConfig;

	public class TalkCursor extends BaseCursor {

		public function TalkCursor() {
			super();
			setMouse("Mouse_talk");
		}

		override public function normalHandler():void {
			mc.play();
		}
	}
}