package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.components.menuItems.MenuBar;
	import com.components.menuItems.MenuItemData;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.events.ItemEvent;
	import com.scene.tile.Hash;
	
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	import modules.family.FamilyConstants;
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	import modules.letter.LetterModule;
	
	import proto.common.p_family_member_info;
	import proto.line.p_friend_info;
	
	public class HandlerToolTip
	{
		public static const XGCH:String = "XGCH";
		public static const JSJZ:String = "JSJZ";
		public static const TCJZ:String = "TCJZ";
		public static const CKDH:String = "CKDH";
		public static const SL:String = "SL";
		public static const XX:String = "XX";
		public static const JWHY:String = "JWHY";
		public static const KCZY:String = "KCZY";
		public static const ZRZZ:String = "ZRZZ";
		public static const JCFZZ:String = "JCFZZ";
		public static const RMFZZ:String = "RMFZZ";
		public static const RMNWS:String = "RMNWS";
		public static const JCNWS:String = "JCNWS";
		public var targetUserId:int;
		public var factionId:int
		private var targetFactionId:int;
		private var functionMap:Hash;
		private var nameMap:Hash;
		public var memberInfo:p_family_member_info;
		public function HandlerToolTip()
		{
			initMenus();
		}
		
		private var menuBar:MenuBar;
		private var menuDatas:Dictionary;
		private function initMenus():void{
			menuBar = new MenuBar();
			menuBar.labelField = "label";
			menuBar.addEventListener(ItemEvent.ITEM_CLICK,onItemClick);
			menuDatas = new Dictionary();
			createItemData("解散门派",JSJZ);
			createItemData("窗口对话",CKDH);
			createItemData("私聊",SL);
			createItemData("写信",XX);
			createItemData("加为好友",JWHY);
			createItemData("修改称号",XGCH);
			createItemData("转让掌门",ZRZZ);
			createItemData("解除长老",JCFZZ);
			createItemData("开除帮众",KCZY);
			createItemData("任命长老",RMFZZ);
			createItemData("任命内务使",RMNWS);
			createItemData("解除内务使",JCNWS);
			
			functionMap = new Hash();
			functionMap.put(getItems(JSJZ),FamilyConstants.ZZ+"_"+FamilyConstants.ZZ);
			functionMap.put(getItems(SL,CKDH,XX,JWHY,ZRZZ,JCFZZ,KCZY),FamilyConstants.ZZ+"_"+FamilyConstants.F_ZZ);
			functionMap.put(getItems(SL,CKDH,XX,JWHY,XGCH,ZRZZ,RMFZZ,KCZY,RMNWS),FamilyConstants.ZZ+"_"+FamilyConstants.ZY);
			functionMap.put(getItems(SL,CKDH,XX,JWHY,XGCH,ZRZZ,RMFZZ,KCZY,JCNWS),FamilyConstants.ZZ+"_"+FamilyConstants.NWS);
			
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.F_ZZ+"_"+FamilyConstants.ZZ);
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.F_ZZ+"_"+FamilyConstants.F_ZZ);
			functionMap.put(getItems(SL,CKDH,XX,JWHY,KCZY),FamilyConstants.F_ZZ+"_"+FamilyConstants.ZY);
			functionMap.put(getItems(SL,CKDH,XX,JWHY,KCZY,JCNWS),FamilyConstants.F_ZZ+"_"+FamilyConstants.NWS);
			functionMap.put(getItems(SL,CKDH,XX,JWHY,KCZY),FamilyConstants.NWS+"_"+FamilyConstants.ZY);
			
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.ZY+"_"+FamilyConstants.ZZ);
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.ZY+"_"+FamilyConstants.F_ZZ);
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.ZY+"_"+FamilyConstants.ZY);
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.ZY+"_"+FamilyConstants.NWS);
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.NWS+"_"+FamilyConstants.ZZ);
			functionMap.put(getItems(SL,CKDH,XX,JWHY),FamilyConstants.NWS+"_"+FamilyConstants.F_ZZ);
		}
		
		private function createItemData(label:String,sign:String):void{
			var menuItemData:MenuItemData = new MenuItemData();
			menuItemData.label = label;
			menuItemData.sign = sign;
			menuDatas[sign] = menuItemData;
		}
	
		private function getItems(...params):Vector.<MenuItemData>{
			var vectors:Vector.<MenuItemData> = new Vector.<MenuItemData>();
			for each(var key:String in params){
				vectors.push(menuDatas[key]);
			}
			return vectors;
		}
		
		private function onItemClick(event:ItemEvent):void{
			var sign:String = event.selectItem.sign;
			switch(sign){
				case JSJZ:FamilyModule.getInstance().dismissFamily();break;//解散门派
				case CKDH:openChatWindow();break;//窗口对话
				case SL:ChatModule.getInstance().priChatHandler(memberInfo.role_name);;break;//私聊
				case XX:LetterModule.getInstance().openLetter(memberInfo.role_name);break;//写信
				case JWHY:addFriend();break;//加为好友
				case XGCH:openNamePanel();break;//修改称号
				case ZRZZ:FamilyModule.getInstance().alienationFamilyCEO(memberInfo.role_id,memberInfo.role_name);break;//转让掌门
				case JCFZZ:FamilyModule.getInstance().unsetSecondOwner(memberInfo.role_id,memberInfo.role_name);break;//解除长老
				case KCZY:FamilyModule.getInstance().fireFamilyMember(memberInfo.role_id,memberInfo.role_name);break;//开除帮众
				case RMFZZ:FamilyModule.getInstance().setSecondOwner(memberInfo.role_id,memberInfo.role_name);break;//任命长老
				case RMNWS:FamilyModule.getInstance().sendInteriorManager(memberInfo.role_id,memberInfo.role_name);break;//任命内务使
				case JCNWS:FamilyModule.getInstance().unSetInteriorManager(memberInfo.role_id,memberInfo.role_name);break;//任命内务使
			}
		}
		
		private function openChatWindow():void{
			var p:p_friend_info = new p_friend_info();
			p.roleid = memberInfo.role_id;
			p.rolename = memberInfo.role_name;
			p.head = 1;
			Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE,p);
		}
		
		private function addFriend():void{
			Dispatch.dispatch(ModuleCommand.ADD_FRIEND,memberInfo.role_name);
		}
		
		private var namePanel:UpdateNamePanel;
		private function openNamePanel():void{
			if(namePanel == null){
				namePanel = new UpdateNamePanel();
			}
			namePanel.roleId = memberInfo.role_id;
			namePanel.title = memberInfo.title;
			WindowManager.getInstance().popUpWindow(namePanel,WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(namePanel);
		}
		
		public function show(userId:int):void{
			this.targetUserId = userId;
			targetFactionId= FamilyLocator.getInstance().getRoleID(targetUserId);
			showMenuBar();
		}

		private function showMenuBar():void{
			var selfId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			if((factionId == FamilyConstants.ZY || factionId == FamilyConstants.F_ZZ || factionId == FamilyConstants.NWS) && selfId == targetUserId){			
				return;
			}else{
				var values:Vector.<MenuItemData> = functionMap.take(factionId+"_"+targetFactionId) as Vector.<MenuItemData>;
				menuBar.dataProvider = values;
				menuBar.show();
			}
		}
	}
}