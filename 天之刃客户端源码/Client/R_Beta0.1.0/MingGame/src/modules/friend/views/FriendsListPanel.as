package modules.friend.views
{	
	
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.TabDirection;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.ScaleShape;
	import com.utils.ComponentUtil;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import modules.educate.EducateModule;
	import modules.family.FamilyModule;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.friend.GroupManager;
	import modules.friend.views.part.BottomBtns;
	import modules.official.OfficialModule;
	
	public class FriendsListPanel extends BasePanel
	{
		private var head:FriendsHead;
		private var friendList:FriendsList;
		private var bottom:BottomBtns;
		private var smallButton:UIComponent;
		private var tab:TabNavigation;
		public function FriendsListPanel()
		{
			super();
			this.width = 252;
			this.height = 489;
			
			addContentBG(35);
			head = new FriendsHead();
			head.x = 4
			head.y = 10;
			addChildToSuper(head);
			
			friendList = new FriendsList();
			
			tab = new TabNavigation();
			tab.tabBarSkin = Style.getLeftTabBarSkin()
			tab.width = 202;
			tab.height = 252;
			tab.x = 8;
			tab.y = 24;
			tab.tabBarPaddingLeft = 15;
			tab.itemDoubleClickEnabled = true;
			tab.direction = TabDirection.LEFT;
			tab.addItem("好\n友",friendList,26,50);
			tab.addItem("宗\n族",FamilyModule.getInstance().getFamilyListView(),30,54);
			//			tab.addItem("师\n门",EducateModule.getInstance().getEducateList(),30,54);
			tab.addItem("国\n家",OfficialModule.getInstance().getTabOfficialView(),30,54);
			tab.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
			
			addChild(tab);
			
			bottom = new BottomBtns();
			bottom.y = 416;
			bottom.x = 55;
			addChild(bottom);
			
			addEventListener(WindowEvent.OPEN,onOpen);
		}
		
		override protected function addContentBG(paddingBottom:Number=30,paddingLR:Number=8,paddingTop:Number=5):void{
			var contentBg:ScaleShape = new ScaleShape(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"panelContentBg"));
			contentBg.setScale9Grid(new Rectangle(30,30,137,99));
			contentBg.setSize(210,395);
			contentBg.x = 36;
			contentBg.y = 20;
			addChild(contentBg);
		}
		
		public function setFriendsDataProvider(dataProvoder:TreeDataProvider):void{
			if(friendList){
				friendList.setFriendsDataProvider(dataProvoder);
			}
		}
		
		public function updateMyInfo():void{
			head.updateMyInfo();
		}	
		
		private function onItemDoubleClick(event:ItemEvent):void{
			var index:int = tab.selectedIndex;	
			if(index == 0){
				FriendsModule.getInstance().openFriendView();
			}else if(index == 1){
				FriendsModule.getInstance().openFamilyView();
			}else if(index == 2){
				FriendsModule.getInstance().openNationView();
			}
		}
		
		private function onOpen(event:WindowEvent):void{
			if(FriendsManager.getInstance().hasFlick()){
				friendList.selectedFriendTab();
			}else if(GroupManager.getInstance().hasFlick()){
				friendList.selectedGroupTab();
			}
		}
	}
}