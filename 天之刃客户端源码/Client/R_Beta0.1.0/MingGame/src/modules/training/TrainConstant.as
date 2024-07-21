package modules.training
{
	import com.common.GlobalObjectManager;

	public class TrainConstant
	{
		
		public static const COST_PER_HOUR:int = 100; //每小时花费多少训练点
		public static const STATUS:int =6;
		
		public static const TRAIN:String = "训练";
		public static const HOUR:String = "小时";
		public static const TRAIN_POINT:String = "训练点数";
		public static const BEGIN_TRAIN:String = "开始训练";
		public static const TOTAL_TRAIN:String = "共计训练";
		public static const MINUTE:String = "分钟";
		public static const REMAIN_POINT:String = "剩余训练点数";
		public static const IS_NOT_ENOUGH:String = "训练点数不足";
		public static const GET_TRAIN_POINT:String = "获得训练点数";
		public static const TRAIN_DESC:String = "<font color='#ffff00'>训练营介绍：</font>";
		public static const DESC_CONTENT:String = "    京城人杰地灵，精气汇集，确是个修炼的好地方！闭关修炼，武学必有所悟。"
		
		public static const TIP_DESC:String="<font color='#ffff00'>小提示：</font>";
		public static const TIP_CONTENT:String = "    <font color='#00ff00'>下线</font>不影响经验获得。在线训练可以聊天，但不能进行其他操作。";
		
		public static const TRAIN_TIP:String = "<font color='#ffff00'>小提示：下线后，经验增长不受影响。</font>";
		/*据说一代武学宗师张三丰晚年为了将一生所学发扬光大，闭关多日，在太平村一个曲径通幽之地修建了训练营。
    潜心向武之人来此处花费一定的训练点，假以时日，就能大幅提高自身的功力。

小提示：<font color=''>下线<>也不影响经验的获得。在线训练时可以聊天，但不能进行其他操作。*/
		
		/**
		 *exchange 
		 */		
		public static const EXCHANGE_TRAIN_POINT:String= "1元宝换10点训练点数";
		public static const USE_YB_NUM:String = "使用元宝数量：";
		public static const EXCHANGE_BTN:String = "花费";
		
		/**
		 *training. 
		 */		
		public static const TRAINING:String = "闭关修炼中";
		public static const TRAING_COST:String = "消耗训练点数";
		public static const TRAING_GET_EXP:String = "获得经验";
		public static const TRAING_PROGRESS:String = "进程（分钟）";
		public static const TRAING_TO_LEVEL:String = "可达到等级";
		public static const TRAINING_STOP:String= "停止训练";
		public static const STOP_TOOLTIP:String = "中途停止训练，将会返还剩余的训练点数。";
		
		// 1-29 :1 ;  30~  : （级数-10）/10 取整
		
		public static function costP_hour():int
		{
			var point:int ;
			var lv:int = GlobalObjectManager.getInstance().user.attr.level
			
			
			if(lv <30)
			{
				point = 1 * 6;
			}else if(lv<40){
				
				point = 2 *6;
			}else if(lv<50){
				point = 3 *6;
			}else if(lv<70){
				point = 4 *6;
			}
			else if(lv<90){
				point = 5 *6;
			}else if(lv<110){
				point = 6 *6;
			}
			else if(lv< 130){
				point = 7 *6;
			}
			else if(lv<150){
				point = 8 *6;
			}
			else
			{
				point = 9 * 6;
			}
			return point;
		}
		
		public function TrainConstant()
		{
		}
	}
}