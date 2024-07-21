package com.ming.ui.style
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	/**
	 * 为了避免组件过多的占用内存，因而将组件皮肤的Bitamp共享一个bitmapdata,这就导致bitmapdata不能随意被销毁
	 * 否则就导致所有组件不能被使用,但是组件的bitmapdata当在外部没有使用时就需要销毁，所以针对这些设计BitampDataPool来
	 * 管理这些bitmapData,由它来统一销毁和调用（模拟flash player的内存回收机制引用计数来实现回收） 
	 * 
	 */	
	public class BitmapDataPool
	{
		private var pool:Dictionary;
		public function BitmapDataPool()
		{
			pool = new Dictionary();
		}
		private static var instance:BitmapDataPool;
		public static function getInstance():BitmapDataPool{
			if(instance == null){
				instance = new BitmapDataPool();
			}
			return instance;
		}
		
		
		public function dispose(name:String,url:String):void{
			var bitmapData:BitmapData = pool[name+"_"+url];
			if(bitmapData){
				bitmapData.dispose();
				delete pool[name+"_"+url];
			}
		}
		
		public function getBitmapData(name:String,url:String):BitmapData{
			if(name == "" || name == null)return null;
			var bitmapData:BitmapData = pool[name+"_"+url];
			return bitmapData;
		}
		
		public function addBitmapData(name:String,url:String,bitmapData:BitmapData):void{
			pool[name+"_"+url] = bitmapData;
		}
	}
}
