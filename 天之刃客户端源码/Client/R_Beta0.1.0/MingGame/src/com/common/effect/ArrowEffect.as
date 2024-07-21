package com.common.effect
{
	import com.globals.GameConfig;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class ArrowEffect extends Sprite
	{
		public static const TOP:int = 1;
		public static const BOTTOM:int = 2;
		public static const LEFT:int = 3;
		public static const RIGHT:int = 4;
		
		private var arrow:Bitmap;
		public var speed:int = 1;
		public function ArrowEffect(source:String="jiantou", dir:int=RIGHT)
		{
			_direction = dir;
			arrow = Style.getBitmap(GameConfig.T1_VIEWUI,source);
			addChild(arrow);
		}
		
		private var _direction:int = RIGHT;
		public function set direction(value:int):void{
			this._direction = value;
			switch(_direction){
				case TOP:centerRotate(-90);break;
				case LEFT:centerRotate(180);break;
				case RIGHT:centerRotate(0);break;
				case BOTTOM:centerRotate(90);break;
			}
			//draw();
		}
		
		private function draw():void{
			with(graphics){
				clear();
				beginFill(0x0f0,1);
				drawRect(0,0,super.width,super.height);
				endFill();
			}	
		}
		
		public function centerRotate(angle:Number):void {		
			var currentRotation:Number = arrow.rotation;
			arrow.rotation = 0;
			var mcWidth:Number = arrow.width;
			var mcHeight:Number = arrow.height;
			arrow.rotation = currentRotation;
			var pointO:Point = arrow.localToGlobal(new Point(mcWidth / 2, mcHeight / 2));
			arrow.rotation = angle;
			var pointO2:Point = arrow.localToGlobal(new Point(mcWidth / 2, mcHeight / 2));
			var p3:Point = pointO.subtract(pointO2);
			var matrix:Matrix = arrow.transform.matrix;
			matrix.translate(p3.x, p3.y);
			arrow.transform.matrix = matrix;
		}
					
		
		public function get direction():int{
			return _direction;
		}
		
		public var isPlaying:Boolean;
		public function start():void{
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			isPlaying = true;
		}
		
		public function stop():void{
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			isPlaying = false;
			value = 1;
			speed = 1;
		}
		
		private var value:int = 1;
		private function onEnterFrame(event:Event):void{
			if(speed == 10){
				if(direction == TOP || direction == BOTTOM){
					y += value*10;
				}else{
					x += value*10;
				}
				value  = value > 0 ? -1 : 1;
				speed = 1;
			}
			speed++;
		}
		
		override public function get height():Number{
			if(direction == TOP || direction == BOTTOM){
				return arrow.height;
			}else{
				return arrow.width;
			}
		}
		
		override public function get width():Number{
			if(direction == TOP || direction == BOTTOM){
				return arrow.width;
			}else{
				return arrow.height;
			}
		}
	}
}