package modules.Activity.activityManager
{
	import com.loaders.CommonLocator;
	import com.managers.Dispatch;
	import com.utils.DateFormatUtil;
	
	import modules.Activity.ActivityConstants;
	import modules.Activity.vo.ActivityFollowVO;
	import modules.ModuleCommand;
	import modules.system.SystemConfig;

	public class ActivityFollowManager
	{
		public static const DAY_SECONDS:int = 86400;
		
		private var inited:Boolean = false;
		private var activitys:Array;
		private var todayActivitys:Array;
		private var displayList:Array;
		private var currentDate:Date;
		private var currentDay:int;
		private var count:int = 60;
		public function ActivityFollowManager()
		{
			Dispatch.register(ModuleCommand.HEART_BEAT,onHeartBeat);
			currentDate = new Date();
			displayList = new Array();
			todayActivitys = new Array();
		}
		
		private static var _instance:ActivityFollowManager;
		public static function getInstance():ActivityFollowManager{
			if(_instance == null){
				_instance = new ActivityFollowManager();
			}
			return _instance;
		}
		
		public function initActivity():void{
			var result:XML = CommonLocator.getXML(CommonLocator.ACTIVITY_FOLLOW);
			var itemList:XMLList = result.activity;
			activitys = new Array();
			for each(var item:XML in itemList){
				var activityVO:ActivityFollowVO = new ActivityFollowVO();
				activityVO.id = item.@id;
				activityVO.advanceTime = item.@advanceTime;
				activityVO.startTime = covertSeconds(item.@startTime);
				activityVO.desc = item.text();
				activityVO.duration = item.@duration;
				activityVO.timeType = item.@timeType;
				activityVO.type = item.@type;
				activitys.push(activityVO);
			}
			inited = true;
		}
		
		private function covertSeconds(time:String):int{
			var results:Array = time.split(":");
			var seconds:int = int(results[0])*3600+int(results[1])*60;
			return seconds;
		}
		
		private function onHeartBeat():void{
			if(inited){
				if(count == 60){
					count = 0;
					currentDate.time = SystemConfig.serverTime*1000;
					var currentSeconds:int = currentDate.hours*3600+currentDate.minutes*60+currentDate.seconds;
					var todayStartSeconds:int = SystemConfig.serverTime - currentSeconds;
					if(currentDay != currentDate.getDate()){
						currentDay = currentDate.getDate();
						todayActivitys.length = 0;
						for each(var vo:ActivityFollowVO in activitys){
							checkActivity(todayStartSeconds,vo);
							if(vo.state != ActivityConstants.STATE_PASS){
								todayActivitys.push(vo);
							}
						}
					}
					displayList.length = 0;
					for each(var activityVO:ActivityFollowVO in todayActivitys){
						checkActivity(todayStartSeconds,activityVO);
						if(activityVO.state != ActivityConstants.STATE_PASS){
							activityVO.wrapperHTML();
							displayList.push(activityVO);
						}
					}
					Dispatch.dispatch(ModuleCommand.ACT_FOLLOW_LIST_CHANGED);
				}
				count++;
			}
		}
		/**
		 * 检测改活动当前状态 
		 * @param todayStartSeconds
		 * @param vo
		 * 
		 */		
		private function checkActivity(todayStartSeconds:int,vo:ActivityFollowVO):void{
			var currentNoticeSeconds:int;//本次活动的公告时间
			var currentStartSeconds:int;
			var currentEndSeconds:int;//本次活动的结束时间
			if(vo.timeType == -1){ //每天都进行的，可以推断此活动时间绝对不超过24小时
				currentNoticeSeconds = todayStartSeconds+vo.startTime-vo.advanceTime;
				currentStartSeconds = todayStartSeconds+vo.startTime;
				currentEndSeconds = todayStartSeconds+vo.startTime+vo.duration;
			}else if(vo.timeType >= 0){
				var startDaySeconds:int;
				if(currentDate.day >= vo.timeType){
					startDaySeconds = todayStartSeconds - (currentDate.day - vo.timeType)*DAY_SECONDS;
				}else{
					startDaySeconds = todayStartSeconds + (vo.timeType - currentDate.day)*DAY_SECONDS;
				}
				currentNoticeSeconds = startDaySeconds+vo.startTime-vo.advanceTime;
				currentStartSeconds = startDaySeconds+vo.startTime;
				currentEndSeconds = startDaySeconds+vo.startTime+vo.duration;
			}
			vo.stateDate = currentStartSeconds;
			vo.endDate = currentEndSeconds;
			if(SystemConfig.serverTime >= currentNoticeSeconds && SystemConfig.serverTime < currentStartSeconds){
				vo.state = ActivityConstants.STATE_NOTICE;
			}else if(SystemConfig.serverTime >= currentStartSeconds && SystemConfig.serverTime < currentEndSeconds){
				vo.state = ActivityConstants.STATE_START;
			}else{
				vo.state = ActivityConstants.STATE_PASS;
			}
		}
		
		public function getDisplayList():Array{
			return displayList.concat();
		}
		
		public function getCurrentDay():int{
			return currentDay;
		}
		
		private var compareDate:Date;
		public function formatTime(seconds:int):String{
			if(compareDate == null){
				compareDate = new Date();
			}
			compareDate.time = seconds*1000;
			if(currentDay != compareDate.getDate()){
				return compareDate.getDate()+"日"+DateFormatUtil.formatHM(seconds);
			}
			return DateFormatUtil.formatHM(seconds);
		}
	}
}