package com.ming.ui.controls
{
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	import com.ming.utils.TextUtil;
	
	import flash.display.*;
	import flash.filters.*;
	import flash.text.*;
	
	public class Button extends UIComponent
	{
		private var formatChanged:Boolean = false;
		private var enabledChanged:Boolean = false;
		private var sizeChange:Boolean = false;
		protected var labelText:TextField;
		public var enabledColor:uint = 0xcccccc;
		public var leftPadding:Number = 0;
		public var topPadding:Number = 0;
		public var iconTop:Number=0;
		public function Button(){
			init();
		}
		
		private function init() : void{
			height = 30;
			width = 100;
			buttonMode = true;
			useHandCursor = true;
			var buttonSkin:Skin = StyleManager.buttonSkin;
			if(buttonSkin){
				bgSkin = buttonSkin;
			}
		}
		
		private var _enabled:Boolean = true;
		public function set enabled(value:Boolean) : void{
			if(value != _enabled){
				_enabled = value;
				enabledChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get enabled() : Boolean{
			return _enabled;
		}
		
		private var _textSize:int = 12;
		public function set textSize(value:int) : void{
			if(_textSize != value){
				_textSize = value;
				formatChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get textSize() : int{
			return _textSize;
		}
		
		private var _textFont:String = "Tahoma";
		public function set textFont(value:String) : void{
			if(_textFont != value){
				_textFont = value;
				formatChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get textFont() : String
		{
			return _textFont;
		}
		
		private var _textBold:Boolean = false;
		public function set textBold(value:Boolean) : void{
			if(_textBold != value){
				_textBold = value;
				formatChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get textBold() : Boolean{
			return _textBold;
		}
		
		private var _textColor:uint = 0xF6F5CD;
		public function set textColor(value:uint) : void{
			if(_textColor != value){
				_textColor = value;
				formatChanged = true;
				invalidateDisplayList();
			}
		}	
		
		public function get textColor() : uint{
			return _textColor;
		}
		
		private var _iconLeft:int;
		public function set iconLeft(value:int) : void{
			if(_iconLeft != value){
				_iconLeft = value;
				sizeChange = true;
				invalidateDisplayList();
			}
		}
		
		public function get iconLeft() : int{
			return _iconLeft;
		}
		
		private var _label:String;
		public function set label(txt:String) : void{
			if (labelText == null){
				createTextField();
			}
			_label = txt;
			labelText.text = txt;
			formatChanged = true;
			invalidateDisplayList();
		}
		
		public function get label() : String{
			return _label;
		}
		
		private var _icon:DisplayObject;
		public function set icon(value:DisplayObject) : void
		{
			if (_icon != null){
				removeChild(_icon);
				_icon = null;
			}
			if (value != null){
				_icon = value;
				if(value is Sprite){
					Sprite(value).mouseEnabled = false;
				}
				addChild(value);
			}
			sizeChange = true;
			invalidateDisplayList();
		}
		
		public function get icon() : DisplayObject{
			return _icon;
		}
		
		override public function set width(value:Number):void{
			super.width = value;
			sizeChange = true;
			invalidateDisplayList();
		}
		
		override public function set height(value:Number):void{
			super.height = value;
			sizeChange = true;
			invalidateDisplayList();			
		}
		
		override public function set bgSkin(skin:Skin) : void{
			super.bgSkin = skin;
			if (bgSkin != null){
				bgSkin.enableMouse = enabled;
			}
		}
		
		private function createTextField() : void
		{
			labelText = new TextField();
			labelText.mouseEnabled = false;
			labelText.autoSize = TextFieldAutoSize.LEFT;
			labelText.selectable = false;
			labelText.filters = [new GlowFilter(0x15383a, 1, 2, 2, 20)];
			addChild(labelText);
			formatChanged = true;
			invalidateDisplayList();
		}
		
		private function setTextFormat() : void{
			if (labelText){
				labelText.defaultTextFormat = new TextFormat(textFont, textSize, textColor, textBold);
			}
		}
		
		private function enabledChange() : void{
			if (_enabled){
				if(bgSkin){
					bgSkin.filters = [];
				}
				setTextColor(textColor);
			}else{
				var btnSkin:ButtonSkin = bgSkin as ButtonSkin;
				if(btnSkin == null || btnSkin.disableSkin == null){
					bgSkin.filters = [new ColorMatrixFilter([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0])];
				}
				setTextColor(enabledColor);
			}
			mouseEnabled = mouseChildren = _enabled;
			if (bgSkin != null){
				bgSkin.enableMouse = enabled;
			}
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void{
			super.updateDisplayList(w, h);
			if (formatChanged){
				setTextFormat();
				updateButtonStyle();
				if(labelText){
					TextUtil.fitText(labelText,labelText.text,width);
				}
				updatePosition();
				formatChanged = false;
			}
			if (sizeChange){
				updatePosition();
				sizeChange = false;
			}
			if (enabledChanged){
				enabledChange();
				enabledChanged = false;
			}
		}
			
		protected function updatePosition() : void{
			var buttonSkin:ButtonSkin = bgSkin as ButtonSkin;
			if(buttonSkin){
				topPadding = buttonSkin.topPadding;
			}
			if (labelText){
				labelText.width = labelText.textWidth + 4;
				labelText.height = labelText.textHeight + 4;
			}
			if (_icon != null){
				_icon.x = Math.round(iconLeft + _icon.width / 2);
				_icon.y = Math.round((this.height - _icon.height) / 2)+iconTop;
				if (labelText){
					labelText.x = iconLeft + _icon.width * 2+leftPadding;
					labelText.y = Math.round((this.height - labelText.height) / 2)+topPadding;
				}
			}
			else if(labelText){
				labelText.x = Math.round((this.width - labelText.width) / 2)+leftPadding;
				labelText.y = Math.round((this.height - labelText.height) / 2)+topPadding;
			}
		}
		
		protected function updateButtonStyle():void{
			var buttonSkin:ButtonSkin = bgSkin as ButtonSkin;
			if(buttonSkin && buttonSkin.color != -1){
				buttonSkin.color = textColor;
			}
		}
		
		public function setTextColor(color:int):void{
			if (labelText){
				labelText.textColor = color;
			}
		}
	}
}
