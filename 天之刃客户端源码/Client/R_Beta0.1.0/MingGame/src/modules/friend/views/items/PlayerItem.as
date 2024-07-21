package modules.friend.views.items {
	import com.common.GameConstant;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	
	import modules.friend.views.vo.GroupItemVO;

	public class PlayerItem extends Sprite implements IDataRenderer {
		private var text:TextField;
		private var head:Image;

		public function PlayerItem():void {
			head = new Image;
			head.width = 20;
			head.height = 20;
			head.y = 1;
			head.x = 5;
			addChild(head);
			text = ComponentUtil.createTextField("", 40, 2, null, 140, 22, this);
			mouseChildren = false;
		}

		private var _data:Object;

		public function get data():Object {
			return _data;
		}

		public function set data(value:Object):void {
			_data = value;
			var role:GroupItemVO = _data as GroupItemVO;
			text.text = role.roleName;
			head.source = GameConstant.getHeadImage(role.head);
			setOnline(role.online);
		}

		private function setOnline(online:Boolean):void {
			if (online == false) {
				filters = [new ColorMatrixFilter([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0])];
			} else {
				filters = [];
			}
		}
	}
}