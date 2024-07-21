package com.components.menuItems {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	
	import flash.system.System;
	
	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	import modules.deal.DealModule;
	import modules.family.FamilyConstants;
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	import modules.flowers.FlowerModule;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.mypackage.PackageModule;
	import modules.official.KingModule;
	import modules.roleStateG.RoleStateModule;
	
	import proto.line.p_friend_info;

	public class MenuItemConstant {
		public static const DEAL:uint=0x0001; //交易
		public static const FRIEND:uint=0x0002; //加为好友
		public static const CHAT:uint=0x0003; //私聊
		public static const FLOWER:uint=0x0004; //送花
		public static const COPYNAME:uint=0x0005; //复制人名
		public static const LETTER:uint=0x0008; //写信
		public static const DEL_FRIEND:uint=0x0009; //删除好友
		public static const ADD_BLACK:uint=0x0010; //添加黑名单
		public static const VIEW_DETAIL:uint=0x0011;
		public static const OPEN_FRIEND_CHAT:uint=0x0012; //窗口聊天
		public static const DEL_BLACK:uint=0x0013; //删除黑名单
		public static const REQUEST_GROUP:uint=0x0014; //请求组队
        public static const APPLY_TEAM:uint=0x0015; //申请组队
		public static const INVITE_JOIN_FAMILY:uint=0x0016; //邀请加入门派
		public static const SELECED:uint=0x0017; //选中
		public static const FOLLOW:uint=0x0018; //跟随
		public static const DEL_ENEMY:uint=0x0019; //删除仇人
		public static const TRACE:uint=0x0020; //追踪玩家
		public static const APPLY_FOR_FAMILY:uint=0x0021; //申请加入门派
		public static const KINGBAN:uint =0x0022;//国王禁言


		public static function getLabelName(flag:uint):String {
			switch (flag) {
				case DEAL:
					return "交易";
				case FRIEND:
					return "加为好友";
				case CHAT:
					return "私聊";
				case DEAL:
					return "交易";
				case FLOWER:
					return "赠送鲜花";
				case COPYNAME:
					return "复制人名";
				case LETTER:
					return "写信";
				case OPEN_FRIEND_CHAT:
					return "窗口聊天";
				case DEL_FRIEND:
					return "删除好友";
				case ADD_BLACK:
					return "添加黑名单";
				case VIEW_DETAIL:
					return "观察";//return "查看详情";
				case DEL_BLACK:
					return "删除黑名单";
				case REQUEST_GROUP:
					return "邀请组队";
				case APPLY_TEAM:
					return "申请入队";
				case INVITE_JOIN_FAMILY:
					return "邀请加入门派";
				case SELECED:
					return "选中";
				case FOLLOW:
					return "跟随";
				case DEL_ENEMY:
					return "删除仇人";
				case TRACE:
					return "追踪玩家";
				case APPLY_FOR_FAMILY:
					return "申请加入门派";
				case KINGBAN:
					return "禁言此人";
				default:
					return "";
			}
		}

		/**
		 * 可以在此处定义决定是否锁定改功能
		 */
		public static function isEnabled(targetRoleInfo:TargetRoleInfo, flag:uint):Boolean {
			if (flag == FRIEND) {
				return !FriendsManager.getInstance().isMyFriend(targetRoleInfo.roleId);
			}else if (flag == REQUEST_GROUP) {
                if(targetRoleInfo && targetRoleInfo.faction_id != 0 && targetRoleInfo.roleId != 0
                    && (targetRoleInfo.faction_id == 1 || targetRoleInfo.faction_id == 2 
                    || targetRoleInfo.faction_id == 3) ){
                    if(targetRoleInfo.faction_id == GlobalObjectManager.getInstance().user.base.faction_id){
                        if(targetRoleInfo.hasOwnProperty("team_id")){
                            if(targetRoleInfo.team_id == 0){
                                return true;
                            }
                            return false;
                        }
                        return true;
                    }
                    return false;
                }
				return true;
                
			}else if(flag == APPLY_TEAM) {
                if(targetRoleInfo && targetRoleInfo.faction_id != 0 && targetRoleInfo.roleId != 0
                    && (targetRoleInfo.faction_id == 1 || targetRoleInfo.faction_id == 2 
                    || targetRoleInfo.faction_id == 3)){
                    if(targetRoleInfo.faction_id == GlobalObjectManager.getInstance().user.base.faction_id
                        && GlobalObjectManager.getInstance().user.base.team_id == 0){
                        if(targetRoleInfo.hasOwnProperty("team_id")){
                            if(targetRoleInfo.team_id != 0){
                                return true;
                            }
                            return false;
                        }
                        return true;
                    }
                    return false;
                }
                return true;
            }else if (flag == INVITE_JOIN_FAMILY) {
				var officeId:int=FamilyLocator.getInstance().getRoleID();
				if (officeId == FamilyConstants.ZZ || officeId == FamilyConstants.F_ZZ) {
					if (targetRoleInfo.family_id > 0) {
						return false;
					}
					return true;
				} else {
					return false;
				}
			}
			return true;
		}

		/**
		 * 功能项函数执行
		 */
		public static function itemHandler(flag:uint, targetRoleInfo:TargetRoleInfo):void {
			switch (flag) {
				case DEAL:
					DealModule.getInstance().requestDeal(targetRoleInfo.roleId);
					break;
				case ADD_BLACK:
					FriendsModule.getInstance().addBlack(targetRoleInfo.roleName);
					break;
				case CHAT:
					ChatModule.getInstance().priChatHandler(targetRoleInfo.roleName);
					break;
				case COPYNAME:
					System.setClipboard(targetRoleInfo.roleName);
					break;
				case DEL_FRIEND:
				case DEL_BLACK:
				case DEL_ENEMY:
					FriendsModule.getInstance().deleteFriend(targetRoleInfo.roleId);
					break;
				case OPEN_FRIEND_CHAT:
					var friendInfo:p_friend_info=new p_friend_info();
					friendInfo.roleid=targetRoleInfo.roleId;
					friendInfo.rolename=targetRoleInfo.roleName;
					friendInfo.sex=targetRoleInfo.sex;
					friendInfo.head=targetRoleInfo.head;
					Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE, friendInfo);
					break;
				case VIEW_DETAIL:
					RoleStateModule.getInstance().lookDetail(targetRoleInfo.roleId);
					break;
				case FRIEND:
					FriendsModule.getInstance().requestFriend(targetRoleInfo.roleName);
					break;
				case REQUEST_GROUP:
					Dispatch.dispatch(ModuleCommand.START_TEAM, {"role_id": targetRoleInfo.roleId,"type_id":0});
					break;
                case APPLY_TEAM:
                    Dispatch.dispatch(ModuleCommand.APPLY_TEAM, {"role_id": targetRoleInfo.roleId});
                    break;
				case LETTER:
					Dispatch.dispatch(ModuleCommand.OPEN_WRITE_LETTER, targetRoleInfo.roleName);
					break;
				case INVITE_JOIN_FAMILY:
					Dispatch.dispatch(ModuleCommand.INVITE_JOIN_FAMILY, targetRoleInfo.roleName);
					break;
				case SELECED:
					//暂无
					break;
				case FOLLOW:
					Dispatch.dispatch(ModuleCommand.FOLLOW,targetRoleInfo.roleId);
					break;
				case FLOWER:
					FlowerModule.getInstance().initSendFlowerView(targetRoleInfo);
					break;
				case TRACE:
					PackageModule.getInstance().useTrace(targetRoleInfo.roleName);
					break;
				case APPLY_FOR_FAMILY:
					FamilyModule.getInstance().joinFamilyRequest(targetRoleInfo.joinFamilyId);
					break;
				case KINGBAN:
					KingModule.getInstance().forbidden(targetRoleInfo);
					break;				
				default:
					;
			}
		}
	}
}