package com.scene.sceneUnit
{
	
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.scene.sceneUnit.baseUnit.MutualThing;
	import com.scene.sceneUtils.SceneUnitType;
	
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;
	
	public class MapStuff extends MutualThing
	{
		private var _type:String;
		private var title:TextField;
		
		public function MapStuff(url:String, type:String="throne")
		{
			super();
			_type=type;
			sceneType=SceneUnitType.MAP_STUFF_TYPE;
			init(url);
			this.buttonMode=true;
		}
		
		public function get type():String
		{
			return _type;
		}
		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().setCursor(CursorName.HAND);
			}
		}
		
		override public function mouseOut():void {
			super.mouseOut();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().clearAllCursor();
			}
		}
		
		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}

	}
}