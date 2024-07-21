package modules.finery
{
	import com.loaders.CommonLocator;
	
	import flash.utils.Dictionary;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;

	public class MaterialID
	{
		public var _typeId:int;
		public var material_lvl:int;
		public var material_type:String;
		
		private static var _instance:MaterialID;
		public function MaterialID(){
			load();
			loadMaterial();
		}
		public static function getInstance():MaterialID{
			if(!_instance){
				_instance = new MaterialID();
			}
			return _instance;
		}
		//可以进行材料合成的ID
		public var matchID_arr:Array = [];
		public var composeInfos:Dictionary;
		private function load():void{
			if(composeInfos == null){
				composeInfos = new Dictionary();
				var xml:XML = CommonLocator.getXML(CommonLocator.MATERIALID);
				var materials:XMLList = xml.material;
				for each(var item:XML in materials){
					var id:String = String(item.@typeId);
					matchID_arr.push(id);
					composeInfos[id] = String(item.@compose);
				}
			}
		}
		
		public function getCompose(materialId:int):BaseItemVO{
			if(composeInfos == null){
				load();
			}
			var typeId:String = composeInfos[materialId];
			var itemVO:BaseItemVO;
			if(typeId){
				itemVO = ItemLocator.getInstance().getObject(int(typeId));
			}
			return itemVO;
		}
		
		private var materialXML:XML;
		private function loadMaterial():void{
			materialXML = CommonLocator.getXML(CommonLocator.MATERIAL);
		}
		
		public function getMaterialByType(type:int):Array{
			var result:Array = [];
			var xmlList:XMLList = materialXML.material.(@type == type);
			for(var i:int=0; i<xmlList.length(); i++){
				result.push({lv:xmlList[i].@level,id:xmlList[i].@id});
			}
			return result;
		}
		
		public function set typeId(value:int):void{
			this._typeId = value;
			deal(value);
		}
		
		private function deal(value:int):void{
			var xmlList:XMLList = materialXML.material.(@id == value);
			this.material_lvl = int(xmlList.@level);
			this.material_type = String(xmlList.@type);
		}
	}
}