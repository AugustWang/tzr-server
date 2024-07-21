package modules.broadcast.views
{
	import com.common.GlobalObjectManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class BroadcastView extends Sprite
	{
		private static var instance:BroadcastView;
		private var source:Array;
		private var showArray:Array;
		private var showNum:int=3;
		private var moveBool:Boolean=false;
		public function BroadcastView()
		{
			super();
			this.y=70;//*******************************80;
			this.mouseChildren=this.mouseEnabled=false;
			source=[];
			showArray=[];
		}
		public static function getInstance():BroadcastView
		{
			if(!instance)instance = new BroadcastView();
			return instance;
		}
		public function addBroadcastMsg(str:String):void
		{
			if(str!=''&&str==null)return;
				
			var array:Array=str.split('\n')
			for(var i:int=0;i<array.length;i++)
			{
				if(array[i]!=''&&array[i]!=null){
				this.source.push(array[i]);
				push(array[i])
				}
			}
		}
		
		private function push(value:String):void
		{
			if(this.hasEventListener(Event.ENTER_FRAME)==false){
				this.addEventListener(Event.ENTER_FRAME,this.enterFrameFunc)
			}
			if(this.showArray.length<showNum){
				if(this.source.length>0)
				{
					var item:BroadItem=new BroadItem()
					item.setup(this.source.shift(),this.showArray.length);
					this.addChild(item);
					this.showArray.push(item);
				}
			}else {
				var broadItem:BroadItem= this.showArray[0];
				broadItem.startTime=getTimer()-8000;
			}		
		}
		private function show():void
		{
			if(this.source.length>0)
			{
				if(this.showArray.length<showNum)
				{
					var item:BroadItem=new BroadItem()
					item.setup(this.source.shift(),this.showArray.length)
					this.addChild(item);
					this.showArray.push(item)
				}
			}
		}
		
		
			
			
		private function move():void
		{
			if(this.moveBool==true) var num:int=0;
			for(var i:int=0;i<this.showArray.length;i++)
			{
				var item:BroadItem=this.showArray[i];
				if(this.moveBool==false)
				{
					
					if(i==0)
					{
					
							item.updata()
					
						
						if(item.y<=-30)
						{
							if(item.parent)item.parent.removeChild(item);
							this.showArray.shift()
							if(this.showArray.length==0&&this.source.length==0)
							{
								this.removeEventListener(Event.ENTER_FRAME,enterFrameFunc)
								this.moveBool=false;
								return;
							}
							
							for(var j:int=0;j<this.showArray.length;j++)
							{
								var itemj:BroadItem=this.showArray[j];
								itemj.index--
								itemj.y=itemj.index*BroadItem.sizeH
								
							}
							
							if(showArray.length>0){
								var broadItem:BroadItem= this.showArray[0];
								broadItem.startTime=getTimer()-1000
							}
								moveBool=true
						}
					}else {
						item.move()
					}
				}else {
						item.reset();
						if(item.y<=item.index*BroadItem.sizeH){
							num++
						}
						if(num>=this.showArray.length-1)
						{
							
							this.show()
							this.moveBool=false;
						}
				}
				
				
			}
		}
		private function enterFrameFunc(e:Event):void
		{
			move()
			
		}
		
		
	}
}