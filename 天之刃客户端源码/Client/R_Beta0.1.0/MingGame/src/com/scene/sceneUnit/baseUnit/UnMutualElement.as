package com.scene.sceneUnit.baseUnit {
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.display.Sprite;
	import flash.geom.Point;

	public class UnMutualElement extends Sprite {
		public var id:int;
		protected var _thing:Thing;
		private var _enabled:Boolean=true;

		public function UnMutualElement() {
			super();
			this.mouseChildren=false;
			this.mouseEnabled=false;
		}

		public function init(skinURL:String):void {
			_thing=new Thing();
			_thing.addEventListener(ThingsEvent.THING_LOAD_COMPLETE, onLoadComplete);
			_thing.load(skinURL);
			addChild(_thing);
		}

		protected function onLoadComplete(event:ThingsEvent):void {
			_thing.removeEventListener(ThingsEvent.THING_LOAD_COMPLETE, onLoadComplete);
		}

		public function set enabled(value:Boolean):void {
			if (_enabled != value) {
				if (_thing != null) {
					if (value) {
						_thing.resume();
					} else {
						_thing.stop();
					}
				}
				_enabled=value;
			}
		}

		public function get index():Pt {
			var pt:Pt=TileUitls.getIndex(new Point(this.x, this.y));
			return pt;
		}


		public function unload():void {
		}
	}
}