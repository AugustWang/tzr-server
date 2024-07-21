
package com.ming.ui.controls
{
	import com.ming.core.IDataRenderer;
	import com.ming.managers.ImageManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class Image extends Sprite implements IDataRenderer
	{
		private var _data:Object;
		private var _source:*
		private var loader:Loader;
		private var _width:Number = NaN;
		private var _height:Number = NaN;
		private var _explicitWSet:Boolean = false;
		private var _explicitHSet:Boolean = false;
		private var content:Bitmap;
		public var cache:Boolean = true; // 是否缓存资源
		public function Image()
		{
			super();
			content = new Bitmap();
			addChild(content);
			defaultIcon = new DefaultIcon();
			ImageManager.getInstance().addImage(this);
		}
		
		private var _defaultIcon:DisplayObject;
		public function set defaultIcon(icon:DisplayObject):void{
			this._defaultIcon = icon;	
		}
		
		public function set source(value:*):void{
			
			if(value is String){
				if(value==null||value==this.source)return;
				var bitmapData:BitmapData = ImageManager.getInstance().getBitmapData(value);
				if(bitmapData){
					value = bitmapData;
				}
			}
			if(_defaultIcon){
				if(_defaultIcon.parent){
					removeChild(_defaultIcon);
				}
			}
			this._source = value;
			loadImage();
		}
		
		public function get source():*{
			return this._source;
		}
		
		override public function set width(value:Number):void{
			this._width = value;
			_explicitWSet = true;
			if(content){
				content.width = _width;
			}
		}
		override public function get width():Number{
			return this._width;
		}
		
		override public function set height(value:Number) : void{
			this._height = value;
			_explicitHSet = true;
			if(content){
				content.height = _height;
			}			
		}
		override public function get height() : Number{
			return this._height;
		}
		
		private function loadImage():void{
			if(loader){
				try{
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadCompleteHandler);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
					loader.unload();
				}catch(e:*){}
			}
			try{
				if(source is String){
					if(_defaultIcon){
						var w:Number = Math.max(width,_defaultIcon.width);
						var h:Number = Math.max(height,_defaultIcon.height);
						_defaultIcon.x = (w - _defaultIcon.width)/2;
						_defaultIcon.y = (h - _defaultIcon.height)/2;
						addChild(_defaultIcon);
					}
					loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
					loader.load(new URLRequest(source));
				}else if(source is BitmapData){
					addContent(source);
				}else if(source is Bitmap){
					addContent(source.bitmapData);
				}else{
					if(content){
						content.bitmapData = null;
					}
				}
			}catch(error:*){
				
			}
		}
		
		public function dispose():void{
			if(numChildren > 0){
				if(content && content.bitmapData)
					ImageManager.getInstance().deleteBitmapData(content.bitmapData);
					if(content.bitmapData){
						content.bitmapData.dispose();
					}
			}	
		}
		
		private function loadCompleteHandler(event:Event):void{
			if(_defaultIcon && _defaultIcon.parent){
				removeChild(_defaultIcon);
				_defaultIcon = null;
			}
			addContent(event.currentTarget.content.bitmapData);
			event.currentTarget.removeEventListener(Event.COMPLETE,loadCompleteHandler);
			event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			loader = null;
			dispatchEvent(event.clone());
		}
		
		private function addContent(bitmapdata:BitmapData):void{
			content.bitmapData = bitmapdata;
			if(_explicitWSet && !isNaN(width)){
				content.width = width;
			}else{
				_width = content.width;
			}
			if(_explicitHSet && !isNaN(height)){
				content.height = height;
			}else{
				_height = content.height;
			}
		}
		
		public function getContent():Bitmap{
			return content;
		}
		
		public function getBitmapData():BitmapData{
			return content.bitmapData;
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void{
			dispatchEvent(event.clone());
		}
		
		public function set data(value:Object):void{
			this._data = value;
		}
		
		public function get data():Object{
			return this._data;
		}
	}
}