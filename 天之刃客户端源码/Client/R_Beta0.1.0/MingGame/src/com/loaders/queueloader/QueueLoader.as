package com.loaders.queueloader
{
	import com.globals.GameConfig;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class QueueLoader extends EventDispatcher
	{
		private var currentItem:LoaderItem;
		private var queues:Array;
		public var size:int;
		public var loadCount:int;
		public function QueueLoader()
		{
			super();
		}
		
		public function load():void{
			if(queues && queues.length > 0){
				currentItem = queues.shift();
				var type:String = currentItem.type;
				if(type == LoaderItem.FILE){
					loadFile(currentItem.url);
				}else if(type == LoaderItem.IMAGE || type == LoaderItem.SWF){
					loadImages(currentItem.url);
				}
			}else{
				dispath(QueueEvent.QUEUE_COMPLETE,null,null);
				clear();
			}
		}
		
		private var urlLoader:URLLoader;
		private function loadFile(url:String):void{
			if(urlLoader == null){
				urlLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE,onFileComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
				urlLoader.addEventListener(ProgressEvent.PROGRESS,onProgress);
			}
			urlLoader.load(getURL(url));
		}
		
		private var loader:Loader;
		private function loadImages(url:String):void{
			if(loader == null){
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onImageComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgress);
			}
			loader.load(getURL(url));
		}
		
		private var urlRequest:URLRequest;
		private function getURL(url:String):URLRequest{
			if(urlRequest == null){
				urlRequest = new URLRequest();
			}
			urlRequest.url = url;
			return urlRequest;
		}
		
		public function add(url:String,data:Object=null):void{
			if(queues == null){
				queues = [];
			}
			var loaderItem:LoaderItem = new LoaderItem();
			loaderItem.url = url;
			loaderItem.data = data;
			queues.push(loaderItem);
			size = queues.length; 
		}
		
		public function clear():void{
			queues = null;
			currentItem = null;
			loadCount = size = 0;
			if(urlLoader){
				urlLoader.removeEventListener(Event.COMPLETE,onFileComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
				urlLoader.removeEventListener(ProgressEvent.PROGRESS,onProgress);
				urlLoader = null;
			}
			if(loader){
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onImageComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onProgress);
				loader.unload();
				loader = null
			}
		}
		
		private function onImageComplete(event:Event):void{
			loadCount++;
			dispath(QueueEvent.ITEM_COMPLETE,currentItem,loader);
			load();
		}
		
		private function onFileComplete(event:Event):void{
			loadCount++
			dispath(QueueEvent.ITEM_COMPLETE,currentItem,urlLoader.data);
			load();
			
		}
		
		private function onProgress(event:ProgressEvent):void{
			dispath(QueueEvent.ITEM_PROGRESS,currentItem,{bytesLoaded:event.bytesLoaded,bytesTotal:event.bytesTotal});
		}
		
		private function onIOError(event:IOErrorEvent):void{
			dispath(QueueEvent.ITEM_IO_ERROR,currentItem,{error:event.text});
		}
		
		private function dispath(type:String,currentItem:LoaderItem,data:*):void{
			var event:QueueEvent = new QueueEvent(type);
			event.loadItem = currentItem;
			event.data = data;
			dispatchEvent(event);
		}
	}
}