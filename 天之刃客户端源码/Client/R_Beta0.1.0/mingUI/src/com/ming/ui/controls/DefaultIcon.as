package com.ming.ui.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class DefaultIcon extends Bitmap
	{
		public static var url:String = "assets/help.png";
		private static var loader:Loader;
		private static var iconData:BitmapData;
		private static var items:Array = [];
		public function DefaultIcon()
		{
			
			if(iconData != null){
				this.bitmapData = iconData;
				return;
			}
			if(loader == null){
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioerrorFunc)
				loader.load(new URLRequest(url));
			}else{
				items.push(this);
			}
		}
		private function ioerrorFunc(e:IOErrorEvent):void
		{
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioerrorFunc)
			trace(this,e.text)
		}
		private function onComplete(evt:Event):void{
			iconData = loader.content["bitmapData"];
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onComplete);
			for each(var bitmap:Bitmap in items){
				bitmap.bitmapData = iconData;
			}
			loader = null;
			items = null;
		}

		override public function get width():Number{
			if(bitmapData){
				return bitmapData.width;
			}
			return 0;
		}
		override public function get height():Number{
			if(bitmapData){
				return bitmapData.height;
			}
			return 0;
		}
		
	}
}