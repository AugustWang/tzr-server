package com.scene.sceneUnit
{
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.scene.sceneUnit.baseUnit.MutualThing;
	
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;
	
	public class Planting extends MutualThing
	{
		public function Planting()
		{
			super();
		}
		override public function mouseOver():void
		{
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false)
			{
				CursorManager.getInstance().setCursor(CursorName.TALK);
			}
		}
		
		override public function mouseOut():void
		{
			super.mouseOut();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false)
			{
				CursorManager.getInstance().clearAllCursor();
			}
		}
		
		override public function mouseDown():void
		{
			MyRoleControler.getInstance().onClickUnit(this);
		}
	}
}