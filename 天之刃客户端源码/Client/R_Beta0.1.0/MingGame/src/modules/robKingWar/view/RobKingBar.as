package modules.robKingWar.view {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.gs.TweenMax;
	import com.ming.ui.controls.Image;

	import flash.display.Sprite;
	import flash.utils.clearTimeout;

	public class RobKingBar extends Sprite {
		private static var _instance:RobKingBar;
		private var bg:Image;
		private var bar:Image;

		public function RobKingBar() {
			super();
			init();
		}

		public static function get instance():RobKingBar {
			if (_instance == null) {
				_instance=new RobKingBar;
			}
			return _instance;
		}

		private function init():void {
			this.mouseChildren=false;
			this.mouseEnabled=false;
			bg=new Image;
			bar=new Image;
			bg.source=GameConfig.ROOT_URL + "com/ui/robKing/robBarBg.png";
			bg.width=225;
			bg.height=79;
			bg.x=-bg.width / 2;
			bg.y=-bg.height / 2;
			bar.source=GameConfig.ROOT_URL + "com/ui/robKing/robBar.png";
			bar.width=149;
			bar.height=19;
			bar.x=-bar.width / 2;
			bar.y=bg.y + 45;
			bar.scaleX=0;
			addChild(bg);
			addChild(bar);
		}

		public function reset():void {
			TweenMax.killTweensOf(bar);
			bar.scaleX=0;
		}

		public function update(percent:Number):void {
			TweenMax.to(bar, 1.2, {scaleX: percent});
		}
	}
}