package modules.familyCollect.views
{
	import com.common.GlobalObjectManager;
	import com.components.components.DragUIComponent;
	import com.managers.Dispatch;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.ModuleCommand;
	
	import proto.line.m_family_collect_info_toc;
	
	public class FamilyCollectScoreView extends DragUIComponent
	{
		private var scoreTxt:TextField;
		private var collectNumTxt:TextField;
		private var leftTimeTxt:TextField;
		private var leftTime:int;
		private var timer:Timer;
		
		
		public function FamilyCollectScoreView()
		{
			super();
			this.width = 175;
			this.height = 110;
			this.x = GlobalObjectManager.GAME_WIDTH-195;
			this.y = 185;
			this.alpha = 0.8;
			this.showCloseButton = false;
			var tf:TextFormat = new TextFormat(null, null, 0xAFE1EC);
			ComponentUtil.createTextField("门派采集活动告示榜", 30, 2, tf, 200, 22, this);
			scoreTxt = ComponentUtil.createTextField("门派当前积分：0", 2, 30, tf, 200, 22, this);
			collectNumTxt = ComponentUtil.createTextField("已采集竹笋： 0", 2, 55, tf, 200, 22, this);
			leftTimeTxt = ComponentUtil.createTextField("活动剩余时间", 2, 80, tf, 200, 22, this);
			
			if (timer == null)
			{
				timer=new Timer(1000, 0);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
			}
			
		}
		
		public function update(vo:m_family_collect_info_toc):void
		{
			scoreTxt.htmlText = "门派当前积分：" + vo.score;
			collectNumTxt.htmlText = "已采集竹笋：" + vo.collect_num;
			leftTime=vo.left_tick;
			if(timer.running == false)
				timer.start();
		}
		
		private function onTimer(e:TimerEvent=null):void
		{
			leftTime--; 
			if (leftTime >= 0)
				leftTimeTxt.htmlText="活动剩余时间：<font color='#FFFF00'>" + DateFormatUtil.formatTime(leftTime) + "</font>";
			else{
				leftTimeTxt.htmlText="<font color='#FFFF00'>活动已经结束</font>";
				this.parent.removeChild(this);
				Dispatch.dispatch(ModuleCommand.MISSION_SHOW_FOLLOW_VIEW);
				timer.stop();
			}
		}
		
		public function onStageResize():void
		{
			this.x = GlobalObjectManager.GAME_WIDTH-195;
		}
	}
}