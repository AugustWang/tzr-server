package modules.bigExpresion
{
	import com.loaders.CommonLocator;
	

	public class BigExpresionDataManager
	{
		private static var _instance:BigExpresionDataManager;
		public static function getInstance():BigExpresionDataManager{
			if(!_instance){
				_instance = new BigExpresionDataManager();
			}
			_instance.load();
			return _instance;
		}
		
		public var arr:Array;
		public function load():void{
			arr = [];
			var xml:XML = CommonLocator.getXML(CommonLocator.EXPRESION);
			
			for each(var m:XML in xml.exp){
				var obj:Object = {};
				obj.name = m.@name.toString();
				obj.id = int(m.@id);
				obj.type = int(m.@type);
				obj.receive = m.@receive.toString();
				obj.send = m.@send.toString();
				obj.self = m.@self.toString();
				arr.push(obj);
			}
			arr.sortOn("id",Array.NUMERIC);
		}
	}
}