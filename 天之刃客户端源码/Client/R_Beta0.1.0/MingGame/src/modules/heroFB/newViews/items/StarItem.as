package modules.heroFB.newViews.items {
	import com.globals.GameConfig;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import modules.flowers.views.Star;

	public class StarItem extends Sprite {
		private var _value:int;
		private var _max:int;
		private var stars:Vector.<Bitmap>;
		public var vPadding:int = 10;
		public function StarItem() {
			super();
			stars=new Vector.<Bitmap>;
		}
		
		public function update(value:int,max:int):void {
			if (value != _value || max != _max) {
				var count:int = max - _max;
				if(count > 0){
					for(var i:int =0; i < count; i++){
						var star:Bitmap = new Bitmap();
						addChild(star);
						stars.push(star);
					}
				}else if(count < 0){
					for(i =0; i < count; i++){
						removeChild(stars.pop());
					}
				}
				for(i = 0; i< stars.length; i++){
					var item:Bitmap = stars[i];
					if(i+1 <= value && item.name != "1"){
						item = Style.getBitmap(GameConfig.T1_VIEWUI,"star_6");
						item.name = "1";
					}else if(item.name != "0"){
						item = Style.getBitmap(GameConfig.T1_VIEWUI,"star_1");
						item.name = "0";
					}
					item.x = i*22;
					addChild(item);
				}
			LayoutUtil.layoutGrid(this,max,0,0);
				_value = value;
				_max = max;
			}
		}
	}
}