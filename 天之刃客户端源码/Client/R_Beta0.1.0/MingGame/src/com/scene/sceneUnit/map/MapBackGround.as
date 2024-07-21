package com.scene.sceneUnit.map {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.gameLoader.GameLoader;
	import com.scene.WorldManager;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.utils.Dictionary;

	public class MapBackGround extends Sprite {
		/**
		 * 地图Tile 宽 高
		 */
		public static const MAP_TILE_WIDTH:int=300;
		public static const MAP_TILE_HEIGHT:int=300;

		private var bmp:Bitmap;
		private var mapHash:Dictionary; //放load好了的
		private var loadingLoaders:Dictionary;
		private var mapURL:String;
		private var maxRow:int;
		private var maxColumn:int;
		private var bigMapWidth:Number;
		private var bigMapHeight:Number;

		public function MapBackGround() {
			super();
			mouseChildren=mouseEnabled=false;
		}

		public function startInitMap(mapid:int, mapWidth:Number, mapHeight:Number):void {
			bigMapWidth=mapWidth;
			bigMapHeight=mapHeight;
			mapURL=WorldManager.getCityVo(mapid).url;
			loadingLoaders=new Dictionary(true);
			mapHash=new Dictionary();
			maxColumn=Math.ceil(mapWidth / MAP_TILE_WIDTH);
			maxRow=Math.ceil(mapHeight / MAP_TILE_HEIGHT);

//			var matrix:Matrix=new Matrix();
//			matrix.a=mapWidth / smallMapData.width;
//			matrix.d=mapHeight / smallMapData.height;
//			graphics.clear();
//			graphics.beginBitmapFill(smallMapData, matrix, false, false);
//			graphics.drawRect(0, 0, mapWidth, mapHeight);
//			graphics.endFill();
		}

		public function createBlur(smallMapData:BitmapData):void {
			var matrix:Matrix=new Matrix();
			matrix.a=bigMapWidth / smallMapData.width;
			matrix.d=bigMapHeight / smallMapData.height;
			graphics.clear();
			graphics.beginBitmapFill(smallMapData, matrix, false, false);
			graphics.drawRect(0, 0, bigMapWidth, bigMapHeight);
			graphics.endFill();
		}
		private var startX:int;
		private var startY:int;
		private var endX:int;
		private var endY:int;
		private var midX:int;
		private var midY:int;
		private var sortIndex:int;
		private var images:Array=[];
		private var imgURL:String;
		private var tileID:String;

		public function loadMap(sceneX:Number, sceneY:Number):void {
			startX=int(Math.abs(sceneX) / MAP_TILE_WIDTH);
			startY=int(Math.abs(sceneY) / MAP_TILE_HEIGHT);
			endX=int(Math.abs(GlobalObjectManager.GAME_WIDTH - sceneX) / MAP_TILE_WIDTH);
			endY=int(Math.abs(GlobalObjectManager.GAME_HEIGHT - sceneY) / MAP_TILE_HEIGHT);
			endX=Math.min(endX, maxColumn);
			endY=Math.min(endY, maxRow);
			midX=(startX + endX) >> 1;
			midY=(startY + endY) >> 1;
			images.length=0;
			for (var i:int=startY; i <= endY; i++) {
				for (var j:int=startX; j <= endX; j++) {
					tileID=i + "_" + j;
					if (mapHash[tileID] == null && loadingLoaders[tileID] == null) {
						sortIndex=Math.abs(i - midY) + Math.abs(j - midX);
						imgURL=GameConfig.ROOT_URL + mapURL + "/" + tileID + ".jpg";
						images.push({index: sortIndex, url: imgURL, pos: {x: j, y: i}});
						loadingLoaders[tileID]=true;
					}
				}
			}
			if (images.length > 0) {
				images.sortOn("index");
				for (i=0; i < images.length; i++) {
					GameLoader.getInstance().addMap(images[i].url, images[i].pos, loadTileComplete);
				}
			}
		}


		protected function loadTileComplete(loader:Loader, obj:Object):void {
			if (loader && obj) {
				var tileData:Bitmap=Bitmap(loader.content);
				loader.unload();
				if (!mapHash) {
					mapHash=new Dictionary;
				}
				if (mapHash) {
					mapHash[obj.y + "_" + obj.x]=tileData;
					tileData.x=obj.x * MAP_TILE_WIDTH;
					tileData.y=obj.y * MAP_TILE_HEIGHT;
					addChild(tileData);
				}
			}
		}

		public function dispose():void {
			GameLoader.getInstance().clearAll();
			this.graphics.clear();
			while (numChildren > 0) {
				var bmp:Bitmap=getChildAt(0) as Bitmap;
				if (bmp) {
					bmp.bitmapData.dispose();
				}
				removeChildAt(0);
			}
			for each (var bitmap:Bitmap in mapHash) {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
				if (bitmap.bitmapData) {
					bitmap.bitmapData.dispose();
					bitmap.bitmapData=null;
				}
				bitmap=null;
			}
			mapHash=null;
		}
	}
}