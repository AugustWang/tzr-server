package modules.scene.other {
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.scene.GameScene;
	import com.scene.WorldManager;
	import com.scene.sceneData.BinaryMath;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.EnterPoint;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.MapEncode;
	import com.scene.sceneKit.LoadingSetter;
	import com.scene.sceneUnit.MapStuff;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.Slice;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import modules.scene.SceneDataManager;
	import modules.scene.cases.MapCase;

	public class EnterScenePreparer {
		private static var mcmLoader:URLLoader;
		private static var _mapID:int;

		public function EnterScenePreparer() {
		}

		public static function init():void {
			mcmLoader=new URLLoader;
			mcmLoader.dataFormat=URLLoaderDataFormat.BINARY;
			mcmLoader.addEventListener(Event.COMPLETE, mcmLoaderOK);
			mcmLoader.addEventListener(IOErrorEvent.IO_ERROR, ioerrorFunc);
			mcmLoader.addEventListener(ProgressEvent.PROGRESS, onMapDataProgress);
		}

		public static function loadMapData(mapid:int):void {
			_mapID=mapid;
			var vo:MapDataVo=WorldManager.getMapDataVo(mapid);
			if (vo) {
				SceneDataManager.setMapData(vo);
				Slice.offsetx=vo.offsetX;
				Slice.offsety=vo.offsetY;
				var city:CityVo=WorldManager.getCityVo(vo.map_id);
				var bgPath:String=GameConfig.ROOT_URL + city.url + '/view.jpg';
				LoadingSetter.mapLoading(true, 0.99, "地图加载完毕，正在请求数据");
				MapCase.getInstance().enterMapPath=bgPath;
				SceneDataManager.isGaming=true;
				MapCase.getInstance().toEnter(mapid);
			} else {
				LoadingSetter.mapLoading(true, 0, "正在加载地图配置");
				var area:String=mapid.toString().substr(0, 2); //预加载当前地图MCM和背景图
				var map_mcm:String=GameConfig.ROOT_URL + "com/maps/mcm/" + area + ".mcms";
				mcmLoader.load(new URLRequest(map_mcm));
				trace("加载mcms。。。。")
			}
			trace("make_mcm:"+getTimer());
		}

		public static function mcmLoaderOK(e:Event):void {
			var bytes:ByteArray=mcmLoader.data as ByteArray;
			WorldManager.parseMcmBag(bytes);
			var vo:MapDataVo=WorldManager.getMapDataVo(_mapID);
			if (vo) {
				loadMapData(_mapID);
			}
		}

		public static function onMapDataProgress(e:ProgressEvent):void {
			LoadingSetter.mapLoading(true, e.bytesLoaded / e.bytesTotal, "正在加载地图配置");
		}

		public static function ioerrorFunc(e:IOErrorEvent):void {
			throw new Error("地图配置加载错误");
		}

		public static function prepareRobKingMap():void {
			var mapData:MapDataVo=SceneDataManager.mapData;
			var e:MapElementVo;
			if (SceneDataManager.isRobKingMap == true) {
				var tiles:Array=SceneDataManager.mapData.tiles;
				var arr:Array;
				var cell:int;
				for (var x:int=0; x < tiles.length; x++) {
					arr=tiles[x];
					for (var z:int=0; z < arr.length; z++) {
						cell=tiles[x][z];
						if (BinaryMath.isExist(cell) == true) {
							cell=BinaryMath.setRun(cell, true);
							cell=BinaryMath.setSafe(cell, true);
							tiles[x][z]=cell;
						}
					}
				}
				//绝对安全区                              mapdata
				for (var i:int=0; i < mapData.elements.length; i++) {
					e=mapData.elements[i] as MapElementVo;
					if (e.itemType == EnterPoint.PLAYGROUND_ITEM && e.id == int(mapData.map_id + "" + 100)) {
						var throne:MapStuff=new MapStuff(GameConfig.OTHER_PATH + 'wangzuo.swf');
						GameScene.getInstance().addUnit(throne, e.tx, e.ty);
						break;
					}
				}
			}
//			if (SceneDataManager.isTaiPingCun == true) {
//				var allProspect:Array=new Array();
//				for (i=0; i < yuArr.length; i++) {
//					var yu:Thing=new Thing();
//					yu.x=yuArr[i][0];
//					yu.y=yuArr[i][1];
//					yu.load(GameConfig.ROOT_URL + "com/ui/effect_scene/yu2.swf");
//					yu.play(4, true);
//					allProspect.push(yu);
//				}
//				for (i=0; i < dieArr.length; i++) {
//					var die:Thing=new Thing();
//					die.x=dieArr[i][0];
//					die.y=dieArr[i][1];
//					die.load(GameConfig.ROOT_URL + "com/ui/effect_scene/hudie1.swf");
//					die.play(8, true);
//					allProspect.push(die);
//
//				}
//				GameScene.getInstance().addProspect(allProspect);
//			}
			if (SceneDataManager.isRobCityMap == true) {
				for (var j:int=0; j < mapData.elements.length; j++) {
					e=mapData.elements[j] as MapElementVo;
					if (e.itemType == EnterPoint.PLAYGROUND_ITEM && e.id == int(mapData.map_id + "" + 100)) {
						var dragon:MapStuff=new MapStuff(GameConfig.OTHER_PATH + "dragonPost.swf", "dragon");
						GameScene.getInstance().addUnit(dragon, e.tx, e.ty);
						break;
					}
				}
			}
			if (SceneDataManager.isCapital) {
				for (var k:int=0; k < mapData.elements.length; k++) {
					e=mapData.elements[k] as MapElementVo;
					if (e.itemType == EnterPoint.PLAYGROUND_ITEM && e.id == 11000130) {
						var lu:MapStuff=new MapStuff(GameConfig.ROOT_URL + "com/ui/lu/tian.swf", "tiangonglu");
						var yingzi:Thing=new Thing(); //影子
						yingzi.load(GameConfig.ROOT_URL + "com/ui/lu/tian_yingzhi.swf");
						yingzi.gotoAndStop(0);
						yingzi.x=-34;
						yingzi.y=-14;
						yingzi.alpha=0.5;
						lu.addChildAt(yingzi, 0);
						GameScene.getInstance().addUnit(lu, e.tx, e.ty);
						break;
					}
				}
			}
//			if(SceneDataManager.isFamilyMap){
//				for (var l:int = 0; l < mapData.elements.length; l++){
//					e=mapData.elements[l] as MapElementVo;
//					if (e.itemType == EnterPoint.BLACKGROUND_ITEM && e.id == 10300222) {
//						var needfire:Needfire=new Needfire();
//						GameScene.getInstance().addUnit(needfire, e.tx, e.ty);
//						needfire.play();
//						break;
//					}
//				}
//			}
		}
		private static var yuArr:Array=[[1047, 912], [979, 1292], [1351, 1544], [647, 1952], [2110, 952], [3214, 2024], [4240, 2468]];
		private static var dieArr:Array=[[1319, 296], [467, 1092], [3042, 432], [3702, 464], [4318, 1020], [3814, 1860], [4406, 1956], [3014, 2188], [2419, 2128], [2039, 2212], [1590, 2536], [2115, 2888], [1895, 2220]];
	}
}