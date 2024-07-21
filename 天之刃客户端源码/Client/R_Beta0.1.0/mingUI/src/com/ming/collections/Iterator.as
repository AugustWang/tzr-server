package com.ming.collections{
	/**
	 * 迭代器
	 */ 
	public class Iterator implements IIterator {
		
		private var _index:uint = 0;
		private var _collection:Array;
		/**
		 * 是否还有下一个 
		 * @return  true or false
		 * 
		 */		
		public function hasNext():Boolean {
			return _index < _collection.length && _collection.length > 0;
		}
		/**
		 * 返回下一个 
		 * @return object
		 * 
		 */		
		public function next():Object {
			return _collection[++_index];
		}
		/**
		 * 重置迭代器 
		 * 
		 */		
		public function reset():void {
			_index = 0;
		}
		/**
		 * 通过数组构造迭代器 
		 * @param collection 数组结构
		 * 
		 */		
		public function Iterator(collection:Array) {
			_collection = collection;
			_index = 0;
		}
		
	}
}