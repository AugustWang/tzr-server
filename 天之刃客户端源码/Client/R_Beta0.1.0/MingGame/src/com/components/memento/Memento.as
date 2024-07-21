package com.components.memento
{
	public class Memento
	{
		public var x:Number;
		
		public var y:Number;
		
		public var object:Object;
		
		public function Memento()
		{
		}
		
		public function save(key:String):void
		{
			CareTaker.instance.addMemento(key, this);
		}
		
		public static function getMemento(key:String):Memento
		{
			return CareTaker.instance.getMemento(key);
		}
		
		public static function removeMemento(key:String):Memento
		{
			return CareTaker.instance.removeMemento(key);
		}
		
	}
}