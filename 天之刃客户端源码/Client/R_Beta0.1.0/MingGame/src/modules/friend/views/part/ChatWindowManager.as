package modules.friend.views.part
{
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.containers.Panel;
	import com.scene.tile.Hash;
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import modules.broadcast.views.Tips;
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.friend.GroupManager;
	import modules.friend.views.messageBox.MessageBox;
	import modules.friend.views.vo.GroupVO;
	import modules.roleStateG.RoleStateModule;
	
	import proto.line.p_friend_info;

	/**
	 * 聊天窗口管理器 
	 */
	public class ChatWindowManager
	{
		public static const INIT_X:int = 50;
		public static const INIT_Y:int = 50;
		private var chatWindowHash:Hash;
		private var groupWindowHash:Hash;
		private var hasNewMessages:Dictionary;
		private var historyMessages:Dictionary; //与同一个人的近期聊天，只要不刷新、重新登录，都有聊天记录缓存
		public function ChatWindowManager()
		{
			chatWindowHash = new Hash();
			groupWindowHash = new Hash();
			hasNewMessages = new Dictionary();
			historyMessages = new Dictionary();
		}
		
		private static var instance:ChatWindowManager;
		public static function getInstance():ChatWindowManager{
			if(instance == null){
				instance = new ChatWindowManager();
			}
			return instance;
		}
		
		
		/**
		 * 打开私聊 聊天窗口
		 */ 
		public var panel:OneToOnePanel;
		public var isOenByChat:Boolean = false;
		public function openChatWindow(role:p_friend_info,msg:String=""):void{
			if(role.roleid == GlobalObjectManager.getInstance().user.attr.role_id){
				Tips.getInstance().addTipsMsg("不能跟自己聊天!");
				return;
			}
			var item:ChatIconItem = LayerManager.uiLayer.chatwindowBar.getChatIconItem(role.roleid);
			if(item == null){
				panel = chatWindowHash.take(role.roleid.toString()) as OneToOnePanel;
				isOenByChat = true;
				if(panel == null){
					if(!allowOpen())return;
					panel = new OneToOnePanel();
					panel.addEventListener(CloseEvent.CLOSE,onCloseHandler);
					chatWindowHash.put(panel,role.roleid.toString());
					item = LayerManager.uiLayer.chatwindowBar.addWindowItem(role);
					WindowManager.getInstance().popUpWindow(panel,WindowManager.UNREMOVE);
					var messages:Array = historyMessages[role.roleid];
					if(messages){
						for(var i:int=0;i<messages.length;i++){
							panel.appendMessage(messages[i])
						}
					}
					panel.sender = role;
					//为了获取聊天对象更为全面的信息，所以在此处加入后台数据请求，
					FriendsModule.getInstance().getFriendInfoById(role.roleid);
					RoleStateModule.getInstance().lookDetail(role.roleid);
				}
				var hasMessage:Boolean = hasNewMessages[role.roleid];
				if(hasMessage){
					delete hasNewMessages[role.roleid];
					FriendsManager.getInstance().setFlick(role.roleid,false);
					MessageBox.getInstance().removeMessage(role.roleid.toString());
				}
				//panel.sender = role;
				var index:int = item.getIndex();
				panel.x = INIT_X + 20*index;
				panel.y = INIT_Y + 20*index;
				panel.getFocus();
				panel.setTextMessage(msg);
				WindowManager.getInstance().bringToFront(panel);
			}else if(item && item.small){
				item.maximize();
			}
		}
		
		/**
		 * 打开群聊天窗口
		 */		
		public function openGroupWindow(groupInfo:GroupVO,memebers:Array=null):void{
			var item:ChatIconItem = LayerManager.uiLayer.chatwindowBar.getChatIconItem(groupInfo.id);
			if(item == null){
				var panel:OneToManyPanel = groupWindowHash.take(groupInfo.id) as OneToManyPanel;
				if(panel == null){
					if(!allowOpen())return;
					panel = new OneToManyPanel();
					panel.groupInfo = groupInfo;
					panel.groupArray = memebers;
					panel.addEventListener(CloseEvent.CLOSE,onCloseHandler);
					groupWindowHash.put(panel,groupInfo.id);
					item = LayerManager.uiLayer.chatwindowBar.addWindowItem(groupInfo,ChatWindowBar.GROUP);
					WindowManager.getInstance().popUpWindow(panel,WindowManager.UNREMOVE);
					var messages:Array = historyMessages[groupInfo.id];
					if(messages){
						for(var i:int=0;i<messages.length;i++){
							panel.appendMessage(messages[i])
						}
					}
				}
				var hasMessage:Boolean = hasNewMessages[groupInfo.id];
				if(hasMessage){
					delete hasNewMessages[groupInfo.id];
					GroupManager.getInstance().setFlick(groupInfo.id,false);
					MessageBox.getInstance().removeMessage(groupInfo.id,MessageBox.GROUP);
				}
				var index:int = item.getIndex();
				panel.x = INIT_X + 20*index;
				panel.y = INIT_Y + 20*index;
				panel.getFocus();
				WindowManager.getInstance().bringToFront(panel);
			}else if(item && item.small){
				item.maximize();
			}
		}
		
		/**
		 * 处理窗口关闭时间 
		 */		
		private function onCloseHandler(event:CloseEvent):void{
			var panel:DisplayObject = event.currentTarget as DisplayObject;
			WindowManager.getInstance().unLoadWindow(panel);
			var id:String;
			if(panel is OneToOnePanel){
				id = OneToOnePanel(panel).sender.roleid.toString();
				chatWindowHash.remove(id);	
				delete hasNewMessages[id];
			}else if(panel is OneToManyPanel){
				id = OneToManyPanel(panel).groupInfo.id;
				groupWindowHash.remove(id);
			}
			LayerManager.uiLayer.chatwindowBar.removeWindowItem(id);
		}
		/**
		 * 销毁群组窗口聊天 
		 */		
		public function disposeGroupWindow(id:String):void{
			var panel:OneToManyPanel = groupWindowHash.remove(id) as OneToManyPanel;
			if(panel){
				WindowManager.getInstance().unLoadWindow(panel);
				LayerManager.uiLayer.chatwindowBar.removeWindowItem(id);
			}
		}
		
		public function getPrivateWindow(roleId:Object):OneToOnePanel{
			return chatWindowHash.take(roleId.toString()) as OneToOnePanel;
		}
		
		public function getGroupWindow(groupId:Object):OneToManyPanel{
			return groupWindowHash.take(groupId.toString()) as OneToManyPanel;
		}
		
		/**
		 * 缓存消息 
		 */		
		public function addMessage(roleId:Object,msg:String):void{
			var chatWindow:IChatWindow = chatWindowHash.take(roleId.toString()) as IChatWindow;
			if(chatWindow == null){
				chatWindow = groupWindowHash.take(roleId.toString()) as IChatWindow;
			}
			var item:ChatIconItem = LayerManager.uiLayer.chatwindowBar.getChatIconItem(roleId);
			if(chatWindow != null){
				if(item.small){
					item.startFlick();
				}
				chatWindow.appendMessage(msg);
			}else{
				hasNewMessages[roleId] = true;
			}
			addHistory(roleId,msg);
		}
		/**
		 * 缓存到历史记录 
		 */		
		private function addHistory(roleId:Object,msg:String):void{
			var messages:Array = historyMessages[roleId];
			if(messages == null){
				messages = [];
				historyMessages[roleId] = messages;
			}else{
				if(messages.length >= 40){
					messages.splice(0,10);
				}
			}
			messages.push(msg);
		}
		/**
		 * 判断是否有聊天窗口 
		 */		
		public function hasChatWindow(roleId:Object):Boolean{
			var panel:Panel = chatWindowHash.take(roleId.toString()) as Panel;
			if(panel == null){
				panel = groupWindowHash.take(roleId.toString()) as Panel;
			}
			return panel != null;
		}
		/**
		 * 窗口是否已经打开 
		 */		
		public function isPopUp(roleId:Object):Boolean{
			var panel:Panel = chatWindowHash.take(roleId.toString()) as Panel;
			if(panel == null){
				panel = groupWindowHash.take(roleId.toString()) as Panel;
			}
			if(panel){
				return true;
			}
			return false;
		}
		/**
		 * 是否再允许打开窗口 
		 */		
		public function allowOpen():Boolean{
			var priCount:int = chatWindowHash.length;
			var groupCount:int = groupWindowHash.length;
			if(priCount + groupCount == 5){
				Tips.getInstance().addTipsMsg("最多只能同时打开5个聊天窗口！");
				return false;
			}
			return true
		}
		/**
		 * 获取当前窗口数量
		 */	
		public function get windowCount():int{
			var priCount:int = chatWindowHash.length;
			var groupCount:int = groupWindowHash.length;
			return priCount + groupCount;
		}
	}
}