package com.ming.ui.controls
{
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.skins.SliderSkin;
	import com.ming.ui.style.StyleManager;
	import com.ming.utils.Handler;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Slider extends UIComponent
	{
		protected var _fillBar:UIComponent;
		protected var _fillMask:Shape;
		protected var _handle:UIComponent;
		protected var _back:UIComponent;
		protected var _value:Number = 0;
		protected var _max:Number = 100;
		protected var _min:Number = 0;
		protected var _tickInterval:Number = 1;
		
		public var backSize:Number = 10;
		public var fillSize:Number = 10;
		private var _handlerSize:Number = 10;
		
		public static const HORIZONTAL:String = "horizontal";
		public static const VERTICAL:String = "vertical";

		public function Slider()
		{
			init();
		}
		
		public function setBackSkin(skin:Skin):void{
			_back.bgSkin = skin;
		}
		
		public function setHandlerSkin(skin:Skin):void{
			_handle.bgSkin = skin;
		}
		
		private var _direction:String = HORIZONTAL;
		public function set direction(value:String):void{
			_direction = value;
		}
		public function get direction():String{
			return _direction;
		}
		
		public function set handlerSize(value:Number):void{
			_handlerSize = value;
			_handle.width = _handlerSize;
		}
		
		public function get handlerSize():Number{
			return _handlerSize;
		}
		
		private var _showFill:Boolean = false;
		public function set showFill(value:Boolean):void{
			_showFill = value;
			if(_showFill){
				_fillBar = new UIComponent();
				_fillBar.mouseChildren = _fillBar.mouseEnabled = false;
				addChild(_fillBar);
				_fillMask = new Shape();
				_fillBar.mask = _fillMask;
				addChild(_fillMask);
			}else if(_fillBar){
				_fillBar.dispose();
				_fillBar = null;
				if(_fillMask){
					_fillMask.parent.removeChild(_fillMask);
				}
			}
		}
		
		public function get showFill():Boolean{
			return _showFill;
		}
		
		private var _fillSkin:Skin;
		public function set fillSkin(value:Skin):void{
			_fillSkin = value;
			if(_fillBar){
				_fillBar.bgSkin = value;
			}
		}
		
		protected function init():void{
			_back = new UIComponent();
			_back.bgColor = 0xff1234;
			_back.addEventListener(MouseEvent.MOUSE_DOWN, onBackClick);
			addChild(_back);
			
			_handle = new UIComponent();
			_handle.bgColor = 0x336699;
			_handle.addEventListener(MouseEvent.MOUSE_DOWN, onDragHandler);
			_handle.buttonMode = true;
			_handle.useHandCursor = true;
			addChild(_handle);
			var sliderSkin:SliderSkin = StyleManager.sliderSkin;
			if(sliderSkin){
				if(sliderSkin.backSkin){
					setBackSkin(sliderSkin.backSkin);
				}
				if(sliderSkin.handlerSkin){
					setHandlerSkin(sliderSkin.handlerSkin);
				}
			}
			
		}
		
		protected function onDragHandler(event:MouseEvent):void{
			stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSlide);
		}
		
		protected function onSlide(event:MouseEvent):void
		{
			var oldValue:Number = _value;
			if(_direction == HORIZONTAL)
			{
				var sliderX:Number = Math.max(-_handle.width/2,mouseX-_handle.width/2);
				sliderX = Math.min(width - _handle.width/2,sliderX);
				_value = (sliderX+_handle.width/2)/ width * (_max - _min) + _min;
			}
			else
			{
				var sliderY:Number = Math.max(-_handle.height/2,mouseY-_handle.height/2);
				sliderY = Math.min(height - _handle.height,sliderY);
				_value = (sliderY + _handle.height/2)/ height * (_max - _min) + _min;
			}
			if(_value != oldValue)
			{
				updateSlider();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		protected function onDrop(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSlide);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(_direction == HORIZONTAL){
				_back.width = width;
				_back.height = backSize;
				_back.y = (height - _back.height)/2;
				_handle.width = handlerSize;
				_handle.height = height;
			}else{
				_back.width = backSize;
				_back.height = height;
				_back.x = (width - _back.width)/2;
				_handle.width = width;
				_handle.height = handlerSize;	
			}
			if(_fillBar){
				_fillBar.bgSkin = _fillSkin;
				if(_direction == HORIZONTAL){
					_fillBar.width = width;
					_fillBar.height = fillSize;
					_fillBar.y = (height - fillSize)/2;
				}else{
					_fillBar.height = height;
					_fillBar.width = fillSize;
					_fillBar.x = (width - fillSize)/2;
				}
				_fillMask.x = _fillBar.x;
				_fillMask.y = _fillBar.y;
			}

		}
		
		protected function correctValue():void
		{
			if(_max > _min)
			{
				_value = Math.min(_value, _max);
				_value = Math.max(_value, _min);
			}
			else
			{
				_value = Math.max(_value, _max);
				_value = Math.min(_value, _min);
			}
		}

		protected function positionHandle():void
		{
			var range:Number;
			if(_direction == HORIZONTAL)
			{
				range = width - _handle.width;
				_handle.x = (_value - _min) / (_max - _min) * range;
			}
			else
			{
				range = height - _handle.height;
				_handle.y = (_value - _min) / (_max - _min) * range;
			}
			updateSlider();
		}
		
		public function setSliderParams(min:Number, max:Number, value:Number):void
		{
			this.minimum = min;
			this.maximum = max;
			this.value = value;
		}
		
		
		protected function onBackClick(event:MouseEvent):void
		{
			if(_direction == HORIZONTAL)
			{
				_handle.x = mouseX - _handle.width / 2;
				_handle.x = Math.max(_handle.x, -_handle.width/2);
				_handle.x = Math.min(_handle.x, width - _handle.width/2);
				_value = (_handle.x + _handle.width / 2)/ width * (_max - _min) + _min;
			}
			else
			{
				_handle.y = mouseY - _handle.height / 2;
				_handle.y = Math.max(_handle.y, -_handle.height/2);
				_handle.y = Math.min(_handle.y, height - _handle.height/2);
				_value = (_handle.y+_handle.width / 2) / height* (_max - _min) + _min;
			}
			updateSlider();
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		private function updateSlider():void{
			if(_direction == HORIZONTAL){
				_handle.x = value/(_max - _min)*width-(_handle.width >> 1);
				if(_fillMask){
					_fillMask.graphics.clear();
					_fillMask.graphics.beginFill(0,0);
					_fillMask.graphics.drawRect(0,0,_handle.x,fillSize);
					_fillMask.graphics.endFill();
				}
			}else{
				_handle.y = value/(_max - _min)*height-(_handle.height >> 1);
				if(_fillMask){
					_fillMask.graphics.clear();
					_fillMask.graphics.beginFill(0,0);
					_fillMask.graphics.drawRect(0,0,fillSize,_handle.y);
					_fillMask.graphics.endFill();
				}
			}
		}
		
		public function set value(v:Number):void
		{
			_value = v;
			correctValue();
			positionHandle();
			
		}
		public function get value():Number
		{
			return Math.round(_value / _tickInterval) * _tickInterval;
		}
		
		public function set maximum(m:Number):void
		{
			_max = m;
			correctValue();
			positionHandle();
		}
		public function get maximum():Number
		{
			return _max;
		}
		
		public function set minimum(m:Number):void
		{
			_min = m;
			correctValue();
			positionHandle();
		}
		public function get minimum():Number
		{
			return _min;
		}

		public function set tickInterval(t:Number):void
		{
			_tickInterval = t;
		}
		public function get tickInterval():Number
		{
			return _tickInterval;
		}
	}
}