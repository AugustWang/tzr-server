package com.managers {
	import com.common.GlobalObjectManager;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import modules.ModuleCommand;

	public class ReSizeManager {
		public static var main:MingGame;
		public static var stage:Stage;
		public static var minWidth:int = 1002;
		public static var minHeight:int = 545;

		public function ReSizeManager() {
		}
		
		public static function init(mingGame:MingGame):void{
			main = mingGame;
			stage = main.stage;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.ACTIVATE, activateHandler);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			GlobalObjectManager.GAME_WIDTH = stage.stageWidth;
			GlobalObjectManager.GAME_HEIGHT = stage.stageHeight;
		}
		
		private static function resizeHandler(event:Event):void{
			GlobalObjectManager.GAME_WIDTH = Math.max(stage.stageWidth,minWidth);
			GlobalObjectManager.GAME_HEIGHT = Math.max(stage.stageHeight,minHeight);
			Dispatch.dispatch(ModuleCommand.STAGE_RESIZE,{width:GlobalObjectManager.GAME_WIDTH,height:GlobalObjectManager.GAME_HEIGHT});
		}
		
		private static function activateHandler(event:Event):void{
			
		}
	}
}