package com.scene.sceneKit {
	import com.globals.GameConfig;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class GuajiTxt extends Sprite {
		private var guajiTxt:MovieClip;

		public function GuajiTxt() {
		}
		
		public function gjPlay():void{
			if(!guajiTxt){											
				var MC:Class=Style.getClass(GameConfig.MOVIE_UI, "ZiDongDaGuai");
				guajiTxt=new MC;
				guajiTxt.play();
				guajiTxt.x = -64;
				addChild(guajiTxt);
			}
			guajiTxt.play();
		}
		
		public function gjRemove():void{
			if(guajiTxt){
				guajiTxt.stop();
			}
			if(this.parent){
				this.parent.removeChild(this);
			}
		}
		
	}
}