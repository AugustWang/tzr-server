package com.scene.sceneKit {
	import com.globals.GameConfig;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.ui.Mouse;

	public class MouseIcon extends Sprite {
		private static var _instance:MouseIcon;
		private var view:MovieClip;
		private var timeOutId:int;
		public var isRoading:Boolean;

		public function MouseIcon() {
			super();
			var MC:Class=Style.getClass(GameConfig.MOVIE_UI, "mouseArray");
			view=new MC;
			view.gotoAndStop(view.totalFrames - 1);
			addChild(view);
			this.mouseChildren=false;
			this.mouseEnabled=false;
		}


		public function reset(p:Point):void {
			if(isFreezing){
				Mouse.show();
			}
			view.gotoAndPlay(1);
			this.x=p.x;
			this.y=p.y;
			isRoading=false;
		}
		
		private var isFreezing:Boolean = false;
		public function freezing(value:Boolean, mouseX:Number, mouseY:Number):void {
			isFreezing = value;
			if (value == true) {
				Mouse.hide();	
				if (view.totalFrames != view.currentFrame) {
					view.gotoAndStop(view.totalFrames);
				}
				isRoading=true;
			} else {
				Mouse.show();
				view.gotoAndStop(view.totalFrames - 1);
			}
			this.x=mouseX;
			this.y=mouseY;
		}

		public static function get instance():MouseIcon {
			if (_instance == null) {
				_instance=new MouseIcon;
			}
			return _instance;
		}
	}
}