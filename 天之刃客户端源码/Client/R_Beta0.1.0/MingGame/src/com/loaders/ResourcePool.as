package com.loaders
{
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	/**
	 * 资源池 
	 */	
	public class ResourcePool
	{
		private static var sources:Dictionary = new Dictionary(true);
		
		public function ResourcePool()
		{
			
		}
		
		public static function add(url:String,source:*):void{
			sources[url] = source;
		}
		
		public static function get(url:String):*{
			return sources[url];
		}
		
		public static function remove(url:String):*{
			var source:* = get(url);
			delete sources[url];
			return source;
		}
		
		public static function hasResource(url:String):*{
			return sources[url] != null;
		}
		
		public static function getClass(url:String,name:String):*{
			var domain:ApplicationDomain = sources[url];
			if(domain && domain.hasDefinition(name)){
				return domain.getDefinition(name);
			}
			return  null;
		}
		
		public static function dispose():void{
			sources = null;
		}
	}
}