package modules.family
{
	import com.common.GlobalObjectManager;
	import com.loaders.CommonLocator;
	import com.managers.Dispatch;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.broadcast.views.Tips;
	import modules.friend.GroupManager;
	import modules.friend.views.vo.GroupType;
	import modules.navigation.NavigationModule;
	
	import proto.common.p_family_info;
	import proto.common.p_family_member_info;
	import proto.common.p_family_request;
	import proto.common.p_family_second_owner;
	import proto.common.p_online_info;

	/**
	 *门派数据管理器 
	 */	
	public class FamilyLocator
	{	
		private static var instance:FamilyLocator;
		public var FMLbuffXml:XML;
		public function FamilyLocator()
		{
			FMLbuffXml = CommonLocator.getXML(CommonLocator.FML_SKILL_BUFF);
		}
		
		public static function getInstance():FamilyLocator{
			if(instance == null){
				instance = new FamilyLocator();
			}
			return instance;
		}
		
		public function isFamilyOwner(role_id:int):Boolean{
			if (familyInfo.owner_role_id == role_id) {
				return true;
			}
			return false;
		}
		
		public function isSecondOwner(role_id:int):Boolean{
			for each(var secondOwner:p_family_second_owner in familyInfo.second_owners) {
				if (secondOwner && secondOwner.role_id == role_id) {
					return true;
				}
			}
			return false;
		}
		
		public var familyInfo:p_family_info;	
		public var onlineNum:int=0;
		public function setFamilyInfo(info:p_family_info):void{
			familyInfo = info;
			var familyId:String = GroupManager.getInstance().getGroupIdByType(GroupType.FAMILY_GROUP);
			if(familyInfo){
				if(!GroupManager.getInstance().isInited(familyId)){
					GroupManager.getInstance().initGroupByType(GroupType.FAMILY_GROUP,info.members);
				}
				familyInfo.members.sort(sortHandler);
				showFamilyRequest();
				for each(var member:p_family_member_info in familyInfo.members) {
					if (member.online) {
						onlineNum++;
					}
				}
			}else{
				GroupManager.getInstance().removeGroupNode(familyId);
			}
			FamilyModule.getInstance().showFamilyIcon();
			if(familyInfo == null){
				FamilyYBCModule.getInstance().removeYBCViews();
			} else {
				if (familyInfo.ybc_status == 2) {
					if (familyInfo.ybc_role_id_list.indexOf(GlobalObjectManager.getInstance().getRoleID()) > -1) {
						FamilyYBCModule.getInstance().showYbcArrow = true;
					}
				}	
			}
		}
		/**
		 * 获取官职ID (如果userId=-1则获取当前玩家的官职ID)
		 */		
		public function getRoleID(userId:int=-1):int{
			if(familyInfo == null)return -1;
			var roleId:int = userId;
			if(roleId == -1){
				roleId = GlobalObjectManager.getInstance().user.attr.role_id;	
			}
			if(roleId == familyInfo.owner_role_id){
				return FamilyConstants.ZZ;
			}
			if(roleId == familyInfo.interiormanager){
				return FamilyConstants.NWS;
			}
			var fzs:Array = familyInfo.second_owners;
			for each(var fz:p_family_second_owner in fzs){
				if(fz.role_id == roleId){
					return FamilyConstants.F_ZZ;
				}
			}
			return FamilyConstants.ZY;
		}
		/**
		 * 添加成员 
		 */		
		public function addMember(member:p_family_member_info):void{
			if(familyInfo){
				familyInfo.cur_members++;
				familyInfo.members.push(member);
				familyInfo.members.sort(sortHandler);
				BroadcastView.getInstance().addBroadcastMsg("欢迎["+member.role_name+"] 加入本门派");
				var familyChannelId:String = GroupManager.getInstance().getGroupIdByType(GroupType.FAMILY_GROUP);
				GroupManager.getInstance().addGroupMember(familyChannelId,member);
			}
		}
		
		/**
		 * 删除成员 
		 */		
		public function removeMember(id:int):void{
			if(familyInfo){
				var size:int = familyInfo.members.length;
				for(var i:int=0;i < size ;i++){
					var p:p_family_member_info = familyInfo.members[i];
					if(id == p.role_id){
						BroadcastView.getInstance().addBroadcastMsg("["+p.role_name+"] 退出了门派");
						familyInfo.members.splice(i,1);
						familyInfo.cur_members--;
						var familyChannelId:String = GroupManager.getInstance().getGroupIdByType(GroupType.FAMILY_GROUP);
						GroupManager.getInstance().deleteMember(familyChannelId,p.role_id);
						break;
					}
				}
			}
		}
		
		/**
		 *根据ID获取成员 
		 */		
		public function getMemberById(id:int):p_family_member_info{
			if(familyInfo == null)return null;
			for each(var p:p_family_member_info in familyInfo.members){
				if(p.role_id == id){
					return p;
				}
			}
			return null;
		}
		/**
		 * 获取所有在线帮众
		 */
		
		public function getOnlineMember():Array
		{			
			if(familyInfo == null)
				return null;
			var arr:Array = new Array();
			for each(var p:p_family_member_info in familyInfo.members)
			{
				if(p.online)
					arr.push(p);
			}
			return arr;
		}
		/**
		 *获取门派资金
		 */
		public function getMoney():int{
			if(familyInfo == null)return 0;
			return familyInfo.money
		}
		
		/**
		 *加入一条请求数据 
		 */		
		public function addRequest(request:p_family_request):void{
			if(familyInfo){
				familyInfo.request_list.push(request);
			}
			showFamilyRequest();
		}
		/**
		 * 删除请求数据 
		 */		
		public function removeRequest(id:int):void{
			if(familyInfo == null)return;
			for(var i:int=0;i<familyInfo.request_list.length;i++){
				var p:p_family_request = familyInfo.request_list[i];
				if(id == p.role_id){
					familyInfo.request_list.splice(i,1);
					break;
				}
			}
		}
		
		/**
		 * 更新称号 
		 */		
		public function updateTitle(id:int,title:String):p_family_member_info{
			var p:p_family_member_info = getMemberById(id);
			if(p){
				p.title = title;
			}
			return p;
		}
		/**
		 * 更新等级 
		 */		
		public function updateLevel(id:int,level:int):p_family_member_info{
			var p:p_family_member_info = getMemberById(id);
			if(p){
				p.role_level = level;
			}
			return p;
		}
		/**
		 * 删除长老
		 */		
		private function deleteSecondOwner(id:int):void{
			if(familyInfo == null)return;
			for(var i:int=0;i<familyInfo.second_owners.length;i++){
				var targetId:int = familyInfo.second_owners[i].role_id;
				if(targetId == id){
					familyInfo.second_owners.splice(i,1);
					break;
				}
			}
		}
		/**
		 * 添加长老
		 */		
		private function addSecondOwner(roleId:int,roleName:String):void{
			if(familyInfo == null)return;
			var seconder:p_family_second_owner = new p_family_second_owner();
			seconder.role_id = roleId;
			seconder.role_name = roleName;
			familyInfo.second_owners.push(seconder);
		}
		/**
		 * 更新在线情况 
		 */		
		public function updateOnline(roleId:int,online:Boolean):void{
			if (online) {
				this.onlineNum++;
			} else {
				this.onlineNum--;
			}
			if(familyInfo == null)return;
			var member:p_family_member_info = getMemberById(roleId);
			if(member){
				member.online = online;
			}
			var groupId:String = GroupManager.getInstance().getGroupIdByType(GroupType.FAMILY_GROUP);
			GroupManager.getInstance().setOnOffLine(groupId,member.role_id,online);
			familyInfo.members.sort(sortHandler);
		}
		
		/**
		 * 批量更新所有在线
		 */
		
		public function updateAllOnlien(pArry:Array):void
		{
			var OnlineArr:Array = getOnlineMember();
			for each(var obj:p_online_info in pArry)
			{
				updateOnline(obj.memberid,true);
			}
			for each(var member:p_family_member_info in OnlineArr)
			{
				if(!checkInOnline(member.role_id,pArry))
				  	updateOnline(member.role_id,false);				
			}					
		}
		
		private function checkInOnline(RoleID:int,pArry:Array):Boolean
		{
			var flag:Boolean = false;
			for each(var obj:p_online_info in pArry)
			{
				flag = obj.memberid == RoleID;
				if(flag){
					break;
				}
			}
			return flag;
			
		}
		/**
		 * 设置长老 
		 */		
		public function setSeconedOwner(id:int):void{
			if(familyInfo == null)return;
			var p:p_family_member_info = getMemberById(id);
			var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			if(userId == id){
				Tips.getInstance().addTipsMsg("你被任命为长老");
			}else if(familyInfo && familyInfo.owner_role_id == userId){
				Tips.getInstance().addTipsMsg("任命 ["+p.role_name+"] 为长老成功");
			}else{
				Tips.getInstance().addTipsMsg("["+p.role_name+"] 被任命为长老");
			}
			if(p){
				p.title = "长老";
				addSecondOwner(p.role_id,p.role_name)
				familyInfo.members.sort(sortHandler);
			}
		}
		/**
		 * 取消长老 
		 */	
		public function unSetSecondOwner(id:int):void{
			if(familyInfo == null)return;
			var p:p_family_member_info = getMemberById(id);
			var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			if(userId == id){
				Tips.getInstance().addTipsMsg("你的门派长老职位已被解除");
			}else if(familyInfo && familyInfo.owner_role_id == userId){
				Tips.getInstance().addTipsMsg("解除 ["+p.role_name+"] 长老职位成功");
			}
			if(p){
				p.title = "帮众";
				deleteSecondOwner(id);
				familyInfo.members.sort(sortHandler);
			}
		}
		/**
		 * 设置新掌门 
		 */		
		public function setNewCEO(id:int):void{
			if(familyInfo == null)return;
			var ceo:p_family_member_info = getMemberById(familyInfo.owner_role_id);
			var newCEO:p_family_member_info = getMemberById(id);
			Tips.getInstance().addTipsMsg("["+newCEO.role_name+"] 成为了门派掌门");
			var beforeFactionId:int = getRoleID(newCEO.role_id);
			if(beforeFactionId == FamilyConstants.F_ZZ){
				ceo.title = "长老";
				addSecondOwner(ceo.role_id,ceo.role_name);
			}else if(beforeFactionId == FamilyConstants.ZY){
				ceo.title = "帮众";
			}
			if(newCEO){
				newCEO.title = "掌门";
			}
			familyInfo.owner_role_id = newCEO.role_id;
			familyInfo.owner_role_name = newCEO.role_name;
			deleteSecondOwner(id);//不管他是之前是长老还是组员都去删除，如果是帮众也没影响
			familyInfo.members.sort(sortHandler);
		}
		/**
		 * 根据成员之间的官职，等级，是否在线排序  
		 */		
		private function sortHandler(p1:p_family_member_info,p2:p_family_member_info):int{
			var online1:int = p1.online ? 1 : 0;
			var online2:int = p2.online ? 1 : 0;
			var result:int = compare(online1,online2);
			if(result == 0){
				var factionId1:int = getRoleID(p1.role_id);
				var factionId2:int = getRoleID(p2.role_id);
				result = compare(factionId1,factionId2);
				if(result == 0){
					result = compare(p1.family_contribution,p2.family_contribution);
				}
			}
			return result;
		}
		private function compare(value1:Number,value2:Number):int{
			if(value1 > value2){
				return -1;
			}else if(value1 < value2){
				return 1;
			}else{
				return 0;
			}
		}
		/**
		 * 是否有请求 
		 */		
		public function hasRequest():Boolean{
			return familyInfo ? familyInfo.request_list.length > 0 : false;
		}
		
		public function showFamilyRequest():void{
			if(familyInfo && familyInfo.request_list && familyInfo.request_list.length > 0){
				var factionId:int = getRoleID();
				if(!FamilyModule.getInstance().isOpenMyFamily() && factionId != FamilyConstants.ZY && NavigationModule.getInstance().gameInit){
					Dispatch.dispatch(ModuleCommand.SOCIETY_FLICK);
				}
			}
		}
		
		public function getObjByIdAndLv(id:int,lv:int):Object
		{
			var obj:Object = {};
			var buffs:XML = FMLbuffXml.buffs.(@id == id)[0];
			if(!buffs)
			{
				return null;
			}
			obj.name = String(buffs.@name);
			obj.url = String(buffs.@url);
			obj.id = id;// String(buffs.@id);
			var buff:XML = buffs.buff.(@level == lv)[0];
			if(!buff)
			{
				return null;
			}
			obj.level = lv;
			obj.familyLv = int(buff.@familyLv);
			obj.cost = int(buff.@cost);
			obj.desc = String(buff.@desc);
			
			
			return obj;
		}
		
		/**
		 * 更新内务使
		 */
		private function updateInteriorManager(id:int):void
		{
			if(familyInfo == null)return;
			familyInfo.interiormanager = id;		
		}
		/**
		 * 设置内务使 
		 */		
		public function setInteriorManager(id:int):void{
			if(familyInfo == null)return;
			updateInteriorManager(id);
			var p:p_family_member_info = getMemberById(id);
			var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			if(userId == id){
				Tips.getInstance().addTipsMsg("你被任命为内务使");
			}else if(familyInfo && familyInfo.owner_role_id == userId){
				Tips.getInstance().addTipsMsg("任命 ["+p.role_name+"] 为内务使成功");
			}else{
				Tips.getInstance().addTipsMsg("["+p.role_name+"] 被任命为内务使");
			}
			if(p){
				p.title = "内务使";		
				familyInfo.members.sort(sortHandler);
			}
		}
		
		/**
		 * 取消内务使  
		 */	
		public function unSetInteriorManager(id:int):void{
			if(familyInfo == null)return;
			var p:p_family_member_info = getMemberById(id);
			var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			if(userId == id){
				Tips.getInstance().addTipsMsg("你的内务使职位已被解除");
			}else if(familyInfo && familyInfo.owner_role_id == userId){
				Tips.getInstance().addTipsMsg("解除 ["+p.role_name+"] 内务使职位成功");
			}
			if(p){
				p.title = "帮众";
				updateInteriorManager(0);
				familyInfo.members.sort(sortHandler);
			}
		}
	}
}