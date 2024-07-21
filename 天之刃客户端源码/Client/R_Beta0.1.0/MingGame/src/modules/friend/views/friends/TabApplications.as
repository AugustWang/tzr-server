package modules.friend.views.friends
{
	import com.components.DataGrid;
	import com.components.MessageIconManager;
	import com.managers.Dispatch;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import modules.friend.FriendsManager;
	import modules.friend.views.items.FriendApplicationsItemRender;
	import modules.friend.views.part.AddFriendPanel;
	
	public class TabApplications extends Sprite
	{
		public static const APPLICATION_UPDATE:String = "APPLICATION_UPDATE";
		private var dataGrid:DataGrid;
		private var addFriend:Button;
		public function TabApplications()
		{
			super();
			dataGrid = new DataGrid();
			dataGrid.itemRenderer = FriendApplicationsItemRender;
			dataGrid.x = 2;
			dataGrid.y = 3;
			dataGrid.width = 457;
			dataGrid.height = 275;
			dataGrid.addColumn("姓名",125);
			dataGrid.addColumn("国家",80);
			dataGrid.addColumn("等级",100);
			dataGrid.addColumn("操作",126);
			dataGrid.itemHeight = 25;
			dataGrid.pageCount = 10;
			dataGrid.verticalScrollPolicy = ScrollPolicy.ON;
			addChild(dataGrid);
			
			addFriend = ComponentUtil.createButton("添加好友",385,289,66,25,this);
			addFriend.addEventListener(MouseEvent.CLICK,onAddFriend);
			Dispatch.register(APPLICATION_UPDATE,update);
			load();
			addEventListener(Event.ADDED_TO_STAGE,onAddToStageHandler);
		}
		
		private function onAddToStageHandler(event:Event):void{
			//ICON重构			MessageIconManager.removeFriendItem();
		}
		
		public function load():void{
			dataGrid.dataProvider = FriendsManager.getInstance().offlineRequest;
		}
		
		private function update():void{
			load();
		}
		
		private function onAddFriend(event:MouseEvent):void{
			AddFriendPanel.getInstance().show();
		}
	}
}