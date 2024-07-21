package modules.friend.views.items {
	import com.common.Constant;
	import com.common.GameConstant;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.friend.FriendsManager;
	import modules.friend.FriendsModule;
	import modules.roleStateG.PlayerConstant;
	
	import proto.line.p_simple_friend_info;

	public class FriendApplicationsItemRender extends Sprite implements IDataRenderer {
		protected var image:Image;
		protected var nameText:TextField;
		protected var nationText:TextField;
		protected var levelText:TextField;
		protected var textFormat:TextFormat;
		protected var allowText:TextField
		public var textColor:uint = 0x99FF00;
		public var linkColor:uint = 0x99FF00;
		public var hoverColor:uint = 0xffff00
		public static var ItemHeight:Number = 25;

		public function FriendApplicationsItemRender() {
			super()

			image = new Image();
			image.width = 25;
			image.height = 25;
			addChild(image);
			textFormat = new TextFormat
			textFormat = Constant.TEXTFORMAT_DEFAULT;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.color = 0xffff00;
			nameText = ComponentUtil.buildTextField("", Constant.TEXTFORMAT_DEFAULT, 100, ItemHeight, this);
			nameText.y = 2;
			nameText.x = 27;

			nationText = ComponentUtil.buildTextField("", textFormat, 80, ItemHeight, this);
			nationText.y = 2;
			nationText.x = 125;

			levelText = ComponentUtil.buildTextField("", textFormat, 100, ItemHeight, this);
			levelText.y = 2;
			levelText.x = 225

			allowText = ComponentUtil.buildTextField("", textFormat, 126, ItemHeight, this);
			allowText.y = 2;
			allowText.x = 355
			allowText.mouseEnabled = true

			var css:StyleSheet = new StyleSheet();
			css.parseCSS("font {color: #" + textColor.toString(16) + "} a {color: #" + linkColor.toString(16) + ";} a:hover {text-decoration: underline; color: #" + hoverColor.toString(16) + ";}");
			allowText.styleSheet = css;
			allowText.addEventListener(TextEvent.LINK, linkclickFunc)
		}

		private function linkclickFunc(e:TextEvent):void {
			var friend:p_simple_friend_info = data as p_simple_friend_info;
			if (e.text == 'yes') {
				FriendsModule.getInstance().acceptFriend(friend.rolename);
			} else {
				FriendsModule.getInstance().refuseFriend(friend.rolename);
			}
			FriendsManager.getInstance().removeFriendRequest(friend.rolename);
		}

		private var _data:Object

		public function set data(value:Object):void {
			_data = value;
			var friend:p_simple_friend_info = value as p_simple_friend_info;
			if (friend != null) {
				image.source = GameConstant.getHeadImage(friend.head);
				nameText.htmlText = '<P align="center"> ' + friend.rolename + '</P>';
				nationText.htmlText = '<P align="center"> ' + GameConstant.getNation(friend.faction_id) + '</P>';
				levelText.htmlText = '<P align="center"> ' + friend.level.toString()

				allowText.htmlText = '<P align="center"><FONT COLOR="#99FF00"><A  href="event:yes">同意</A> / <A  href="event:no">拒绝</A></FONT></P>'
				allowText.y = 2;
				allowText.x = 310;
			}
		}


		public function get data():Object {
			return _data;
		}
	}
}