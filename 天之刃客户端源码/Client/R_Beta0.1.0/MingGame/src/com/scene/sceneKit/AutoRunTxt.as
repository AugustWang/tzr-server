package com.scene.sceneKit {
	import com.globals.GameConfig;

	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class AutoRunTxt extends Sprite {

		private var zidongTxt:MovieClip;

		public function AutoRunTxt() {
		}

		public function zdxlPlay():void {
			if (!zidongTxt) {
				var MC:Class=Style.getClass(GameConfig.MOVIE_UI, "ZiDongXunLu");
				zidongTxt=new MC;
				zidongTxt.play();
				zidongTxt.x=-64;
				addChild(zidongTxt);
			}
			zidongTxt.play();
		}

		public function zdxlRemove():void {
			if (zidongTxt) {
				zidongTxt.stop();
			}
			if (this.parent) {
				this.parent.removeChild(this);
			}
		}
	}
}