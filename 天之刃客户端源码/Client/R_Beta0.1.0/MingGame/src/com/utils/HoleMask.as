package com.utils {
	import com.components.alert.Alert;
	import com.managers.LayerManager;

	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class HoleMask extends Shape {
		private static var _instance:HoleMask;
		private var rectHole:Rectangle;

		public function HoleMask() {
			super();
		}

		public static function getInstance():HoleMask {
			if (_instance == null) {
				_instance=new HoleMask;
			}
			return _instance;
		}

		public function showHole(rect:Rectangle):void {
			var stage:Stage=LayerManager.stage;
			if (stage) {
				if (rect.x < 0 || rect.x > stage.stageWidth || rect.x + rect.width > stage.stageWidth) {
					Alert.show("矩形不合规格");
					return;
				}
				if (rect.y < 0 || rect.y > stage.stageHeight || rect.y + rect.height > stage.stageHeight) {
					Alert.show("矩形不合规格");
					return;
				}
				rectHole=rect;
				graphics.clear();
				graphics.beginFill(0x0, 0.25);
				graphics.drawRect(0, 0, stage.stageWidth, rect.y);
				graphics.drawRect(0, rect.y + rect.height, stage.stageWidth, stage.stageHeight - rect.y - rect.height);
				graphics.drawRect(0, rect.y, rect.x, rect.height);
				graphics.drawRect(rect.x + rect.width, rect.y, stage.stageWidth - rect.x - rect.width, rect.height);
				stage.addChild(this);
			}
		}

		public function onReSize():void {
			if (stage && rectHole) {
				graphics.clear();
				graphics.beginFill(0xffffff, 0.3);
				graphics.drawRect(0, 0, stage.stageWidth, rectHole.y);
				graphics.drawRect(0, rectHole.y + rectHole.height, stage.stageWidth, stage.stageHeight - rectHole.y - rectHole.height);
				graphics.drawRect(0, rectHole.y, rectHole.x, rectHole.height);
				graphics.drawRect(rectHole.x + rectHole.width, rectHole.y, stage.stageWidth - rectHole.x - rectHole.width, rectHole.height);
				stage.addChild(this);
			}
		}

		public function hide():void {
			rectHole=null;
			graphics.clear();
			if (parent) {
				parent.removeChild(this);
			}
		}
	}
}