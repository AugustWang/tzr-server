package com.scene.sceneUnit.baseUnit.things.common {
	import com.globals.GameConfig;

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class NumberImage {
		public var dic:Dictionary;
		public var hspace:Number=-6;

		public function NumberImage() {
			dic=new Dictionary();
			init();
		}

		private static var _instance:NumberImage;

		public static function getInstance():NumberImage {
			if (_instance == null) {
				_instance=new NumberImage();
			}
			return _instance;
		}

		public function init():void {
			dic["sb_word"]=Style.getUIBitmapData(GameConfig.T1_VIEWUI, 'sb_word');
			dic["pj1_word"]=Style.getUIBitmapData(GameConfig.T1_VIEWUI, 'pj1_word');
			dic["pj2_word"]=Style.getUIBitmapData(GameConfig.T1_VIEWUI, 'pj2_word');
			dic["bj1_word"]=Style.getUIBitmapData(GameConfig.T1_VIEWUI, 'bj1_word');
			dic["bj2_word"]=Style.getUIBitmapData(GameConfig.T1_VIEWUI, 'bj2_word');
			dic["exp"]=Style.getUIBitmapData(GameConfig.T1_VIEWUI, 'exp');
			dic["gunxun"]=Style.getUIBitmapData(GameConfig.T1_VIEWUI, 'gunxun');
			incisionNumImg("101", Style.getUIBitmapData(GameConfig.T1_VIEWUI, '101'));
			incisionNumImg("102", Style.getUIBitmapData(GameConfig.T1_VIEWUI, '102'));
			incisionNumImg("103", Style.getUIBitmapData(GameConfig.T1_VIEWUI, '103'));
			incisionNumImg("104", Style.getUIBitmapData(GameConfig.T1_VIEWUI, '104'));
		}

		private function incisionNumImg($url:String, $data:BitmapData):void {
			var desc:NumberDesc=new NumberDesc();
			desc.numBitmapData=$data;
			if ($url == "104") {
				desc.numberWidth=int(desc.numBitmapData.width / 10)
			} else {
				desc.numberWidth=int(desc.numBitmapData.width / 11)
			}
			desc.numberHeight=desc.numBitmapData.height;
			var numberBitmapData:BitmapData;
			for (var i:int=0; i < 11; i++) {

				var rect:Rectangle=new Rectangle(i * desc.numberWidth, 0, desc.numberWidth, desc.numberHeight);
				numberBitmapData=new BitmapData(desc.numberWidth, desc.numberHeight, true, 0x00ffffff);
				numberBitmapData.copyPixels(desc.numBitmapData, rect, new Point(0, 0));
				desc.numArray[i]=numberBitmapData;
			}
			pushURL($url, desc);
		}



		public function hasURL(url:String):Boolean {
			return dic[url] != null;
		}

		public function pushURL(url:String, desc:NumberDesc):void {
			dic[url]=desc;
		}

		public function getNumberDesc(url:String):NumberDesc {
			return dic[url];
		}

		public function toImage(countStr:String, url:String):Shape {
			var shape:ImageShape=new ImageShape();
			shape.toImage(countStr, url);
			shape.cacheAsBitmap=true;
			return shape;
		}
		
		public function toOnlyNum(countStr:String, url:String):Shape {
			var shape:ImageShape=new ImageShape();
			shape.toOnlyImage(countStr, url);
			shape.cacheAsBitmap=true;
			return shape;
		}

		public function toWord(countStr:String):Shape {
			var shape:ImageShape=new ImageShape();
			shape.toWordImage(countStr);
			shape.cacheAsBitmap=true;
			return shape;
		}
	}
}

import com.globals.GameConfig;
import com.scene.sceneUnit.baseUnit.things.common.NumberImage;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

class ImageShape extends Shape {
	public var url:String;
	private var countStr:String;
	public var hspace:Number=0;

	public function ImageShape() {
	}

	private function onloadComplete(event:Event):void {
		var loaderInfo:LoaderInfo=event.target as LoaderInfo;
		var bitmap:Bitmap=Bitmap(loaderInfo.content);
		NumberImage.getInstance().dic[loaderInfo.loader.name]=bitmap.bitmapData;
	}

	private function onIOError(event:Event):void {

	}

	public function toWordImage(countStr:String):void {
		if (NumberImage.getInstance().hasURL(countStr)) {
			var g:Graphics=graphics;
			var source:BitmapData=NumberImage.getInstance().dic[countStr];
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, 0, 0), false);
			g.drawRect(0, 0, source.width, source.height);
			g.endFill();
		} else {
			var loader:Loader=new Loader();
			loader.name=countStr;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(new URLRequest(GameConfig.EFFECT_SKILL_PATH + "word/" + countStr + ".png"));
		}
	}
	
	public function toOnlyImage(countStr:String, url:String):void{
		var desc:NumberDesc;
		desc=NumberImage.getInstance().getNumberDesc(url);
		var g:Graphics=graphics;
		var hgap:Number=(desc.numberWidth + hspace);
		var drawSatrtX:Number=0;
		var source:BitmapData;
		var len:int=countStr.length;
		for (var i:int=0; i < len; i++) {
			var index:int=int(countStr.charAt(i));
			source=desc.numArray[index] as BitmapData;
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, desc.numberWidth, desc.numberHeight);
			g.endFill();
			drawSatrtX+=22;
		}
	}

	public function toImage(countStr:String, url:String):void {
		var desc:NumberDesc;
		desc=NumberImage.getInstance().getNumberDesc(url);
		var g:Graphics=graphics;
		var hgap:Number=(desc.numberWidth + hspace);
		var drawSatrtX:Number=0;
		var source:BitmapData;
		var work:String=countStr.charAt(0);
		if (work == "m") {
			source=NumberImage.getInstance().dic["sb_word"];
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, source.width, source.height);
			g.endFill();
			return;
		}
		if (work == "b") {
			if (url == "101") {
				source=NumberImage.getInstance().dic["bj2_word"];
			} else {
				source=NumberImage.getInstance().dic["bj1_word"];
			}
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, source.width, source.height);
			g.endFill();
			drawSatrtX+=source.width;
			countStr=countStr.substr(1, countStr.length);
		} else if (work == "p") {
			if (url == "101") {
				source=NumberImage.getInstance().dic["pj2_word"];
			} else {
				source=NumberImage.getInstance().dic["pj1_word"];
			}
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, source.width, source.height);
			g.endFill();
			drawSatrtX+=source.width;
			countStr=countStr.substr(1, countStr.length);
		}else if (work == "g"){
			source=NumberImage.getInstance().dic["gunxun"];
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, source.width, source.height);
			g.endFill();
			drawSatrtX+=source.width;
			countStr=countStr.substr(1, countStr.length);
		}else if (work == "e") {
			source=NumberImage.getInstance().dic["exp"];
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, source.width, source.height);
			g.endFill();
			drawSatrtX+=source.width;
			countStr=countStr.substr(1, countStr.length);
		} else {
			source=desc.numArray[0] as BitmapData;
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, desc.numberWidth, desc.numberHeight);
			g.endFill();
			drawSatrtX+=22;
		}
		var len:int=countStr.length;
		for (var i:int=0; i < len; i++) {
			var index:int=int(countStr.charAt(i));
			if (work == "e") {
			} else {
				index+=1;
			}
			source=desc.numArray[index] as BitmapData;
			g.beginBitmapFill(source, new Matrix(1, 0, 0, 1, drawSatrtX, 0), false);
			g.drawRect(drawSatrtX, 0, desc.numberWidth, desc.numberHeight);
			g.endFill();
			drawSatrtX+=22;
		}
	}
}

class NumberDesc {

	public var numBitmapData:BitmapData; //数字图片数据源
	public var numArray:Array;
	public var numberWidth:Number;
	public var numberHeight:Number;

	public function NumberDesc() {
		numArray=[];
	}
}
