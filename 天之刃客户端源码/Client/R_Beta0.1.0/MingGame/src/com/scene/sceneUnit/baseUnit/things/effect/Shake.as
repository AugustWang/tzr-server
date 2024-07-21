package com.scene.sceneUnit.baseUnit.things.effect {

	import com.gs.TweenLite;
	import com.gs.TweenMax;
	import com.scene.GameScene;
	
	import flash.display.DisplayObject;
	import flash.utils.setTimeout;
	
	import modules.scene.SceneModule;

	public class Shake {
		private static var tween:TweenMax

		public function Shake() {
		}

		public static function shake(target:DisplayObject, dis:int=15, time:Number = 0.5, onComplete:Function=null):void {
			var x:Number=target.x;
			var y:Number=target.y
			var f:int=dis;
			if (tween)
				TweenMax.killTweensOf(tween);
//			tween=TweenMax.to(target, time, {bezier: [{x: x - f, y: y - f}, {x: x, y: y}, {x: x - f, y: y + f}, {x: x, y: y},
//						{x: x + f, y: y + f}, {x: x, y: y}, {x: x + f, y: y - f}, {x: x, y: y}, {x: x, y: y}], onComplete: onComplete,
//					onCompleteParams: [target]});
			tween=TweenMax.to(target, time, {bezier: [{x: x + 15, y: y + 15}, {x: x-15, y: y-15},{x: x + 7, y: y +7}, {x: x-6, y: y-6},
				{x: x + 4, y: y + 4}, {x: x-2, y: y-2}, {x: x, y: y},{x: x, y: y}], onComplete: onComplete,
				onCompleteParams: [target]});

		}

		public static function onComplete(target:DisplayObject):void {
			GameScene.getInstance().x=GameScene.getInstance().x;
			GameScene.getInstance().y=GameScene.getInstance().y;
		}

		public static function shakeScene(dis:int = 8,time:Number=0.6):void {
			Shake.shake(GameScene.getInstance(), dis, time, onComplete);
		}
	}
}