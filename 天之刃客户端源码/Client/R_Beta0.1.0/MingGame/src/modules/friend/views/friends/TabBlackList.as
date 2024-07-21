package modules.friend.views.friends
{
	import com.components.DataGrid;
	import com.managers.Dispatch;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.friend.FriendsConstants;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.friend.views.items.EnemyItemRender;
	import modules.friend.views.part.AddBlackPanel;
	
	import proto.line.p_friend_info;
	
	public class TabBlackList extends Sprite
	{
		private var dataGrid:DataGrid;
		private var addBlackName:Button;
		private var delBlackName:Button;
		public function TabBlackList()
		{
			dataGrid = new DataGrid();
			dataGrid.itemRenderer = EnemyItemRender;
			dataGrid.x = 2;
			dataGrid.y = 3;
			dataGrid.width = 457;
			dataGrid.height = 275;
			dataGrid.addColumn("姓名",125);
			dataGrid.addColumn("等级",94);
			dataGrid.addColumn("国家",100);
			dataGrid.addColumn("门派",111);
			dataGrid.itemHeight = 25;
			dataGrid.pageCount = 10;
			dataGrid.verticalScrollPolicy = ScrollPolicy.ON;
			addChild(dataGrid);
			
			addBlackName = ComponentUtil.createButton("添加黑名单",311,289,71,25,this);
			addBlackName.addEventListener(MouseEvent.CLICK,onAddBlackList);
			delBlackName = ComponentUtil.createButton("删除黑名单",385,289,71,25,this);
			delBlackName.addEventListener(MouseEvent.CLICK,onDeleteBlackList);
			Dispatch.register(FriendsConstants.BLACK_TYPE.toString(),update);
			load();
		}
		
		public function load():void{
			var datas:Array = FriendsManager.getInstance().getFriendsByType(FriendsConstants.BLACK_TYPE);
			dataGrid.dataProvider = datas;
		}
		
		private function update():void{
			load();
		}
		
		private function onAddBlackList(event:MouseEvent):void{
			AddBlackPanel.getInstance().show();
		}
		
		private function onDeleteBlackList(event:MouseEvent):void{
			var friend:p_friend_info = dataGrid.list.selectedItem as p_friend_info;
			if(friend){
				FriendsModule.getInstance().deleteFriend(friend.roleid);
			}
		}
	}
}