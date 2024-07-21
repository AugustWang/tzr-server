package com.scene.tile
{
	import flash.system.System;
	import flash.utils.Dictionary;

	/**
	 *  简单哈希表
	 * @author sai
	 * @playerversion flashplayer 10
	 */
	public class Hash
	{
		private var hash:Dictionary
		private var _length:int
		public function Hash()
		{
			this.hash=new Dictionary
		}
		/**
		 *  元素长度
		 * @return 
		 * 
		 */		
		public function get length():int
		{
			return _length;
		}

		
		/**
		 *  添加元素
		 * @param key
		 * @param value
		 * 
		 */		
		public function put(value:Object,key:String):void
		{
			if(!this.has(key)){
				this.hash[key]=value
					this._length++
			}
		}
		/**
		 *  判断元素是否存在
		 * @param key
		 * @return 
		 * 
		 */		
		public function has(key:String):Boolean
		{
			if(key==null)return false;
			if(hash==null)return false;
			if(this.hash[key]!=null)return true;
			return false
		}
		/**
		 *  删除元素
		 * 
		 * @param key
		 * 
		 */		
		public function remove(key:String):Object
		{
			if(this.has(key)){
				var obj:Object=this.hash[key]
				delete this.hash[key];
				this._length--
					return obj
			}
			return null
		}
		/**
		 * 御载 
		 * 
		 */		
		public function unload():void
		{
			
			this.hash=null;
			this._length=0;
		}
		public function take(key:String):Object
		{
			if(this.hash!=null){
			return this.hash[key]
			}else{
				return null;
			}
		}
		/**
		 *  初始化
		 * 
		 */		
		public function init():void
		{
			this.hash=new Dictionary
			this._length=0;
		}
		/**
		 * 返回当前哈希表的引用 
		 * @return 
		 * 
		 */		
		public function get hashMap():Dictionary
		{
			return this.hash
		}
		public function set hashMap(value:Dictionary):void
		{
			this.hash=value
		}
		/**
		 * 返回哈希表当前的元素列表 
		 * @return 
		 * 
		 */		
		public function get values():Vector.<Object>
		{
			var array:Vector.<Object>=new Vector.<Object>
			for(var i:String in this.hash){
				array.push(this.hash[i])
			}
			return array
		}
		/**
		 *   
		 * @return 
		 * 
		 */		
		public function get valuesArray():Array
		{
			var array:Array=new Array
			for(var i:String in this.hash){
				array.push(this.hash[i])
			}
			return array
		}
	}
}