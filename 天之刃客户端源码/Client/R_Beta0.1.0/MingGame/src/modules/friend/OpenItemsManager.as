package modules.friend
{
	import com.common.GlobalObjectManager;
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.TargetRoleInfo;
	
	import modules.official.views.vo.OfficalMemberVO;
	import modules.team.TeamDataManager;
	
	import proto.common.p_family_info;
	import proto.common.p_family_member_info;
	import proto.line.p_friend_info;

	public class OpenItemsManager
	{
		private var roleTargetInfo:TargetRoleInfo;
		public function OpenItemsManager()
		{
			roleTargetInfo = new TargetRoleInfo();
		}
		
		private static var instance:OpenItemsManager;
		public static function getInstance():OpenItemsManager{
			if(instance == null){
				instance = new OpenItemsManager();
			}	
			return instance;
		}
		
		public function openFriendItems(friend:p_friend_info):void{
			if(friend == null)return;
			var isSelf:Boolean = friend.roleid == GlobalObjectManager.getInstance().user.attr.role_id;
			if(isSelf)return;
			var flags:Array = [];
			if(friend.type == FriendsConstants.FRIENDS_TYPE){
				flags.push(MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,MenuItemConstant.FLOWER,getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.LETTER,MenuItemConstant.DEL_FRIEND,MenuItemConstant.ADD_BLACK,MenuItemConstant.VIEW_DETAIL,
					    MenuItemConstant.COPYNAME,getTraceItem(friend.roleid,friend.is_online));
			}else if(friend.type == FriendsConstants.BLACK_TYPE){
				flags.push(MenuItemConstant.DEL_BLACK,MenuItemConstant.FRIEND,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.COPYNAME,getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.LETTER,getTraceItem(friend.roleid,friend.is_online));
			}else if(friend.type == FriendsConstants.ENEMY_TYPE){
				flags.push(MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,MenuItemConstant.DEL_ENEMY,getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.LETTER,MenuItemConstant.ADD_BLACK,MenuItemConstant.VIEW_DETAIL,
					    MenuItemConstant.COPYNAME,getTraceItem(friend.roleid,friend.is_online));
			}else{
				flags.push(MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,getAddFriendItem(friend.roleid),MenuItemConstant.ADD_BLACK,MenuItemConstant.LETTER,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.COPYNAME);
			}
			
			roleTargetInfo.roleId = friend.roleid;
			roleTargetInfo.roleName = friend.rolename;
			roleTargetInfo.faction_id = friend.faction_id;
			roleTargetInfo.sex = friend.sex;
			roleTargetInfo.head = friend.head;
			GameMenuItems.getInstance().show(flags,roleTargetInfo);
		}
		
		public function openNormalItems(friend:p_friend_info):void{
			if(friend == null)return;
			var isSelf:Boolean = friend.roleid == GlobalObjectManager.getInstance().user.attr.role_id;
			if(isSelf)return;
			var flags:Array = [];
			if(friend.type == FriendsConstants.FRIENDS_TYPE){
				flags.push(getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.FLOWER,MenuItemConstant.ADD_BLACK,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.COPYNAME,getTraceItem(friend.roleid,friend.is_online));
			}else if(friend.type == FriendsConstants.BLACK_TYPE){
				flags.push(MenuItemConstant.FRIEND,getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.COPYNAME,getTraceItem(friend.roleid,friend.is_online));
			}else if(friend.type == FriendsConstants.ENEMY_TYPE){
				flags.push(getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.ADD_BLACK,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.COPYNAME,getTraceItem(friend.roleid,friend.is_online));
			}else{
				flags.push(getAddFriendItem(friend.roleid),MenuItemConstant.ADD_BLACK,getRequestTeamItem(friend.roleid,friend.is_online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.COPYNAME,getTraceItem(friend.roleid,friend.is_online));
			}
			roleTargetInfo.roleId = friend.roleid;
			roleTargetInfo.roleName = friend.rolename;
			roleTargetInfo.faction_id = friend.faction_id;
			roleTargetInfo.sex = friend.sex;
			roleTargetInfo.head = friend.head;
			GameMenuItems.getInstance().show(flags,roleTargetInfo);
		}
		
		public function openOfficialItems(vo:OfficalMemberVO):void{
			if(vo == null)return;
			var isSelf:Boolean = vo.roleId == GlobalObjectManager.getInstance().user.attr.role_id;
			if(isSelf)return;
			var flags:Array = [];
			flags.push(MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,MenuItemConstant.FLOWER,getAddFriendItem(vo.roleId),getRequestTeamItem(vo.roleId,vo.online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.LETTER,MenuItemConstant.COPYNAME,getTraceItem(vo.roleId,vo.online));
			roleTargetInfo.roleId = vo.roleId;
			roleTargetInfo.roleName = vo.roleName;
			roleTargetInfo.head = vo.head;
			roleTargetInfo.faction_id = GlobalObjectManager.getInstance().user.base.faction_id;
			GameMenuItems.getInstance().show(flags,roleTargetInfo);
		}
		
		public function openFamilyItems(vo:p_family_member_info):void{
			if(vo == null)return;
			var isSelf:Boolean = vo.role_id == GlobalObjectManager.getInstance().user.attr.role_id;
			if(isSelf)return;
			var flags:Array = [];
			flags.push(MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,MenuItemConstant.FLOWER,getAddFriendItem(vo.role_id),getRequestTeamItem(vo.role_id,vo.online),MenuItemConstant.APPLY_TEAM,MenuItemConstant.LETTER,MenuItemConstant.COPYNAME,getTraceItem(vo.role_id,vo.online),MenuItemConstant.VIEW_DETAIL);
			roleTargetInfo.roleId = vo.role_id;
			roleTargetInfo.roleName = vo.role_name;
			roleTargetInfo.head = vo.head;
			roleTargetInfo.faction_id = GlobalObjectManager.getInstance().user.base.faction_id;
			GameMenuItems.getInstance().show(flags,roleTargetInfo);
		}
		
		private function getAddFriendItem(roleId:int):uint{
			if(!FriendsManager.getInstance().isMyFriend(roleId)){
				return MenuItemConstant.FRIEND;
			}
			return 0;
		}
		
		private function getRequestTeamItem(roleId:int,online:Boolean):uint{
			if(!TeamDataManager.isTeamMember(roleId) && online){
				return MenuItemConstant.REQUEST_GROUP;
			}
			return 0;
		}
		public function getTraceItem(roleId:int,online:Boolean):uint{
			if(GlobalObjectManager.getInstance().user.attr.role_id == roleId){
				return 0;
			}
			return online == false ? 0 : MenuItemConstant.TRACE;
		}
	}
}