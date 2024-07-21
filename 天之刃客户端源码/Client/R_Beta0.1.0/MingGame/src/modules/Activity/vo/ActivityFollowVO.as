package modules.Activity.vo
{
	import com.utils.HtmlUtil;
	
	import modules.Activity.ActivityConstants;
	import modules.Activity.activityManager.ActivityFollowManager;

	/**
	 * 活动追踪VO 
	 * @author huyongbo
	 * 
	 */	
	public class ActivityFollowVO
	{
		public static const ACTIVITY_NAMES:Array = ["","[活动]：","[银子]：","[经验]：","[道具]："];
		/**
		 * 活动ID 
		 */		
		public var id:int;
		/**
		 * 活动类型 1:活动，2：银子，3：经验，4：道具 
		 */		
		public var type:int;
		/**
		 * 时间类型 1：每日 2:每周 
		 */		
		public var timeType:int;
		/**
		 * 预告时间以秒为单位，例如提前一个小时 advanceTime=3600
		 */		
		public var advanceTime:Number;
		/**
		 * 开始时间以秒为单位 例如12:00开始，就是12*60*60
		 */		
		public var startTime:Number;
		/**
		 * 这是一个基于秒的时间戳，时间是自1970年1月1日午夜的秒数,程序自动计算 
		 */		
		public var endTime:Number;
		/**
		 * 持续时间以秒为单位
		 */		
		public var duration:Number;
		/**
		 * 活动描述 
		 */		
		public var desc:String;
		/**
		 * 当前状态 
		 */		
		public var state:int;
		
		/**
		 *  开始日期
		 */		
		public var stateDate:Number;
		/**
		 *  结束日期 
		 */		
		public var endDate:Number;
		
		public function ActivityFollowVO()
		{
			
		}
		
		private var html:String = "";
		public function wrapperHTML():void{
			html = HtmlUtil.font(ACTIVITY_NAMES[type],"#f09450");
			if(state == ActivityConstants.STATE_START){
				html += HtmlUtil.font(desc,"#00ff00")+HtmlUtil.font("（进行中）","#ffff00")+ActivityFollowManager.getInstance().formatTime(endDate)+"结束";
			}else{
				html += ActivityFollowManager.getInstance().formatTime(stateDate)+"-"+ActivityFollowManager.getInstance().formatTime(endDate)+HtmlUtil.font(desc,"#00ff00");
			}
		}
		
		public function get htmlText():String{
			return html;
		}
	}
}