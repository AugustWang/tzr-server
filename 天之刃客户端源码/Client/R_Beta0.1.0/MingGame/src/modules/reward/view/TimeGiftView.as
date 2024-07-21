package modules.reward.view
{
	import com.ming.managers.DragManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import modules.reward.RewardModule;
	
	public class TimeGiftView extends UIComponent
	{
		public function TimeGiftView()
		{
			super();
			this.width = 220;
			this.height = 105;
		}
		
		private var libao:Sprite;
		private var time_libao_di:Sprite;
		public var timeTxt:TextField;
		private var time_libao_guan:Sprite;
		private var arrows:Sprite;
		public function init():void{
			
			
			//礼包
			libao = Style.getViewBg("time_libao");
			this.addChild(libao);
			libao.x = (this.width - libao.width)/2;
			libao.y = 0;
			libao.name = "libao";
			libao.buttonMode = true;
			libao.useHandCursor = true;
			libao.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			libao.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			libao.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			
			//箭头
			arrows = Style.getViewBg("jt");
			this.addChild(arrows);
			arrows.visible = false;
			arrows.x = libao.x + libao.width;
			arrows.y = libao.y;
		
			
			//发光
			time_libao_guan = Style.getViewBg("time_libao_guan");
			this.addChildAt(time_libao_guan,0);
			time_libao_guan.visible = false;
			time_libao_guan.alpha = 1.0;
			time_libao_guan.x = (this.width - libao.width)/2 - 16;
			time_libao_guan.y = -16;
			
			//显示时间的界面
			time_libao_di = Style.getViewBg("time_libao_di");
			this.addChild(time_libao_di);
			time_libao_di.name = "time_libao_di";
			time_libao_di.buttonMode = true;
			time_libao_di.useHandCursor = true;
			time_libao_di.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			time_libao_di.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			time_libao_di.x = 2;
			time_libao_di.y = libao.y + libao.height + 2;
			timeTxt = ComponentUtil.createTextField("",72,20,null,80,30,time_libao_di);
			DragManager.register(time_libao_di,this,new Rectangle(0,0,1002,540),DragManager.BORDER);
		}
		
		private var currentTime:int;
		private var timer:Timer;
		/**
		 *到时间了，光效，提示牌子和箭头要显示出来 
		 * @param time
		 * 
		 */		
		public function glow(time:int):void{
			currentTime = time;
			if(time == 0){//如果时间为0了，倒计时那界面消失
				arrows.visible = true;
				time_libao_guan.visible = true;
				timer = new Timer(800);
				timer.addEventListener(TimerEvent.TIMER,onTimerHandler);
				timer.start();
			}
		}
		
		private function onTimerHandler(evt:TimerEvent):void{
			time_libao_guan.alpha == 1.0?time_libao_guan.alpha = 0.5:time_libao_guan.alpha = 1.0;
			arrows.x == libao.x + libao.width ? arrows.x = libao.x + libao.width + 10:arrows.x = libao.x + libao.width;
		}
		
		/**
		 * 点击确定后，需要把发光，箭头去除
		 * @param evt
		 * 
		 */	
		public function removeSomeDisplayObject():void{
			timer.removeEventListener(TimerEvent.TIMER,onTimerHandler);
			timer.stop();
			time_libao_guan.visible = false;
			arrows.visible = false;
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void{
			RewardModule.getInstance().loaderSource();
			RewardModule.getInstance().isClickTimeGiftOpen = true;
		}
		private function onRollOverHandler(evt:MouseEvent):void{
			if(evt.currentTarget.name == "libao"){
				if(currentTime == 0){
					ToolTipManager.getInstance().show("点击礼包领取奖励！",50);
				}else{
					ToolTipManager.getInstance().show("点击查看礼包详细信息",50);
				}
			}else if(evt.currentTarget.name == "time_libao_di"){
				ToolTipManager.getInstance().show("按住鼠标左键可以移动该界面",50);
			}
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
	}
}