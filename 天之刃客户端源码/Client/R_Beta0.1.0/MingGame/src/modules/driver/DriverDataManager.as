package modules.driver
{
	import flash.utils.Dictionary;
	
	import modules.driver.vo.DriverDataIndex;

	public class DriverDataManager
	{
		public function DriverDataManager(singletonObj:singleton)
		{
			if(!singletonObj){
				throw(new Error("MissionModule Singleton."));
			}
		}
		
		static private var _instance:DriverDataManager;
		static public function getInstance():DriverDataManager{
			if(!_instance){
				_instance = new DriverDataManager(new singleton());
			}
			
			return _instance;
		}
		
		/**
		 * 初始化车夫列表
		 */
		private var _driverData:Dictionary;
		public function initDriverData(data:XML):void {
			
			this._driverData = new Dictionary();
			for each(var driverData:XML in data..driver){
				var npcID:String = driverData.@id.toString();
				this._driverData[npcID] = new Dictionary();
				for each(var target:XML in driverData..target){
					var targetID:String = target.@id.toString();
					this._driverData[npcID][targetID] = new Dictionary();
					this._driverData[npcID][targetID]['id'] = parseInt(targetID);
					this._driverData[npcID][targetID]['name'] = '传送到'+target.@name.toString();
					this._driverData[npcID][targetID]['show_faction'] = parseInt(target.@show_faction);
					this._driverData[npcID][targetID]['data'] = [];
					
					for each(var targetData:XML in target..data){
						var targetDataArr:Array = [];
						targetDataArr[DriverDataIndex.DRIVER_TARGET_DATA_MIN_LEVEL] = parseInt(targetData.@min);
						targetDataArr[DriverDataIndex.DRIVER_TARGET_DATA_MAX_LEVEL] = parseInt(targetData.@max);
						targetDataArr[DriverDataIndex.DRIVER_TARGET_DATA_COST] = parseInt(targetData.@cost);
						targetDataArr[DriverDataIndex.DRIVER_TARGET_DATA_COST_DES] = targetData.@des.toString();
						targetDataArr[DriverDataIndex.DRIVER_TARGET_DATA_ABLED] = (targetData.@abled == 'true' ? true : false);
						this._driverData[npcID][targetID]['data'].push(targetDataArr);
					}
				}
			}
		}
		
		/**
		 * 获取NPC车夫列表
		 */
		public function getNPCDriverList(npcID:int):Dictionary{
			return this._driverData[npcID];
		}
	}
}
class singleton{}