package com.scene.sceneUnit.baseUnit.things.effect
{
	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	
	import flash.display.Sprite;

	public class SceneEffect extends Sprite
	{
		public var onlyKey:String;
		public function SceneEffect()
		{
			onlyKey = OnlyIDCreater.createID();
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
	}
}