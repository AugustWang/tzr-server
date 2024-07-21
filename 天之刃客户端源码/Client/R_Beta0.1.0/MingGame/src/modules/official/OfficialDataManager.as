package modules.official
{
	import com.events.ParamEvent;
	
	import flash.events.EventDispatcher;
	
	import proto.line.p_faction;
	import proto.line.p_office;

	public class OfficialDataManager extends EventDispatcher
	{
		public static const FACTIOIN_INIT:String = "FACTIOIN_INIT";
		public static const FACTIOIN_NOTICE_UPDATE:String = "FACTIOIN_NOTICE_UPDATE";
		public static const FACTIOIN_RANK_UPDATE:String = "FACTIOIN_RANK_UPDATE";
		
		private var _faction:p_faction;
		public var factionRanks:Array;
		public function OfficialDataManager()
		{
		}
		
		private static var _instance:OfficialDataManager;
		public static function getInstance():OfficialDataManager{
			if(_instance == null){
				_instance = new OfficialDataManager();
			}
			return _instance;
		}
		
		public function set faction(vo:p_faction):void{
			this._faction = vo;
			dispatchEvent(new ParamEvent(FACTIOIN_INIT));
		}
		
		public function get faction():p_faction{
			return _faction;
		}
		
		public function getOfficial():p_office{
			if(_faction){
				return _faction.office_info;
			}
			return null;
		}
		
		public function updateNotice(notice:String):void{
			if(faction){
				faction.notice_content = notice;
				dispatchEvent(new ParamEvent(FACTIOIN_NOTICE_UPDATE));
			}
		}
		
		public function setFactonRank(vos:Array):void{
			factionRanks = vos;
			dispatchEvent(new ParamEvent(FACTIOIN_RANK_UPDATE));
		}
	}
}