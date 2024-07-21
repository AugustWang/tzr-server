package modules.family.views
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.TabBar;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.family.views.items.ListMemberItem;
	import modules.friend.FriendsModule;
	import modules.friend.OpenItemsManager;
	import modules.friend.views.part.ChatWindowManager;
	
	import proto.common.p_family_info;
	import proto.common.p_family_member_info;
	import proto.line.p_friend_info;
	
	public class FamilyList extends Sprite
	{
		private var tabBar:TabBar;
		private var memberList:List;
		private var placard:VScrollText;
		private var info:p_family_info;
		private var text:TextField;
		public function FamilyList()
		{
			init();
		}
		
		private function init():void
		{
			tabBar = new TabBar();
			tabBar.x = 3;
			tabBar.tabBarSkin = Style.getTabBar1Skin();
			tabBar.x = 10;
			tabBar.addItem("帮众列表",63,22);
			tabBar.addItem("门派公告",63,22);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onChangedHandler);
			addChild(tabBar);
			
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"friend_Border");
			bg.y = 22;
			bg.x = 3;
			addChild(bg);
			
			if(GlobalObjectManager.getInstance().user.base.family_id == 0){
				addDefaultText();
			}else{
				tabBar.validateNow();				
			}
		}
		
		private function onItemDoubleClick(event:ItemEvent):void{
			clearTimeout(timeout);
			var item:p_family_member_info = event.selectItem as p_family_member_info;
			if(item){
				var friend:p_friend_info = new p_friend_info();
				friend.roleid = item.role_id;
				friend.head = item.head;
				friend.rolename = item.role_name;
				friend.sex = item.sex;
				ChatWindowManager.getInstance().openChatWindow(friend);
			}
		}
		
		private var timeout:int;
		private function onItemClick(event:ItemEvent):void
		{
			clearTimeout(timeout);
			if(event.selectItem != null){
				timeout = setTimeout(doItemClick, 200, event.selectItem);
			}
		}
		
		private function doItemClick(data:p_family_member_info):void
		{
			OpenItemsManager.getInstance().openFamilyItems(data);
		}
		
		public function setFamilyInfo(value:p_family_info):void{
			if(value == null){
				addDefaultText();
				if(placard && placard.parent){
					placard.parent.removeChild(placard);
				}
				if(memberList && memberList.parent){
					memberList.parent.removeChild(memberList);
				}
			}else if(value.family_id != 0){
				if(text && text.parent){
					removeText();
					tabBar.selectIndex = 0;
					tabBar.validateNow();
				}
				this.info = value;
				updateMembers();
				if(placard){
					placard.text = info.private_notice;
				}
			}
		}
		
		private function onChangedHandler(event:TabNavigationEvent):void{
			if(GlobalObjectManager.getInstance().user.base.family_id == 0)return;
			if(event.index == 0){
				addList();
			}else{
				addPlcard();
			}
		}
		
		public function setPlcard(content:String):void{
			if(placard){
				placard.text = content;
			}
		}
		
		public function updateMembers():void{
			if(memberList){
				memberList.dataProvider = info.members;
			}
		}
		
		public function addDefaultText():void{
			if(text == null){
				var css:StyleSheet = new StyleSheet();
				css.parseCSS("a {color: #00ff00;} a:hover {color: #00ff00; text-decoration: underline;}");
				text = ComponentUtil.createTextField("",80,190,null,NaN,25);
				text.styleSheet = css;
				text.mouseEnabled = true;
				text.filters = FilterCommon.FONT_BLACK_FILTERS;
				text.htmlText = "<a href='event:addFamily'>加入门派</a>";
				text.addEventListener(TextEvent.LINK,onLinkHandler);
			}
			addChild(text);
		}
		
		private function removeText():void{
			if(text && text.parent){
				text.parent.removeChild(text);
			}
		}
		
		private function addList():void{
			if(memberList == null){
				memberList = new List();
				memberList.y = 25;
				memberList.x = 6;
				memberList.width = 196;
				memberList.height = 360;
				memberList.bgSkin = null;
				memberList.itemRenderer = ListMemberItem;
				memberList.itemHeight = 25;
				memberList.itemDoubleClickEnabled = true;
				memberList.addEventListener(ItemEvent.ITEM_CLICK,onItemClick);
				memberList.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
			}
			if(placard && placard.parent){
				placard.parent.removeChild(placard);
			}
			addChild(memberList);
		}
		
		private function addPlcard():void{
			if(placard == null){
				placard = new VScrollText();
				placard.textField.textColor = 0xF6F5CD;
				placard.direction = ScrollDirection.RIGHT;
				placard.verticalScrollPolicy = ScrollPolicy.AUTO;
				placard.width = 196;
				placard.height = 360;
				placard.y = 25;
				placard.x = 6;
			}
			if(memberList && memberList.parent){
				memberList.parent.removeChild(memberList);
			}
			if(placard && info){
				placard.text = info.private_notice;
			}
			addChild(placard);
		}
		
		private function onLinkHandler(event:TextEvent):void{
			FriendsModule.getInstance().openFamilyView();
		}
	}
}