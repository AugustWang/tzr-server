package modules.greenHand
{
	
	import com.loaders.CommonLocator;
	
	public class LoaderActivityXML
	{
		private static var _instance:LoaderActivityXML;
		public var treasuryData:Array = [];
		
		public function LoaderActivityXML():void
		{
			loader();
		}
		
		public static function getInstance():LoaderActivityXML{
			if(!_instance){
				_instance = new LoaderActivityXML();
			}
			return _instance;
		}
		
		public function loader():void{
			var xml:XML = CommonLocator.getXML(CommonLocator.TREASURY);
			for each(var x:XML in xml.treasury){
				var obj:Object = {};
				obj.question = x.title.@question;
				obj.anwser = x.title.answer;
				treasuryData.push(obj);
			}
		}
	}
}