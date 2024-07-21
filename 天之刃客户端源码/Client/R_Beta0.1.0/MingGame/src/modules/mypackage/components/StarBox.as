package modules.mypackage.components
{
	import com.globals.GameConfig;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class StarBox extends Sprite
	{
		private var stars:Array;
		public function StarBox()
		{
			super();
			stars = [];
			var starBitmap:Bitmap;
			var startX:int = 0;
			for(var i:int=0;i<6;i++){
				starBitmap = new Bitmap();
				starBitmap.x = startX;
				startX += 17;
				addChild(starBitmap);
				stars.push(starBitmap);
			}
		}
		
		public function setStar(count:int,color:int):void{
			removeStars();
			var starBitmap:Bitmap;
			for(var i:int=0;i<count;i++){
				starBitmap = stars[i];
				starBitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"star_"+color);
			}
		}
		
		public function removeStars():void{
			for each(var bitmap:Bitmap in stars){
				bitmap.bitmapData = null;
			}
		}
	}
}