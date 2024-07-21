package modules.friend.views.items {
	import com.common.GameConstant;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	
	import proto.line.p_friend_info;

	public class SearchFriendItem extends UIComponent {
		private var _roleName:TextField;
		private var _headImage:Image;

		public function SearchFriendItem() {
			init();
		}

		private function init():void {
			_headImage = new Image();
			_headImage.x = 10;
			_headImage.width = 22;
			_headImage.height = 22;
			addChild(_headImage);

			_roleName = ComponentUtil.createTextField("", 50, 3, null, 100, 25, this);
		}

		override public function set data(value:Object):void {
			super.data = value;
			var friendInfo:p_friend_info = data as p_friend_info;
			if (friendInfo) {
				_headImage.source = GameConstant.getHeadImage(friendInfo.head);
				;
				if (friendInfo.is_online) {
					filters = [];
				} else {
					filters = [new ColorMatrixFilter([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0])];
				}
				_roleName.text = friendInfo.rolename;
			}
		}
	}
}