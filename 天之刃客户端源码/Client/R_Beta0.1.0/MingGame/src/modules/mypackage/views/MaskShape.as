package modules.mypackage.views
{
	import flash.display.Shape;
	
	public class MaskShape extends Shape
	{
		public static const LOCK:int = 0;
		public static const BINDABLE:int = 1;
		public static const NO_ENDURANCE:int = 2;
		public function MaskShape()
		{
		
		}
		
		private function drawRect(color:uint,alpha:Number,w:Number,h:Number):void{
			with(graphics){
				graphics.clear();
				graphics.beginFill(color,alpha);
				graphics.drawRect(0,0,w,h);
				endFill();
			}
		}
		
		public function draw(type:int,w:Number=36,h:Number=36):void{
			switch(type){
				case LOCK:drawRect(0xcccccc,0.8,w,h);break;
				case BINDABLE:drawRect(0x00ffff,0.4,w,h);break;
				case NO_ENDURANCE:drawRect(0xff0000,0.4,w,h);break;
			}
		}
		
		public function remove():void{
			if(parent){
				parent.removeChild(this);
			}
		}
		
	}
}