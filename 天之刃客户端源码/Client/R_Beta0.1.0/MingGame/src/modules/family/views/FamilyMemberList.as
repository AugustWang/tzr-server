package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.common.effect.GlowTween;
	import com.components.DataGrid;
	import com.components.DataGridColumn;
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyItemEvent;
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	import modules.family.views.items.MemberItem;
	
	import proto.common.p_family_info;
	import proto.common.p_family_member_info;
	
	public class FamilyMemberList extends Sprite
	{
		private var list:DataGrid;
		private var buttonRecruit :Button;
		private var buttonLeave :Button;
		private var buttonRefOnlie:Button;
		private var buttonDissolve :Button;
		private var buttonApplyList :Button;
		private var buttonDelete:Button;
		private var goBackFamily:Button;
		
		private var familyInfoBg:Sprite;
		private var info:p_family_info;
		public function FamilyMemberList()
		{
			super();
			var backBg:UIComponent = ComponentUtil.createUIComponent(3,1,460,279);
			Style.setBorderSkin(backBg);
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			list = new DataGrid();
			list.verticalScrollPolicy = ScrollPolicy.AUTO;
			list.itemRenderer = MemberItem;
			list.x = 2;
			list.y = 1;
			list.width = 456;
			list.height = 277;
			list.addColumn("姓名",100);
			
			var titleColumn:DataGridColumn = list.createColumn("称号",100,"title");
			titleColumn.sortCompareFunc = sortTitleHandler;
			list.add(titleColumn);
			
			var levelColumn:DataGridColumn = list.createColumn("等级",60,"role_level");
			levelColumn.sortCompareFunc = sortLevelHandler;
			list.add(levelColumn);
			
			var conColumn:DataGridColumn = list.createColumn("门派贡献度",88,"family_contribution");
			conColumn.sortCompareFunc = sortConHandler;
			list.add(conColumn);
			
			list.addColumn("操作",95);
			list.itemHeight = 25;
			list.pageCount = 10;
			list.list.addEventListener(FamilyItemEvent.SHOW_TOOLTIP,onShowHandlerTip);
			backBg.addChild(list);
			
			familyInfoBg = new Sprite();
			familyInfoBg.x = 3;
			familyInfoBg.y = 282;
			addChild(familyInfoBg);
			
			buttonLeave = ComponentUtil.createButton("离开门派",14,2,74,25,familyInfoBg);			
			buttonLeave.addEventListener(MouseEvent.CLICK,clickLeaveHandler);
			
			goBackFamily = ComponentUtil.createButton("返回门派",14,2,74,25,familyInfoBg);			
			goBackFamily.addEventListener(MouseEvent.CLICK,goBackHandler); 
		}
		
		private function sortTitleHandler(p1:p_family_member_info,p2:p_family_member_info):int{
			var value1:String = p1.title;
			var value2:String = p2.title;
			var online1:int = p1.online ? 1 : 0;
			var online2:int = p2.online ? 1 : 0;
			var result:int = compare(online1,online2);
			if(result == 0){
				//使用Flash默认字符串比较
				var compares:Array = [value1,value2];
				return compares.sort();
			}
			return result;
		}
		
		private function sortLevelHandler(p1:p_family_member_info,p2:p_family_member_info):int{
			var online1:int = p1.online ? 1 : 0;
			var online2:int = p2.online ? 1 : 0;
			var result:int = compare(online1,online2);
			if(result == 0){
				return compare(p1.role_level,p2.role_level);
			}
			return result;
		}
		
		private function sortConHandler(p1:p_family_member_info,p2:p_family_member_info):int{
			var online1:int = p1.online ? 1 : 0;
			var online2:int = p2.online ? 1 : 0;
			var result:int = compare(online1,online2);
			if(result == 0){
				return compare(p1.family_contribution,p2.family_contribution);
			}
			return result;
		}
		
		private function compare(value1:int,value2:int):int{
			if(value1 > value2){
				return -1;
			}else if(value1 < value2){
				return 1;
			}else{
				return 0;
			}
		}
		
		public function setFamilyInfo(info:p_family_info):void{
			this.info = info;
			updateMembers();
			changeFaction(FamilyLocator.getInstance().getRoleID());
		}
		
		private var factionId:int;
		private function addButton():void{
			if(factionId == FamilyConstants.ZY){
				if(buttonRecruit)buttonRecruit.dispose();buttonRecruit=null;
				if(buttonDissolve)buttonDissolve.dispose();buttonDissolve=null;
				if(buttonApplyList)buttonApplyList.dispose();buttonApplyList=null;
				if(buttonDelete)buttonDelete.dispose();buttonDelete = null;
				
			}else{
				if(factionId == FamilyConstants.ZZ){
					buttonLeave.label = "解散门派";
				}else{
					buttonLeave.label = "离开门派";
				}
				if(factionId == FamilyConstants.F_ZZ || factionId == FamilyConstants.ZZ || factionId == FamilyConstants.NWS){
					if(buttonDelete == null){
						buttonDelete = ComponentUtil.createButton("开除帮众",338,2,80,25,familyInfoBg);	
						buttonDelete.addEventListener(MouseEvent.CLICK,clickRemoveHandler);
					}
					if(buttonRecruit == null){
						buttonRecruit = ComponentUtil.createButton("招收帮众",117,2,74,25,familyInfoBg);
						buttonRecruit.addEventListener(MouseEvent.CLICK,clickRecruitHandler);
					}
					if(buttonApplyList == null){
						buttonApplyList = ComponentUtil.createButton("查看申请列表",338,2,80,25,familyInfoBg);	
						buttonApplyList.addEventListener(MouseEvent.CLICK,clickApplyListHandler);
						glowRequestButton();
					}
				}
			}
			familyInfoBg.addChild(goBackFamily);
			LayoutUtil.layoutHorizontal(familyInfoBg,13,5);
		}
		
		private var handlerTip:HandlerToolTip;
		private function onShowHandlerTip(event:FamilyItemEvent):void{
			if(handlerTip == null){
				handlerTip = new HandlerToolTip();
			}
			var userId:int = (event.data as p_family_member_info).role_id;
			handlerTip.factionId = factionId;
			handlerTip.memberInfo = event.data as p_family_member_info;
			handlerTip.show(userId);
		}
		
		private var recruitPanel:RecruitPanel;
		private function clickRecruitHandler(event:MouseEvent):void{
			if(recruitPanel == null){
				recruitPanel = new RecruitPanel();
			}
			recruitPanel.open();
			recruitPanel.getRecruits();
			WindowManager.getInstance().centerWindow(recruitPanel);
		}	
		
		private function clickLeaveHandler(event:MouseEvent):void{
			if(buttonLeave.label == "解散门派"){
				FamilyModule.getInstance().dismissFamily();
			}else if(buttonLeave.label == "离开门派"){
				FamilyModule.getInstance().LeaveFamily()	
			}
		}
		
		private function goBackHandler(event:MouseEvent):void{
			Alert.show("你是否确定要跳转到门派NPC（此次跳转将要扣除10两银子）？","温馨提示",FamilyModule.getInstance().goBackFamily);
		}
		
		public function refOnline():void
		{
			FamilyModule.getInstance().reffamilyOnlie();
		}
		
//		private function clickDissolveHandler(event:MouseEvent):void{
//			FamilyModel.getInstance().dismissFamily();
//		}
		
		private var applicationPanel:ApplicationPanel;
		private function clickApplyListHandler(event:MouseEvent):void{
			if(applicationPanel == null){
				applicationPanel = new ApplicationPanel();
			}
			applicationPanel.setApplications(info.request_list);
			applicationPanel.open();
			WindowManager.getInstance().centerWindow(applicationPanel);
			if(glow){
				glow.stopGlow();
			}
		}
		
		private function clickRemoveHandler(event:MouseEvent):void{
			var memberInfo:p_family_member_info = list.list.selectedItem as p_family_member_info;
			if(memberInfo){
				FamilyModule.getInstance().fireFamilyMember(memberInfo.role_id,memberInfo.role_name);
			}
		}
		
		public function updateRequestList():void{
			if(applicationPanel){
				applicationPanel.setApplications(info.request_list);
			}
			glowRequestButton();
		}
		
		private var glow:GlowTween;
		public function glowRequestButton():void{
			if((applicationPanel == null || applicationPanel.parent == null) && info.request_list.length > 0){
				if(glow == null){
					glow =  new GlowTween();
				}
				glow.startGlow(buttonApplyList,0.8,0xffffff,0,1);
			}
		}
		
		public function updateMembers():void{
			var on_arr:Array = new Array();
			var off_arr:Array = new Array();
			var all_member:Array = new Array();
			for(var i:int =0;i<info.members.length;i++)
			{
				var m_info:p_family_member_info = info.members[i] as p_family_member_info;
				if(m_info.online)
				{
					on_arr.push(m_info);
				}else{
					off_arr.push(m_info);
				}
			}
			off_arr.sortOn("last_login_time",Array.DESCENDING);
			all_member = on_arr.concat(off_arr);
			list.dataProvider = all_member;
		}
		
		public function updateMemberItem(item:Object):void{
			list.list.refreshItem(item);
		}
		
		public function setSeconedOwner(id:int):void{
			var factionId:int = FamilyLocator.getInstance().getRoleID();
			changeFaction(factionId);
			updateMembers();
		}

		public function setInteriorManager(id:int):void{
			var factionId:int = FamilyLocator.getInstance().getRoleID();
			changeFaction(factionId);
			updateMembers();
		}

		public function unSetInteriorManager(id:int):void{
			var factionId:int = FamilyLocator.getInstance().getRoleID();
			changeFaction(factionId);
			updateMembers();
		}
		
		public function unSetSecondOwner(id:int):void{
			var factionId:int = FamilyLocator.getInstance().getRoleID();
			changeFaction(factionId);
			updateMembers();
		}
		
		public function updateNewCEO():void{
			var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			factionId = FamilyLocator.getInstance().getRoleID(userId);
			changeFaction(factionId);
			updateMembers();
		}
			
		public function setRecruits(list:Array):void{
			if(recruitPanel){
				recruitPanel.setRecruits(list);
			}
		}
		
		public function dispose():void{
			if(recruitPanel){
				WindowManager.getInstance().removeWindow(recruitPanel);
			}
			if(applicationPanel){
				WindowManager.getInstance().removeWindow(applicationPanel);
			}
		}
		
		private function changeFaction(newfaction:int):void{
			factionId = newfaction;
			addButton();
		}
	}
}