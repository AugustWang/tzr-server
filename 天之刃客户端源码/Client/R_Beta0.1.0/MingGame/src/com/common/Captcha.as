package com.common
{
	import com.scene.tile.Pt;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Captcha extends Sprite
	{
		private var _length:uint;
		private var _noiseFlag:Boolean;
		private var _size:uint;
		private var _randCode:String = "";
			
		private var _sp_cont:Sprite = new Sprite();
		private var _sp_noise:Sprite = new Sprite();
		private var _tft:TextFormat = new TextFormat();
			
		public function Captcha(length:uint=5, noiseFlag:Boolean=true, size:uint=18)
		{			
			_length = length;
			_noiseFlag = noiseFlag;
			_size = size;
				
			_tft.font = "Arial";
			_tft.bold = true;
			_tft.size = size;
				
			addChild(_sp_cont);
				
			reRandCaptcha(null);
			addEventListener(MouseEvent.MOUSE_DOWN, reRandCaptcha);
		}
			
		private function reRandCaptcha(e:MouseEvent):void
		{
			removeAllChild(_sp_cont);
			randCaptcha();
			drawNoise();
			drawBorder();
		}
			
		private function randCaptcha():void
		{
			_randCode = "";
			for (var i:uint=0; i < _length; i ++) {
				var tf:TextField = new TextField();
				tf.text = String(randInt(0, 9));
				_randCode += tf.text;
				tf.selectable = false;
				tf.x = int(_tft.size) * i;
				tf.textColor = randInt(0, 0x888888);
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.setTextFormat(_tft);
				_sp_cont.addChild(tf);
			}
		}
			
		private function drawNoise():void
		{
			if(_noiseFlag){
				_sp_noise.graphics.clear();
				
				for(var i:int=0; i < 25; i ++){
					var ptx:int = randInt(1, width);
					var pty:int = randInt(1, height);
					var ex:int = ptx + randInt(-width, width);
					var ey:int = pty + randInt(-height, height);
					ex = (ex<=1) ? 1 : ((ex>=(width)) ? (width) : ex);
					ey = (ey<=1)? 1 : ((ey>=height-1) ? (height-1) : ey);
					_sp_noise.graphics.lineStyle(1, randInt(0,0xFFFFFF), 0.25);
					_sp_noise.graphics.moveTo(ptx, pty);
					_sp_noise.graphics.lineTo(ex, ey);
				}

				_sp_noise.width = _sp_cont.width;
				_sp_noise.height = _sp_cont.height;
				addChild(_sp_noise);
			}
			return;
		}
		
		private function drawBorder():void
		{
			graphics.clear();
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 0, _sp_cont.width, height);
			graphics.endFill();
		}
			
		private function removeAllChild(container:DisplayObjectContainer):void
		{
			while(container.numChildren > 0){
				container.removeChildAt(0);
			}
		}
			
		private function randInt(min:int, max:int):int 
		{
			return Math.random() * (max - min) + min;
		}
			
		public function get captcha():String
		{
			return _randCode;
		}
	}
}