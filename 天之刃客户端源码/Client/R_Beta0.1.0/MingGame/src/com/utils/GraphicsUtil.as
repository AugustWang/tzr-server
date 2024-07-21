package com.utils
{
	import flash.display.Graphics;

	public class GraphicsUtil
	{
		public static function drawRect(g:Graphics,x:int,y:int,w:Number,h:Number,alpha:Number=1,color:uint=0x000000):void{
			g.beginFill(color,alpha);
			g.drawRect(x,y,w,h);
			g.endFill();
		}
		
		public static function drawRoundRect(g:Graphics,x:int,y:int,w:Number,h:Number,alpha:Number=1,color:uint=0x000000,ellipseWidth:Number=0, ellipseHeight:Number=0):void{
			g.beginFill(color, alpha);
			g.drawRoundRect(x, y, w, h, ellipseWidth, ellipseHeight);
			g.endFill();
		}
	}
}