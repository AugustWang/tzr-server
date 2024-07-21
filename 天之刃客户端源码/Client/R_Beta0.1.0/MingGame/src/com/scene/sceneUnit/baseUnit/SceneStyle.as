package com.scene.sceneUnit.baseUnit {
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;

	public class SceneStyle {
		private static var _bodyFilter:Array;
		private static var _deathFilter:ColorMatrixFilter;
		private static var _nameFilter:GlowFilter;

		public static function get bodyFilter():Array {
			if (_bodyFilter == null) {
				_bodyFilter=[new GlowFilter(0xffffff, 1, 6, 6, 6, 1)];
			}
			return _bodyFilter;
		}

		public static function get deathFilter():Array {
			if (_deathFilter == null) {
				var mat:Array=[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]
				_deathFilter=new ColorMatrixFilter(mat);
			}
			return [_deathFilter];
		}

		public static function get nameFilter():Array {
			if (_nameFilter == null) {
				_nameFilter=new GlowFilter(0x000000, 1, 2, 2, 20)
			}
			return [_nameFilter];
		}

	}
}