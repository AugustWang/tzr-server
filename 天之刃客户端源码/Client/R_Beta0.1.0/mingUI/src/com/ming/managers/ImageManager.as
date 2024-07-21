package com.ming.managers
{
	import com.ming.ui.controls.Image;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;

	/**
	 * 图片资源缓存管理器 
	 */
	public class ImageManager
	{
		private var images:Dictionary;
		private var sources:Dictionary;
		
		private static var instance:ImageManager;
		public function ImageManager():void{
			images = new Dictionary();
			sources = new Dictionary();
		}
		
		public static function getInstance():ImageManager{
			if(instance == null){
				instance = new ImageManager();
			}
			return instance;
		}
		
		public function addImage(image:Image):void{
			if(image){
				image.addEventListener(Event.COMPLETE,onLoadComplete);
				image.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			}
		}
		
		private function onLoadComplete(event:Event):void{
			var image:Image = Image(event.currentTarget);
			image.removeEventListener(Event.COMPLETE,onLoadComplete);
			image.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			if(image.cache){
				addBitmapData(image.source,image.getContent().bitmapData);
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void{
			var image:Image = Image(event.currentTarget);
			image.removeEventListener(Event.COMPLETE,onLoadComplete);
			image.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		}
				
		public function addBitmapData(url:String,bitmapData:BitmapData):BitmapData{
			return sources[url] = bitmapData; 
		}
		
		public function getBitmapData(url:String):BitmapData{
			return sources[url];
		}
		
		public function removeBitmapData(url:String):void{
			var bitmapData:BitmapData = sources[url];
			if(bitmapData){
				bitmapData.dispose();
			}
			delete sources[url];
		}
		
		public function deleteBitmapData(bitmapData:BitmapData):void{
			for(var url:String in sources){
				if(bitmapData == sources[url]){
					bitmapData.dispose();
					delete sources[url];
					break;
				}
			}	
		}
		
		public function disposeAll():void{
			for each(var bitmapData:BitmapData in sources){
				bitmapData.dispose();
			}
			sources = null;
		}
	}
}