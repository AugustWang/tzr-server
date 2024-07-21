package modules.personalybc
{
	import com.components.MessageIconManager;
	
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastView;
	
	import proto.line.p_personybc_info;

	public class DealGeRenAndGuoYunTime
	{
		private var timer:Timer;
		private var personYBCFactionCounter:GeRenAndGuoYunTimeView
		private var personCounter:GeRenAndGuoYunTimeView
		public static const PERSON:String='person';
		public static const PERSON_YBC_FACTION:String='person_ybc_faction';//国运
		public static const PERSONYBC:String='personybc';
		public function DealGeRenAndGuoYunTime()
		{
			init();
		}
		public function init():void
		{
			timer=new Timer(500)
			timer.addEventListener(TimerEvent.TIMER,timerFunc);
			timer.start()
		}
		public function add(value:ClockVo):void
		{
			if(value.id==PERSON){
				if(personCounter!=null){
					personCounter.parent.removeChild(personCounter)
					personCounter.unload();
					personCounter=null;
				}
				personCounter = new GeRenAndGuoYunTimeView();
				personCounter.vo.data=value;
				personCounter.setUp(PERSON)
				
				BroadcastModule.getInstance().countdownView.addChilren(personCounter);
			}else {
				if(personYBCFactionCounter!=null){
					personYBCFactionCounter.parent.removeChild(personCounter);
					personYBCFactionCounter.unload();
					personYBCFactionCounter=null;
				}
				personYBCFactionCounter = new GeRenAndGuoYunTimeView();
				personYBCFactionCounter.vo.data=value;
				personYBCFactionCounter.setUp(DealGeRenAndGuoYunTime.PERSON_YBC_FACTION);
				
				//卷轴
				MessageIconManager.removeFactionYbcIcon();
				MessageIconManager.showFactionYbcIcon();
				BroadcastModule.getInstance().countdownView.addChilren(personYBCFactionCounter);
			}
			
		}
		public function remove(id:String):void{
			if(id==PERSON){
				if(personCounter!=null){
					personCounter.parent.removeChild(personCounter)
					personCounter.unload();
					personCounter=null;
				}
			}else {
				if(personYBCFactionCounter!=null){
					//把国运状态设置为0
					var _vo:p_personybc_info = PersonalYbcModule.getInstance().view.info_toc.info;
					if(_vo){
						_vo.event_status = 0;
					}
					
					if(personYBCFactionCounter!=null){
						personYBCFactionCounter.parent.removeChild(personYBCFactionCounter);
						personYBCFactionCounter.unload();
						personYBCFactionCounter=null;
					}
					BroadcastView.getInstance().addBroadcastMsg('<FONT COLOR="#FFFF00">今日国运已结束。</FONT>')
					
					MessageIconManager.removeFactionYbcIcon();
				}
			}
			BroadcastModule.getInstance().countdownView.dealPosition();
		}
		
		private function timerFunc(e:TimerEvent):void{
			if(personCounter){
				var vo:ClockVo=personCounter.vo.data as ClockVo
				vo.showTime=vo.time-getTimer()
				if(vo.showTime>=0){
					vo.showTime>0?personCounter.text='<FONT COLOR="#FFF673">护镖时间 </FONT>'+'<FONT COLOR="#FFF673">'+vo.showTimerString+'</FONT>':'<FONT COLOR="#FF0000">'+vo.showTimerString+'</FONT>';
					personCounter.link.htmlText=vo.des
				}else {
					personCounter.text='<FONT COLOR="#FFF673">护镖时间 </FONT>'+'<FONT COLOR="#FF0000">已超时</FONT>'
					personCounter.link.htmlText=vo.des
				}
			}if(personYBCFactionCounter){
				var fvo:ClockVo=personYBCFactionCounter.vo.data as ClockVo;
				fvo.showTime=fvo.time-getTimer()
				if(fvo.showTime>=0){
					fvo.showTime>0?personYBCFactionCounter.text='<FONT COLOR="#FFF673">国运时间 </FONT>'+'<FONT COLOR="#FFF673">'+fvo.showTimerString+'</FONT>':'<FONT COLOR="#FF0000">'+fvo.showTimerString+'</FONT>';
				}else {
					this.remove(DealGeRenAndGuoYunTime.PERSON_YBC_FACTION);

				}
			}
		}
		
		
		
		
	}
}