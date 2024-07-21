package modules.duplicate.views.vo
{
	public class DuplicateLeaderVO
	{
		public var index:int;
		public var role_id:int;
		public var role_name:String;
		public var use_tx:int;
		public var use_ty:int;
		public var item_id:int;
		public var view_status:String;
		public var cur_use_role_id:int;
		public var cur_role_name:String;
		
		public function DuplicateLeaderVO(){
			
		}
		
		private var _status:int;
		public function set status(value:int):void{
			_status = value;
			if(_status == 1){
				view_status = "已使用";
			}else if(_status == 2){
				view_status = "已丢弃";
			}else{
				view_status = "未使用";
			}
		}
		public function get status():int{
			return _status;
		}
		
	}
}