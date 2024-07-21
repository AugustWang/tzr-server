package modules.flowers
{
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.chat.ChatType;
	import modules.goods.Flower;
	import modules.system.SystemConfig;
	
	import proto.line.p_flowers_give_broadcast_info;

	public class FlowersBroacastManager
	{
		public function FlowersBroacastManager()
		{
		}
		private static var _instance:FlowersBroacastManager;
		
		public static function getInstance():FlowersBroacastManager
		{
			if(!_instance)
			{
				_instance = new FlowersBroacastManager();
			}
			return _instance;
		}
		
		private var is_play_ing:Boolean;
		private var broadTxt:TextField;
		private var broadtext:String="";
		private var timer:Timer;
		private var flowersView:Flower;
		public function playFlowers():void
		{
			if(is_play_ing)
				return;
			var vo:p_flowers_give_broadcast_info = FlowersTypes.getFlowerBroadcast();
			
			if(vo)
			{
//				if(SystemConfig.openEffect)
				var str:String = vo.broadcasting.split("\n").join("");
				broadtext = str;//vo.broadcasting;
				play(vo.flowers_type);
				
				if(vo.receiver == GlobalObjectManager.getInstance().user.base.role_name)
				{
					FlowerModule.getInstance().openflowerRecPanel();
				}
			}
			
			// to do 
			//判断接收者是本人 出开花界面 与 收花的界面。
			
		}
		
		private function nextPlay(e:Event=null):void
		{
			if(flowersView)
			{
				flowersView.removeEventListener(Flower.PLAY_OVER_EVENT,nextPlay);
				flowersView.unload();
				if(flowersView.parent)
				{
					flowersView.parent.removeChild(flowersView);
				}
				flowersView= null;
			}
			var vo:p_flowers_give_broadcast_info = FlowersTypes.getFlowerBroadcast();
			
			if(vo)
			{
//				if(SystemConfig.openEffect)
				
				var str:String = vo.broadcasting.split("\n").join("");
				broadtext = str;//vo.broadcasting;
				play(vo.flowers_type);
				if(vo.receiver == GlobalObjectManager.getInstance().user.base.role_name)
				{
					FlowerModule.getInstance().openflowerRecPanel();
				}	
				// to do 
				//判断接收者是本人 出开花界面 与 收花的界面。
				
			}else{
				is_play_ing = false ;
				broadtext = "";
				if(broadTxt)
				{
					broadTxt.text = "";
					if(broadTxt.parent)
					{
						LayerManager.main.removeChild(broadTxt);
					}
					
					broadTxt = null;
				}
				if(timer)
				{
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER,onNextBroad);
					timer = null;
					
				}
			}
			
		}
		
		/**
		 * 播放新手任务的鲜花效果
		 */		
		public function playNewMissionFlower():void{
			playWithTimeAndSpeed(FlowersTypes.TYPE9_TIME,Flower.FAST_SPEED,2);
		}

		private function playWithTimeAndSpeed( time:int, speed:int, ttype:int ):void {
			if ( SystemConfig.openEffect ) {
				flowersView=new Flower();
				flowersView.setTimeOut( time, speed, ttype );

				LayerManager.main.addChild( flowersView );
				//			LayerManager.popUpWindow(flowersView);

				flowersView.addEventListener( Flower.PLAY_OVER_EVENT, nextPlay );
			}

			var tf:TextFormat=new TextFormat( "Tahoma", 16, 0xffff00, true );
			tf.leading=10;
			tf.align="center";

			if ( !broadTxt ) {
				broadTxt=ComponentUtil.createTextField( "", 255, 455, tf, 639, 60 );
				broadTxt.wordWrap=broadTxt.multiline=true;
				broadTxt.mouseEnabled=false;
				broadTxt.filters=[ new GlowFilter( 0x0, 1, 2, 2, 2 )];
			}
			broadTxt.text=broadtext;
			//			var msg:String="";
			//			if(broadtext!="")
			//			{
			//				msg = "<font color='#ffff00'>【系】" + broadtext +
			//					"</font>";
			//				msg = msg.split("[").join("<font color='#ffff00'>[");
			//				msg = msg.split("]").join("]</font>");
			//				ChatModel.getInstance().chat.appendMessage(msg,null);//,getChannel(ttype)
			//					
			//			}

			broadTxt.height=broadTxt.textHeight + 4;
			broadTxt.y=455 + 60 - broadTxt.height;
			//			broadTxt.width = broadTxt.textWidth
			LayerManager.main.addChild( broadTxt );
			if ( !timer ) {
				timer=new Timer( time - 3000 );
				timer.addEventListener( TimerEvent.TIMER, onNextBroad );
			}
			timer.start();
			is_play_ing=true;
		}		
		
		
		private function play(type:int):void
		{
			
			var time:int = FlowersTypes.getPlayTimeByType(type);
			var speed:int;
			var ttype:int;             //1场景只飘花瓣  ，2国家飘花瓣+红， 3世界 花瓣+红+粉
			if(time == FlowersTypes.TYPE9_TIME)
			{
				speed = Flower.FAST_SPEED;
				ttype = 1;
			}else if(time==FlowersTypes.TYPE99_TIME)
			{
				speed= Flower.NORMAL_SPEED;
				ttype = 2;
				
			}else if(time == FlowersTypes.TYPE999_TIME)
			{
				ttype = 3;
				speed= Flower.NORMAL_SPEED;
			}
			
			this.playWithTimeAndSpeed(time,speed,ttype);
			
		}
		
		private function getChannel(ii:int):String
		{
			var channel:String="";
			switch(ii)
			{
				case 1:
					channel = ChatType.COUNTRY_CHANNEL;
					break;
				case 2:
					channel = ChatType.COUNTRY_CHANNEL;
					break;
				case 3:
					channel = ChatType.WORLD_CHANNEL;
					break;
				default:break;
			}
			return channel;
		}
		
		private function onNextBroad(e:TimerEvent):void
		{
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,onNextBroad);
				timer = null;
			}
			if(!SystemConfig.openEffect)
			{
				is_play_ing = false;
				broadTxt.text = "";
				nextPlay();
			}
		}
		
		
		public function closeEffect():void
		{
			if(flowersView)
			{
				flowersView.removeEventListener(Flower.PLAY_OVER_EVENT,nextPlay);
				flowersView.unload();
				if(flowersView.parent)
				{
					flowersView.parent.removeChild(flowersView);
				}
				flowersView= null;
			}
			
//			if(recieve)
//			{
//				
//			}
			
		}
		
//		private var recieve:KuaihuaView;
//		public function showRecieve():void
//		{
//			if(SystemConfig.openEffect)
//			{
//				recieve= new KuaihuaView();
//				LayerManager.main.addChild(recieve);
//			}
//		}
//		
//		public function removeRecieve():void
//		{
//			if(recieve)
//			{
//				recieve.unload();
//				if(recieve.parent)
//				{
//					recieve.parent.removeChild(recieve);
//				}
//				flowersView= null;
//			}
//			
//		}
		
		
	}
}


