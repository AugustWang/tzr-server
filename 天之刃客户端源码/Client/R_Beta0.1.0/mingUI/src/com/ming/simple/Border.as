package com.ming.simple {
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;

	public class Border extends Shape {
		public static const DIR_HOR:int=0;
		public static const DIR_VER_LEFT:int=1;
		public static const DIR_VER_RIGHT:int=2;

		public function Border() {
			super();
			this.cacheAsBitmap=true;
		}

		public function setUp(x:Number, y:Number, width:Number, height:Number, parent:DisplayObjectContainer, dir:int=0, alpha:Number=0.15):void {
			switch (dir) {
				case 0:
					this.graphics.lineStyle(0, 0x0, alpha);
					this.graphics.moveTo(0, 0);
					this.graphics.lineTo(width, 0);
					this.graphics.lineStyle(0, 0xffffff, alpha);
					this.graphics.moveTo(0, 1);
					this.graphics.lineTo(width, 1);
					break;
				case 1:
					this.graphics.lineStyle(0, 0x0, 0.1);
					this.graphics.moveTo(0, 0);
					this.graphics.lineTo(0, height);
					this.graphics.lineStyle(0, 0xffffff, alpha);
					this.graphics.moveTo(1, 0);
					this.graphics.lineTo(1, height);
					break;
				case 2:
					this.graphics.lineStyle(0, 0xffffff, alpha);
					this.graphics.moveTo(0, 0);
					this.graphics.lineTo(0, height);
					this.graphics.lineStyle(0, 0x0, alpha);
					this.graphics.moveTo(1, 0);
					this.graphics.lineTo(1, height);
					break;
				default:
					break;
			}
			this.x=x;
			this.y=y;
			parent.addChild(this);
		}
	}
}