package com.scene.sceneKit
{
	import com.globals.GameConfig;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Sprite;
	
	public class SelectedStyle extends Sprite
	{
		private static var _instance:SelectedStyle;
		private var lotus:Thing;
		
		public function SelectedStyle()
		{
			super();
			lotus=new Thing;
			lotus.load(GameConfig.OTHER_PATH + "guanquan.swf");
			addChild(lotus);
		}
		
		public static function get instance():SelectedStyle
		{
			if (_instance == null)
			{
				_instance=new SelectedStyle;
			}
			return _instance;
		}
		
		public function set color(color:int):void
		{
			lotus.gotoAndStop(color);
		}
		
		public function reParent(father:Sprite=null):void
		{
			if (this.parent != null)
			{
				this.parent.removeChild(this);
			}
			if (father != null)
			{
				father.addChildAt(this, 0);
			}
		}
	}
}