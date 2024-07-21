package modules.trading.tradingManager
{
	import com.loaders.CommonLocator;
	
	public class TradingLocator
	{
		public static const BASE_DIR:String = "com/assets";
		
		public var tradingXML:XML;
		
		private static var instance:TradingLocator;
		public static function getInstance():TradingLocator{
			if(instance == null){
				instance = new TradingLocator();
			}
			return instance;
		}
		
		public function TradingLocator()
		{
			tradingXML = CommonLocator.getXML(CommonLocator.TRADING);
			
		}
		
		public function getObject(typeId:int,npcId:int):Object{
			var obj:Object = {};
			var item:XML = tradingXML.items.(@id == typeId)[0];
			var subItem:XML = item.item.(@npc_id == npcId)[0];
			if(!subItem)
			{
				return null;
			}
				obj.type_id = typeId;
				obj.name = String(subItem.@name);
				obj.url =BASE_DIR + String(subItem.@path);
				obj.desc = String(subItem.@desc);
			
			return obj;
		}
	}
}