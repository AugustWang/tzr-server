package modules.friend.views.messageBox {

	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;

	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import modules.ModuleCommand;
	import modules.friend.GroupManager;
	import modules.friend.views.part.ChatWindowManager;
	import modules.friend.views.vo.GroupVO;

	import proto.line.p_friend_info;

	public class MessageBox extends UIComponent {
		public static const PRIVATE:String="private";
		public static const GROUP:String="group";

		private var title:TextField;
		private var list:List;
		private var dataProvider:Array;
		private var queue:Array;
		private var timeOut:int;

		public function MessageBox() {
			super();

			this.width=178;
			this.height=80;
			this.bgSkin=Style.getSkin("tipBgSkinSmall", GameConfig.T1_UI, new Rectangle(30, 20, 118, 30));
			var tf:TextFormat=Style.textFormat;
			tf.bold=true;
			title=ComponentUtil.createTextField("消息盒子", 5, 1, tf, 100, 25, this);

			dataProvider=[];

			list=new List();
			list.bgSkin=null;
			list.itemRenderer=MessageBoxItem;
			list.setSelectItemSkin(null);
			list.x=5;
			list.y=30;
			list.itemHeight=20;
			list.width=168;
			list.dataProvider=dataProvider;
			list.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			addChild(list);

			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);

		}

		private static var instance:MessageBox;

		public static function getInstance():MessageBox {
			if (instance == null) {
				instance=new MessageBox();
			}
			return instance;
		}

		private function onRollOver(event:MouseEvent):void {
			clearTimeout(timeOut);
		}

		private function onRollOut(event:MouseEvent):void {
			hide();
		}

		public function show():void {
			clearTimeout(timeOut);
			LayerManager.main.addChild(this);
			x=GlobalObjectManager.GAME_WIDTH * 0.5 + 178;
			y=GlobalObjectManager.GAME_HEIGHT - height - 50;
		}

		public function hide():void {
			timeOut=setTimeout(close, 500);
		}

		private function close():void {
			if (parent) {
				parent.removeChild(this);
			}
		}

		public function addMessage(messageInfo:Object, type:String=PRIVATE):void {
			var id:String=type == PRIVATE ? messageInfo.roleid : messageInfo.id;
			var obj:Object=getMessageById(id, type);
			if (obj) {
				obj.messageInfo=messageInfo;
				obj.count+=1;
				list.refreshItem(obj);
			} else {
				obj={messageInfo: messageInfo, type: type};
				obj.count=1;
				if (dataProvider.length < 5) {
					dataProvider.push(obj);
					list.height=list.itemHeight * dataProvider.length;
					list.invalidateList();
					list.validateNow();
					updateSize();
				} else {
					if (queue == null) {
						queue=[];
					}
					queue.push(obj);
				}
			}
			flickNavBarIcon();
		}


		private function flickNavBarIcon():void {
			if (dataProvider.length > 0) {
				Dispatch.dispatch(ModuleCommand.FRIEND_FLICK);
			} else {
				Dispatch.dispatch(ModuleCommand.FRIEND_STOP_FLICK);
			}
			var queueCount:int=queue ? queue.length : 0;
			var totalCount:int=queueCount + dataProvider.length;
			if (totalCount > 0) {
				title.text="消息盒子(" + totalCount + ")";
			}
		}

		public function removeMessage(id:String, type:String=PRIVATE):void {
			var size:int=dataProvider.length;
			for (var i:int=0; i < size; i++) {
				var obj:Object=dataProvider[i];
				if (type == obj.type) {
					if (type == PRIVATE && obj.messageInfo.roleid == id) {
						dataProvider.splice(i, 1);
						break;
					} else if (type == GROUP && obj.messageInfo.id == id) {
						dataProvider.splice(i, 1);
						break;
					}
				}
			}
			if (queue && queue.length > 0) {
				dataProvider.push(queue.shift());
			}
			var count:int=dataProvider.length;
			if (count > 0) {
				list.height=list.itemHeight * dataProvider.length;
				list.invalidateList();
				list.validateNow();
				updateSize();
			} else if (count == 0) {
				close();
			}
			flickNavBarIcon();
		}

		private function getMessageById(id:String, type:String):Object {
			for each (var obj:Object in dataProvider) {
				if (type == obj.type) {
					if (type == PRIVATE && obj.messageInfo.roleid == id) {
						return obj;
					} else if (type == GROUP && obj.messageInfo.id == id) {
						return obj;
					}
				}
			}
			return null;
		}


		private function updateSize():void {
			height=list.height + 40;
			validateNow();
			x=GlobalObjectManager.GAME_WIDTH * 0.5 + 178;
			y=GlobalObjectManager.GAME_HEIGHT - height - 50;
		}

		private function onItemClick(event:ItemEvent):void {
			if (!event.selectItem["cancel"]) {
				if (event.selectItem.type == PRIVATE) {
					ChatWindowManager.getInstance().openChatWindow(event.selectItem.messageInfo as p_friend_info);
				} else if (event.selectItem.type == GROUP) {
					var groupInfo:GroupVO=event.selectItem.messageInfo as GroupVO;
					GroupManager.getInstance().initGroup(groupInfo);
					var memebers:Array=GroupManager.getInstance().getMemebers(groupInfo.id);
					ChatWindowManager.getInstance().openGroupWindow(groupInfo, memebers);
				}
			}
		}
	}
}