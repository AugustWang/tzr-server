package com.ming.ui.containers.treeList.events
{
	import flash.events.Event;
	
	public class DataChangeEvent extends Event
	{
		protected var _items:Array;
		protected var _endIndex:uint;
		protected var _changeType:String;
		protected var _startIndex:uint;
		public static const PRE_DATA_CHANGE:String = "preDataChange";
		public static const DATA_CHANGE:String = "dataChange";
		
		public function DataChangeEvent(type:String, changeType:String, items:Array, startIndex:int = -1, endIndex:int = -1)
		{
			super(type);
			_changeType = changeType;
			_startIndex = startIndex;
			_items = items;
			_endIndex = endIndex == -1 ? (_startIndex) : (endIndex);
		}
		
		public function get changeType() : String
		{
			return _changeType;
		}
		
		public function get startIndex() : uint
		{
			return _startIndex;
		}
		
		public function get items() : Array
		{
			return _items;
		}
		
		override public function clone() : Event
		{
			return new DataChangeEvent(type, _changeType, _items, _startIndex, _endIndex);
		}
		
		override public function toString() : String
		{
			return formatToString("DataChangeEvent", "type", "changeType", "startIndex", "endIndex", "bubbles", "cancelable");
		}
		
		public function get endIndex() : uint
		{
			return _endIndex;
		}
	}
}