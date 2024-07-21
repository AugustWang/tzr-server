package modules.family.views
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.LoadingSprite;
	import com.managers.Dispatch;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	import modules.family.FamilyConstants;
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	
	import proto.common.p_family_info;
	import proto.common.p_family_task;
	import proto.line.m_family_activestate_toc;

	public class MyFamilyView extends LoadingSprite
	{
		private var tabNav:TabNavigation;
		private var memberList:FamilyMemberList;
		private var familyPlacard:FamilyPlacard;
		private var aboutFamily:AboutFamily;
		private var familyBuild:FamilyBuildView;

		public function MyFamilyView()
		{
			tabNav=new TabNavigation();
			tabNav.tabBarPaddingLeft=5;
			tabNav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onTabChanged);
			tabNav.tabContainerSkin = Style.getPanelContentBg();
			tabNav.width = 465;
			tabNav.height = 345;
			memberList=new FamilyMemberList();
			familyBuild = new FamilyBuildView();
			familyPlacard=new FamilyPlacard();
			aboutFamily=new AboutFamily();
			memberList.y = familyPlacard.y = aboutFamily.y = 3;
			
			tabNav.addItem("门派成员", memberList, 70, 25);
			tabNav.addItem("门派建设", familyBuild, 70, 25);
			tabNav.addItem("门派公告", familyPlacard,70, 25);
			tabNav.addItem("关于门派", aboutFamily, 70, 25);
			addChild(tabNav);
			if (FamilyLocator.getInstance().familyInfo && FamilyLocator.getInstance().familyInfo.family_id != 0)
			{
				setFamilyInfo(FamilyLocator.getInstance().familyInfo);
			}
			else
			{
				getFamilyInfo();
			}


			addEventListener(Event.ADDED_TO_STAGE, onTabChanged);

			var tf:TextFormat=new TextFormat('Tahoma', 12, 0x3be450);
			tf.underline=true;
//			var textMap:TextField = ComponentUtil.createTextField("", 275, 4, tf, 90, 26, this);
//			textMap.htmlText = "<a href='event:backToFamilyMap'>回门派地图</a>";
//			textMap.mouseEnabled = true;
//			textMap.selectable = true;
//			textMap.addEventListener(TextEvent.LINK, onTextNPCClick);
			if(checkDisplySendtoChat(FamilyLocator.getInstance().familyInfo))
			{
				var sendChat:TextField=ComponentUtil.createTextField("", 295, 6, tf, 90, 26, this);
				sendChat.filters = FilterCommon.FONT_BLACK_FILTERS;
				sendChat.htmlText="<a href='event:sendchat'>聊天招帮众</a>";
				sendChat.mouseEnabled=true;
				sendChat.selectable=true;
				sendChat.addEventListener(TextEvent.LINK, onSendToChat);
			}

			var textNpc:TextField=ComponentUtil.createTextField("", 370, 6, tf, 90, 26, this);
			textNpc.filters = FilterCommon.FONT_BLACK_FILTERS;
			textNpc.htmlText="<a href='event:" + getFamilyNpcID() + "'>前往门派管理员</a>";
			textNpc.mouseEnabled=true;
			textNpc.selectable=true;
			textNpc.addEventListener(TextEvent.LINK, onTextNPCClick);
		}

		private function checkDisplySendtoChat(info:p_family_info):Boolean
		{
			var officeId:int=FamilyLocator.getInstance().getRoleID();
			if (officeId == FamilyConstants.ZZ || officeId == FamilyConstants.F_ZZ || officeId == FamilyConstants.NWS) 
				return info.cur_members != FamilyConstants.counts[info.level];
			else
				return false;
		}
		
		private function onSendToChat(E:TextEvent):void
		{
			//if(memberList.MemberCount
			var familyID:int = GlobalObjectManager.getInstance().user.base.family_id;
			var familyName:String = GlobalObjectManager.getInstance().user.base.family_name;
			var str:String="<a href='event:view_family:" + familyID + "'><font color='#FFFF00'>【<u>"+familyName+"</u>】</font></a>门派诚招天下英雄豪杰！";
			str+=" <a href='event:join_family:"+familyID+ "'><u><font color='#00FF00'>申请加入</font></u></a>";
			ChatModule.getInstance().showPet(str);			
		}
		
		private function onTextNPCClick(e:TextEvent):void
		{
			if (e.text == 'backToFamilyMap')
			{
				FamilyModule.getInstance().enterFamilyMapNormal();
			}
			else
			{
				PathUtil.findNpcAndOpen(getFamilyNpcID());
			}
		}

		private function getFamilyNpcID():String
		{
			var faction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String="1" + faction + "100120";
			return npcId;
		}

		private function onTabChanged(event:*):void
		{
			if (tabNav.selectedIndex == 0)
			{
				memberList.refOnline();
				Dispatch.dispatch(ModuleCommand.STOP_SOCIETY_FLICK);
			}
			if (tabNav.selectedIndex == 2)
			{
				getFamilyTask();

			}
		}

		public function get selectIndex():int
		{
			return tabNav.selectedIndex;
		}

		public function setSelectIndex(index:int):void
		{
			tabNav.selectedIndex=index;
		}

		private function getFamilyInfo():void
		{
			addDataLoading();
			FamilyModule.getInstance().getFamilyInfo();
		}

		private function getFamilyTask():void
		{
			FamilyModule.getInstance().getFamilyTask();
		}

		public function setFamilyInfo(info:p_family_info):void
		{
			removeDataLoading();
			if (info)
			{
				memberList.setFamilyInfo(info);
				familyPlacard.setFamilyInfo(info)
				familyBuild.setFamilyInfo(info);
			}
		}

		public function updateFamilyInfo():void
		{
			familyPlacard.updateFamilyInfo()
			familyBuild.updateFamilyInfo();
		}

		public function updateRequestInfo():void
		{
			memberList.updateRequestList();
		}

		public function updateMemberItem(item:Object):void
		{
			memberList.updateMemberItem(item);
		}

		public function setSeconedOwner(id:int):void
		{
			memberList.setSeconedOwner(id);
			familyPlacard.updateFactioin();
		}

		public function setInteriorManager(id:int):void
		{
			memberList.setInteriorManager(id);
			familyPlacard.updateFactioin();
		}

		public function unsetInteriorManager(id:int):void
		{
			memberList.unSetInteriorManager(id);
			familyPlacard.updateFactioin();
		}

		public function unSetSecondOwner(id:int):void
		{
			memberList.unSetSecondOwner(id);
			familyPlacard.updateFactioin();
		}

		public function updateNewCEO():void
		{
			memberList.updateNewCEO();
			familyPlacard.updateFactioin();
		}

		public function updateMembers():void
		{
			memberList.updateMembers();
		}


		public function updatePlacard(content:String, isprivate:Boolean):void
		{
			familyPlacard.updatePlacard(content, isprivate)
		}

		public function setRecruits(list:Array):void
		{
			memberList.setRecruits(list);
		}

		public function dispose():void
		{
			tabNav.dispose();
			memberList.dispose();
		}

		public function setFamilyTask(data:Object):void
		{
			aboutFamily.setFamilyActivity(data);
		}
	}
}