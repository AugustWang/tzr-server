package com.scene.sceneKit {

	import com.components.chat.Face;
	import com.components.chat.TextImageItem;
	
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * 角色名字的一行
	 * @author LXY
	 *
	 */
	public class BubbleText extends Sprite {

		private static const FACE_ICON_SIZE:int=24;
		private var textField:TextField;
		public var addHtmlText:String="";
		private var myFacePattern:RegExp=/00·/g;
		private var faceTextFormat:TextFormat;
		private var _height:Number;
		private var faces:Array;
		private var masks:Array;
		public var data:Object;
		private var shapes:Array;
		public var handler:Function;

		public function BubbleText() {
			super();
			cacheAsBitmap = true;
			faceTextFormat=new TextFormat()
			faceTextFormat.color=0xffffff;
			faceTextFormat.bold=false;
			faceTextFormat.size=12;
			faceTextFormat.leading=6;
			textField=new TextField;
			textField.autoSize=TextFieldAutoSize.LEFT;
			textField.condenseWhite=false;
			textField.mouseEnabled=false;
			textField.wordWrap=true;
			textField.multiline=true;
			textField.width=124;
			textField.defaultTextFormat=faceTextFormat;
			this.addChild(textField);
			blendMode=BlendMode.LAYER;
			faces=[];
			masks=[];
			shapes=[];
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void{
			if(htmlUpdate){
				htmlText = _htmlText;
			}
		}
		
		private var htmlUpdate:Boolean = false;
		private var _htmlText:String = "";
		
		private var pattern:RegExp=/(\/&d{2})/g;
		private var regHtml:RegExp=new RegExp("<u>|</u>", "gi");

		public function set htmlText(value:String):void {
			_htmlText = value;
			htmlUpdate = false;
			if(stage){			
				disposeAllFace();
				reg.lastIndex=0;
				value=value.replace(regHtml, "");
				value=value.replace(pattern, "$& ");
				addHtmlText=value;
				textField.htmlText='<FONT color="#ffffff" size="12" >' + addHtmlText + '</FONT>';
	//			textField.setTextFormat(faceTextFormat);
				setFaces();
			}else{
				htmlUpdate = true;
			}
		}

		public var reg:RegExp=/\&\d{2}/;

		private function setFaces():void {
			var splitArr:Array=textField.text.split(/(\&\d{2})/);
			if (!splitArr || splitArr.length == 0)
				return;
			var lastIndex:int=0;
			var count:int=1;
			for (var i:int=0; i < splitArr.length; i++) {
				if (reg.test(splitArr[i]) && int(String(splitArr[i]).slice(1, 3)) > 0 && int(String(splitArr[i]).slice(1, 3)) <= 36) {
					textField.replaceText(lastIndex, lastIndex + 3, splitArr[i] + "  ");
					addImg(int(String(splitArr[i]).slice(1, 3)).toString(), textField.getCharBoundaries(lastIndex));
					lastIndex+=5;
					if (count == 5)
						break;
					count++;

				} else {
					lastIndex+=String(splitArr[i]).length;
				}

			}
			//由于在textField换行时将00.替换成空格并没有效果，所以使用一个制表符和空格符，用来保证空格符号生效
//			textField.htmlText=textField.htmlText.replace(myFacePattern, "\u0020\u0020\u0020\u0020\u0020\u0020\u0020")
		}

		private function addImg(imgid:String, rect:Rectangle):void {
			if (rect == null)
				return;
			var shape:Shape=new Shape();
			shape.blendMode=BlendMode.ERASE;
			var facey:Number=rect.y - 4;
			var rectWidth:int=24;
			if (imgid == TextImageItem.LOADSPEACK) {
				facey=rect.y;
				rectWidth=20;
			}
			with (shape.graphics) {
				clear();
				beginFill(0, 1);
				drawRect(0, 0, rectWidth, 18);
				endFill();
			}
			shape.x=rect.x - 1;
			shape.y=rect.y;
			shapes.push(shape);
			addChild(shape);
			var face:Face=new Face();
			face.source=imgid;
			face.x=rect.x - 1;
			face.y=facey;
			faces.push(face);
			addChild(face);
		}

		private function addMask(img:Face):void {
			var mask:Sprite=new Sprite;
			mask.x=img.x - 2;
			mask.y=img.y - 2;
			mask.blendMode=BlendMode.ALPHA;
			mask.graphics.beginFill(0x000000, 0);
			mask.graphics.drawRect(0, 0, img.width + 2, img.height + 2);
			mask.graphics.endFill();
			addChild(mask);
			masks.push(mask);
		}

		private function disposeAllFace():void {
			for each (var face:Face in faces) {
				removeChild(face);
			}
			faces.length=0;
			for each (var mask:Shape in shapes) {
				removeChild(mask);
			}
			shapes.length=0;
		}

	}
}