package com.loaders
{
	import com.ming.utils.Handler;
	
	import flash.utils.Dictionary;

	public class ViewLoader
	{
		private static var sourceLoader:SourceLoader;
		private static var buzy:Boolean = false;
		public function ViewLoader()
		{
		}
		
		public static function hasLoaded(url:String):Boolean{
			return ResourcePool.hasResource(url);
		}
		
		public static function load(url:String,completeFunc:Function,params:Array=null):void{
			if(!buzy && !ResourcePool.hasResource(url)){
				if(sourceLoader == null){
					sourceLoader = new SourceLoader();
				}
				buzy = true;
				sourceLoader.loadSource(url,"",completeHandler,errorHandler);
			}
			function completeHandler():void{
				if(completeFunc != null){
					completeFunc.apply(null,params);
				}
				buzy = false;
			}
			function errorHandler():void{
				buzy = false;
			}
		}
		

	}
}