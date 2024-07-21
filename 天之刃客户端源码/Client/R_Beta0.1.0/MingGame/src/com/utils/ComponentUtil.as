package com.utils {
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * 组件创建函数 (在游戏大量需要创建按钮和文本)
	 * @author Administrator
	 *
	 */
	public class ComponentUtil {

		/**
		 * 创建按钮
		 * @param label 文本
		 * @param x
		 * @param y
		 * @param w 宽度
		 * @param h 高度
		 * @param parent 父容器
		 * @param styleFunc 样式函数,用于指定特定的样式(默认建议将函数添加在GStyle中)
		 * @param wrapperFunc 装配函数(如果需要对按钮设置额外属性，如name 可以自己单独定义函数,函数参数是当前button)
		 * @return 按钮
		 *
		 */
		public static function createButton(label:String, x:Number, y:Number, w:Number=NaN, h:Number=NaN, parent:DisplayObjectContainer=
			null, styleFunc:Function=null, wrapperFunc:Function=null):Button {
			var button:Button=new Button();
			button.label=label;
			button.x=x;
			button.y=y;
			if (!isNaN(w)) {
				button.width=w;
			}
			if (!isNaN(h)) {
				button.height=h;
			}
			if (styleFunc != null) {
				styleFunc(button);
			}
			if (wrapperFunc != null) {
				wrapperFunc(button);
			}
			if (parent) {
				parent.addChild(button);
			}
			return button;
		}

		/**
		 * 创建带选择状态的按钮
		 * @param label 文本
		 * @param x
		 * @param y
		 * @param w 宽度
		 * @param h 高度
		 * @param parent 父容器
		 * @param styleFunc 样式函数,用于指定特定的样式(默认建议将函数添加在GStyle中)
		 * @param wrapperFunc 装配函数(如果需要对按钮设置额外属性，如name 可以自己单独定义函数,函数参数是当前button)
		 * @return 按钮
		 *
		 */
		public static function createToggleButton(label:String, x:Number, y:Number, w:Number=NaN, h:Number=NaN, parent:DisplayObjectContainer=
			null, styleFunc:Function=null, wrapperFunc:Function=null):ToggleButton {
			var button:ToggleButton=new ToggleButton();
			button.label=label;
			//button.filters = [new GlowFilter(0x0, 1, 2, 2, 20)];
			button.x=x;
			button.y=y;
			if (!isNaN(w)) {
				button.width=w;
			}
			if (!isNaN(h)) {
				button.height=h;
			}
			if (styleFunc != null) {
				styleFunc(button);
			}
			if (wrapperFunc != null) {
				wrapperFunc(button);
			}
			if (parent) {
				parent.addChild(button);
			}
			return button;
		}

		/**
		 * 创建文本
		 * @param text 文本
		 * @param x
		 * @param y
		 * @param w 宽度
		 * @param h 高度
		 * @param textFormat 文本格式(默认为GStyle.textFormat)
		 * @param parent 父容器
		 * @param wrapperFunc 装配函数(如果需要对文本设置额外属性，如name 可以自己单独定义函数,函数参数是当前文本对象)
		 * @return 文本对象
		 *
		 */
		public static function createTextField(text:String, x:Number, y:Number, textFormat:TextFormat=null, w:Number=NaN,
			h:Number=NaN, parent:DisplayObjectContainer=null, wrapperFunc:Function=null, txtName:String=""):TextField {
			var textField:TextField=new TextField();
			//textField.filters = [new GlowFilter(0x0, 1, 2, 2, 20)];
			textField.x=x;
			textField.y=y;
			if (!isNaN(w)) {
				textField.width=w;
			}
			if (!isNaN(h)) {
				textField.height=h;
			}
			if (textFormat != null) {
				textField.defaultTextFormat=textFormat;
			} else {
				textField.defaultTextFormat=Style.textFormat;
			}
			textField.text=text;
			if (parent) {
				parent.addChild(textField);
			}
			textField.selectable=false;
			textField.mouseEnabled=false;
			if (wrapperFunc != null) {
				wrapperFunc(textField);
			}
			if (txtName != "") {
				textField.name=txtName;
			}
			return textField;
		}

		/**
		 * 创建UIComponent （为MingUI库里的UIComponent）
		 * @param width 宽度
		 * @param height 高度
		 * @param skin 皮肤
		 * @return  当前UIComponent
		 *
		 */
		public static function createUIComponent(x:Number, y:Number, width:Number, height:Number, skin:Skin=null):UIComponent {
			var uiComponent:UIComponent=new UIComponent();
			uiComponent.x=x;
			uiComponent.y=y;
			uiComponent.width=width;
			uiComponent.height=height;
			if (skin) {
				uiComponent.bgSkin=skin
			}
			return uiComponent;
		}

		public static function createCheckBox(label:String, x:Number, y:Number, parent:DisplayObjectContainer, styleFunc:Function=
			null, wrapperFunc:Function=null):CheckBox {
			var checkBox:CheckBox=new CheckBox();
			checkBox.text=label;
			checkBox.space=2;
			checkBox.x=x;
			checkBox.y=y;
			checkBox.textFormat=StyleManager.textFormat;
			if (styleFunc != null) {
				styleFunc(checkBox);
			}
			if (wrapperFunc != null) {
				wrapperFunc(checkBox);
			}
			if (parent) {
				parent.addChild(checkBox);
			}
			return checkBox;
		}


		public static function buildTextField(text:String, textFormat:TextFormat=null, w:Number=NaN, h:Number=NaN, parent:DisplayObjectContainer=
			null, wrapperFunc:Function=null):TextField {
			var textField:TextField=new TextField();

			if (!isNaN(w)) {
				textField.width=w;
			}
			if (!isNaN(h)) {
				textField.height=h;
			}
			if (textFormat != null) {
				textField.defaultTextFormat=textFormat;
			} else {
				textField.defaultTextFormat=Style.textFormat;
			}
			textField.text=text;
			if (wrapperFunc != null) {
				wrapperFunc(textField);
			}
			if (parent) {
				parent.addChild(textField);
			}
			textField.selectable=false;
			textField.mouseEnabled=false;

			return textField;
		}

		public static function buildTextArea(text:String, w:Number=NaN, h:Number=NaN, parent:DisplayObjectContainer=null,
			wrapperFunc:Function=null):TextArea {
			var textArea:TextArea=new TextArea();

			if (!isNaN(w)) {
				textArea.width=w;
			}
			if (!isNaN(h)) {
				textArea.height=h;
			}

			textArea.text=text;
			if (wrapperFunc != null) {
				wrapperFunc(textArea);
			}
			if (parent) {
				parent.addChild(textArea);
			}

			return textArea;
		}

		public static function createTextInput(_x:Number, _y:Number, _w:Number, _h:Number, _parent:DisplayObjectContainer,
			_changeFunc:Function=null, _maxChars:int=0, _restrict:String=null):TextInput {

			var _textInput:TextInput=new TextInput;
			_textInput.textField.defaultTextFormat = Style.textFormat;
			_textInput.x=_x;
			_textInput.y=_y;
			_textInput.height=_h;
			_textInput.width=_w;
			_textInput.maxChars=_maxChars;
			_textInput.restrict=_restrict;
			if (_changeFunc is Function) {
				_textInput.addEventListener(Event.CHANGE, _changeFunc);
			}
			if (_parent) {
				_parent.addChild(_textInput);
			}
			return _textInput;
		}

		/**
		 * 绘制陷入效果的线条 即一条深色一条浅色
		 */
		public static function drawDubbleLine(w:Number, colorH:uint, colorL:uint, parent:DisplayObjectContainer=null, x:Number=
			0, y:Number=0):Sprite {
			var sprite:Sprite=new Sprite();
			sprite.graphics.lineStyle(1, colorL);
			sprite.graphics.moveTo(0, 0);
			sprite.graphics.lineTo(w, 0);
			sprite.graphics.lineStyle(1, colorH);
			sprite.graphics.moveTo(0, 1);
			sprite.graphics.lineTo(w, 1);
			if (parent) {
				parent.addChild(sprite);
				sprite.x=x;
				sprite.y=y;
			}
			return sprite;
		}

		public static function drawHightLightBorder(w:Number, h:Number, c:int=5, thick:int=2, color:uint=0xffff00, alpha:Number=1, x:Number=
			0, y:Number=0, parent:DisplayObjectContainer=null):Sprite {
			var sprite:Sprite=new Sprite();
			sprite.graphics.lineStyle(thick, color, alpha);
			sprite.graphics.beginFill(color, 0.3);
			sprite.graphics.drawRoundRect(0, 0, w, h, c);
			sprite.graphics.endFill();
			if(parent){
				parent.addChild(sprite);
				sprite.x = x;
				sprite.y = y;
			}
			sprite.mouseEnabled = false;
			return sprite;
		}
		
		public static function createBitmap(bitmapData:BitmapData=null,x:int=0,y:int=0,parent:DisplayObjectContainer=null):Bitmap{
			var bitmap:Bitmap = new Bitmap();
			bitmap.x = x;
			bitmap.y = y;
			bitmap.bitmapData = bitmapData;
			if(parent){
				parent.addChild(bitmap);
			}
			return bitmap;
		}
		
		public static function createProcessBar(x:int,y:int,bgSkin:Skin,bar:DisplayObject,w:Number = 100,h:Number=12,parent:DisplayObjectContainer=null):ProgressBar{
			var progressBar:ProgressBar = new ProgressBar();
			progressBar.bgSkin = bgSkin;
			progressBar.bar = bar;
			progressBar.x = x;
			progressBar.y = y;
			progressBar.width = w;
			progressBar.height = h;
			if(parent){
				parent.addChild(progressBar);
			}
			return progressBar;
		}
	}
}