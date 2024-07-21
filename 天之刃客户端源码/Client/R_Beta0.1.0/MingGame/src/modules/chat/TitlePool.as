package modules.chat
{
	import com.loaders.CommonLocator;

	public class TitlePool
	{
//		public static const BASE_DIR:String = "com/assets";
		
		public var titleXML:XML;
		public function TitlePool()
		{
		
			titleXML = CommonLocator.getXML(CommonLocator.TITLE);
			
//			var byte:ByteArray = loader.data;
//			byte.position = 0;
//			titleXML:XML = XML(byte.readUTFBytes(byte.length));
			
			
		}
		
		private static var instance:TitlePool;
		public static function getInstance():TitlePool{
			if(instance == null){
				instance = new TitlePool();
			}
			return instance;
		}
		
		/* name:String;
		public var id:int;
		public var type:int;
		public var chatType:int;
		public var color:String ;
		public var url:String;
		public  var mark:int; // String */
		public function getObject(name:String):Object
		{
			var obj:Object={};
			var item:XML ;//= titleXML.title.(@name == name)[0];
			for each(var itemxml:XML in titleXML.title)
			{
				if(itemxml.@name == name)
				{
					item = itemxml;
					break;
				}
			}
			if(!item)
				return null;
			
			obj.id = int(item.@id);
			obj.name = String(item.@name);
			obj.url =  String(item.@url);//BASE_DIR +
			obj.type = int(item.@type);
			obj.chatType = int(item.@chatType);
			obj.mark = int(item.@mark);
			obj.color = String(item.@color);
			obj.chatName = String(item.@chatName);
			
			return obj;
		}
	}
}