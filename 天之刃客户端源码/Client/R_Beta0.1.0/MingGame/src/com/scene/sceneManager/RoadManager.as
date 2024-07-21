package com.scene.sceneManager {
	import com.scene.sceneData.HandlerAction;

	public class RoadManager {
		public static var cut:int = 0;
		public static var macroPath:Array=[];
		public static var action:HandlerAction;

		public function RoadManager() {
		}

		public static function pathAndAction(path:Array,cutCount:int,handAction:HandlerAction=null):void {
			macroPath=path;
			action=handAction;
			cut = cutCount;
		}

		public static function clear():void {
			macroPath=[];
			action=null;
			cut = 0;
		}
	}
}