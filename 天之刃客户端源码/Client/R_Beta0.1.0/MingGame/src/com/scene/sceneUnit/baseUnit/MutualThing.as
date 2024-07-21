package com.scene.sceneUnit.baseUnit {
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * 场景中基于Thing的可交互单位基类
	 * @author LXY
	 *
	 */
	public class MutualThing extends Sprite implements IMutualUnit {
		public var onlyKey:String;
		private var _sceneType:int;
		public var id:int;
		protected var _thing:Thing;
		protected var _shadow:Bitmap;
		protected var _silhouette:Bitmap;
		protected var _bg:Sprite
		private var _enabled:Boolean=true;

		public function MutualThing() {
			super();
			onlyKey=OnlyIDCreater.createID();
			this.mouseChildren=false;
			this.mouseEnabled=false;
		}

		protected function addShadow():void {
			_bg=new Sprite();
			addChild(_bg);
			_shadow=new Bitmap();
			_shadow.bitmapData=SourceManager.getInstance().getShadow();
			_shadow.x=-27;
			_shadow.y=-14;
			_bg.addChild(_shadow);
			_silhouette=new Bitmap();
			_silhouette.bitmapData=SourceManager.getInstance().getSilhouette();
			_silhouette.x=-21;
			_silhouette.y=-96;
			_silhouette.alpha=0.6
			_bg.addChild(_silhouette);
		}

		protected function removeSilhouette():void {
			if (_silhouette) {
				_bg.removeChild(_silhouette);
				_silhouette=null;
			}
		}

		public function init(skinURL:String):void {
			_thing=new Thing();
			_thing.addEventListener(ThingsEvent.THING_LOAD_COMPLETE, onLoadComplete);
			_thing.load(skinURL);
			_thing.gotoAndStop(0);
			addChild(_thing);
			if(_thing.isLoaderComplete()){
				removeSilhouette();
			}
		}

		protected function onLoadComplete(event:ThingsEvent):void {
			_thing.removeEventListener(ThingsEvent.THING_LOAD_COMPLETE, onLoadComplete);
			if (_silhouette) {
				removeSilhouette();
			}
		}

		public function hide():void {
			if (this.parent)
				this.parent.removeChild(this);
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

		public function mouseOver():void {
			if (this._thing != null) {
				if (this._thing.filters == null || this._thing.filters.length == 0) {
					this._thing.filters=SceneStyle.bodyFilter;
				}
			}
		}

		public function mouseOut():void {
			if (this._thing != null) {
				if (this._thing.filters != null || this._thing.filters.length > 0) {
					this._thing.filters=null;
				}
			}
		}

		public function mouseDown():void {

		}

		public function mouseUp(e:MouseEvent):void {

		}

		public function remove():void {
			if (this._thing) {
				_thing.removeEventListener(ThingsEvent.THING_LOAD_COMPLETE, onLoadComplete);
				this._thing.stop();
				_thing.unload();
				_thing=null;
			}
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
			if (_bg) {
				_bg.parent.removeChild(_bg);
				if (_shadow)
					_shadow.parent.removeChild(_shadow);
				if (_silhouette)
					_silhouette.parent.removeChild(_silhouette);
				_bg=null;
				_shadow=null;
				_silhouette=null;
			}
		}

		public function get unitKey():String {
			return sceneType + "_" + id;
		}

		public function set sceneType(value:int):void {
			_sceneType=value;
		}

		public function get sceneType():int {
			return _sceneType;
		}
	}
}