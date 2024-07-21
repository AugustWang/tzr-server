package modules.broadcast.views
{
	
	import com.common.GlobalObjectManager;
	import com.components.chat.TextImageItem;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.VScrollCanvas;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.effect.LabaEffect;
	import modules.chat.ChatModule;
	import modules.system.Anti_addiction;
	import modules.system.SystemModule;
	
	import proto.common.p_chat_role;
	import proto.line.m_system_fcm_toc;
	
	public class SpeakerView extends Sprite
	{
		private static var instance:SpeakerView;
//		private var _waitList:Array;
		private var vstext:VScrollText;
		private var vsCanvas:VScrollCanvas;
		private var hideShow_btn:UIComponent;
		private var item:TextImageItem;
		
		private var _effect:LabaEffect;
		
		private var items:Array = [];
		private var waitArr:Array= [];
		private var time6:Timer;
		private var time30:Timer;
		private var timer:Timer;
		private static const defSecond:int=120; //60; pt
		
		public function SpeakerView()
		{
			super();
			this.mouseEnabled=false;
			y=GlobalObjectManager.GAME_HEIGHT - 310;
			setupUI()
		}
		
		public static function getInstance():SpeakerView
		{
			if(!instance)
			{
				instance = new SpeakerView();
			}
			return instance;
		}
		public function set visibled(v:Boolean):void
		{
			vsCanvas.visible = v;
		}
		
		private var text:TextField
		private function setupUI():void
		{
			this.mouseEnabled = false ;
			
			vsCanvas = new VScrollCanvas();
			vsCanvas.width = 270;//280;
			vsCanvas.height = 50;//36;
			vsCanvas.direction = ScrollDirection.LEFT;
			vsCanvas.verticalScrollPolicy = ScrollPolicy.OFF;
			vsCanvas.bgAlpha = 0.4;
			vsCanvas.bgColor = 0x000000;
			vsCanvas.mouseEnabled=false
			addChild(vsCanvas);
			
			hideShow_btn = new UIComponent();
			hideShow_btn.buttonMode=true
			hideShow_btn.setToolTip('喇叭记录');//小喇叭
			Style.setLoudSpeakBtnStyle(hideShow_btn);
			hideShow_btn.width = 18;
			hideShow_btn.height = 15;
			hideShow_btn.x = 0;
			hideShow_btn.y = 33;//3;//
			addChild(hideShow_btn);
			
			hideShow_btn.addEventListener(MouseEvent.CLICK,onHideShow);
		}
		
		private function onHideShow(e:MouseEvent):void
		{
//			if(vstext.visible)
//			{
//				vstext.visible = false;
//				
//			}else{
//				vstext.visible = true;
//				
//			}
			
			BroadcastModule.getInstance().popupLabaRecord();
		}
		
		private function getTextFormat():TextFormat
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = "0xFF0099";
			textFormat.size = 14;
			return textFormat;
		}
		
		public var roleData:Array=[]
		public function appMsgRole(role:p_chat_role):void
		{
			roleData.push(role)
		}
		public function appendMsg(str:String):void
		{
			var msg:String = "<p><font size = '12' color = '#ff4800'>"+str +"</font></p>";
			
			if(vsCanvas.visible == false)
			{
				vsCanvas.visible = true;
			}
			waitArr.push(msg); 
			changeTimer();
		}
		
		public function appendSysMsg(str:String):void
		{
			if(str=="")
				return;
			waitArr.push(str); 
			
			changeTimer();
		}
		
		public function showLaba(str:String,role:Object):void
		{
			if(!item)
			{
				item = new TextImageItem();
				item.x = 13;
				item.width = 260;
				item.handler=itemClickHandler
//				this.mouseEnabled = true ;
//				vsCanvas.mouseEnabled = true;
				vsCanvas.addChild(item);
			}
			item.data=role;
			item.setHtmlText(str);
			if(str)
				BroadcastModule.getInstance().recordLabaMsg(str,role);
			
			if(!_effect)
			{
				_effect = new LabaEffect();
				addChild(_effect);
			}else
			{
				_effect.playSwf(2);
			}
			
			
		}
		
		private function itemClickHandler(evt:TextEvent, data:Object):void
		{
			if(evt.text == "somebody")
			{
				ChatModule.getInstance().chat.itemClickHandler(evt,data);
				return;
			}else if(evt.text.indexOf("=") != -1){
				ChatModule.getInstance().chat.itemClickHandler(evt,data);
				return;
			}
			var args:Array=evt.text.split('#');
			if(args.length>0){
				var order:String=args.shift()
				var key:String;
				
				switch(order){
					case Anti_addiction.OPEN_VIEW:
						args=args[0].split('$')
						var value:m_system_fcm_toc = new m_system_fcm_toc();
						value.info = String(args[0])
						value.total_time = int(args[1]);
						value.remain_time = int(args[2]);
						SystemModule.getInstance().openFCMWindow(value);
						break;
				}
			}
			
			
		}
		
		private function changeTimer():void
		{
			if(waitArr.length==0)
			{
				//showLaba("",0);
				return;
			}
			
			if(waitArr.length >= 1 )//=
			{
				if(timer)
				{
					return;
//					clearTimer();
				}
				
				timer = new Timer(1000,defSecond);
				
				timer.addEventListener(TimerEvent.TIMER,ontimer);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeComplt);
				
				timer.start();
				showLaba(waitArr[0],roleData[0]);
			}
			
			
		}
		
		private function ontimer(e:TimerEvent):void
		{
			if(timer.currentCount>=4 && waitArr.length>1)
			{
				clearTimer();
				
				changeTimer();
			}
		}
		
		private function onTimeComplt(e:TimerEvent):void
		{
			clearTimer();
			if(waitArr.length>0)
			{
				changeTimer();
			}else{
				if(item && vsCanvas &&vsCanvas.contains(item))
				{
					vsCanvas.removeChild(item);
					
					item = null;
					vsCanvas.visible = false;
				}
//				showLaba("",null);
			}
		}
		
		
		private function clearTimer():void
		{
			if(waitArr.length>0)
			{
				waitArr.shift();
				roleData.shift();
			}
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER,ontimer);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeComplt);
			timer = null;
		}
		
		public static function logger(msg:String):void{
			getInstance().appendMsg(msg);
		}
		
	}
}