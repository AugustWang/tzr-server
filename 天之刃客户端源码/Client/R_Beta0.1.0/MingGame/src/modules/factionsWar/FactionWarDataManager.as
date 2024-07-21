package modules.factionsWar {
	import com.common.GlobalObjectManager;

	import modules.scene.SceneDataManager;

	public class FactionWarDataManager {
		public static var factionMoney:int=0;
		public static var levels:Array=["一", "二", "三", "四", "五", "六", "七"];
		public static var moneys:Array=[0, 5, 10, 15, 20, 30, 40, 50];
		public static var isInWarTime:Boolean;
		public static var phase:int; //0非国战阶段，1，国战准备阶段，2，国战阶段

		//计算守卫typeid
		public static function getGuardTypeid(isLeft:Boolean, level:int):int {
			var faction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var dir:int=isLeft ? 1 : 2;
			var typeId:String="2" + faction + "21" + dir + "1" + (level - 1) + "0";
			return int(typeId);
		}

		//计算拒马typeid
		public static function getRoadBlock():int {
			var faction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var typeId:String="2" + faction + "201001";
			return int(typeId);
		}

		public static function isFlag(type_id:int):Boolean {
			var flag:Boolean;
			if (type_id == 21202001 || type_id == 22202001 || type_id == 23202001) {
				flag=true;
			}
			return flag;
		}

		public static function isInWarTimeAndPlace():Boolean {
			var value:Boolean;
			var mapid:int=SceneDataManager.mapData.map_id;
			var isInPlace:Boolean;
			if (mapid == 11100 || mapid == 11102 || mapid == 11105 || mapid == 12100 || mapid == 12102 || mapid == 12105 || mapid == 13100 || mapid == 13102 || mapid == 13105) {
				isInPlace=true;
			}
			if (isInWarTime && isInPlace) {
				value=true;
			}
			return value;
		}
	}
}