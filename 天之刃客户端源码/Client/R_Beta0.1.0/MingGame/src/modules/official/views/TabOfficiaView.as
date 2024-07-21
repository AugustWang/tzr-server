package modules.official.views
{
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.TabBar;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.friend.OpenItemsManager;
	import modules.friend.views.part.ChatWindowManager;
	import modules.official.OfficialConstants;
	import modules.official.OfficialModule;
	import modules.official.views.items.TabOfficiaListItem;
	import modules.official.views.vo.OfficalMemberVO;
	
	import proto.line.p_faction;
	import proto.line.p_friend_info;
	import proto.line.p_office_position;
	import modules.official.OfficialDataManager;

	public class TabOfficiaView extends Sprite
	{
		private var tabBar:TabBar;
		private var memberList:List;
		private var placard:VScrollText;
		private var faction:p_faction;
		public function TabOfficiaView()
		{
			init();
		}
		
		private function init():void
		{
			tabBar = new TabBar();
			tabBar.x = 10;
			tabBar.tabBarSkin = Style.getTabBar1Skin();
			tabBar.x = 10;
			tabBar.addItem("国家官员",63,22);
			tabBar.addItem("国家公告",63,22);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onChangedHandler);
			addChild(tabBar);
			
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"friend_Border");
			bg.y = 22;
			bg.x = 3;
			addChild(bg);
			
			OfficialDataManager.getInstance().addEventListener(OfficialDataManager.FACTIOIN_INIT,factionInitHandler);		
			OfficialDataManager.getInstance().addEventListener(OfficialDataManager.FACTIOIN_NOTICE_UPDATE,factionNoticeHandler);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function factionInitHandler(event:ParamEvent):void{
			initFaction(OfficialDataManager.getInstance().faction);
		}
		
		private function onAddedToStage(event:Event):void{
			OfficialModule.getInstance().getOfficialInfo();	
		}
		
		private function onItemDoubleClick(event:ItemEvent):void{
			var item:OfficalMemberVO = event.selectItem as OfficalMemberVO;
			if(item){
				var friend:p_friend_info = new p_friend_info();
				friend.roleid = item.roleId;
				friend.rolename = item.roleName;
				friend.head = item.head;
				ChatWindowManager.getInstance().openChatWindow(friend);
			}
		}
		
		private var timeout:int;
		private function onItemClick(event:ItemEvent):void{
			clearTimeout(timeout);
			var item:OfficalMemberVO = event.selectItem as OfficalMemberVO;
			if(item){
				timeout = setTimeout(doItemClick, 200, item);
			}
		}
		
		private function doItemClick(item:OfficalMemberVO):void{
			OpenItemsManager.getInstance().openOfficialItems(item);
		}
		
		private function initFaction(faction:p_faction):void{
			this.faction = faction;
			var listDataProvider:Array = []; 
			if(faction.office_info.king_role_id > 0){
				var kingVO:OfficalMemberVO = new OfficalMemberVO();
				kingVO.roleId = faction.office_info.king_role_id;
				kingVO.roleName = faction.office_info.king_role_name;
				kingVO.head = faction.office_info.king_head;
				kingVO.officeId = OfficialConstants.OFFICIAL_KING;
				kingVO.online = true;
				kingVO.officeName = OfficialConstants.OFFICE_NAMES[kingVO.officeId];
				listDataProvider.push(kingVO);
			}
			for each(var role:p_office_position in faction.office_info.offices){
				if(role.role_id != 0){
					var vo:OfficalMemberVO = new OfficalMemberVO();
					vo = new OfficalMemberVO();
					vo.roleId = role.role_id;
					vo.roleName = role.role_name;
					vo.head = role.head;
					vo.officeId = role.office_id;
					vo.officeName = role.office_name;
					vo.online = true;// 目前暂时假设对方在线
					listDataProvider.push(vo);
				}
			}
			memberList.dataProvider = listDataProvider;
			if(placard){
				placard.text = faction.notice_content;
			}
		}
		
		private function onChangedHandler(event:TabNavigationEvent):void{
			if(event.index == 0){
				addList();
			}else{
				addPlcard();
			}
		}
		
		public function factionNoticeHandler(content:String):void{
			if(placard){
				placard.text = OfficialDataManager.getInstance().faction.notice_content;
			}
		}
		
		private function addList():void{
			if(memberList == null){
				memberList = new List();
				memberList.width = 196;
				memberList.height = 360;
				memberList.y = 25;
				memberList.x = 6;
				memberList.bgSkin = null;
				memberList.itemRenderer = TabOfficiaListItem;
				memberList.itemHeight = 25;
				memberList.itemDoubleClickEnabled = true;
				memberList.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
				memberList.addEventListener(ItemEvent.ITEM_CLICK,onItemClick);
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
				placard.selecteable = true;
				placard.width = 196;
				placard.height = 360;
				placard.y = 25;
				placard.x = 6;
			}
			if(memberList && memberList.parent){
				memberList.parent.removeChild(memberList);
			}
			if(placard){
				placard.text = faction.notice_content;
			}
			addChild(placard);
		}
	}
}