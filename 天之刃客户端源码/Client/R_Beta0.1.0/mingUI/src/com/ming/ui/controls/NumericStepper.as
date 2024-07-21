package com.ming.ui.controls
{
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.NumericStepperSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class NumericStepper extends UIComponent
	{
		public static const INT:String = "int";
		public static const NUMBER:String = "Number";
		
		private var textInput:TextInput;
		private var up:UIComponent;
		private var down:UIComponent;
		public var stepSize:Number = 1;
		public function NumericStepper()
		{
			super();
			init();
		}
		
		private function init():void{
			width = 67;
			height = 22;
			textInput = new TextInput();
			textInput.addEventListener(Event.CHANGE,onTextChange);
			textInput.bgSkin = null;
			type = INT;
			up = new UIComponent;
			up.addEventListener(MouseEvent.MOUSE_DOWN,upHandler);
			down = new UIComponent();
			down.addEventListener(MouseEvent.MOUSE_DOWN,downHandler);
			addChild(textInput);
			addChild(up);
			addChild(down);
			var numericStepperSkin:NumericStepperSkin = StyleManager.numericStepperSkin;
			if(numericStepperSkin){
				if(numericStepperSkin.bgSkin){
					bgSkin = numericStepperSkin.bgSkin;
				}
				if(numericStepperSkin.upSkin){
					setUpSkin(numericStepperSkin.upSkin);
				}
				if(numericStepperSkin.downSkin){
					setDownSkin(numericStepperSkin.downSkin);
				}
			}
		}
		
		private function onTextChange(event:Event):void{
			if(textInput.text != ""){
				value = parseInt(textInput.text);
				if(isNaN(value)){
					value = minnum;
				}
			}else{
				_value = 0;
			}
		}
		
		private var startTime:int = 0;
		private var step:int = 1;
		private function upHandler(event:MouseEvent):void{
			value += stepSize;
			step = 1;
			startStep();
		}
		private function downHandler(event:MouseEvent):void{
			value -= stepSize;
			step = -1;
			startStep();
		}
		
		private function startStep():void{
			addEventListener(Event.ENTER_FRAME,onAddStep);
			stage.addEventListener(MouseEvent.MOUSE_UP,onStopHandler);
		}
		
		private function onStopHandler(event:MouseEvent):void{
			startTime = 0;
			removeEventListener(Event.ENTER_FRAME,onAddStep);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onStopHandler);
		}
		
		private function onAddStep(event:Event):void{
			if(startTime > 10){
				value += step*stepSize;
			}else{
				startTime++;	
			}
		}
		
		private var _minnum:Number = 0;
		public function set minnum(v:Number):void{
			if(_minnum != v){
				this._minnum = v;
				if(v < _minnum)
					value = _minnum;
			}
		}
		public function get minnum():Number{
			return this._minnum;
		}
		
		private var _maxnum:Number = Number.MAX_VALUE;
		public function set maxnum(v:Number):void{
			if(_maxnum != v){
				this._maxnum = v;
				_maxnum = Math.max(_maxnum,_minnum);
				if(v > _maxnum)
					value = _maxnum;
				textInput.maxChars = _maxnum.toString().length;
			}
		}
		public function get maxnum():Number{
			return this._maxnum;
		}
		private var _value:Number = 0;
		public function set value(v:Number):void{
			if(_value != v){
				v = Math.max(v,minnum);
				v = Math.min(v,maxnum);
				this._value = v;
				textInput.text = _value.toString();
				textInput.validateNow();
				dispatchEvent(new Event(Event.CHANGE));
			}else{
				textInput.text = v.toString();
				textInput.validateNow();
			}
		}
		public function get value():Number{
			return this._value;
		}
		
		private var _type:String = INT;
		public function set type(value:String):void{
			_type = value;
			if(_type == NUMBER){
				textInput.restrict = "[0-9.]";
			}else{
				textInput.restrict = "[0-9]";
			}
		}
		
		public function get type():String{
			return _type;
		}
		
		public function get textFiled():TextInput{
			return textInput;
		}
		private var _buttonWidth:Number = 16;
		public function set buttonWidth(v:Number):void{
			if(_buttonWidth != v){
				this._buttonWidth = v;
				invalidateDisplayList();
			}
		}
		public function get buttonWidth():Number{
			return this._buttonWidth;
		}
		
		public function setUpSkin(skin:Skin):void{
			if(skin){
				skin.enableMouse = enable;
				up.bgSkin = skin;
			}
		}
		
		public function setDownSkin(skin:Skin):void{
			if(skin){
				skin.enableMouse = enable;
				down.bgSkin = skin;
			}
		}
		
		override public function dispose():void{
			super.dispose();
			textInput.dispose();
			up.dispose();
			down.dispose();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			up.width = down.width = _buttonWidth;
			up.height = down.height = 10;
			
			textInput.height = height;
			textInput.width = width - buttonWidth;
			
			up.x = down.x = textInput.width-2;
			up.y = (h - 21) >> 1;
			down.y = up.height+up.y+1;
			
		}
		
		private var _enable:Boolean = true;
		public function set enable(value:Boolean) : void{
			_enable = value;
			if(up.bgSkin){
				up.bgSkin.enableMouse = value;
			}
			if(down.bgSkin){
				down.bgSkin.enableMouse = value;
			}
			if(bgSkin){
				bgSkin.enableMouse = value;
			}
			mouseEnabled = mouseChildren = _enable;
		}
		
		public function get enable() : Boolean{
			return _enable;
		}
	}
}