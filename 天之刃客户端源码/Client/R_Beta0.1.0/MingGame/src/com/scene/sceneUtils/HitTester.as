package com.scene.sceneUtils {
	import com.scene.sceneUnit.IMutualUnit;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class HitTester {
		private static var pixBmd:BitmapData;

		public static function hitTest(target:IMutualUnit, point:Point):Boolean {
			var isHit:Boolean;
			var rect:Rectangle=DisplayObject(target).getBounds((target as DisplayObject).parent);
			if (rect.containsPoint(point)) {
				////////////////加入矩形热区
				var recHot:Rectangle=new Rectangle(-15, -80, 30, 80);
				if (recHot.containsPoint(new Point(target.mouseX, target.mouseY))) {
					isHit=true;
				}
				//////////////////////
				pixBmd=new BitmapData(1, 1, true, 0);
				var matrix:Matrix=new Matrix;
				matrix.tx=-int(target.mouseX);
				matrix.ty=-int(target.mouseY);
				pixBmd.draw(target, matrix, null, null, new Rectangle(0, 0, 1, 1))
				var alphaValue:uint=pixBmd.getPixel32(0, 0) >> 24 & 0xFF;
				if (alphaValue > 40) {
					isHit=true;
				}
			}
			return isHit;
		}

		public static function checkMutualUnit(tar:DisplayObject, except:Array=null):IMutualUnit {
			if (tar is TextField) {
				return null;
			}
			while (tar.parent != null) {
				var obj:DisplayObject=tar.parent;
				if (except != null) { //排除，一些类
					for (var i:int=0; i < except.length; i++) {
						if (tar is except[i] || obj is except[i]) {
							return null;
						}
					}
				}
				if (obj is IMutualUnit) {
					return obj as IMutualUnit;
				}
				tar=obj;
			}
			return null;
		}

		public static function checkClass(target:DisplayObject, ClassType:Class):Boolean {
			if (target is ClassType) {
				return true;
			}
			while (target.parent != null) {
				var obj:DisplayObject=target.parent;
				if (obj is ClassType) {
					return true;
				}
				target=obj;
			}
			return false;
		}

		public static function checkIsTypeClass(tar:DisplayObject, typeClass:Array):Boolean {
			while (tar.parent != null) {
				var obj:DisplayObject=tar.parent;
				for (var i:int=0; i < typeClass.length; i++) {
					if (obj is typeClass[i]) {
						return true;
					}
				}
				tar=obj;
			}
			return false;
		}
	}
}