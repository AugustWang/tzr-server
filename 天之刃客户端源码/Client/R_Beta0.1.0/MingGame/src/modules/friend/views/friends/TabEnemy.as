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
	
	import proto.line.p_friend_info;
	
	public class TabEnemy extends Sprite
	{
		private var dataGrid:DataGrid;
		private var delEnemy:Button;
		public function TabEnemy()
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
			
			delEnemy = ComponentUtil.createButton("删除仇人",385,289,65,26,this);
			delEnemy.addEventListener(MouseEvent.CLICK,onDeleteEnemy);
			Dispatch.register(FriendsConstants.ENEMY_TYPE.toString(),update);
			load();
		}
		
		public function load():void{
			var datas:Array = FriendsManager.getInstance().getFriendsByType(FriendsConstants.ENEMY_TYPE);
			dataGrid.dataProvider = datas;
		}
		
		private function update():void{
			load();
		}
		
		private function onDeleteEnemy(event:MouseEvent):void{
			var friend:p_friend_info = dataGrid.list.selectedItem as p_friend_info;
			if(friend){
				FriendsModule.getInstance().deleteFriend(friend.roleid);
			}
		}
	}
}