package modules.scene {
	import com.common.GlobalObjectManager;
	import com.scene.GameScene;
	import com.scene.WorldManager;
	import com.scene.sceneData.BinaryMath;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.EnterPoint;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.MapTransferVo;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.scene.tile.Pt;
	import com.scene.tile.gameAstar.MapGrid;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	import modules.sceneWarFb.SceneWarFbModule;


	public class SceneDataManager {
		public static var mapData:MapDataVo;
		public static var visualTurns:Array; //可见的跳转点
		public static var npcs:Array; //本图NPC
		public static var mapStuffs:Array=[];
		public static var isGaming:Boolean; //场景是否准备好，没准备好不允许东西进入，忽略进入的消息
		public static var isAttackBack:Boolean=true; //攻击是否已经返回，目的是自动挂机时，等后台返回后才能发起第二次攻击
		public static var lockEnemyKey:String=""; //锁定的敌人
		public static var monster_types:Array; //特殊地图的怪物Typeid列表，目前只有讨伐敌营特殊
		public static var offsetX:int;
		public static var offsetY:int;

		public function SceneDataManager() {
		}

		public static function setMapData(vo:MapDataVo):void {
			mapData=vo;
			offsetX=vo.offsetX;
			offsetY=vo.offsetY;
			var city:CityVo;
			for each (var t:MapTransferVo in vo.transfers) {
				city=WorldManager.getCityVo(t.tar_Map);
				t.minLevel=city.turn_map_abled;
			}
			npcs=[];
			for each (var n:MapElementVo in vo.elements) {
				if (n.itemType == EnterPoint.NPC) {
					npcs.push(n);
				}
			}
			city=WorldManager.getCityVo(vo.map_id);
			resetVisualPoint(city);
		}

		public static function get mapID():int {
			return mapData.map_id;
		}

		public static function get isRobKingMap():Boolean {
			var b:Boolean;
			if (mapData.map_id == 11111 || mapData.map_id == 12111 || mapData.map_id == 13111) {
				b=true;
			}
			return b;
		}

		public static function get isOtherMap():Boolean {
			var b:Boolean;
			if (mapData.map_id == 11106 || mapData.map_id == 11107 || mapData.map_id == 11108 || mapData.map_id == 11110 || mapData.map_id == 12106 || mapData.map_id == 12107 || mapData.map_id == 12108 || mapData.map_id == 12110 || mapData.map_id == 13106 || mapData.map_id == 13107 || mapData.map_id == 13108 || mapData.map_id == 13110 || mapData.map_id == 10202) {
				b=true;
			}
			return b;
		}

		public static function get isRobCityMap():Boolean {
			var b:Boolean;
			if (mapData.map_id == 10301) {
				b=true;
			}
			return b;
		}

		//讨伐敌营地图
		public static function get isCrusadeMap():Boolean {
			var b:Boolean;
			if (mapData.map_id == 10400) {
				b=true;
			}
			return b;
		}

		//师徒副本地图
		public static function get isEducateFbMap():Boolean {
			var b:Boolean;
			if (mapData.map_id == 10600) {
				b=true;
			}
			return b;
		}

		public static function get isBaoZangMap():Boolean {
			var b:Boolean;
			if (mapData.map_id == 10500) {
				b=true;
			}
			return b;
		}

		public static function get isFamilyMap():Boolean {
			if (mapID == 10300) {
				return true;
			}
			return false;
		}

		public static function isInSafeMap():Boolean {
			if (mapID == 11107 || mapID == 11108 || mapID == 12107 || mapID == 12108 || mapID == 13107 || mapID == 13108) {
				return true;
			}
			return false;
		}

		/**
		 * 场景大战副本地图
		 * @return
		 *
		 */
		public static function get isSceneWarFbMap():Boolean {
			return SceneWarFbModule.getInstance().isSceneWarFbMapId(mapData.map_id);
		}

		public static function get isInHomeCountry():Boolean {
			var inHomeCountry:Boolean; //在国外
			var country_id:String=mapData.map_id.toString().substr(0, 2);
			if (country_id == "11" || country_id == "12" || country_id == "13") {
				var myFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
				if ("1" + myFaction == country_id) {
					inHomeCountry=true;
				}
			}
			return inHomeCountry;
		}

		//是否在中立区
		public static function get isInNeutrality():Boolean {
			var country_id:String=mapData.map_id.toString().substr(0, 2);
			if (country_id == "10") {
				return true;
			}
			return false;
		}

		public static function get inWhichArea():int {
			var area:String=mapData.map_id.toString().substr(1, 1);
			if (mapData.isSub == 1) {
				area=GlobalObjectManager.getInstance().user.base.faction_id + "";
			}
			return int(area);
		}

		public static function get isInStallArea():Boolean {
			var isInStall:Boolean;
			if (isInHomeCountry == true) {
				var NowPt:Pt=SceneDataManager.getMyPostion().pt;
				var newCell:int=SceneDataManager.getCell(NowPt.x, NowPt.z);
				if (BinaryMath.isExist(newCell) && BinaryMath.isSell(newCell)) {
					isInStall=true;
				}
			}
			return isInStall;
		}

		public static function getMonsters(includeBoss:Boolean=true):Dictionary {
			var dic:Dictionary=new Dictionary;
			if (mapData != null) {
				for (var i:int=0; i < mapData.elements.length; i++) {
					var es:MapElementVo=mapData.elements[i] as MapElementVo;
					if (es.itemType == EnterPoint.BOGEY) {
						var mt:MonsterType=MonsterConfig.hash[es.id];
						if (mt != null) {
							if (dic.hasOwnProperty(mt.type) == false) {
								if ((mapData.map_id == 10400 || mapData.map_id == 10600) && monster_types != null) { //讨伐敌营地图
									if (monster_types.indexOf(mt.type) != -1) { //列表有的
										if (includeBoss == true) { //含精英，BOSS
											dic[mt.type]=mt;
										} else { //不含精英，BOSS
											if (mt.rarity == 1) {
												dic[mt.type]=mt;
											}
										}
									}
								} else {
									if (includeBoss == true) { //含精英，BOSS
										dic[mt.type]=mt;
									} else { //不含精英，BOSS
										if (mt.rarity == 1) {
											dic[mt.type]=mt;
										}
									}
								}
							} else {
								continue;
							}
						}
					}
				}
			}
			return dic;
		}

		public static function getMonster(type_id:int):MonsterType {
			var mt:MonsterType=MonsterConfig.hash[type_id];
			return mt;
		}

		public static function getMonsterByName(monsterName:String):Array {
			var arr:Array=MonsterConfig.getMonsterByName(monsterName);
			if (arr == null) {
				arr=[];
			}
			return arr;
		}

		//找出王座附近的格子
		public static function getThroneNearTiles():Array {
			var arr:Array=[];
			if (isRobKingMap == true || isRobCityMap == true) {
				for (var i:int=0; i < mapData.elements.length; i++) {
					var e:MapElementVo=mapData.elements[i] as MapElementVo;
					if (e.itemType == EnterPoint.PLAYGROUND_ITEM && e.id == int(mapData.map_id + "" + 110)) {
						arr.push(e);
					}
				}
			}
			return arr;
		}

		public static function get isProtectMap():Boolean {
			var b:Boolean;
			if (mapData != null) {
				var map_id:int=mapData.map_id;
				//太平村，横涧山，鄱阳湖
				if (map_id == 11000 || map_id == 11001 || map_id == 11101 || map_id == 12000 || map_id == 12001 || map_id == 12101 || map_id == 13000 || map_id == 13001 || map_id == 13101) {
					b=true;
				}
			}
			return b;
		}

		//是否是京城地图
		public static function get isCapital():Boolean {
			var isCapital:Boolean;
			if (mapData != null) {
				var map_id:int=mapData.map_id;
				//太平村，横涧山，鄱阳湖
				if (map_id == 11100 || map_id == 12100 || map_id == 13100) {
					isCapital=true;
				}
			}
			return isCapital;
		}

		public static function get isPingJiang():Boolean {
			if (mapData != null) {
				var map_id:int=mapData.map_id;
				if (map_id == 11102 || map_id == 12102 || map_id == 13102) {
					return true;
				}
			}
			return false;
		}

		public static function get isBianCheng():Boolean {
			if (mapData != null) {
				var map_id:int=mapData.map_id;
				if (map_id == 11105 || map_id == 12105 || map_id == 13105) {
					return true;
				}
			}
			return false;
		}

		public static function get YBCMapIndex():int {
			if (isCapital == true)
				return 0;
			if (isPingJiang == true)
				return 1;
			if (isBianCheng == true)
				return 2;
			return -1;
		}

		public static function get isTaiPingCun():Boolean {
			var isCun:Boolean;
			if (mapData != null) {
				var map_id:int=mapData.map_id;
				if (map_id == 11000 || map_id == 12000 || map_id == 13000) {
					isCun=true;
				}
			}
			return isCun;
		}

		public static function resetVisualPoint(city:CityVo):void {
			var arr:Array=[];
			var t:MapTransferVo;
			var m:MacroPathVo;
			for (var s:String in city.parents) {
				m=city.parents[s] as MacroPathVo;
				t=new MapTransferVo;
				t.tar_Map=m.mapid;
				t.tx=m.pt.x;
				t.ty=m.pt.z;
				arr.push(t);
			}
			for (var ss:String in city.children) {
				m=city.children[ss] as MacroPathVo;
				t=new MapTransferVo;
				t.tar_Map=m.mapid;
				t.tx=m.pt.x;
				t.ty=m.pt.z;
				arr.push(t);
			}
			visualTurns=arr;
		}

		public static function isSubMap():Boolean {
			return mapData.isSub == 1;
		}

		// 设置地图格子能不能走
		public static function setNodeWalk(tx:int, ty:int, walk:Boolean):void {
			if (mapData) {
				if (tx >= 0 && tx < mapData.tileRow && ty >= 0 && ty <= mapData.tileCol) {
					var cell:int=mapData.tiles[tx][ty];
					if (BinaryMath.isExist(cell) && BinaryMath.isRun(cell) == false) { //格子是阻挡区才需要
						var grid:MapGrid=GameScene.getInstance().mapGrid;
						if (grid) {
							grid.setNodeWalkAble(tx, ty, walk);
						}
					}
				}
			}
		}

		public static function getCell(x:int, z:int):int {
			var cell:int;
			if (mapData && x >= 0 && x < mapData.tileRow && z >= 0 && z < mapData.tileCol) {
				cell=mapData.tiles[x][z];
			}
			return cell;
		}

		public static function hasCell(x:int, z:int):Boolean {
			if (mapData) {
				if (x >= 0 && x <= mapData.tileRow && z >= 0 && z <= mapData.tileCol) {
					var cell:int=mapData.tiles[x][z];
					return BinaryMath.isExist(cell);
				}
			}
			return false;
		}

		public static function isBlockCell(x:int, z:int):Boolean {
			var isBlock:Boolean;
			if (mapData) {
				var cell:int=getCell(x, z);
				if (BinaryMath.isExist(cell)) { //有此格子
					if (BinaryMath.isRun(cell) == true) { //非阻挡区
						isBlock=false;
					} else { //阻挡区
						var grid:MapGrid=GameScene.getInstance().mapGrid;
						if (grid) {
							isBlock=!grid.getNodeWalkAble(x, z);
						}
					}
				} else {
					isBlock=true;
				}
			}
			return isBlock;
		}

		public static function getMyPostion():MacroPathVo {
			var pos:MacroPathVo;
			var myRole:MyRole=SceneUnitManager.getSelf();
			if (myRole != null) {
				pos=new MacroPathVo(mapData.map_id, myRole.index);
			} else {
				pos=new MacroPathVo(0, new Pt());
			}
			return pos;
		}

		public static function getMyStagePoint():Point {
			var myRole:MyRole=SceneUnitManager.getSelf();
			if (myRole != null) {
				return myRole.localToGlobal(new Point());
			}
			return null;
		}
	}
}