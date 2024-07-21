package modules.mypackage.operateMode
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 背包处于某种模式下的操作情况 
	 */
	public class OperateMode extends EventDispatcher
	{
		public static const NORMAL_MODE:int = 10;
		public static const DEAL_MODE:int = 9;
		public static const BT_MODE:int = 8;
		public static const FML_DEPOT_MODE:int = 7;

		private var currentModes:Array;
		public function OperateMode()
		{
			currentModes = [NORMAL_MODE];
		}
		
		private static var instance:OperateMode;
		public static function getInstance():OperateMode{
			if(instance == null){
				instance = new OperateMode();
			}
			return instance;
		}
		
		private var mode:int;
		public function setMode(modeId:int):void{
			var index:int = currentModes.indexOf(modeId);
			if(index != -1){
				return;
			}
			currentModes.push(modeId);
			currentModes.sort(Array.NUMERIC);
			mode = modeName;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function removeMode(modeId:int):void{
			var index:int = currentModes.indexOf(modeId);
			if(index != -1){
				currentModes.splice(index,1);
			}
			mode = modeName;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get modeName():int{
			return currentModes[0];
		}
	}
}