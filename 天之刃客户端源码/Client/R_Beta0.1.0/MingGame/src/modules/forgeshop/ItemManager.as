package modules.forgeshop
{
	import com.loaders.CommonLocator;

	public class ItemManager
	{
		private static var _instance:ItemManager;
		public static function getInstance():ItemManager{
			if(!_instance){
				_instance = new ItemManager();
			}
			return _instance;
		}
		public var arr:Array = [];
		public function ItemManager()
		{
			var xml:XML = CommonLocator.getXML(CommonLocator.CANTBUYITEM);
			for each(var m:XML in xml.material){
				arr.push(int(m.@id));
			}
		}
	}
}