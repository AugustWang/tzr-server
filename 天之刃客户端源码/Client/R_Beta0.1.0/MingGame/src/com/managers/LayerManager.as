package com.managers
{
	import com.common.cursor.CursorManager;
	import com.globals.GameParameters;
	import com.layers.UILayer;
	import com.ming.managers.FocusManager;
	import com.ming.managers.ToolTipManager;
	
	import flash.display.Sprite;
	import flash.display.Stage;

	public class LayerManager
	{
		public static var main:MingGame;
		public static var uiLayer:UILayer;
		public static var sceneLayer:Sprite;
		public static var windowLayer:Sprite;
		public static var alertLayer:Sprite;
		public static var stage:Stage;
		
		public function LayerManager()
		{
		}
		
		public static function init(mingGame:MingGame):void{
			main = mingGame;
			stage = main.stage;
		}
		
		public static function createLayers():void{
			stage.stageFocusRect=false;
			CursorManager.init(stage);
			
			sceneLayer = new Sprite();
			sceneLayer.tabChildren=sceneLayer.tabChildren=false;
			main.addChild(sceneLayer);
			
			uiLayer = new UILayer();
			uiLayer.tabEnabled=uiLayer.tabChildren=false;
			main.addChild(uiLayer);
			
			windowLayer = new Sprite();
			windowLayer.mouseEnabled=false;
			windowLayer.tabEnabled = windowLayer.tabChildren=false;
			main.addChild(windowLayer);
			WindowManager.getInstance().registerWindowContainer(windowLayer);
			
			alertLayer = new Sprite();
			main.addChild(alertLayer);
			ToolTipManager.getInstance().registerContainer(main);
			
			FocusManager.getInstance().stage = stage;
//			if(GameParameters.getInstance().debug == "true"){
//				var f:FPS=new FPS();
//				f.x=54;
//				f.y=68;
//				main.addChild(f);
//			}
		}
	}
}