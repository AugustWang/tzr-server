package modules.team {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	
	import proto.line.p_team_role;

	public class TeamDataManager {

		private static var _teamMembers:Array=[];
		private static var _membersDic:Dictionary;

		public function TeamDataManager() {
		}

		private static var _pickMode:int = 1;
		public static function set pickMode(value:int):void{
			if(value != _pickMode){
				_pickMode = value;
				Dispatch.dispatch(ModuleCommand.CHANGE_PICK_MODE);
			}
		}
		
		public static function get pickMode():int{
			return _pickMode;
		}
		
		public static function set teamMembers(value:Array):void {
			var isJoin:Boolean = false;
			if (value.length > 0 && _teamMembers.length == 0) {
				isJoin = true;
			}
			_teamMembers=value;
			_membersDic = new Dictionary();
			for(var i:int = 0; i < value.length; i++){
				var member:p_team_role = value[i];
				_membersDic[member.role_id] = member;
			}
			if(isJoin){
				Dispatch.dispatch(ModuleCommand.JOIN_TEAM);
			}else{
				Dispatch.dispatch(ModuleCommand.UPDATE_TEAMGROUP);
			}
		}

		public static function get teamMembers():Array {
			return _teamMembers;
		}

		public static function isTeamMember(role_id:int):Boolean {
			return _membersDic && _membersDic[role_id]!=undefined;
		}

		public static function isTeamLeader():Boolean {
			var isLeader:Boolean;
			var role_id:int=GlobalObjectManager.getInstance().user.base.role_id;
			var arr:Array=TeamDataManager.teamMembers;
			for (var i:int=0; i < arr.length; i++) {
				var p:p_team_role=arr[i];
				if (p.role_id == role_id && p.is_leader == true) {
					isLeader=true;
					break;
				}
			}
			return isLeader;

		}

		public static function getMyTeamRole():p_team_role {
			var vo:p_team_role;
			var role_id:int=GlobalObjectManager.getInstance().user.base.role_id;
			var arr:Array=TeamDataManager.teamMembers;
			for (var i:int=0; i < arr.length; i++) {
				var p:p_team_role=arr[i];
				if (p.role_id == role_id) {
					vo=p;
					break;
				}
			}
			return vo;
		}
	}
}