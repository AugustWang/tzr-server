package modules.broadcast.views
{
	import com.common.GlobalObjectManager;
	
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterType;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class BroadItem extends TextField
	{
		
		public var index:int
		public var startTime:Number;
		public static var sizeH:int=26
		
		public function BroadItem()
		{
			super();
			this.selectable=false;
			this.mouseEnabled=false;
		}
		
		public function setup(str:String,index:Number):void
		{
			htmlText=str
			this.index=index
			this.y=sizeH*index
//			this.filters=[new GlowFilter(0x0,1,2,2,20)]//修改描边
			this.filters = [new GlowFilter(0x000000, 1, 2, 2, 5)];
			this.alpha=0
			this.startTime=getTimer();

		}
		
		override public function set htmlText(value:String):void
		{
			super.htmlText='<FONT color="#ffff00" size="14" ><b>'+value+'</b></FONT>';//size=16
			this.width=this.textWidth+10;
			this.height=this.textHeight+10
			this.x=(GlobalObjectManager.GAME_WIDTH-this.textWidth)*0.5;
		}
		
		public function move():void
		{
			if(this.y>this.index*sizeH){
				this.y-=4
			}
			if(this.alpha<1)this.alpha+=.2
		}
		
		public function reset():void
		{
			if(this.y>this.index*sizeH){
				this.y-=4
				
			}
		}
		public function remove():void
		{
			var time:Number=getTimer()-this.startTime;
			this.alpha-=.2
			if(this.alpha<=0)
			{
				this.y-=4
				
			}
			if(time>100){
				this.alpha=0
				this.y=-30
			}
		}
		public function updata():void	
		{
			var time:Number=getTimer()-this.startTime;
			if(time>1000)
			{
				if(time>5000){
					this.alpha-=.2
					if(this.alpha<=0)
					{
						this.y-=4
						
					}
					if(time>7000){
						this.alpha=0				
						this.y=-30
					}
				}
					
			}else {
				if(this.y>this.index*sizeH){
					this.y-=4
					
				}
				if(this.alpha<1)this.alpha+=.1
			}
		}
		
	}
}