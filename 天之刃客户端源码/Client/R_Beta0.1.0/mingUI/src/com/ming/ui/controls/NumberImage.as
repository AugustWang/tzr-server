package com.ming.ui.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class NumberImage
	{
		private var dic:Dictionary;
		public var hspace:Number = -6;
		
		public function NumberImage()
		{	
			dic = new Dictionary();
		}
		
		private static var _instance:NumberImage;
		public static function getInstance():NumberImage{
			if(_instance == null){
				_instance = new NumberImage();
			}
			return _instance;
		}
		
		public function hasURL(url:String):Boolean{
			return dic[url] != null;
		}
		
		public function pushURL(url:String,desc:NumberDesc):void{
			dic[url] = desc;
		}
		
		public function getNumberDesc(url:String):NumberDesc{
			return dic[url];
		}
		
		public function toImage(countStr:String,url:String="com/assets/num.png"):Shape{
			var shape:ImageShape = new ImageShape();
			shape.toImage(countStr,url);
			shape.cacheAsBitmap = true;
			return shape;
		}
		
	}
}

import com.ming.ui.controls.NumberImage;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.Shape;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

class ImageShape extends Shape{
	public var url:String;
	private var countStr:String;
	public var hspace:Number = -6;
	public function ImageShape(){
	}
	
	public function load():void{
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioerrorFunc)
		loader.load(new URLRequest(url));				
	}
	private function ioerrorFunc(e:IOErrorEvent):void
	{
		e.target.removeEventListener(IOErrorEvent.IO_ERROR,ioerrorFunc)
		trace(e.text)
	}
	private function onLoadComplete(event:Event):void{
		var desc:NumberDesc = new NumberDesc();
		desc.numBitmapData = (event.currentTarget.content as Bitmap).bitmapData;
		desc.numberWidth = desc.numBitmapData.width/10;
		desc.numberHeight = desc.numBitmapData.height;
		var numberBitmapData:BitmapData;	
		for(var i:int=0;i<10;i++){
			var rect:Rectangle = new Rectangle(i*desc.numberWidth,0,desc.numberWidth,desc.numberHeight);
			numberBitmapData = new BitmapData(desc.numberWidth,desc.numberHeight,true,0x00ffffff);
			numberBitmapData.copyPixels(desc.numBitmapData,rect,new Point(0,0));
			desc.numArray[i] = numberBitmapData;
		}
		NumberImage.getInstance().pushURL(url,desc);
		toImage(countStr,url);
	}
	
	public function toImage(countStr:String,url:String):void{
		var desc:NumberDesc;
		if(NumberImage.getInstance().hasURL(url)){
			desc = NumberImage.getInstance().getNumberDesc(url);
			var len:int = countStr.length;
			var g:Graphics = graphics;
			var hgap:Number = (desc.numberWidth+hspace);
			for(var i:int=0;i<len;i++){
				var index:int = int(countStr.charAt(i));
				var source:BitmapData = desc.numArray[index] as BitmapData;
				g.beginBitmapFill(source,new Matrix(1,0,0,1,i*hgap,0),false);
				g.drawRect(i*hgap,0,desc.numberWidth,desc.numberHeight);
				g.endFill();
			}			
		}else{
			this.countStr = countStr;
			this.url = url;
			load();
		}
	}
}
class NumberDesc{
	
	public var numBitmapData:BitmapData; //数字图片数据源
	public var numArray:Array;
	public var numberWidth:Number;
	public var numberHeight:Number;
	
	public function NumberDesc(){
		numArray = [];
	}
}
