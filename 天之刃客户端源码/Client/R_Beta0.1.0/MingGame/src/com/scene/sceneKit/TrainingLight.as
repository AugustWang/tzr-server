package com.scene.sceneKit {
	import com.globals.GameConfig;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	public class TrainingLight extends Sprite {
		private var lotus:Thing;

		public function TrainingLight() {
			super();
			lotus=new Thing;
			lotus.load(GameConfig.OTHER_PATH + "training_light.swf");
			addChild(lotus);
			lotus.play(4, true);
			lotus.x=-1;
			lotus.y=2;
			lotus.scaleX=lotus.scaleY=1.2;
		}

		public function remove():void {
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}
	}
}
