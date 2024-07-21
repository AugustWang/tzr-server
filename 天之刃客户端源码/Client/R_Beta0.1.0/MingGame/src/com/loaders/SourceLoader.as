package com.loaders
{
	import com.scene.sceneKit.LoadingSetter;
	import com.utils.KeyUtil;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class SourceLoader extends Loader
	{
		public var url:String;
		private var msg:String;
		private var completeFunc:Function;
		private var errorFunc:Function;
		
		public var init:Boolean = false;
		private var loading:Boolean = false;
		public function SourceLoader()
		{
			super();
			contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgress);
		}
		
		public function loadSource(url:String,msg:String,completeFunc:Function=null, _errorFunc:Function=null):void{
			if(loading == false){
				this.url = url;
				this.msg = msg;
				this.completeFunc = completeFunc;
				this.errorFunc = _errorFunc;
				loading = true;
				init = false;
				KeyUtil.getInstance().enabled = false;
				load(new URLRequest(url));
			}
		}
		
		private function onLoadComplete(event:Event):void
		{
			if (!ResourcePool.hasResource(url)) {
				ResourcePool.add(url, (event.target.loader as Loader).contentLoaderInfo.applicationDomain);
			}
			init = true;
			loading = false;
			LoadingSetter.mapLoading(false);
			KeyUtil.getInstance().enabled = true;
			if(completeFunc != null){
				completeFunc.apply(null,null);
			}
		}
		
		private function onProgress(event:ProgressEvent):void{
			LoadingSetter.mapLoading(true,event.bytesLoaded/event.bytesTotal,msg);
		}
		
		private function onIOError(evet:IOErrorEvent):void{
			loading = false;
			init = false;
			LoadingSetter.mapLoading(false);
			KeyUtil.getInstance().enabled = true;
			if (errorFunc != null) {
				errorFunc.apply(null,null);
			}
		}
		
		public function getMovieClip(name:String):Sprite{
			if(contentLoaderInfo.applicationDomain && contentLoaderInfo.applicationDomain.hasDefinition(name)){
				var clazz:Class = contentLoaderInfo.applicationDomain.getDefinition(name) as Class;
				return new clazz();
			}
			return new Sprite();
		}
		
		public function getBitmapData(name:String):BitmapData{
			if(contentLoaderInfo.applicationDomain && contentLoaderInfo.applicationDomain.hasDefinition(name)){
				var clazz:Class = contentLoaderInfo.applicationDomain.getDefinition(name) as Class;
				return new clazz(0,0);
			}
			return new BitmapData(0,0);
		}
		
		public function clear():void
		{
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
			this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onProgress);
			this.unload();
		}
	}
}