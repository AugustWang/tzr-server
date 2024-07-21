package modules.friend
{
	
	import com.components.MessageIconManager;
	import com.managers.Dispatch;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.LeafNode;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.scene.tile.Hash;
	
	import flash.utils.Dictionary;
	
	import modules.friend.views.friends.TabApplications;
	
	import proto.line.p_friend_info;
	import proto.line.p_simple_friend_info;

	public class FriendsManager
	{
		private var _friends:Array;
		private var _offlineRequest:Array;
		private var flickMap:Hash;
		/**
		 * 我的好友一栏 ，数据信息 
		 */		
		private var _friendsDataProvider:TreeDataProvider;
		private var myFriendsNode:BranchNode;
		private var blacksNode:BranchNode;
		private var enemysNode:BranchNode;
		private var strangerNode:BranchNode;
		
		private var nodePool:Dictionary;
		public function FriendsManager()
		{
			nodePool = new Dictionary(true);
			flickMap = new Hash();
		}
		
		private static var instance:FriendsManager;
		public static function getInstance():FriendsManager{
			if(instance == null){
				instance = new FriendsManager();
			}	
			return instance;
		}
		/**
		 * 设置好友数据结合，并根据当前最新数据构建树状数据
		 */		
		public function setFriendLists(values:Array):void{
			_friends = values;
			createFriendsDataProvider();
		}
		
		public function get friends():Array{
			return _friends;
		}
		
		public function get friendsDataProvider():TreeDataProvider{
			return _friendsDataProvider;
		}
		/**
		 * 构建好友树状数据结构
		 */		
		private function createFriendsDataProvider():void{
			if(_friends == null)return;
			_friendsDataProvider = new TreeDataProvider();
			myFriendsNode = createBranchNode(_friendsDataProvider,FriendsConstants.FRIENDS_TYPE_NAMES[FriendsConstants.FRIENDS_TYPE]);
			myFriendsNode.type = FriendsConstants.FRIENDS_TYPE;
			blacksNode = createBranchNode(_friendsDataProvider,FriendsConstants.FRIENDS_TYPE_NAMES[FriendsConstants.BLACK_TYPE]);
			blacksNode.type = FriendsConstants.BLACK_TYPE;
			enemysNode = createBranchNode(_friendsDataProvider,FriendsConstants.FRIENDS_TYPE_NAMES[FriendsConstants.ENEMY_TYPE]);
			enemysNode.type = FriendsConstants.ENEMY_TYPE;
			strangerNode = createBranchNode(_friendsDataProvider,FriendsConstants.FRIENDS_TYPE_NAMES[FriendsConstants.STRANGER_TYPE]);
			strangerNode.type = FriendsConstants.STRANGER_TYPE;
			_friendsDataProvider.addItems([myFriendsNode,blacksNode,enemysNode,strangerNode]);
			for each(var p:p_friend_info in _friends){
				addFreindToNode(p);
			}
			sortBranchNode(myFriendsNode);
			sortBranchNode(blacksNode);
			sortBranchNode(enemysNode);
			sortBranchNode(strangerNode);
			
		}
		/**
		 * 添加好友（并根据好友的类型决定添加到对应的节点）
		 */		
		private function addFreindToNode(friend:p_friend_info):void{
			var branchNode:BranchNode = getBranchNode(friend.type);
			if(branchNode){
				createLeafNode(_friendsDataProvider,friend,branchNode);
			}
		}
		/**
		 * 创建支节点
		 */		
		private function createBranchNode(_dataProvider:TreeDataProvider,data:Object=null,parent:BranchNode=null):BranchNode{
			var branchNode:BranchNode = new BranchNode(_dataProvider);
			if(parent){
				parent.addChildNode(branchNode);
			}
			branchNode.data = data;
			return branchNode;
		}
		/**
		 * 创建叶节点
		 */	
		private function createLeafNode(_dataProvider:TreeDataProvider,data:p_friend_info=null,parent:BranchNode=null):LeafNode{
			var leafNode:LeafNode = new LeafNode(_dataProvider);
			if(parent){
//				if(data.is_online){
//					parent.addChildNodeAt(leafNode,0);
//				}else{
					parent.addChildNode(leafNode);
//				}
				parent.data = parent.data;
				invalidateItem(parent);
			}
			leafNode.data = data;
			nodePool[data.roleid] = leafNode;
			return leafNode;
		}
		/**
		 * 获取节点
		 */		
		public function getNode(id:String):TreeNode{
			return nodePool[id];
		}
		/**
		 * 根据好友type获取特定的支节点 
		 */		
		private function getBranchNode(type:int):BranchNode{
			if(type == FriendsConstants.FRIENDS_TYPE){
				return myFriendsNode;
			}else if(type == FriendsConstants.BLACK_TYPE){
				return blacksNode;
			}else if(type == FriendsConstants.ENEMY_TYPE){
				return enemysNode;
			}else if(type == FriendsConstants.STRANGER_TYPE){
				return strangerNode;
			}	
			return null;
		}
		
		/**
		 * 获取特定好友类型ID列表 
		 */		
		public function getFriendIdsByType(type:int):Array{
			if(_friends == null)return null;
			var ids:Array = [];
			for each(var friend:p_friend_info in _friends){
				if(friend.type == type){
					ids.push(friend.roleid);
				}
			}
			return ids;
		}
		/**
		 * 获取节点下的对象 (比上面一种更节省的方法)
		 */		
		public function getIdsByType(type:int):Array{
			var branchNode:BranchNode = getBranchNode(type);
			var ids:Array = [];
			if(branchNode){
				var children:Array = branchNode.children;
				for each(var node:TreeNode in children){
					ids.push(node.data.roleid);
				}
			}
			return ids;
		}
		/**
		 * 获取特定好友类型VO 
		 */		
		public function getFriendsByType(type:int):Array{
			if(_friends == null)return null;
			var friends:Array = [];
			var branch:BranchNode = getBranchNode(type);
			var children:Array = branch.children;
			for each(var node:TreeNode in children){
				friends.push(node.data);
			}
			return friends;
		}
		/**
		 * 添加好友 
		 */		
		public function addFriend(friend:p_friend_info):void{
			if(_friends == null)return;
			var node:LeafNode = nodePool[friend.roleid];
			if(node){
				var oldType:String = node.data.type;
				var friendVO:p_friend_info = getFriendVO(friend.roleid);
				copyValues(friendVO,friend);
				node.removeNode();
				node.data = friendVO;
//				if(node.data.is_online){
//					myFriendsNode.addChildNodeAt(node,0);
//				}else{
					myFriendsNode.addChildNode(node);
//				}
					Dispatch.dispatch(oldType); //通知社会界面更新数据
			}else{
				_friends.push(friend);
				addFreindToNode(friend);
			}
			sortBranchNode(myFriendsNode);
		}
		/**
		 * 添加黑名单 
		 */	
		public function addBlack(friend:p_friend_info):void{
			if(_friends == null)return;
			var node:LeafNode = nodePool[friend.roleid];
			var friendVO:p_friend_info = getFriendVO(friend.roleid);
			var oldType:String = "";
			if(friendVO){
				oldType = friendVO.type.toString();
				copyValues(friendVO,friend);
			}
			if(node){
				node.removeNode();
				node.data = friendVO;
//				if(node.data.is_online){
//					blacksNode.addChildNodeAt(node,0);
//				}else{
					blacksNode.addChildNode(node);
//				}
			}else{
				_friends.push(friend);
				addFreindToNode(friend);
			}
			if(oldType != ""){
				Dispatch.dispatch(oldType); //通知社会界面更新数据
			}
			sortBranchNode(blacksNode);
		}
		/**
		 * 删除好友 
		 */	
		public function deleteFriend(id:int):void{
			if(_friends == null)return;
			var node:LeafNode = nodePool[id] as LeafNode;
			if(node){
				delete nodePool[id];	
				node.removeNode();
			}
			removeFriendVO(id);
			Dispatch.dispatch(node.data.type.toString()); //通知社会界面更新数据
		}
		/**
		 * 设置好友上下线 
		 */		
		public function setOnline(id:int,online:Boolean):void{
			if(_friends == null)return;
			var node:LeafNode = nodePool[id] as LeafNode;
			var friend:p_friend_info = getFriendVO(id);
			if(friend){
				friend.is_online = online;
			}
			if(node){
				var parent:BranchNode = node.parentNode;
				sortBranchNode(parent);
				invalidateItem(parent);
			}
		}
		/**
		 * 改变和好友之间的特殊关系 
		 */		
		public function changeRelative(id:int,relativs:Array):void{
			if(_friends == null)return;
			var friend:p_friend_info = getFriendVO(id);
			friend.relative = relativs;
			var node:LeafNode = nodePool[id] as LeafNode;
			if(node){
				invalidateItem(node);
				sortBranchNode(node.parentNode);
			}
		}
		/**
		 * 改变好友个性签名 
		 */		
		public function changeSign(id:int,sign:String):void{
			if(_friends == null)return;
			var friend:p_friend_info = getFriendVO(id);
			friend.sign = sign;
			var node:LeafNode = nodePool[id] as LeafNode;
			if(node){
				invalidateItem(node);
			}
		}
		/**
		 * 通过Id获取好友VO 
		 */		
		public function getFriendVO(id:int):p_friend_info{
			if(_friends == null)return null;
			for each(var friend:p_friend_info in _friends){
				if(friend.roleid == id){
					return friend;
				}
			}
			return null;
		}
		/**
		 * 通过Id删除好友VO 
		 */	
		public function removeFriendVO(id:int):void{
			if(_friends == null)return;
			for(var i:int=0;i<_friends.length;i++){
				var friend:p_friend_info = _friends[i];
				if(friend.roleid == id){
					_friends.splice(i,1);
					break;
				}
			}
		}
		/**
		 * 根据上下线和关系进行排序
		 */	
		private function sortHandler(obj1:LeafNode,obj2:LeafNode):int{
			var p1:p_friend_info = obj1.data as p_friend_info;
			var p2:p_friend_info = obj2.data as p_friend_info;
			var online1:int = p1.is_online ? 1 : 0;
			var online2:int = p2.is_online ? 1 : 0;
			if(online1 > online2){
				return -1;
			}else if(online1 < online2){
				return 1;
			}else{
				var relative1:int,relative2:int;
				if(p1.relative && p1.relative.length > 0){
					if(p1.relative.length > 1){
						p1.relative.sort();
					}
					relative1 = p1.relative[0];
				}
				if(p2.relative && p2.relative.length > 0){
					if(p2.relative.length > 1){
						p2.relative.sort();
					}
					relative2 = p2.relative[0];
				}
				return compare(relative1,relative2);
			}
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
		/**
		 * 是否是我的好友 
		 */		
		public function isMyFriend(id:int):Boolean{
			if(_friends == null)return false;
			var friend:p_friend_info = getFriendVO(id);
			if(friend){
				return friend.type == FriendsConstants.FRIENDS_TYPE;
			}
			return false;
		}
		/**
		 * 根据名称模糊匹配好友 
		 */		
		public function getFriendsByName(name:String):Array{
			var friends:Array = [];
			name = name.toLowerCase();
			for each(var friend:p_friend_info in _friends){
				if(friend.rolename.toLowerCase().indexOf(name) != -1){
					friends.push(friend);
				}
			}
			return friends;
		}
		/**
		 * 根据名称获取好友 
		 */		
		public function getFriendByName(name:String):p_friend_info{
			for each(var friend:p_friend_info in _friends){
				if(friend.rolename == name){
					return friend;
				}
			}
			return null;
		}
		/**
		 * 好友是否在线 
		 */		
		public function isOnline(friendId:int):Boolean{
			var friend:p_friend_info = getFriendVO(friendId);
			return friend ? friend.is_online : false;
		}
		
		/**
		 * 设置闪烁和解除闪烁(如果节点没有展开就闪烁节点) 
		 */		
		public function setFlick(roleId:int,flick:Boolean):void{
			if(_friends == null)return;
			var friend:p_friend_info = getFriendVO(roleId);
			var node:TreeNode = nodePool[friend.roleid];
			if(node){
				node.flick = flick;
				if(flick){
					flickMap.put(flick,roleId.toString());
				}else{
					flickMap.remove(roleId.toString());
				}
				if(node.isVisible()){
					invalidateItem(node);
				}
				if(!node.parentNode.isOpen()){
					var children:Array = node.parentNode.children;
					var isFlick:Boolean;
					for each(var treeNode:TreeNode in children){
						if(treeNode.flick){
							isFlick = true;
							break;
						}
					}
					node.parentNode.flick = isFlick;
					invalidateItem(node.parentNode);
				}
			}
		}
		/**
		 * 是否还有消息闪烁 
		 */		
		public function hasFlick():Boolean{
			return flickMap.length != 0;
		}
		/**
		 * 是否有好友离线请求 
		 */		
		public function hasRequest():Boolean{
			return offlineRequest ? offlineRequest.length > 0 : false;
		}
		/**
		 *  删除好友请求数据
		 */		
		public function removeFriendRequest(roleName:String):void{
			if(offlineRequest == null || offlineRequest.length == 0)return;
			for(var i:int=0;i<offlineRequest.length;i++){
				var friend:p_simple_friend_info = offlineRequest[i];
				if(friend.rolename == roleName){
					offlineRequest.splice(i,1);
					break;
				}
			}
			Dispatch.dispatch(TabApplications.APPLICATION_UPDATE);
		}
		
		public function set offlineRequest(requests:Array):void{
			_offlineRequest = requests;
		}
		public function get offlineRequest():Array{
			return _offlineRequest;
		}
		
		public function showOfflineRequest():void{
			if(_offlineRequest && _offlineRequest.length > 0){
				//ICON重构				MessageIconManager.showFriendItem();
			}
		}
		
		private function copyValues(source:p_friend_info,target:p_friend_info):void{
			source.roleid = target.roleid;
			source.rolename = target.rolename;
			source.type = target.type;
			source.sex = target.sex;
			source.faction_id = target.faction_id;
			source.level = target.level;
			source.friendly = target.friendly;
			source.is_online = target.is_online;
			source.sign = target.sign;
			source.family_name = target.family_name;
			source.relative = target.relative;
			source.head = target.head;
		}
		
		private function invalidateItem(node:TreeNode):void{
			if(listRenderer && node){
				_friendsDataProvider.invalidateItem(node);
			}
		}
		
		private var needDic:Dictionary = new Dictionary();
		private function sortBranchNode(branchNode:BranchNode):void{
			if((viewRenderer || listRenderer) && branchNode){
				branchNode.children.sort(sortHandler);
				branchNode.sortChildren();
				Dispatch.dispatch(branchNode.type.toString());
			}else{
				needDic[branchNode] = true;
			}
		}
		/**
		 * 好友列表 是否需要渲染 
		 */	
		private var _listRenderer:Boolean = false;
		public function set listRenderer(value:Boolean):void{
			_listRenderer = value;
			if(_listRenderer){
				startRenderer();
			}
		}
		public function get listRenderer():Boolean{
			return _listRenderer;
		}
		/**
		 * 社会界面 是否需要渲染 
		 */		
		private var _viewRenderer:Boolean = false;
		public function set viewRenderer(value:Boolean):void{
			_viewRenderer = value;
			if(_viewRenderer){
				startRenderer();
			}
		}
		public function get viewRenderer():Boolean{
			return _viewRenderer;
		}
		/**
		 * 开始渲染实效的数据排序 
		 */		
		private function startRenderer():void{
			var nodes:Array = [myFriendsNode,blacksNode,enemysNode,strangerNode];
			for each(var node:BranchNode in nodes){
				if(needDic[node]){
					sortBranchNode(node);
					delete needDic[node];
				}
			}
		}
	}
}