package modules.friend.views.vo
{
	import proto.common.p_chat_channel_role_info;
	import proto.common.p_family_member_info;
	import proto.line.p_team_role;

	public class GroupItemVO
	{
		public var roleId:int;
		public var roleName:String;
		public var head:int;
		public var online:Boolean;
		public var sign:String;
		public function GroupItemVO(role:*)
		{
			if(role is p_chat_channel_role_info){
				copyChannelRole(role as p_chat_channel_role_info);
			}else if(role is p_family_member_info){
				copyFamilyMember(role as p_family_member_info);
			}else if(role is p_team_role){
				copyTeamMember(role as p_team_role);
			}
		}
		
		public function copyChannelRole(role:p_chat_channel_role_info):void{
			roleId = role.role_id;
			roleName = role.role_name;
			head = role.head;
			online = role.is_online;
			sign = role.sign;
		}
		
		public function copyFamilyMember(role:p_family_member_info):void{
			roleId = role.role_id;
			roleName = role.role_name;
			head = role.head;
			online = role.online;
			sign = "";
		}
		
		public function copyTeamMember(role:p_team_role):void{
			roleId = role.role_id;
			roleName = role.role_name;
			head = role.skin.skinid;
			online = !role.is_offline;
			sign = "";
		}
		
	}
}