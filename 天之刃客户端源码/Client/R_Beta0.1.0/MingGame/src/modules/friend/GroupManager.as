package modules.friend
{
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.scene.tile.Hash;
	
	import flash.utils.Dictionary;
	
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	import modules.friend.views.part.ChatWindowManager;
	import modules.friend.views.vo.GroupItemVO;
	import modules.friend.views.vo.GroupSettingVO;
	import modules.friend.views.vo.GroupType;
	import modules.friend.views.vo.GroupVO;
	import modules.team.TeamModule;
	
	import proto.common.p_family_info;
	
	public class GroupManager
	{
		/**
		 * 我的群组 ，数据信息 
		 */		
		public static const GROUP_MEMBER_ONLINE_CHANGED:String = "GROUP_MEMBER_ONLINE_CHANGED" ;
		private var _groupDataProvider:TreeDataProvider;
		private var nodePool:Dictionary;
		private var groupMembers:Dictionary;
		private var flickMap:Hash;
		public static var groupSettings:Dictionary = new Dictionary(true);
		public function GroupManager()
		{
			nodePool = new Dictionary(true);
			groupMembers = new Dictionary(true);
			flickMap = new Hash();
			_groupDataProvider = new TreeDataProvider();
		}
		
		private static var instance:GroupManager;
		public static function getInstance():GroupManager{
			if(instance == null){
				instance = new GroupManager();
			}	
			return instance;
		}
	
		public function get groupDataProvider():TreeDataProvider{
			return _groupDataProvider;
		}
		
		private function wrapperId(groupId:String,roleId:Object):String{
			return groupId+"_"+roleId;
		}
		/**
		 * 创建群
		 */		
		public function createGroupNode(groupVO:GroupVO=null):BranchNode{
			var branchNode:BranchNode = new BranchNode(_groupDataProvider);
			_groupDataProvider.addItem(branchNode);
			branchNode.data = groupVO;
			nodePool[groupVO.id] = branchNode;
			return branchNode;
		}
		/**
		 * 判断是否存在该群 
		 */		
		public function hasGroup(groupId:String):Boolean{
			return nodePool[groupId] != null;
		}
		/**
		 * 删除群 
		 */		
		public function removeGroupNode(id:String):void{
			var groupNode:BranchNode = nodePool[id] as BranchNode;
			if(groupNode){
				groupNode.closeNode();
				_groupDataProvider.removeItem(groupNode);
				delete nodePool[id];
			}
			ChatWindowManager.getInstance().disposeGroupWindow(id);
		}
		/**
		 * 获取群VO  
		 */		
		public function getGroupVOById(id:String):GroupVO{
			var branchNode:BranchNode =  nodePool[id];
			if(branchNode){
				return branchNode.data as GroupVO;
			}
			return null;
		}
		/**
		 * 更新群组所有组员信息 
		 */	
		public function updateGroupChildren(id:String,children:Array):void{
			var groupNode:BranchNode = nodePool[id] as BranchNode;
			if(groupNode){
				initGroupMembers(id,children);
			}
		}
		/**
		 * 初次初始化列表失败时，可以设置 inited = false,以便以后再次展开的时候，再次请求数据
		 */		
		public function setGroupInit(id:String,init:Boolean):void{
			var branchNode:BranchNode = nodePool[id];
			if(branchNode){
				branchNode.data.inited = init;
			}
		}
		/**
		 * 数据是否初始化 
		 */		
		public function isInited(id:String):Boolean{
			var branchNode:BranchNode = nodePool[id];
			if(branchNode){
				return branchNode.data.inited;
			}
			return false;
		}
		/**
		 * 是否存在改群了 
		 */		
		public function isexist(id:String):Boolean{
			var branchNode:BranchNode = nodePool[id];
			return branchNode != null;
		}
		/**
		 * 初始化群成员 
		 */		
		public function initGroupMembers(id:String,roles:Array):void{
			var branchNode:BranchNode = nodePool[id];
			if(branchNode){
				branchNode.data.inited = true;
				var members:Array = [];
				for each(var role:Object in roles){
					members.push(new GroupItemVO(role));
				}
				groupMembers[id] = members;
				Dispatch.dispatch(id);
			}
		}
		/**
		 * 通过群组类型获取群组ID 
		 */		
		public function getGroupIdByType(type:int):String{
			for each(var node:TreeNode in nodePool){
				var branch:BranchNode = node as BranchNode;
				if(branch && branch.data.type == type){
					return branch.data.id;
				}
			}
			return "";
		}
		/**
		 * 通过Id获取类型
		 */		
		public function getTypeByGroupId(id:String):int{
			var branchNode:BranchNode = nodePool[id];
			if(branchNode){
				return branchNode.data.type;
			}
			return -1;
		}
		/**
		 * 通过群组类型初始化组员 
		 */		
		public function initGroupByType(type:int,roles:Array):void{
			var id:String = getGroupIdByType(type);
			initGroupMembers(id,roles);
		}
		/**
		 * 初始化群组  
		 */		
		public function initGroup(groupVO:GroupVO):void{
			if(groupVO.inited == false){
				if(groupVO.type == GroupType.LEVEL_GROUP){
					groupVO.inited = true;
					FriendsModule.getInstance().getGroupList(groupVO.id);
				}else if(groupVO.type == GroupType.FAMILY_GROUP){
					var familyInfo:p_family_info = FamilyLocator.getInstance().familyInfo;
					if(familyInfo == null){
						FamilyModule.getInstance().getFamilyInfo();
					}
				}else if(groupVO.type == GroupType.TEAM_GROUP){
					GroupManager.getInstance().initGroupMembers(groupVO.id,TeamModule.getInstance().members);
					groupVO.inited = true;
				}
			}
		}
		/**
		 * 删除群成员 
		 */		
		public function deleteMember(id:String,roleId:int):void{
			var members:Array = groupMembers[id];
			if(members){
				for(var i:int=0;i<members.length;i++){
					var role:GroupItemVO = members[i];
					if(role.roleId == roleId){
						members.splice(i,1);
						break;
					}
				}
				Dispatch.dispatch(id);
			}
		}
		/**
		 * 设置群成员上下线状态 
		 */		
		public function setOnOffLine(id:String,roleId:int,online:Boolean):void{
			var groupMembers:Array = getMemebers(id);
			for each(var role:GroupItemVO in groupMembers){
				if(role.roleId == roleId){
					role.online = online;
					Dispatch.dispatch(GROUP_MEMBER_ONLINE_CHANGED,role);
					break;	
				}
			}
		}
		/**
		 * 添加群成员 
		 */	
		public function addGroupMember(id:String,roleInfo:Object):void{
			var members:Array = groupMembers[id];
			if(members == null){
				members = [];
				groupMembers[id] = members;
			}
			members.push(new GroupItemVO(roleInfo));	
			Dispatch.dispatch(id);
		}
		/**
		 * 设置闪烁和解除闪烁(如果节点没有展开就闪烁节点) 
		 */		
		public function setFlick(groupId:String,flick:Boolean):void{
			var node:TreeNode = nodePool[groupId];
			if(node){
				node.flick = flick;
				if(flick){
					flickMap.put(flick,groupId);
				}else{
					flickMap.remove(groupId);
				}
				_groupDataProvider.invalidateItem(node);	
			}
		}
		/**
		 * 根据群标识获取群成员
		 */		
		public function getMemebers(groupId:String):Array{
			var members:Array = groupMembers[groupId];
			if(members){
				members.sort(sortHandler);
			}
			return members;
		}
		/**
		 * 修改群组消息设置 
		 */		
		public static function setGroupSetting(groupId:String,acptTipMsg:Boolean,acptMsg:Boolean,stopMsg:Boolean):GroupSettingVO{
			var groupSetting:GroupSettingVO = groupSettings[groupId];
			if(groupSetting == null){
				groupSetting = new GroupSettingVO();
				groupSettings[groupId] = groupSetting;
			}
			groupSetting.acptMsg = acptMsg;
			groupSetting.acptTipMsg = acptTipMsg;
			groupSetting.stopMsg = stopMsg;
			return groupSetting;
		}
		/**
		 * 是否还有消息闪烁 
		 */		
		public function hasFlick():Boolean{
			return flickMap.length != 0;
		}
		/**
		 * 获取群组消息设置 
		 */		
		public static function getGroupSetting(groupId:String,type:int):GroupSettingVO{
			var groupSetting:GroupSettingVO = groupSettings[groupId];
			if(groupSetting == null){
				var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
				var key:String = userId +"_"+ "GS"+"_"+type;
				var value:Object = GlobalObjectManager.getInstance().getObject(key,true);
				var value1:Object,value2:Object,value3:Object;
				if(value){
					var values:Array = value.toString().split("_");
					value1 = values[0];
					value2 = values[1];
					value3 = values[2];
				}
				if(type == GroupType.FAMILY_GROUP || type == GroupType.TEAM_GROUP){
					value1 = (value1 == null || value1 == 0) ? false : true;
					value2 = (value2 == 0) ? false : true;
					value3 = (value3 == null || value3 == 0) ? false : true;
				}else{
					value1 = (value1 == 0) ? false : true;
					value2 = (value2 == null || value2 == 0) ? false : true;
					value3 = (value3 == null || value3 == 0) ? false : true;
				}
				groupSetting = GroupManager.setGroupSetting(groupId,value1,value2,value3);
			}
			return groupSetting;
		}
		/**
		 * 根据上下线进行排序
		 */	
		private function sortHandler(obj1:GroupItemVO,obj2:GroupItemVO):int{
			var online1:int = obj1.online ? 1 : 0;
			var online2:int = obj2.online ? 1 : 0;
			if(online1 > online2){
				return -1;
			}else if(online1 < online2){
				return 1;
			}else{
				return 0;
			}
		}
	}
}