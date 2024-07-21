package modules.goal
{
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	import com.loaders.queueloader.QueueEvent;
	import com.scene.sceneKit.LoadingSetter;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import modules.goal.vo.GoalVO;

	public class GoalResource
	{
		public static var GOAL_SWF_PATH:String = "com/assets/goal/goal.swf";
		
		public static var loaded:Boolean = false; 
		private static var goalXML:XML;
		private static var swfDomain:ApplicationDomain;
		private static var loader:Loader;
		private static var loading:Boolean = false;
		public static var callBack:Function;
		public function GoalResource()
		{
		}
		
		public static function loadGoalResource():void{
			if(loaded == false && !loading){
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onItemIOError);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onItemProgress);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onItemComplete);
				GOAL_SWF_PATH = GameConfig.ROOT_URL+GOAL_SWF_PATH;
				loader.load(new URLRequest(GOAL_SWF_PATH));
				loading = true;
			}
			
		}
		
		private static function onItemProgress(event:ProgressEvent):void{
			LoadingSetter.mapLoading(true,event.bytesLoaded/event.bytesTotal,"正在加载资源......");
		}
		
		private static function onItemIOError(event:IOErrorEvent):void{
			Alert.show("抱歉，资源加载不成功，请刷新后重新！");	
			loading = false;
			LoadingSetter.mapLoading(false);
		}
		
		private static function onItemComplete(event:Event):void{
			swfDomain = loader.contentLoaderInfo.applicationDomain;
			loader.unload();
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onItemIOError);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onItemProgress);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onItemComplete);
			loader = null;
			loaded = true;
			loading = false;
			if(callBack != null){
				callBack.apply(null,null);
			}
			LoadingSetter.mapLoading(false);
		}
		
		public static function getBitmapData(name:String):BitmapData{
			if(swfDomain && swfDomain.hasDefinition(name)){
				var clazz:Class = swfDomain.getDefinition(name) as Class;
				return new clazz(0,0);
			}
			return new BitmapData(0,0);
		}
		
		public static function getGoals():Array{
			if(goalXML == null){
				goalXML = CommonLocator.getXML(CommonLocator.GOAL_XML_PATH);
			}
			var goalXMLList:XMLList = goalXML..goal;
			var i:int = 0;
			var items:Array = [];
			for each(var itemXML:XML in goalXMLList){
				var goalVO:GoalVO = new GoalVO();
				goalVO.label = itemXML.@label;
				goalVO.active = itemXML.@active;
				goalVO.index = i++;
				goalVO.goalXML = itemXML;
				goalVO.parse();
				items.push(goalVO);
			}
			return items;
		}
		
	}
}