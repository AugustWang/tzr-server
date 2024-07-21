package modules.broadcast.views
{
	import com.common.GlobalObjectManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	
	public class Tips extends Sprite
	{
		private static var instance:Tips;
		private var source:Array
		private var showArray:Array
		private var showNum:int=3
		private var moveBool:Boolean=false
		public function Tips()
		{
			super();
			this.y=GlobalObjectManager.GAME_HEIGHT*0.5 + 25;
			this.mouseChildren=this.mouseEnabled=false;
			source=[];
			showArray=[];
		}
		public static function getInstance():Tips
		{
			if(!instance)instance = new Tips();
			return instance;
		}
		public function addTipsMsg(str:String):void
		{
			if(str!=''&&str==null)return;
			var array:Array=str.split('\n')
			for(var i:int=0;i<array.length;i++)
			{
				if(array[i]!=null&&array[i]!=''){
				this.source.push(array[i]);
				push(array[i])
				}
			}
		}
		public function sceneChangeGoOn():void
		{
			
		}
		private function push(value:String):void
		{
			if(this.hasEventListener(Event.ENTER_FRAME)==false){
				this.addEventListener(Event.ENTER_FRAME,this.enterFrameFunc)
			}
			if(this.showArray.length<showNum){
				if(this.source.length>0)
				{
					var item:TipsItem=new TipsItem();
					item.setup(this.source.shift(),this.showArray.length);
					item.startTime=getTimer();
					this.addChild(item);
					this.showArray.push(item);
				}
			}else {
				var broadItem:TipsItem= this.showArray[0];
				broadItem.startTime=getTimer()-8000;
			}		
		}
		private function show():void
		{
			if(this.source.length>0)
			{
				if(this.showArray.length<showNum)
				{
					var item:TipsItem=new TipsItem();
					item.setup(this.source.shift(),this.showArray.length);
					item.startTime = getTimer();
					this.addChild(item);
					this.showArray.push(item);
				}
			}
		}
		
		
		private function move():void
		{
			if(this.moveBool==true)
				var num:int=0;
			for(var i:int=0;i<this.showArray.length;i++)
			{
				var item:TipsItem=this.showArray[i];
				if(this.moveBool==false)
				{
					
					if(i==0)
					{
						item.updata();
						if(item.y<=-30)
						{
							if(item.parent)item.parent.removeChild(item);
							this.showArray.shift();
							if(this.showArray.length==0&&this.source.length==0)
							{
								this.removeEventListener(Event.ENTER_FRAME,enterFrameFunc)
								this.moveBool=false;
								return;
							}
							
							for(var j:int=0;j<this.showArray.length;j++)
							{
								var itemj:TipsItem=this.showArray[j];
								itemj.index--;
								itemj.y=itemj.index*TipsItem.sizeH;
								
							}
							//broadItem.startTime=getTimer()-1000;
							if(showArray.length>0){
								var broadItem:TipsItem= this.showArray[0];
								if(source.length>4)
								{
									broadItem.startTime-=500;
								}else{
//									broadItem.startTime-=100;
								}
							}
							moveBool=true;
						}
					}else {
						item.move();
					}
				}else {
					item.reset();
					if(item.y<=item.index*TipsItem.sizeH){
						num++;
					}
					if(num>=this.showArray.length-1)
					{
						
						this.show();
						this.moveBool=false;
						
					}
				}
				
				
			}
		}
		private function enterFrameFunc(e:Event):void
		{
			move();
			
		}
		
		
	}
}