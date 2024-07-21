package modules.friend.views
{
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.treeList.Tree;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.friend.FriendsManager;
	import modules.friend.OpenItemsManager;
	import modules.friend.views.items.FriendCell;
	import modules.friend.views.items.SearchFriendItem;
	import modules.friend.views.part.ChatWindowManager;
	
	import proto.line.p_friend_info;
	
	public class FriendsList extends UIComponent
	{
		public static const DEFAULT_TEXT:String = "搜索联系人";
		private var searchInput:TextInput;
		private var searchList:List;
		public var tabBar:TabBar;
		private var tree:Tree;
		
		private var groupList:GroupListView;
		public function FriendsList()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.width = 166;
			this.height = 248;
			
			tabBar = new TabBar();
			tabBar.tabBarSkin = Style.getTabBar1Skin();
			tabBar.x = 10;
			tabBar.addItem("好友列表",63,22);
			tabBar.addItem("群组列表",63,22);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onSelectedTab);
			addChild(tabBar);
			
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"friend_Border");
			bg.y = 22;
			bg.x = 3;
			addChild(bg);
			
			searchInput = new TextInput();
			searchInput.textField.textColor = 0xcccccc;
			searchInput.text = DEFAULT_TEXT;
			searchInput.maxChars = 7;
			searchInput.width = 167;
			searchInput.height = 21;
			searchInput.x = 17;
			searchInput.y = 26;
			searchInput.addEventListener(FocusEvent.FOCUS_IN,focusHandler);
			searchInput.addEventListener(FocusEvent.FOCUS_OUT,focusHandler);
			searchInput.addEventListener(Event.CHANGE,changeHandler);
			addChild(searchInput);
			
			tree = new Tree();
			tree.y = 48;
			tree.x = 6;
			tree.width = 196;
			tree.height = 336;
			tree.rowHeight = 24;
			tree.cellRenderer = FriendCell;
			tree.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
			tree.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			addChild(tree);
		
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
		}
		
		private function focusHandler(event:FocusEvent):void{
			if(event.type == FocusEvent.FOCUS_IN){
				searchInput.text = "";
			}else if(StringUtil.trim(searchInput.text) == ""){
				searchInput.text = DEFAULT_TEXT;
			}
		}
		
		private function changeHandler(event:Event):void{
			var name:String = StringUtil.trim(searchInput.text);
			if(name != ""){
				var result:Array = FriendsManager.getInstance().getFriendsByName(name);
				if(result.length != 0){
					if(!searchList){
						searchList = new List();
						Style.setRectBorder(searchList);
						searchList.x = searchInput.x;
						searchList.y = searchInput.y + searchInput.height;
						searchList.itemRenderer = SearchFriendItem;
						searchList.width = searchInput.width;
						searchList.itemHeight = 25
						addChild(searchList);
						searchList.addEventListener(ItemEvent.ITEM_CLICK,itemClickHandler)
					}
					searchList.height = searchList.itemHeight*result.length;
					searchList.dataProvider = result;
					addChild(searchList);
					stage.addEventListener(MouseEvent.CLICK,onRemoveListHandler);
				}
			}
		}
		
		private function itemClickHandler(evt:ItemEvent):void
		{
			var friend:p_friend_info = evt.selectItem as p_friend_info;
			var friendNode:TreeNode = FriendsManager.getInstance().getNode(friend.roleid.toString());
			friendNode.parentNode.openNode();
			tree.scrollToItem(friendNode);
			
//			ChatWindowManager.getInstance().openChatWindow(friend);
		}
		
		private function onRemoveListHandler(evt:MouseEvent):void{
			if(stage && searchList.parent != null){
				stage.removeEventListener(MouseEvent.CLICK,onRemoveListHandler);
				searchList.parent.removeChild(searchList);
			}
		}

		private function onAddedToStageHandler(event:Event):void{
			FriendsManager.getInstance().listRenderer = true;
			if(tree.dataProvider == null){
				var dataProvider:TreeDataProvider = FriendsManager.getInstance().friendsDataProvider;
				if(dataProvider){
					tree.dataProvider = dataProvider;
				}
			}
			tree.invalidateList();
		}
		
		private function onRemovedFromStage(event:Event):void{
			FriendsManager.getInstance().listRenderer = false;
		}
		
		public function setFriendsDataProvider(dataProvoder:TreeDataProvider):void{
			tree.dataProvider = dataProvoder;
		}
		
		private function onItemDoubleClick(event:ItemEvent):void{
			clearTimeout(timeout);
			var friend:p_friend_info = event.selectItem.data as p_friend_info;
			if(friend){
				ChatWindowManager.getInstance().openChatWindow(friend);
			}
		}
		
		private var timeout:int;
		private function onItemClick(event:ItemEvent):void
		{
			clearTimeout(timeout);
			var data:p_friend_info = event.selectItem.data as p_friend_info;
			if(data != null){
				timeout = setTimeout(doItemClick, 200, data);
			}
		}
		
		public function selectedFriendTab():void{
			tabBar.selectIndex = 0;
		}
		
		public function selectedGroupTab():void{
			tabBar.selectIndex = 1;
		}
		
		private function doItemClick(data:p_friend_info):void
		{
			OpenItemsManager.getInstance().openFriendItems(data);
		}
		
		private function onSelectedTab(event:TabNavigationEvent):void{
			if(event.index == 0){
				addChild(tree);
				if(groupList && contains(groupList)){
					removeChild(groupList);
				}
			}else{
				if(groupList == null){
					groupList = new GroupListView();
					groupList.y = 48;
					groupList.x = 6;
				}
				addChild(groupList);
				if(contains(tree)){
					removeChild(tree);
				}
			}	
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}