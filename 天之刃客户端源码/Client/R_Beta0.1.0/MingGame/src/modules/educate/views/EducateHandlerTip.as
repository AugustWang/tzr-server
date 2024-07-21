package modules.educate.views
{
	import com.common.GlobalObjectManager;
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.TargetRoleInfo;
	
	import modules.team.TeamDataManager;
	
	import proto.line.p_educate_role_info;
	
	public class EducateHandlerTip
	{
		public static const COMMEND_VIEW:int = 0; //推荐视图功能
		public static const ITEM_VIEW:int = 1; //视图功能
		
		public var info:p_educate_role_info;
		private var flags:Array;
		public function EducateHandlerTip()
		{
			
		}
		
		private static var instance:EducateHandlerTip;
		public static function getInstance():EducateHandlerTip{
			if(instance == null){
				instance = new EducateHandlerTip();
			}
			return instance;
		}
		
		public function initView(type:int):void{
			if(type == COMMEND_VIEW){
				flags = [MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,getRequestTeamItem(),MenuItemConstant.FRIEND,MenuItemConstant.COPYNAME,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.FLOWER];
			}else if(type == ITEM_VIEW){
				flags = [MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,getRequestTeamItem(),MenuItemConstant.LETTER,MenuItemConstant.COPYNAME,MenuItemConstant.VIEW_DETAIL,MenuItemConstant.FLOWER];
			}
		}
		
		private function getRequestTeamItem():uint{
			if(!TeamDataManager.isTeamMember(info.roleid) && info.online){
				return MenuItemConstant.REQUEST_GROUP;
			}
			return 0;
		}
		
			
		private var targetInfo:TargetRoleInfo;
		public function show(info:p_educate_role_info,type:int=0):void{
			this.info = info;
			initView(type);
			if(targetInfo == null){
				targetInfo = new TargetRoleInfo();
			}
			targetInfo.roleId = info.roleid;
			targetInfo.roleName = info.name;
			targetInfo.faction_id = GlobalObjectManager.getInstance().user.base.faction_id;
			targetInfo.head = info.sex;
			targetInfo.sex = info.sex;
			GameMenuItems.getInstance().show(flags,targetInfo);
		}
		
	}
}