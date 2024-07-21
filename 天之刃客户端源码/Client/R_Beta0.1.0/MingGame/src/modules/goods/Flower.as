package modules.goods
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.loaders.ResourcePool;
	import com.loaders.queueloader.QueueEvent;
	import com.loaders.queueloader.QueueLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class Flower extends Sprite
	{
		public static const PLAY_OVER_EVENT:String = "PLAY_OVER_EVENT";
		public static const FAST_SPEED:int = 10;
		public static const NORMAL_SPEED:int = 6;//4;
		
		private var bitmapdata:BitmapData;
		private var hongHua_bitmapdata:BitmapData; // 红色的花
		private var huaBanBMD_arr:Array ;           //花瓣  6种。
		private var flower_type:int;              //1 飘花瓣， 2花瓣+红， 3花瓣+红+粉.
		private var index:int = 0;           //花瓣索引；
		private var add:int = 0;         // 上限=type  随定时器 加加， 1的时候花瓣， 2红  3 粉
		
		private var tween:Timer
		public var counter:int;
		private var speedY:int;
		private var q:QueueLoader;
		private var timer:Timer
		public var unloaded:Boolean;
		private var delateUnLoade:int;
		private var flowerDatas:Array
		
		
		public function Flower()
		{
			super();
			flowerDatas=[]
			this.mouseChildren = this.mouseEnabled = false;
			this.tabChildren=this.tabEnabled=false;
			
			q = new QueueLoader;
			q.add(GameConfig.ROOT_URL+'com/assets/flower.png');
			q.add(GameConfig.ROOT_URL+'com/assets/hua.png');
			for(var i:int=0;i<5;i++)
			{
				q.add(GameConfig.ROOT_URL+'com/assets/huaban/'+ String(i+1)+'.png');
				
			}
			q.addEventListener(QueueEvent.ITEM_COMPLETE, itemLoadedFunc);
			q.addEventListener(QueueEvent.QUEUE_COMPLETE,loadedFunc)
			q.load();
		}
		
		private function itemLoadedFunc(e:QueueEvent):void
		{
			ResourcePool.add(e.loadItem.url, Bitmap(e.data.content).bitmapData.clone());
		}
		
		private function loadedFunc(event:QueueEvent):void
		{
			bitmapdata = (ResourcePool.get(GameConfig.ROOT_URL+'com/assets/flower.png') as BitmapData).clone();
			hongHua_bitmapdata=(ResourcePool.get(GameConfig.ROOT_URL+'com/assets/hua.png') as BitmapData).clone();
			if(!huaBanBMD_arr) {
				huaBanBMD_arr = new Array();
			}
			
			for(var i:int=0;i<5;i++)
			{
				var bimpdata:BitmapData = (ResourcePool.get(GameConfig.ROOT_URL+'com/assets/huaban/'+String(i+1) +'.png') as BitmapData).clone();
				huaBanBMD_arr.push(bimpdata);
			}
			timer=new Timer(80);
			timer.addEventListener(TimerEvent.TIMER,timerFunc);
			
			tween=new Timer(80)
			tween.addEventListener(TimerEvent.TIMER,moveFunc)
			timer.start();
			tween.start()
		}
		private function moveFunc(event:TimerEvent):void
		{
			if(this.stage==null)return;
			
			if(delateUnLoade)
			{
				this.dispatchEvent(new Event(PLAY_OVER_EVENT));
				this.unload();
				return;
			}
			if(timer)
			{
				if(counter<getTimer()){
					stopTimer();
				}
			}
			
			this.graphics.clear();
			var bool:Boolean=true
			for each(var n:FLowerData in flowerDatas)
			{
				var data:FLowerData=n;
				if(data){
					bool=false;
					data.y+=speedY+data.vy;
					data.a+=.1;
					data.dir=Math.sin(data.a)
					
					data.draw(this.graphics)
					if(data.isOver)
					{
						data.unload();
						delete flowerDatas[data.id];
					}
				}
			}
			
			if(bool){
				delateUnLoade=1;
			}
		}
		
		private function stopTimer():void
		{
			if(timer)
			{		
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,timerFunc);
				timer=null;
			}
		}
		
		public function unload():void
		{
			if(unloaded==true)
				return;
			if(timer)
			{		
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,timerFunc);
				timer=null
			}
			if(timer)
			{	
				this.tween.stop();
				tween.removeEventListener(TimerEvent.TIMER,moveFunc);
				tween=null;
			}
			q.clear();
			if(bitmapdata) {
				this.bitmapdata.dispose();
			}
			if(hongHua_bitmapdata) {
				hongHua_bitmapdata.dispose();
			}
			while(huaBanBMD_arr.length>0)
			{
				var bmpD:BitmapData = huaBanBMD_arr.shift() as BitmapData;
				if(bmpD)
				{
					bmpD.dispose();
					bmpD =  null;
				}
			}
			
			this.flowerDatas=null;
			bitmapdata=null;
			hongHua_bitmapdata = null;
			unloaded=true;
		}
		
		private function timerFunc(event:TimerEvent):void
		{	
			var bmpData:BitmapData;
			var data:FLowerData=new FLowerData;
			add++;               
			if(add ==flower_type)
			{
				add = 0;
				bmpData = huaBanBMD_arr[index] as BitmapData;
				data.bitmapdatas=huaBanBMD_arr;
				data.num=(Math.random()* huaBanBMD_arr.length)>>0;
				index++;
				if(index>=6)index = 0;
				
			}else if(add == flower_type-1)
			{
				bmpData = hongHua_bitmapdata;
				data.bitmapdatas=[bmpData];
				data.num=0
			}else if(add == flower_type - 2)
			{
				bmpData = bitmapdata;
				data.bitmapdatas=[bmpData];
				data.num=0;
			}
			
			var scale:Number=1;
			if(add != 0)
			{
				if(FLowerData.index%2==0){
					data.zoon=true;
				}
				if(scale < 0.4)scale = 0.4;
				data.vy=(1-scale)*2;
			}else {
				data.vy=Math.random()*10>>0
			}
			var X_delta:int = int(Math.random()*10>>0)*10; 
			
			data.bitmapdata=bmpData;
			data.scale=scale;
			data.vx=X_delta;
			
			data.dir=1
			data.x=Math.random()*(GlobalObjectManager.GAME_WIDTH - 2);
			trace(GlobalObjectManager.GAME_WIDTH);
			this.flowerDatas[data.id]==null?this.flowerDatas[data.id]=data:'';
		}
		public function setTimeOut(value:int=1000,Yspeed:int=4,type:int= 3):void
		{
			flower_type = type;
			
			if(type ==1)
			{
				this.counter=value + getTimer()-3000 ;
			}else if(type ==2)
			{
				this.counter=value + getTimer()-6000;
			}else if(type ==3)
			{
				this.counter=value + getTimer()-8000;
			}
			this.speedY = Yspeed;
		}
	}
}