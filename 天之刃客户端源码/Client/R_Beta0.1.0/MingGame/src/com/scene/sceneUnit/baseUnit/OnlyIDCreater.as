package com.scene.sceneUnit.baseUnit
{
	
	public class OnlyIDCreater
	{
		private static var ID_INDEX:uint=0;
		
		public static function createID():String
		{
			ID_INDEX++;
			return ID_INDEX + "";
		}
	}
}