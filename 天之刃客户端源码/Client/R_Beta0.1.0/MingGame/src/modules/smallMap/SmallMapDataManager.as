package modules.smallMap {
	import com.globals.GameConfig;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class SmallMapDataManager {
		private static var bits:Array; // 0.紫、1.粉红、2.红、3.深蓝、4.绿、5.黑、6浅蓝.、7.白、8.朱红、9.黄、10.橙、11.青

		public function SmallMapDataManager() {
		}

		public static function initBits():void {
			bits=[];
			var bitClazz:Class=Style.getClass(GameConfig.T1_VIEWUI, "smallMapPoints");
			var bitmapData:BitmapData=new bitClazz(0, 0);
			for (var i:int=0; i < 12; i++) {
				var xx:int=int(i % 4) * 10;
				var yy:int=int(i / 4) * 10;
				var bit:BitmapData=new BitmapData(10, 10, true, 0);
				bit.copyPixels(bitmapData, new Rectangle(xx, yy, 10, 10), new Point());
				bits.push(bit);
			}
		}

		public static function getBit(index:int):BitmapData {
			return bits[index];
		}
	}
}