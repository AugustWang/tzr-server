package com.components.chat
{
	
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TextImageItem extends Sprite
	{
		public static const LOADSPEACK:String = "$0$";
		private static const FACE_ICON_SIZE:int=24;
		private var textField:TextField;
		public var addHtmlText:String="";
		private var myFacePattern:RegExp = /000/g;
		private var faceTextFormat:TextFormat;
		private var _width:Number = 210;
		private var _height:Number;
		private var faces:Array;
		private var shapes:Array;
		
		private var hoverColor:uint = 0xffff00
		private var css:StyleSheet;
		public var data:Object;
		
		public var handler:Function;
		public function TextImageItem()
		{
			super();
			faceTextFormat = new TextFormat("Tahoma",12,0xffffff)
			faceTextFormat.leading = 2;
			css = new StyleSheet();
			css.parseCSS("a:hover {text-decoration: underline; color: #"+hoverColor.toString(16)+";}");			
			blendMode = BlendMode.LAYER;
			faces = [];
			shapes = []
		}
		
		private function createTextField():void{
			if(textField){
				textField.removeEventListener(TextEvent.LINK,linkHandler);
				textField.parent.removeChild(textField);
			}
			textField = new TextField();
			textField.selectable = false;
			textField.width=250;
			textField.multiline=true;
			textField.wordWrap=true;
			textField.autoSize=TextFieldAutoSize.NONE;
			textField.condenseWhite=false;	
			textField.filters = [new GlowFilter(0x000000,1,3,3)];
			addChild(textField);
			textField.defaultTextFormat = faceTextFormat;
			textField.addEventListener(TextEvent.LINK,linkHandler);
		}
		
		private var pattern:RegExp=/(\&\d{2})/g;
		public function setHtmlText(value:String):void
		{
			createTextField();
			disposeAllFace();
			addHtmlText=value;
			textField.htmlText=addHtmlText;  
			var index:int = value.indexOf(LOADSPEACK);
			if(index == 0){
				addImg(LOADSPEACK,textField.getCharBoundaries(0));
			}
			setFaces();
			_height = textField.height = textField.textHeight+6;
		}
		
		override public function set width(value:Number):void{
			_width = value;
		}
		override public function get width() : Number{
			return this._width;
		}
		
		override public function get height():Number{
			return _height;
		}
		
		public var reg:RegExp=/\&\d{2}/;		
		private function setFaces():void
		{
			var splitArr:Array=textField.text.split(/(\&\d{2})/);
			if(!splitArr||splitArr.length==0)return;
			var lastIndex:int=0;
			var count:int = 1;
			for (var i:int=0; i < splitArr.length; i++)
			{
				var value:int = int(String(splitArr[i]).slice(1, 3));
				if (reg.test(splitArr[i]) && value>0 && value <= 36)
				{  	
					textField.replaceText(lastIndex,lastIndex+3,splitArr[i]+"  ");
					addImg(value.toString(),textField.getCharBoundaries(lastIndex));
					lastIndex+=5;
					if(count == 5)break;
					count++;
				}else
				{
					lastIndex+=String(splitArr[i]).length;
				}	
			}
			textField.styleSheet=css;
			//由于在textField换行时将00.替换成空格并没有效果，所以使用一个制表符和空格符，用来保证空格符号生效
			//textField.htmlText=textField.htmlText.replace(myFacePattern, "\t")
		}
		
		private function addImg(imgid:String,rect:Rectangle):void
		{
			var face:Face = new Face();
			face.source = imgid;
			if (face.hasImg) {
				var shape:Shape = new Shape();
				shape.blendMode = BlendMode.ERASE;
				var facey:Number = rect.y - 4;
				var rectWidth:int = 24;
				if(imgid == LOADSPEACK){
					facey = rect.y;
					rectWidth = 20;
				}
				with(shape.graphics){
					clear();
					beginFill(0,1);
					drawRect(0,0,rectWidth,18);
					endFill();
				}
				shape.x = rect.x -1;
				shape.y = rect.y;
				addChild(shape);
				shapes.push(shape);
				
				face.x=rect.x - 1;
				face.y = facey;
			
				faces.push(face);
				addChild(face); 	
			}
		}
		
		private function disposeAllFace():void{
			for each(var shape:Shape in shapes){
				removeChild(shape);
			}
			shapes.length = 0;
			for each(var face:Face in faces){
				removeChild(face);
			}
			faces.length = 0;
		}
		
		private function linkHandler(e:TextEvent):void
		{
			ChatList.CLICK_CHAT_LIST = false;
			if(handler != null)
				handler.call( null,e,data);
		}
	}
}