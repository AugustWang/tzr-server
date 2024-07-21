package com.scene.sceneKit {
	import com.scene.sceneUnit.baseUnit.SceneStyle;
	import com.utils.HtmlUtil;

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
	public class RoleNameItem extends Sprite {

		private static const FACE_ICON_SIZE:int=24;
		private var textField:TextField;
		public var addHtmlText:String="";
		private var myFacePattern:RegExp=/00·/g;
		private var faceTextFormat:TextFormat;
		private var _height:Number;
		private var faces:Array;

		public var data:Object;

		public var handler:Function;

		public function RoleNameItem(str:String="") {
			super();
			faceTextFormat=new TextFormat()
			textField=new TextField()
			textField.autoSize=TextFieldAutoSize.LEFT;
			textField.condenseWhite=false;
			textField.filters=SceneStyle.nameFilter;
			addChild(textField);
			faces=[];
			this.mouseEnabled=false;
			this.mouseChildren=false;
			setHtmlText(HtmlUtil.font(str, "#ffffff"));
			this.x=int(-this.width / 2);
		}

		public function multiline(b:Boolean):void {
			textField.wordWrap=b;
			textField.multiline=b;
		}

		public function set txtWidth(value:Number):void {
			textField.width=value;
		}

		public function set textColor(value:uint):void {
			textField.textColor=value;
		}

		public function get text():String {
			return textField.text;
		}

		public function setTextFormat(tf:TextFormat):void {
			textField.setTextFormat(tf);
		}
		private var pattern:RegExp=/(\/\d{2})/g;

		public function setHtmlText(value:String):void {
			disposeAllFace();
			value=value.replace(pattern, "$& ");
			addHtmlText=value;
			textField.htmlText=addHtmlText;
			//			textField.setTextFormat(faceTextFormat);
			if (_height != Math.floor(textField.textHeight + 6)) {
				_height=textField.height=Math.floor(textField.textHeight + 6);
			}
			setFaces();
			if (this.x != Math.floor(-this.width / 2)) { 
				this.x=Math.floor(-this.width / 2);
			}
		}

		public var reg:RegExp=/\/\d{2}/;

		private function setFaces():void {
			var splitArr:Array=textField.text.split(/(\/\d{2})/);
			if (!splitArr || splitArr.length == 0)
				return;
			var lastIndex:int=0;
			for (var i:int=0; i < splitArr.length; i++) {
				if (reg.test(splitArr[i]) && int(String(splitArr[i]).slice(1, 3)) > 0 && int(String(splitArr[i]).slice(1, 3)) <= 36) {
					addImg(int(String(splitArr[i]).slice(1, 3)).toString(), textField.getCharBoundaries(lastIndex));

					textField.replaceText(lastIndex, lastIndex + 3, "00·");
					lastIndex+=String(splitArr[i]).length;

				} else {
					lastIndex+=String(splitArr[i]).length;
				}

			}
			//由于在textField换行时将00.替换成空格并没有效果，所以使用一个制表符和空格符，用来保证空格符号生效
			textField.htmlText=textField.htmlText.replace(myFacePattern, "\u0020\u0020\u0020\u0020\u0020\u0020")
		}

		private function addImg(imgid:String, rect:Rectangle):void {
			//			var face:Face=new Face();
			//			face.source=imgid;
			//			face.width=FACE_ICON_SIZE;
			//			face.height=FACE_ICON_SIZE;
			//			face.x=int(rect.x - 5);
			//			face.y=int(rect.y - 4);
			//			faces.push(face);
			//			addChild(face);
		}

		private function disposeAllFace():void {
			//			for each (var face:Face in faces)
			//			{
			//				removeChild(face);
			//			}
			//			faces.length=0;
		}

	}
}