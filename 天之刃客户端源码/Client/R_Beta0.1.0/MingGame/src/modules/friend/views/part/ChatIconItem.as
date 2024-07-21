package modules.friend.views.part {
	import com.common.GameConstant;
	import com.common.effect.FlickerEffect;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.friend.views.vo.GroupVO;
	
	import proto.line.p_friend_info;

	public class ChatIconItem extends UIComponent {

		private var img:Image;
		public var type:String;

		public function ChatIconItem() {		
			buttonMode = useHandCursor = true;
			var boxBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			addChild(boxBg);

			img = new Image();
			img.x = img.y = 4;
			img.width = img.height = 34;
			addChild(img);

			width = 40;
			height = 40;
			mouseChildren = false;
			useHandCursor = buttonMode = true;
			addEventListener(MouseEvent.CLICK, openChatWindow);
		}

		private var _chatInfo:Object;

		public function set chatInfo(value:Object):void {
			_chatInfo = value;
			if (type == ChatWindowBar.PRIVATE) {
				var friendInfo:p_friend_info = _chatInfo as p_friend_info;
				//				if(friendInfo.head > 0){
				//					img.source = GameConstant.getHeadImage(friendInfo.head);
				//				}
				setToolTip("点击和" + friendInfo.rolename + "聊天", 0);
			} else {
				var groupInfo:GroupVO = _chatInfo as GroupVO;
				img.source = GameConfig.ROOT_URL + "com/assets/friend/group.png";
				setToolTip("点击进入" + groupInfo.name + "群聊天", 0);
			}
			showToolTip = false;
		}

		public function updateChatInfo(value:Object):void {
			_chatInfo = value;
			if (type == ChatWindowBar.PRIVATE) {
				var friendInfo:p_friend_info = _chatInfo as p_friend_info;
				if (friendInfo.head > 0) {
					img.source = GameConstant.getHeadImage(friendInfo.head);
				}
				setToolTip("点击和" + friendInfo.rolename + "聊天", 0);
			}
			showToolTip = false;
		}

		private var _small:Boolean = false;

		public function set small(value:Boolean):void {
			_small = value;
			showToolTip = value;
		}

		private var flick:FlickerEffect;

		public function startFlick():void {
			if (flick == null) {
				flick = new FlickerEffect();
			}
			if (!flick.running()) {
				flick.start(img);
			}
		}

		public function stopFlick():void {
			if (flick) {
				flick.stop();
			}
			img.visible = true;
		}

		public function get small():Boolean {
			return _small;
		}

		private function openChatWindow(event:MouseEvent):void {
			if (small) {
				stopFlick();
				maximize();
			} else {
				var panel:IChatWindow = getPanel();
				panel.minResize();
			}
		}

		public function maximize():void {
			var panel:IChatWindow = getPanel();
			if (panel) {
				var index:int = getIndex();
				var newX:Number = ChatWindowManager.INIT_X + index * 20;
				var newY:Number = ChatWindowManager.INIT_Y + index * 20;
				small = false;
				panel.maxReisze(newX, newY);
			}
		}

		public function getIndex():int {
			return parent ? parent.getChildIndex(this) : 0;
		}

		private function getPanel():IChatWindow {
			var panel:IChatWindow;
			if (type == ChatWindowBar.PRIVATE) {
				panel = ChatWindowManager.getInstance().getPrivateWindow(_chatInfo.roleid) as IChatWindow;
			} else {
				panel = ChatWindowManager.getInstance().getGroupWindow(_chatInfo.id) as IChatWindow;
			}
			return panel;
		}
	}
}