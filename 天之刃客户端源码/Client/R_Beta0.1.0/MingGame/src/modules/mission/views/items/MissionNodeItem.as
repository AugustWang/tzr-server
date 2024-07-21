package modules.mission.views.items {
	import com.common.Constant;
	import com.common.FilterCommon;
	import com.globals.GameConfig;
	import com.ming.ui.containers.treeList.ICellRenderer;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import modules.mission.MissionDataManager;

	public class MissionNodeItem extends UIComponent implements ICellRenderer {
		private var icon:Bitmap;
		private var nameText:TextField;

		public function MissionNodeItem() {
			icon = Style.getBitmap(GameConfig.T1_VIEWUI,"icon_open");
			icon.x = 5;
			icon.y = 2;
			addChild(icon);

			nameText = ComponentUtil.createTextField("", 50, 0, null, 140, 22, this);
			nameText.filters = FilterCommon.FONT_BLACK_FILTERS;
			mouseChildren = false;
		}

		override public function set data(value:Object):void {
			super.data = value;
			var treeNode:TreeNode = value as TreeNode;
			var missionVO:Object = treeNode.data;
			if (treeNode.nodeType == TreeNode.BRANCH_NODE) {
				if (treeNode.isOpen()) {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_close");
				} else {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_open");
				}
				nameText.x = 25;
				nameText.text = missionVO.toString();
			} else if (treeNode.nodeType == TreeNode.LEAF_NODE) {
				icon.bitmapData = null;
				nameText.x = 35;
				var html:String = missionVO.name;
				nameText.htmlText = HtmlUtil.font(html,"#ffff00");
			}
		}

		private var _selected:Boolean;

		public function set selected(value:Boolean):void {
			_selected = value;
		}

		public function get selected():Boolean {
			return false;
		}
	}
}