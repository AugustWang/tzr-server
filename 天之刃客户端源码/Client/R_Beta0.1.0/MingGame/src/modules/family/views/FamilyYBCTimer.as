package modules.family.views
{
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class FamilyYBCTimer extends UIComponent
	{
		public var totalTime:int = 3600;
		private var text:TextField;
		private var timer:Timer;
		public function FamilyYBCTimer()
		{
			super();
			width = 100;
			height = 40;
//			x = 720;
//			y = 10;
//			bgSkin = Style.getInstance().tipSkin;
//			var bg:Sprite = Style.getViewBg("timerBg");
			var bg:UIComponent = new UIComponent();
			Style.setMenuItemBg(bg);
			this.addChild(bg);
			bg.width = 100;
			bg.height = 40;
			var tf:TextFormat = new TextFormat("Tahoma",12,0xFFF673);
			tf.align = "center";
			text = ComponentUtil.createTextField("",5,3,tf,95,40,this);
			text.wordWrap = true;
			text.multiline = true;
		}
		
		public function start(hasGoTime:int):void{
			var rest:int = totalTime - hasGoTime;
			if(rest > 0){
				if(timer == null){
					timer = new Timer(1000,rest);
					timer.addEventListener(TimerEvent.TIMER,onTimer);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE,onComplete);
				}
				timer.reset();
				timer.start();
			}else{
				text.htmlText = "门派护镖时间\n已过期";
			}
		}
		
		public function stop():void{
			if(timer){
				timer.stop();
			}
		}
		
		private function onComplete(event:TimerEvent):void{
			text.htmlText = "门派护镖时间\n已过期";
		}
		
		private function onTimer(event:TimerEvent):void{
			text.htmlText = "门派护镖时间\n"+DateFormatUtil.formatTime(timer.repeatCount - timer.currentCount);
		}
	}
}