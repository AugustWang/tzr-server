package com.utils
{
	import flash.net.SharedObject;

	public final class ShareObjectUtil
	{
		public static var minDiskSpace:int = 10000;
		public static const MCSODATA:String = "mgeData";
		private static var shareObject:SharedObject;
		public function ShareObjectUtil()
		{
			
		}
		
		public static function save(name:String,data:Object=null, errorFun:Function = null):void
		{
			try
			{
				if(shareObject == null){
					shareObject = SharedObject.getLocal(MCSODATA);
				}
				shareObject.data[name] = data;
			}catch(e:Error){
				if(errorFun != null)
					errorFun.apply(null,null);
			}
		}
		
		public static function read(name:String, errorFun:Function = null):Object
		{
			try{
				if(shareObject == null){
					shareObject = SharedObject.getLocal(MCSODATA);
				}
				if(shareObject.data.hasOwnProperty(name))
					return shareObject.data[name];
			}
			catch(e:Error){
				if(errorFun != null)
					errorFun.apply(null, null);
			}
			
			return null;
		}

	}
}