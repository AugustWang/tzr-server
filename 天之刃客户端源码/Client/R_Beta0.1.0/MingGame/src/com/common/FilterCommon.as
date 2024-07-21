package com.common
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	public class FilterCommon
	{
		public static const FONT_BLACK_FILTERS:Array = [new GlowFilter(0x000000,1,3,3,3)];
		public static const SHADOW_BLACK_FILTERS:Array = [new DropShadowFilter(2,45,0,1,2,2)];
		public static const GRAY_MATRIX:Array=[new ColorMatrixFilter([0.5, 0.5, 0.082, 0, -50, 0.5, 0.5, 0.082, 0, -50, 0.5, 0.5, 0.082, 0, -50, 0, 0, 0, 1, 0])];
		private static var _PACK_FILTERS:Array = null;
		public function FilterCommon()
		{
		}
		
		public static function get PACK_FILTERS():Array {
			if (_PACK_FILTERS == null) {
				var mat:Array=[1, 0, 0, 0, 40, 0, 1, 0, 0, 40, 0, 0, 1, 0, 40, 0, 0, 0, 1, 0];
				var f:ColorMatrixFilter=new ColorMatrixFilter(mat);
				_PACK_FILTERS =[f, new GlowFilter(0xffff00, 1, 5, 5, 3, 1), new GlowFilter(0xffff00, 1, 3, 3, 3, 1, true)];
			}
			return _PACK_FILTERS;
		}

	}
}