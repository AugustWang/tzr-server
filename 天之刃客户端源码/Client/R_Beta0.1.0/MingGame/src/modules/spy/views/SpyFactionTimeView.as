package modules.spy.views
{
	
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastView;
	import modules.spy.SpyModule;
	
	public class SpyFactionTimeView extends Sprite
	{
		private var txt:TextField;
		private var timeLeft:int = 0;	
		//提供给外界的height属性
		private var heightValue:int=40;
		
		public function SpyFactionTimeView()
		{
			initView();
		}
		
		private function initView():void
		{
			var bg:UIComponent= new UIComponent();
			Style.setMenuItemBg(bg);//背景
			bg.width = 100;
			bg.height = 40;
			this.addChild(bg);
			
			this.addEventListener(MouseEvent.MOUSE_OVER, showToolTip);
			this.addEventListener(MouseEvent.MOUSE_OUT, hideToolTip);
			
			txt = ComponentUtil.createTextField("", 3, 8, null, 95, 20, this);
		}
		
		private function showToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show("国探期间完成刺探军情任务可获得30%的经验加成");
		}
		
		private function hideToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function reset(remainTime:int):void
		{
			timeLeft = remainTime;
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			SpyModule.isInSpyFaction = true;
			//SceneTopTimeIconManager.getInstance().addChildren(this);
			BroadcastModule.getInstance().countdownView.addChilren(this);
		}
		
		private function onTimer(evt:TimerEvent):void
		{
			timeLeft --;
			if (timeLeft >= 0){
				txt.htmlText = "<p align='left'><font color='#FFF673'>国探时间  "+ DateFormatUtil.formatTime(timeLeft)+"</font></p>";
			} else {
				if (this.parent != null) {
//					this.parent.removeChild(this);
//					SceneTopTimeIconManager.getInstance().dealPosition();
					BroadcastModule.getInstance().countdownView.removeChildren(this);
				}
				var timer:Timer = evt.currentTarget as Timer;
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.stop();
				SpyModule.isInSpyFaction = false;
				
				BroadcastView.getInstance().addBroadcastMsg("我国今天的国探已结束");
			}
		}
		
		override public function get height():Number{
			return heightValue;
		}
	}
}