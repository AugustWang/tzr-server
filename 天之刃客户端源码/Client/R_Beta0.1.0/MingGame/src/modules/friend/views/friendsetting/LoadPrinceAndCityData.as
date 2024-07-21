package modules.friend.views.friendsetting
{
	import com.loaders.CommonLocator;
	
	
	
	public class LoadPrinceAndCityData
	{
		private static var _instance:LoadPrinceAndCityData;
		public static function get instance():LoadPrinceAndCityData{
			if(!_instance){
				_instance = new LoadPrinceAndCityData();
			}
			return _instance;
		}
		
		private var _prince_arr:Array = [];
		public function get prince_arr():Array{
			if(_prince_arr.length == 0){
				loadData();
			}
			return _prince_arr;
		}
		
		private var _city_arr:Array = [];
		public function get city_arr():Array{
			if(_city_arr.length == 0){
				loadData();
			}
			return _city_arr;
		}
		
		private var princeURL:String;
		private var cityURL:String;
		public function loadData():void{
			var princeXML:XML = CommonLocator.getXML(CommonLocator.PRINCE);
			for each(var xml:XML in princeXML.prince){
				var prince_obj:Object = {};
				prince_obj.princeID = int(xml.@id);
				prince_obj.princeName = String(xml.@name);
				_prince_arr.push(prince_obj);
			}
			
			var cityXML:XML = CommonLocator.getXML(CommonLocator.CITY);
			for each(var i:Object in _prince_arr){
				var arr:Array = [];
				for each(var xml2:XML in cityXML.city){
					if(int(xml2.@id) == i.princeID){
						var obj:Object = {};
						obj.cityID = int(xml2.@id);
						obj.cityName = String(xml2.@name);
						arr.push(obj);
						continue;
					}
				}
				if(arr.length != 0){
					_city_arr.push(arr);
				}
			}
		}
	}
}