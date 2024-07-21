package com.net.connection
{
	import flash.utils.Dictionary;

	/**
	 * 协议配置 
	 * @author Administrator
	 * 
	 */	
	public class ServerMapConfig
	{
		public static var protocolXML:XML;
		private static var methodIdMap:Dictionary = new Dictionary(true);
		private static var methodMap:Dictionary = new Dictionary(true);
		public function ServerMapConfig()
		{
					
		}
		/**
		 * 解析Method 并缓存
		 */	
		private static function analyse(xml:XML):Object{
			var name:String = xml.@name;
			var id:int = xml.@id;
			var module:String = xml.parent().@name;
			var moduleId:int = xml.parent().@id;
			var packageName:String = xml.parent().parent().@name;
			var desc:Object = {name:name,id:id,module:module,moduleId:moduleId,packageName:packageName};
			methodIdMap[id] = desc;
			methodMap[name] = desc;
			return desc;
		}
		
		public static function getMethodById(methodId:int):Object{
			if(!methodIdMap[methodId]){
				var list:XMLList = protocolXML..method.(@id == methodId);
				if(list && list.length() > 0){
					return analyse(list[0]);	
				}
			}
			return methodIdMap[methodId];
		}

		public static function getMethodByName(method:String):Object{
			
			if(!methodMap[method]){
				if(method == 'BGP_LOGIN'){
					methodMap[method] = {name:method,id:7701,module:'BGP',moduleId:'77',packageName:'line'};
					methodIdMap[7701] = methodMap[method];
					return methodMap[method];
				}else{
					var list:XMLList = protocolXML..method.(@name == method);
					if(list && list.length() > 0){
						return analyse(list[0]);	
					}
				}
			}
			return methodMap[method];
		}
	}
}