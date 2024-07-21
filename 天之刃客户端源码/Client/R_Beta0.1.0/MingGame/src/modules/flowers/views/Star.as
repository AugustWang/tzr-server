package modules.flowers.views
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class Star
	{
		public static var index:int=1000000000
		public static var rectangle:Rectangle=new Rectangle(0,0,1002,500)
		public var id:String
		public var scale:Number=1;
		public var vx:Number=0;
		public var vy:Number=0;
		public var x:Number=0
		public var y:Number=0;
		public var dir:Number=1;
		public var a:Number=.1;
		private var mat:Matrix;
		public var isOver:Boolean=false
		public var zoon:Boolean=false
			
		private var bmpDataArr:Array=[];
		public var beginIndex:int=0;
		public function Star()
		{
			mat=new Matrix();
			index--
				index==0?index=1000000000:''
			this.id=index.toString()
		}
		public function setbitmapData(arr:Array):void
		{
			bmpDataArr = arr;
			if(!arr)
				return;
			for(var i:int=0;i<bmpDataArr.length;i++)
			{
				var btmpData:BitmapData = bmpDataArr[i] as BitmapData;
				
			}
		}
		
		public function draw(graphics:Graphics):void
		{
			if(!bmpDataArr||bmpDataArr.length==0)
				return;
			if(beginIndex<0)
			{
				beginIndex++
				return;
			}
//			graphics.clear();
			var _x:Number=(x) ;
			var _y:Number=(y);
			
			
			var rect:Rectangle;
			
			rect=new Rectangle(_x,_y,(bmpDataArr[beginIndex] as BitmapData).width,(bmpDataArr[beginIndex] as BitmapData).height);
			
//			mat = new Matrix();
			mat.scale(1,1);
			mat.tx=_x;
			mat.ty=_y;
			
			graphics.beginBitmapFill((bmpDataArr[beginIndex] as BitmapData),mat,false);
			graphics.drawRect(_x,_y,rect.width,rect.height);
			graphics.endFill();
			
			
			rect=null;
			beginIndex++;
			if(beginIndex==bmpDataArr.length)
			{
				beginIndex=-3;
			}
		}
		
		public function unload():void
		{
			for(var j:int=0;j<bmpDataArr.length;j++)
			{
				var bitmapdata:BitmapData = bmpDataArr[j] as BitmapData;
				bitmapdata=null;
				bmpDataArr = null;
			}
			
		}
	}
}

