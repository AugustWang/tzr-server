package com.scene.sceneUnit.map {

	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.loaders.gameLoader.GameLoader;
	import com.managers.Dispatch;
	import com.scene.GameScene;
	import com.scene.WorldManager;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.EnterPoint;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.MapTransferVo;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.MapElement;
	import com.scene.sceneUnit.MapTransfer;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.baseUnit.UnMutualElement;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.Slice;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.scene.SceneDataManager;


	public class Map extends Sprite {
		public static var centerHero:Boolean;
		public static var heroMoving:Boolean=true;
		private var resize:Boolean=false;
		private var pieceWidth:int=200;
		private var pieceHeight:int=200;
		private var bgLayer:MapBackGroundII;
		private var activeLayer:Sprite;
		private var inited:Boolean;
		private var activeArr:Array; //放不交互的东西，路牌跳转点等
		private var loopKey:String="start"; //用于管理item在屏幕内外是否显示
		private var screenRectangle:Rectangle=new Rectangle(0, 0, 1002, 545);

		public function Map() {
			super();
			init();
		}

		public function init():void {
			if (inited == false) {
				this.mouseEnabled=false;
				this.mouseEnabled=false;
				bgLayer=new MapBackGroundII();
				activeLayer=new Sprite;
				addChild(bgLayer);
				addChild(activeLayer);
				inited=true;
				Dispatch.register(ModuleCommand.STAGE_RESIZE, onStageResize);
			}
		}

		public function createBlur(url:String):void {
			var vo:MapDataVo=SceneDataManager.mapData;
			var smallMapBmp:BitmapData=ResourcePool.get(url) as BitmapData;
			bgLayer.startInitMap(vo.map_id, vo.width, vo.height);
			LoopManager.addToTimer(this, loadPiece);
		}

		private var smallMapLoader:Loader;

		public function startLoadBlur(url:String):void {
			var map_id:int=SceneDataManager.mapID;
			var vo:CityVo=WorldManager.getCityVo(map_id);
			var fix:String = map_id.toString().substr(0, 3);
			if (fix == "108" || fix == "103") { //个人副本地图，加载的是jpg
				GameLoader.getInstance().addMap(url, {mapID: map_id}, onSmallMapComplete);
			} else {
				url=GameConfig.ROOT_URL + "com/maps/smallMap" + vo.url.substring(8, vo.url.length) + ".swf";
				GameLoader.getInstance().addMap(url, {mapID: map_id}, onSmallMapSwfComplete);
			}
		}

		private function onSmallMapSwfComplete(loader:Loader, obj:Object):void {
			if (loader && obj) {
				var app:ApplicationDomain=loader.contentLoaderInfo.applicationDomain;
				if (app.hasDefinition("View") == false) {
					BroadcastSelf.getInstance().appendMsg("小地图文件出错");
					return;
				}
				var View:Class=app.getDefinition("View") as Class;
				var smallMap:BitmapData=new View(0, 0);
				loader.unload();
				var city:CityVo=WorldManager.getCityVo(int(obj.mapID));
				var vo:MapDataVo=SceneDataManager.mapData;
				var mapScale:Number=vo.width / vo.height;
				var sw:int;
				var sh:int;
				if (city.posx == 0) {
					sw=smallMap.width;
					sh=int(sw / mapScale);
				} else if (city.posy == 0) {
					sh=smallMap.height;
					sw=int(sh * mapScale);
				} else {
					BroadcastSelf.getInstance().appendMsg("小地图尺寸出错");
				}
				var rect:Rectangle=new Rectangle(city.posx, city.posy, sw, sh);
				var bmd:BitmapData=new BitmapData(sw, sh, false);
				bmd.copyPixels(smallMap, rect, new Point());
				bgLayer.thumbnail = bmd; //没字的小地图，剪切过

				if (app.hasDefinition("Msg")) {
					var Msg:Class=app.getDefinition("Msg") as Class;
					var smallMsg:BitmapData=new Msg(0, 0);
					var smallFull:BitmapData=smallMap.clone();
					smallFull.copyPixels(smallMsg, new Rectangle(0, 0, smallMsg.width, smallMsg.height), new Point());
					Dispatch.dispatch(ModuleCommand.ON_SMALL_MAP_COMPLETE, {s: bmd, f: smallFull});
				} else {
					Dispatch.dispatch(ModuleCommand.ON_SMALL_MAP_COMPLETE, {s: bmd, f: smallMap});
				}
			}
		}

		protected function onSmallMapComplete(loader:Loader, obj:Object):void {
			if (loader && obj) {
				var smallMap:BitmapData=Bitmap(loader.content).bitmapData;
				loader.unload();
				var city:CityVo=WorldManager.getCityVo(int(obj.mapID));
				var vo:MapDataVo=SceneDataManager.mapData;
				var mapScale:Number=vo.width / vo.height;
				var sw:int;
				var sh:int;
				if (city.posx == 0) {
					sw=smallMap.width;
					sh=int(sw / mapScale);
				} else if (city.posy == 0) {
					sh=smallMap.height;
					sw=int(sh * mapScale);
				} else {
					BroadcastSelf.getInstance().appendMsg("小地图尺寸出错");
				}
				var rect:Rectangle=new Rectangle(city.posx, city.posy, sw, sh);
				var bmd:BitmapData=new BitmapData(sw, sh, false);
				bmd.copyPixels(smallMap, rect, new Point());
				bgLayer.thumbnail = bmd;
				Dispatch.dispatch(ModuleCommand.ON_SMALL_MAP_COMPLETE, {s: bmd, f: smallMap});
			}
		}


		public function loadPiece():void {
			var hero:MyRole=GameScene.getInstance().hero;
			if (hero == null) {
				return;
			}
			if (hero.curState == RoleActState.RUNING) {
				heroMoving=true;
				centerHero=true;
			}
			if (centerHero == true && heroMoving == true) {
				heroMoving=false;
				bgLayer.loadMap(this.x, this.y);
			}
		}
		
		public function loadPieceForFly($x:int, $y:int):void{
			bgLayer.loadMap(this.x, this.y);
		}

		private function onStageResize(param:Object):void {
			frontLoadMap();
		}

		//人出现之前先LOAD地图，mapCase调用
		public function frontLoadMap():void {
			bgLayer.loadMap(this.x, this.y);
		}

		public function addActiveItem():void {
			activeArr=new Array;
			var mapdata:MapDataVo=SceneDataManager.mapData;
			activeLayer.x=Slice.offsetx;
			activeLayer.y=Slice.offsety;
			var pos:Point;
			var t:MapElement;
			for each (var k:MapElementVo in mapdata.elements) { //不是NPC，不是跳转点，不是出生点
				if (k.itemType != EnterPoint.BOGEY && k.itemType != EnterPoint.NPC && k.itemType != EnterPoint.ENTER_POINT && k.itemType != EnterPoint.LIVE_POINT) {
					t=new MapElement(k);
					activeLayer.addChild(t);
					activeArr.push(t);
				}
			}
			var tt:MapTransfer;
			for each (var j:MapTransferVo in SceneDataManager.visualTurns) {
				tt=new MapTransfer(j);
				activeLayer.addChild(tt);
				activeArr.push(tt);
			}
		}

		private function itemCheckOut():void {
			var item:UnMutualElement;
			var globalPoint:Point;
			var itemPoint:Point;
			for (var i:int=0; i < activeArr.length; i++) {
				item=activeArr[i];
				itemPoint=new Point(item.x, item.y);
				globalPoint=activeLayer.localToGlobal(itemPoint);
				if (screenRectangle.containsPoint(globalPoint) == true) {
					item.enabled=true;
					if (item.parent == null) {
						activeLayer.addChild(item);
					}
				} else {
					item.enabled=false;
					if (item.parent != null) {
						item.parent.removeChild(item);
					}
				}
			}
		}

		public function clear():void {
			bgLayer.dispose();
			LoopManager.removeFromFrame(this);
			while (activeLayer.numChildren > 0) {
				activeLayer.removeChildAt(0);
			}
		}
	}
}