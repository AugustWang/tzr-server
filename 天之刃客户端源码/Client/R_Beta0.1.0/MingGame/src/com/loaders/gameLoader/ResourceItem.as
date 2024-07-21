package com.loaders.gameLoader
{
	import flash.utils.ByteArray;

	public class ResourceItem
	{
		public static const SWF:String = "swf";
		public static const FILE:String = "file";
		public static const IMAGE:String = "image";
		
		public static const MAP:String = "map";
		
		public var data:Object;
		public var handler:Function;
		public var url:String;
		public var priority:int;
		public var reload:Boolean;
		public var sourceType:String;
		public var content:ByteArray;
		public function ResourceItem()
		{
		}
		
		public function get type():String{
			//此处匹配如果需要更智能匹配，可以换成正则表达式
			var endFix:String = url.substr(-3,3);
			endFix = endFix.toLowerCase();
			if(endFix == SWF){
				return SWF;
			}else if(endFix == "xml" || endFix == "txt" || endFix == "lib"){
				return FILE;
			}else if(endFix == "png" || endFix == "jpg"){
				return IMAGE;
			}
			throw new Error("非法文件类型！");
		}
	}
}