package modules.friend.views.items {
	import com.common.Constant;
	import com.common.GameConstant;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.friend.OpenItemsManager;
	import modules.roleStateG.PlayerConstant;
	
	import proto.line.p_friend_info;

	public class EnemyItemRender extends Sprite implements IDataRenderer {
		protected var image:Image;
		protected var nameText:TextField;
		protected var nationText:TextField;
		protected var familyText:TextField;
		protected var levelText:TextField;

		protected var textFormat:TextFormat;

		public static var ItemHeight:Number = 25;

		public function EnemyItemRender() {
			image = new Image();
			image.width = 25;
			image.height = 25;
			addChild(image);

			textFormat = Constant.TEXTFORMAT_DEFAULT;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.color = 0xffff00;
			nameText = ComponentUtil.buildTextField("", Constant.TEXTFORMAT_DEFAULT, 125, ItemHeight, this);
			nameText.y = 2;
			nameText.mouseEnabled = true;
			nameText.addEventListener(TextEvent.LINK, onNameLink);

			levelText = ComponentUtil.buildTextField("", textFormat, 94, ItemHeight, this);
			levelText.y = 2;
			levelText.x = 125;

			nationText = ComponentUtil.buildTextField("", textFormat, 100, ItemHeight, this);
			nationText.y = 2;
			nationText.x = 219;

			familyText = ComponentUtil.buildTextField("", textFormat, 111, ItemHeight, this);
			familyText.y = 2;
			familyText.x = 319;
		}

		private function onNameLink(event:TextEvent):void {
			var friend:p_friend_info = data as p_friend_info;
			if (friend != null) {
				OpenItemsManager.getInstance().openFriendItems(friend);
			}
		}

		protected var _data:Object;

		public function set data(value:Object):void {
			_data = value;
			var friend:p_friend_info = value as p_friend_info;
			if (friend != null) {
				image.source = GameConstant.getHeadImage(friend.head);
				nameText.htmlText = HtmlUtil.link(friend.rolename);
				levelText.text = friend.level.toString();
				nationText.text = GameConstant.getNation(friend.faction_id);
				familyText.text = friend.family_name;
				if (friend.is_online)
					filters = [];
				else
					filters = [new ColorMatrixFilter([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0])];
			}
		}

		public function get data():Object {
			return _data;
		}
	}
}