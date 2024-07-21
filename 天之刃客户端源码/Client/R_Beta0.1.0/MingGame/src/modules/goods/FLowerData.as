package modules.goods
{
	import com.common.GlobalObjectManager;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class FLowerData
	{
		public static var index:int=1000000000;
		public var rectangle:Rectangle;
		public var id:String;
		public var bitmapdata:BitmapData;
		public var bitmapdatas:Array;
		public var num:int = 0;
		public var scale:Number=1;
		public var vx:Number=0;
		public var vy:Number=0;
		public var x:Number=0;
		public var y:Number=0;
		public var dir:Number=1;
		public var a:Number=.1;
		private var mat:Matrix;
		public var isOver:Boolean=false;
		public var zoon:Boolean=false;
			
		public function FLowerData()
		{
			mat=new Matrix;
			index--;
			index==0?index=1000000000:'';
			this.id=index.toString();
			rectangle=new Rectangle(0,0,GlobalObjectManager.GAME_WIDTH, GlobalObjectManager.GAME_HEIGHT);
		}
		private var counter:int=0
		public function draw(graphics:Graphics):void
		{
		
			var _x:Number=(x+vx*dir) ;
			var _y:Number=(y);
			counter++;
			if(this.bitmapdatas.length>1&&counter%4==0){
				counter=0;
				num++;
				if(num>=this.bitmapdatas.length)
					num = 0;
			}
			this.bitmapdata=this.bitmapdatas[num%this.bitmapdatas.length];
			
			var rect:Rectangle
			if(zoon){
				var t:Number=(Math.sin(a)+1)/2+.4;
				if(t<.4)t=.4;
				if(t>.9)t=.9;
				rect=new Rectangle(_x,_y,this.bitmapdata.width*scale*t,this.bitmapdata.height*scale*t)
			}else {
				rect=new Rectangle(_x,_y,this.bitmapdata.width*scale,this.bitmapdata.height*scale)
			}
			
			if(rectangle.intersects(rect)){
				
				mat=new Matrix
				
				if(zoon){
					mat.scale(scale*t,scale*t);	
				}else {
					mat.scale(scale,scale);	
				}
				mat.tx=_x
				mat.ty=_y
				graphics.beginBitmapFill(this.bitmapdata,mat,false);
				graphics.drawRect(_x,_y,rect.width,rect.height);
				graphics.endFill();
				mat=null;
			}else {
				isOver=true
			}
			
			rect=null
		}
		
		public function unload():void
		{
			this.bitmapdata=null;
			this.mat=null;
			
		}
				
	}
}