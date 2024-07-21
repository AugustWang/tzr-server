package com.common.cursor {
	import com.globals.GameConfig;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class BaseCursor extends Sprite implements ICursor {
		private var _data:Object;
		protected var mc:MovieClip;

		public function BaseCursor() {
			super();
			mouseChildren=mouseEnabled=false;
		}

		protected function setMouse(mouseStyle:String):void {
			var MC:Class=Style.getClass(GameConfig.MOVIE_UI, mouseStyle);
			mc=new MC;
			addChild(mc);
		}

		protected function onLoadComplete(event:ThingsEvent):void {
			normalHandler();
		}

		public function downHandler(event:MouseEvent):void {

		}

		public function upHandler(event:MouseEvent):void {
		}

		public function normalHandler():void {
		}

		public function stop():void {
			mc.stop();
		}

		public function set data(value:Object):void {
			this._data=value;
		}

		public function get data():Object {
			return _data;
		}
	}
}