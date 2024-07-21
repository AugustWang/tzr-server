package modules.team {
	import com.common.GlobalObjectManager;
	import com.components.menuItems.MenuBar;
	import com.components.menuItems.MenuItemData;
	import com.ming.events.ItemEvent;
	
	import modules.chat.ChatModule;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.system.SystemConfig;
	
	import proto.line.p_team_role;

	public class TeamMenuManager {
		private static var _instance:TeamMenuManager;
		public static const LEADER_SELF:String="LEADER_SELF";
		public static const LEADER_OTHER:String="LEADER_OTHER";
		public static const MEMBER_SELF:String="MEMBER_SELF";
		public static const MEMBER_OTHER:String="MEMBER_OTHER";
		private var dealItems:Array=["解散队伍", "退出队伍", "物品自由拾取", "物品独自拾取", "移交队长", "请出队伍", "加为好友", "私聊", "窗口聊天", "跟随","√ 允许自动入队"];
		private var menu:MenuBar;
		private var disbandItem:MenuItemData;
		private var leavlItem:MenuItemData;
		public var freePickItem:MenuItemData;
		public var turnPickItem:MenuItemData;
		private var changeLeaderItem:MenuItemData;
		private var kickItem:MenuItemData;
		private var addFriendItem:MenuItemData;
		private var talkItem:MenuItemData;
		private var chatItem:MenuItemData;
		private var myLeaveItem:MenuItemData;
		private var windowChatItem:MenuItemData;
		private var followItem:MenuItemData;
        public var autoApplyTeam:MenuItemData;
		private var data:p_team_role;

		public function TeamMenuManager() {
			menu=new MenuBar;
			menu.labelField="label";
			menu.addEventListener(ItemEvent.ITEM_CLICK, onClickItem);
			disbandItem=new MenuItemData;
			leavlItem=new MenuItemData;
			freePickItem=new MenuItemData;
			turnPickItem=new MenuItemData;
            autoApplyTeam =new MenuItemData;
			changeLeaderItem=new MenuItemData;
			kickItem=new MenuItemData;
			addFriendItem=new MenuItemData;
			talkItem=new MenuItemData;
			chatItem=new MenuItemData;
			windowChatItem=new MenuItemData;
			followItem=new MenuItemData;
			disbandItem.label=dealItems[0];
			leavlItem.label=dealItems[1];
			freePickItem.label=dealItems[2];
			turnPickItem.label=dealItems[3];
			changeLeaderItem.label=dealItems[4];
			kickItem.label=dealItems[5];
			addFriendItem.label=dealItems[6];
			chatItem.label=dealItems[7];
			windowChatItem.label=dealItems[8];
			followItem.label=dealItems[9];
            autoApplyTeam.label = dealItems[10];
			disbandItem.index=0;
			leavlItem.index=1;
			freePickItem.index=2;
			turnPickItem.index=3;
			changeLeaderItem.index=4;
			kickItem.index=5;
			addFriendItem.index=6;
			chatItem.index=7;
			windowChatItem.index=8;
			followItem.index=9;
            autoApplyTeam.index = 10;
		}

		public static function get instance():TeamMenuManager {
			if (_instance == null) {
				_instance=new TeamMenuManager;
			}
			return _instance;
		}

		private function reset(type:String, isFriend:Boolean):void {
			addFriendItem.enabled=!isFriend;
			var menuData:Vector.<MenuItemData>=new Vector.<MenuItemData>;
			switch (type) {
				case "LEADER_SELF": //队长点自己
					menuData.push(leavlItem);
					menuData.push(disbandItem);
					menuData.push(freePickItem);
					menuData.push(turnPickItem);
                    menuData.push(autoApplyTeam);
					break;
				case "LEADER_OTHER": //队长点队员
					menuData.push(chatItem);
					menuData.push(windowChatItem);
					menuData.push(changeLeaderItem);
					menuData.push(kickItem);
					menuData.push(addFriendItem);
					menuData.push(followItem);
					break;
				case "MEMBER_SELF": //队员点自己
					menuData.push(leavlItem);
					break;
				case "MEMBER_OTHER": //队员点别人
					menuData.push(chatItem);
					menuData.push(windowChatItem);
					menuData.push(addFriendItem);
					menuData.push(followItem);
					break;
				default:
					break;
			}
			menu.dataProvider=menuData;
			menu.validateNow();
		}

		public function show(type:String, vo:p_team_role=null):void {
			data=vo;
			var isFriend:Boolean;
			if (vo != null) {
				isFriend=FriendsManager.getInstance().isMyFriend(vo.role_id);
			}
            if(type == TeamMenuManager.LEADER_SELF){
                //队长点击自己
                var pick_type:int=TeamDataManager.pickMode;
                if(pick_type == 1 || pick_type == 0){
                    freePickItem.label = "√ 物品自由拾取";
                    turnPickItem.label = "物品独自拾取";
                    freePickItem.enabled=false;
                    turnPickItem.enabled=true;
                }else{
                    freePickItem.label = "物品自由拾取";
                    turnPickItem.label = "√ 物品独自拾取";
                    freePickItem.enabled=true;
                    turnPickItem.enabled=false;
                }
                var pro:TeamProcessor=TeamModule.getInstance().pro;
                if(SystemConfig.autoTeam){
                    autoApplyTeam.label = "√ 允许自动入队";
                }else{
                    autoApplyTeam.label = "允许自动入队";
                }
            }
			reset(type, isFriend);
            
			menu.show();
		}
		private function onClickItem(e:ItemEvent):void {
			var pro:TeamProcessor=TeamModule.getInstance().pro;
			var index:int=int(e.selectItem.index);
			switch (index) {
				case 0: //解散队伍
					pro.toDisband();
					break;
				case 1: //退出队伍
					pro.toLeave();
					break;
				case 2: //物品自由拾取
					pro.toChangePick(1);
					break;
				case 3: //物品独自拾取
					pro.toChangePick(2);
					break;
				case 4: //移交队长
					pro.toChangeLeader(data.role_id, data.role_name);
					break;
				case 5: //请出队伍
					pro.toKick(data.role_id);
					break;
				case 6: //加为好友
					FriendsModule.getInstance().requestFriend(data.role_name);
					break;
				case 7: //私聊
					ChatModule.getInstance().priChatHandler(data.role_name);
					break;
				case 8: //窗口聊天
					pro.toWindowChat(data);
					break;
				case 9: //跟随
					pro.toFollow(data);
					break;
                case 10: //允许自动入队
                    pro.autoApplyTeamItem();
                    break;
			}
		}
	}
}