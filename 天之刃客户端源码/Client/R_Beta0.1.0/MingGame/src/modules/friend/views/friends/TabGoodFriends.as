package modules.friend.views.friends
{
	
	import com.components.DataGrid;
	import com.components.DataGridColumn;
	import com.managers.Dispatch;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.ModuleCommand;
	import modules.friend.FriendsConstants;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.friend.views.items.FriendItemRender;
	import modules.friend.views.part.AddFriendPanel;
	
	import proto.line.p_friend_info;
	
	public class TabGoodFriends extends Sprite
	{
		private var dataGrid:DataGrid;
		private var addFriend:Button;
		private var delFriend:Button;
		private var teamFriend:Button;
		
		private var addPanel:AddFriendPanel;
		private var isPopup:Boolean = false;
		
		private var friend_info:p_friend_info;
		
		public function TabGoodFriends()
		{
			super();
			
			dataGrid = new DataGrid();
			dataGrid.itemRenderer = FriendItemRender;
			dataGrid.x = 2;
			dataGrid.y = 3;
			dataGrid.width = 457;
			dataGrid.height = 275;
			var nameColumn:DataGridColumn = dataGrid.createColumn("姓名",125,"rolename");
			nameColumn.sortCompareFunc = sortOnlineHandler;
			dataGrid.add(nameColumn);
			
			var levelColumn:DataGridColumn = dataGrid.createColumn("等级",65,"level");
			levelColumn.sortOptions = Array.NUMERIC;
			dataGrid.add(levelColumn);
			
			var nationColumn:DataGridColumn = dataGrid.createColumn("国家",77,"faction_id");
			nationColumn.sortOptions = Array.NUMERIC;
			dataGrid.add(nationColumn);
			
			var familyColumn:DataGridColumn = dataGrid.createColumn("门派",100,"family_name");
			dataGrid.add(familyColumn);
			
			var friendColumn:DataGridColumn = dataGrid.createColumn("好友度",92,"friendly");
			friendColumn.sortOptions = Array.NUMERIC;
			dataGrid.add(friendColumn);
			
			dataGrid.itemHeight = 25;
			dataGrid.pageCount = 10;
			dataGrid.verticalScrollPolicy = ScrollPolicy.ON;
			addChild(dataGrid);
			
			teamFriend = ComponentUtil.createButton("邀请组队",237,289,66,25,this);
			teamFriend.addEventListener(MouseEvent.CLICK,onTeamFriend);
			addFriend = ComponentUtil.createButton("添加好友",311,289,66,25,this);
			addFriend.addEventListener(MouseEvent.CLICK,onAddFriend);
			delFriend = ComponentUtil.createButton("删除好友",385,289,66,25,this);
			delFriend.addEventListener(MouseEvent.CLICK,onDeleteFriend);
			
			Dispatch.register(FriendsConstants.FRIENDS_TYPE.toString(),update);
			load();
		}
		
		private function sortOnlineHandler(p1:p_friend_info,p2:p_friend_info):int{
			var online1:int = p1.is_online ? 1 : 0;
			var online2:int = p2.is_online ? 1 : 0;
			if(online1 > online2){
				return -1;
			}else if(online1 < online2){
				return 1;
			}else{
				return 0;
			}
		}
		
		public function load():void{
			var datas:Array = FriendsManager.getInstance().getFriendsByType(FriendsConstants.FRIENDS_TYPE);
			dataGrid.dataProvider = datas;
		}
		
		private function update():void{
			load();
		}
		
		private function onAddFriend(event:MouseEvent):void{
			AddFriendPanel.getInstance().show();
		}
	
		private function onTeamFriend(event:MouseEvent):void{
			var data:p_friend_info = dataGrid.list.selectedItem as p_friend_info;
			if(data != null){
				Dispatch.dispatch(ModuleCommand.START_TEAM,{"role_id":data.roleid});
			}	
		}
				
		private function onDeleteFriend(event:MouseEvent):void{
			var friend:p_friend_info = dataGrid.list.selectedItem as p_friend_info;
			if(friend){
				FriendsModule.getInstance().deleteFriend(friend.roleid);
			}
		}
	}
}