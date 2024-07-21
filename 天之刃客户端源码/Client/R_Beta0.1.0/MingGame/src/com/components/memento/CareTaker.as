package com.components.memento
{
	import com.engine.utils.hash.Hash;

	public class CareTaker
	{
		
		private var hash:Hash;
		public function CareTaker(sigleton:SigletonPress)
		{
			init();
		}
		
		public static function get instance():CareTaker
		{
			if(_instance == null)
				_instance = new CareTaker(new SigletonPress);
			
			return _instance;
		}
		
		private function init():void
		{
			this.hash = new Hash();
		}
		
		public function addMemento(key:String, value:Memento):void
		{
			hash.remove(key);
			
			hash.put(value, key);
		}
		
		public function getMemento(key:String):Memento
		{
			var result:Memento = hash.take(key) as Memento;
			
			return result;
		}
		
		public function removeMemento(key:String):Memento
		{
			return hash.remove(key) as Memento;
		}
		
		public function unload():void
		{
			_instance = null;
			hash.unload();
		}
		
		private static var _instance:CareTaker;
	}
}
class SigletonPress{}