package com.ming.ui.controls
{
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ProgressBar extends UIComponent
	{
		public var text:TextField;
		public var padding:Number = 2;
		public function ProgressBar()
		{
			super();	
			init();
		}
		
		private function init():void{
			var tf:TextFormat = StyleManager.textFormat;
			tf.align = "center";
			text = new TextField();
			text.height = 20;
			text.defaultTextFormat = tf;
			text.mouseEnabled = false;
			text.filters = [new GlowFilter(0x000000, 1, 3, 3)];
			addChild(text);
			value = 0;
		}
		
		private var _label:String;
		public function set htmlText(param:String):void{
			_label = param;
			text.htmlText = param;
		}
		public function get htmlText():String{
			return _label;
		}
		
		private var _bar:DisplayObject;
		public function set bar(param:DisplayObject):void{
			_bar = param;	
			addChild(_bar);
			addChild(text);
			invalidateDisplayList();
		}
		
		private var valueChanged:Boolean = false;
		private var _value:Number = -1;
		public function set value(param:Number):void{
			if(_value != param){
				_value = param;	
				_value = Math.max(0,param);
				_value = Math.min(1,param);
				valueChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get value():Number{
			return _value;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(_bar){
				_bar.y = h - _bar.height >> 1;
				_bar.x = padding;
			}
			text.width = w;
			text.y = h - text.height >> 1;
			if(valueChanged && _bar){
				valueChanged = false;
				_bar.width = _value*(width-2*padding);
			}	
		}
	}
}