package modules.Activity.vo
{
	import com.utils.HtmlUtil;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.activityManager.BossGroupManager;

	public class BossGroupVO
	{
		public static const UNKNOW:String = "未生成";
		public static const UN_START:int = 0;
		public static const START:int = 1;
		public static const FINISH:int = 2;
		
		public var id:int;
		public var name:String = "";
		public var level:int;
		
		public var startTime:int;
		public var duration:int;
		public var gapTime:int;
		public var endTime:int;
		
		public var mapName:String = "";
		public var mapId:int;
		public var tx:int;
		public var ty:int;
		
		public var desc:String = "";
		public var dropThings:Array;
		public var stateDesc:String = "";
		
		public var callBack:Function;
		public function BossGroupVO()
		{
		
		}
		
		private function reset():void{
			mapId = 0;
			tx = 0;
			ty = 0;
		}
		
		public function get positionHtml():String{
			if(mapId != 0){
				return HtmlUtil.font(HtmlUtil.link(mapName,"goto",true),"#00FF00");
			}else{
				return HtmlUtil.font(mapName,"#FF0000");
			}	
		}
		
		private var _state:int = UN_START;
		public function set state(value:int):void{
			if(value != _state){
				_state = value;
				if(_state == START){
					ActivityModule.getInstance().requestBossGroupDetail(id);
				}else{
					reset();
				}
			}
		}
		
		public function get state():int{
			return _state;
		}
		
		private var _attention:Boolean;
		public function set attention(value:Boolean):void{
			if(_attention != value){
				_attention = value;
				if(_attention){
					BossGroupManager.getInstance().addAttention(id);
				}else{
					BossGroupManager.getInstance().removeAttention(id);
				}
			}
		}
		
		public function get attention():Boolean{
			return _attention;
		}
	}
}