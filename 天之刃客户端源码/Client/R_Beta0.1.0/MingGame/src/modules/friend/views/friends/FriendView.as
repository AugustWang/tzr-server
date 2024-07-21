package modules.friend.views.friends
{	
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import modules.friend.FriendsManager;
	
	public class FriendView extends Sprite
	{
		private var tabNavigation:TabNavigation;	
		private var goodFriends:TabGoodFriends;
		private var enemy:TabEnemy;
		private var blacklist:TabBlackList;
		private var applications:TabApplications;
		public function FriendView()
		{
			init();
		}
		
		private function init():void{
			goodFriends = new TabGoodFriends();
			enemy = new TabEnemy();
			blacklist = new TabBlackList();
			applications = new TabApplications(); 
			goodFriends.y = 3;
			enemy.y = 3;
			blacklist.y = 3;
			applications.y = 3;
			
			var container:UIComponent = ComponentUtil.createUIComponent(0,0,465,320);
			container.bgSkin = Style.getPanelContentBg();
			container.y = 24;
			container.mouseEnabled = false;
			addChild(container);
			
			tabNavigation = new TabNavigation(); 
			tabNavigation.x = 2;
			Style.setBorderSkin(tabNavigation.tabContainer);
			tabNavigation.tabBarPaddingLeft = 5;
			tabNavigation.height = 318;
			tabNavigation.width = 461;
			tabNavigation.addItem("好友",goodFriends,64,25);
			tabNavigation.addItem("仇人",enemy,64,25);
			tabNavigation.addItem("黑名单",blacklist,64,25); 
			tabNavigation.addItem("申请列表",applications,64,25); 	
			addChild(tabNavigation);
			
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
		}
		
		private function onAddedToStageHandler(event:Event):void{
			FriendsManager.getInstance().viewRenderer = true;
		}
		
		private function onRemovedFromStage(event:Event):void{
			FriendsManager.getInstance().viewRenderer = false;
		}
		
		public function selectIndex(value:int):void{
			tabNavigation.selectedIndex = value;
		}
	}
}