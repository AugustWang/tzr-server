package com.scene.sceneUnit.map
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.gameLoader.GameLoader;
	import com.scene.WorldManager;
	import com.utils.tick.ITick;
	import com.utils.tick.TickManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class MapBackGroundII extends Sprite implements ITick
	{
		/**
		 * 地图Tile 宽 高
		 */
		public static const TILE_SIZE:int=300;
		
		private var mapHash:Dictionary; 
		private var mapURL:String;
		private var maxRow:int;
		private var maxColumn:int;
		private var bigMapWidth:Number;
		private var bigMapHeight:Number;
		private var todoList:Array;
		private var loadingLoaders:Dictionary;
		
		private var xscale:Number = 1;
		private var yscale:Number = 1;
		private var thumbnailData:BitmapData;
		private var thumbMatrix:Matrix;
		private var thumbs:Dictionary;
				
		private var filledRect:Rectangle;
		private var viewRect:Rectangle;
		private var renders:Dictionary;
		
		public function MapBackGroundII() {
			super();
			mouseChildren=mouseEnabled=false;
			viewRect = new Rectangle();
			todoList = new Array();
		}
		/**
		 * 初始化地图数据 
		 * @param mapid
		 * @param mapWidth
		 * @param mapHeight
		 * 
		 */		
		public function startInitMap(mapid:int, mapWidth:Number, mapHeight:Number):void {
			bigMapWidth = mapWidth;
			bigMapHeight = mapHeight;
			mapURL = WorldManager.getCityVo(mapid).url;
			mapHash = new Dictionary();
			thumbs = new Dictionary();
			loadingLoaders = new Dictionary();
			maxColumn = Math.ceil(mapWidth / TILE_SIZE);
			maxRow = Math.ceil(mapHeight / TILE_SIZE);
			thumbMatrix = new Matrix();
			filledRect = new Rectangle();
			TickManager.getInstance().addTick(this);
		}
		/**
		 * 设置缩略图数据 
		 * @param thumbBitmapData
		 * 
		 */		
		public function set thumbnail(thumbBitmapData:BitmapData):void{
			thumbnailData = thumbBitmapData; 
			xscale = bigMapWidth/thumbBitmapData.width;
			yscale = bigMapHeight/thumbBitmapData.height;
			thumbMatrix.scale(xscale,yscale);
			var keys:Array;
			var shape:Shape;
			for (var key:String in thumbs){
				if (thumbs[key]){
					keys = key.split("_");
					var xvalue:int = int(keys[1]);
					var yvalue:int = int(keys[0]);
					thumbMatrix.tx = (-xvalue) * TILE_SIZE;
					thumbMatrix.ty = (-yvalue) * TILE_SIZE;
					shape = thumbs[key];
					shape.graphics.clear();
					shape.graphics.beginBitmapFill(thumbnailData, thumbMatrix);
					shape.graphics.drawRect(0, 0, TILE_SIZE, TILE_SIZE);
					shape.graphics.endFill();
				}
			}
		}
		/**
		 * 获取缩略图 
		 * @param row
		 * @param column
		 * 
		 */		
		private function getThumbnail(row:int,column:int):DisplayObject{
			var thumbnailShape:Shape = null;
			var key:String = row + "_" + column;
			if (thumbnailData == null){
				thumbnailShape = new Shape();
				thumbnailShape.x = column * TILE_SIZE;
				thumbnailShape.y = row * TILE_SIZE;
				thumbnailShape.graphics.beginFill(0);
				thumbnailShape.graphics.drawRect(0, 0, TILE_SIZE, TILE_SIZE);
				thumbnailShape.graphics.endFill();
				thumbs[key] = thumbnailShape;
			}else if (thumbs[key] == null){
				thumbMatrix.tx = (-column) * TILE_SIZE;
				thumbMatrix.ty = (-row) * TILE_SIZE;
				thumbnailShape = new Shape();
				thumbnailShape.graphics.beginBitmapFill(thumbnailData, thumbMatrix);
				thumbnailShape.graphics.drawRect(0, 0, TILE_SIZE, TILE_SIZE);
				thumbnailShape.graphics.endFill();
				thumbnailShape.x = column * TILE_SIZE;
				thumbnailShape.y = row * TILE_SIZE;
				thumbs[key] = thumbnailShape;
			}
			return thumbs[key] as DisplayObject;
		}
		/**
		 * 填充地图可视区域
		 * @param viewRect
		 * 
		 */
		private function fillRect() : void{
			if (filledRect && filledRect.containsRect(viewRect)){
				return;
			}
			var startX:int=int(viewRect.x / TILE_SIZE);
			var startY:int=int(viewRect.y / TILE_SIZE);
			var endX:int=Math.ceil((viewRect.width + viewRect.x) / TILE_SIZE);
			var endY:int=Math.ceil((viewRect.height + viewRect.y) / TILE_SIZE);
			endX=Math.min(endX, maxColumn);
			endY=Math.min(endY, maxRow);
			filledRect.x = startX * TILE_SIZE;
			filledRect.y = startY * TILE_SIZE;
			filledRect.width = (endX - startX) * TILE_SIZE;
			filledRect.height = (endY - startY) * TILE_SIZE;
			var renderShapes:Dictionary = new Dictionary();
			var imgURL:String,tileID:String;
			for (var i:int=startY; i <= endY; i++) {
				for (var j:int=startX; j <= endX; j++) {
					tileID=i + "_" + j;
					var mapShape:DisplayObject = mapHash[tileID];
					if (mapShape == null){
						mapShape = getThumbnail(i,j);
					}
					if (contains(mapShape)){
						delete renders[tileID];
					}else{
						addChild(mapShape);
					}
					if (mapHash[tileID] == null && loadingLoaders[tileID] == null){
						imgURL=GameConfig.ROOT_URL + mapURL + "/" + tileID + ".jpg";
						loadingLoaders[tileID]=true;			
						todoList.push({url:imgURL,pos: {x: j, y: i}});
					}
					renderShapes[tileID] = mapShape;
				}
			}
			for each(var renderObj:DisplayObject in renders){	
				if (contains(renderObj)){
					removeChild(renderObj);
				}
			}
			renders = renderShapes;
		}
		
		/**
		 * 加载要填充的地图 
		 * @param sceneX
		 * @param sceneY
		 * 
		 */		
		public function loadMap(sceneX:Number, sceneY:Number):void {
			viewRect.x = Math.abs(sceneX);
			viewRect.y = Math.abs(sceneY);
			viewRect.width = GlobalObjectManager.GAME_WIDTH;
			viewRect.height = GlobalObjectManager.GAME_HEIGHT;
			fillRect();
		}
		
		/**
		 * 图片加载完成 
		 * @param loader
		 * @param obj
		 * 
		 */		
		protected function loadTileComplete(loader:Loader,obj:Object):void {
			if (loader && obj) {
				var tileData:Bitmap=Bitmap(loader.content);
				loader.unload();
				var key:String = obj.y + "_" + obj.x;
				mapHash[key] = tileData;
				tileData.x=obj.x * TILE_SIZE;
				tileData.y=obj.y * TILE_SIZE;
				addChild(tileData);
				
				var thumbShape:Shape = thumbs[key];
				if (thumbShape && thumbShape.parent){
					thumbShape.parent.removeChild(thumbShape);
				}
			}
		}
		
		/**
		 * 定时加载图片资源 
		 * @param framecount
		 * @param dt
		 * 
		 */		
		public function onTick(framecount:int,dt:Number=33) : void{
			if (todoList.length > 0){
				var loadObj:Object = todoList.shift();
				GameLoader.getInstance().addMap(loadObj.url, loadObj.pos, loadTileComplete);
			}
		}
		
		/**
		 * 销毁 
		 * 
		 */		
		public function dispose() : void{
			GameLoader.getInstance().clearLoadingMap();
			TickManager.getInstance().removeTick(this);
			todoList.length = 0;
			if (thumbnailData){
				thumbnailData.dispose();
				thumbnailData = null;
			}
			var fillBitmap:Bitmap;
			var fillObj:DisplayObject;
			for(var key:String in mapHash){
				fillObj = mapHash[key];
				if (fillObj is Bitmap){
					fillBitmap = fillObj as Bitmap;
					if (fillBitmap.bitmapData){
						fillBitmap.bitmapData.dispose();
					}
				}
				if (fillObj && fillObj.parent){
					fillObj.parent.removeChild(fillObj);
				}
				delete mapHash[key];
			}
			for(key in thumbs){
				fillObj = thumbs[key];
				if (fillObj && fillObj.parent){
					fillObj.parent.removeChild(fillObj);
				}
				delete thumbs[key];
			}	
		}
	}
}