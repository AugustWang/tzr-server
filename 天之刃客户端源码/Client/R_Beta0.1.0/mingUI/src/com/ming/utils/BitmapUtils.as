package  com.ming.utils
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class BitmapUtils
	{
		public static const AAA:int = 1;
		public function BitmapUtils() 
		{
			
		}
		
		public static function drawUV(g:Graphics,bmd:BitmapData,x:int,y:int,width:int,height:int,u1:Number=0,v1:Number=0,u2:Number=1,v2:Number=1):void {
			var matr:Matrix = new Matrix();
			var u12:Number = Math.round((u2 - u1)*10000) == 1 ? 0 : (u2 - u1);
			var v12:Number = Math.round((v2 - v1)*10000) == 1 ? 0 : (v2 - v1);
			var sx:Number = width / bmd.width / u12;
			var sy:Number = height / bmd.height / v12;
			matr.scale(sx, sy);
			matr.translate(x-bmd.width*u1*sx, y-bmd.height*v1*sy);
			g.beginBitmapFill(bmd, matr);
			g.drawRect(x, y, width, height);
			g.endFill();
		}		
		
		/** 
		 * 
		 * @param	g			graphics
		 * @param	bmd			将要执行bitmapFill的bitmapdata
		 * @param	s9Top		顶部距离
		 * @param	s9Right		右部距离
		 * @param	s9Left		左部距离
		 * @param	s9Bottom	底部距离
		 * @param	x			执行bitmapFill的x
		 * @param	y			执行bitmapFill的y
		 * @param	width		执行bitmapFill的width
		 * @param	height		执行bitmapFill的height
		 */
		public static function scale9Draw(g:Graphics,bmd:BitmapData,s9Top:int,s9Right:int,s9Left:int,s9Bottom:int,x:int,y:int,width:int,height:int,u1:Number=0,v1:Number=0,u2:Number=1,v2:Number=1):void {
			var u3:Number = u1 + s9Left / bmd.width;
			var u4:Number = u2 - s9Right / bmd.width
			var v3:Number = v1 + s9Top / bmd.height;
			var v4:Number = v2 - s9Bottom / bmd.height;
			//topLeft
			drawUV(g, bmd, x, y, s9Left, s9Top, u1, v1, u3 , v3);
			//topRight
			drawUV(g, bmd, x + width - s9Right, y, s9Right, s9Top, u4, v1, u2, v3);
			//bottomRight
			drawUV(g, bmd, x + width - s9Right, y+height-s9Bottom, s9Right, s9Bottom, u4, v4, u2, v2);
			//bottomleft
			drawUV(g, bmd, x, y + height - s9Bottom, s9Left, s9Bottom, u1, v4, u3, v2);
			//cenleft
			drawUV(g, bmd, x, y+s9Top, s9Left, height - s9Top - s9Bottom, u1, v3, u3 , v4);
			//cenright
			drawUV(g, bmd, x+width-s9Right, y+s9Top, s9Right, height-s9Top-s9Bottom, u4, v3, u2 , v4);
			//centop
			drawUV(g, bmd, x+s9Left, y, width-s9Left-s9Right, s9Top, u3, v1, u4 , v3);
			//cenbottom
			drawUV(g, bmd, x + s9Left, y + height - s9Bottom, width - s9Left - s9Right, s9Bottom, u3, v4, u4 , v2);
			//cen
			drawUV(g, bmd, x + s9Left, y + s9Top, width - s9Left - s9Right, height-s9Top-s9Bottom, u3, v3, u4 , v4);
		}
		
		/**
		 * 填充位位图数据 
		 * @param g
		 * @param bmd
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param sx
		 * @param sy
		 * @param tx
		 * @param ty
		 * 
		 */		
		public static function fillBitmapData(g:Graphics,bmd:BitmapData,x:int,y:int,width:int,height:int,sx:Number=1,sy:Number=1,tx:Number=0,ty:Number=0):void {
			var matr:Matrix = new Matrix();
			matr.scale(sx, sy);
			matr.translate(tx,ty);
			g.beginBitmapFill(bmd, matr,false);
			g.drawRect(x, y, width, height);
			g.endFill();
		}
		/**
		 * 比scaleBitmap算法性能更高的算法，并且解决scale9Draw方法经常出现错误拼接和拉伸的问题。
		 * @param g
		 * @param bmd
		 * @param s9Top
		 * @param s9Right
		 * @param s9Left
		 * @param s9Bottom
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * 
		 */		
		public static function scale9Fill(g:Graphics,bmd:BitmapData,s9Top:int,s9Right:int,s9Left:int,s9Bottom:int,x:int,y:int,width:int,height:int):void{
			var grid9:Rectangle = new Rectangle(s9Left,s9Top,s9Right - s9Left,s9Bottom - s9Top);
			
			var right:Number = bmd.width - grid9.right;
			var bottom:Number = bmd.height - grid9.bottom;
			
			var rows : Array = [0, s9Top, s9Bottom, bmd.height];
			var cols : Array = [0, s9Left, s9Right, bmd.width];
			
			var rectx:Number,recty:Number,w:Number,h:Number,drawW:Number,drawH:Number;
			var sx:Number=1,sy:Number=1,startx:Number=0,starty:Number=0;
			for (var cx : int = 0;cx < 3; cx++) {
				for (var cy : int = 0 ;cy < 3; cy++) {
					rectx = cols[cx];
					recty = rows[cy];
					w = cols[cx + 1] - cols[cx];
					h = rows[cy + 1] - rows[cy];
					if((cx == 1 && cy == 0) || (cx == 1 && cy == 2)){
						drawW = (width - (right + s9Left));
						drawH = h;
						sx = drawW/w;
						sy = 1;
					}else if((cx == 0 && cy == 1) || (cx == 2 && cy == 1)){
						drawW = w;
						drawH = (height - (bottom + s9Top));
						sx = 1;
						sy = drawH/h;
					}else if(cx == 1 && cy == 1){
						drawW = (width - (right + s9Left));
						drawH = (height - (bottom + s9Top));
						sx = drawW/w;
						sy = drawH/h;
					}else{
						drawW = w;
						drawH = h;
						sx = sy = 1;
					}
					fillBitmapData(g,bmd,startx,starty,drawW,drawH,sx,sy,startx-rectx*sx,starty-recty*sy);
					starty += drawH;
				}
				startx += drawW;
				starty = 0;
			}
		}
		
		
	}

}