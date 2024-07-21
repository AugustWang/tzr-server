package modules.factionsWar.views {
	import com.common.GlobalObjectManager;
	
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;

	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import modules.broadcast.BroadcastModule;
	import modules.factionsWar.FactionWarDataManager;

	import proto.line.m_waroffaction_count_down_toc;

	public class FactionCountDownView extends Sprite {
		private var timer:Timer;
		private var txt:TextField;
		private var timeTxt:TextField;
		private var timeLeft:int=0;
		private var txt2:TextField;
		private var tarTxt:TextField;

		public function FactionCountDownView() {
			this.name="FactionCountDownView";
			initView();
		}

		private function initView():void {
			var bg:UIComponent=new UIComponent();
			Style.setMenuItemBg(bg); //背景
			bg.width=85;
			bg.height=80;
			this.addChild(bg);
			var tf:TextFormat=new TextFormat(null, null, 0xFFF673, null, null, null, null, null, "center");
			txt=ComponentUtil.createTextField("", 0, 3, tf, 80, 22, this);
			timeTxt=ComponentUtil.createTextField("", 0, 19, tf, 80, 22, this);
			txt2=ComponentUtil.createTextField("当前进攻目标", 0, 35, tf, 80, 22, this);
			tarTxt=ComponentUtil.createTextField("", 0, 53, tf, 80, 22, this);
			if (timer == null) {
				timer=new Timer(1000, 0);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
			}
		}

		public function reset(vo:m_waroffaction_count_down_toc):void {
			if (vo.type == 1) { //还有多长时间开始
				txt.text="距离国战开始";
				timeLeft=vo.tick;
				onTimer();
				timer.start();
//				SceneTopTimeIconManager.getInstance().addChildren(this);
				BroadcastModule.getInstance().countdownView.addChilren(this);

				FactionWarDataManager.phase=1;
			} else if (vo.type == 2) { //还有多少时间结束
				txt.text="距离国战结束";
				timeLeft=vo.tick;
				onTimer();
				timer.start();
//				SceneTopTimeIconManager.getInstance().addChildren(this);
				BroadcastModule.getInstance().addToCountDown(this);
				FactionWarDataManager.isInWarTime=true;
				FactionWarDataManager.phase=2;
			} else {
				hide();
				FactionWarDataManager.isInWarTime=false;
				FactionWarDataManager.phase=0;
			}
			if (vo.attack_faction_id == GlobalObjectManager.getInstance().user.base.faction_id) {
				txt2.text="当前进攻目标";
			} else {
				txt2.text="敌方进攻目标";
			}
			tarTxt.text=vo.current_target;
		}

		private function hide():void {
			if (this.parent != null) {
//				this.parent.removeChild(this);
//				SceneTopTimeIconManager.getInstance().dealPosition();
				BroadcastModule.getInstance().countdownView.removeChildren(this);
			}
			timer.stop();
		}

		private function onTimer(e:TimerEvent=null):void {
			timeLeft--;
			if (timeLeft >= 0) {
				timeTxt.text=DateFormatUtil.formatTime(timeLeft);
			}
		}
	}
}