package modules.market.item
{
	import com.ming.ui.containers.treeList.ICellRenderer;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.globals.GameConfig;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import modules.market.MarketModule;
	
	public class TreeItem extends UIComponent implements ICellRenderer
	{
		private var icon:Bitmap;
		private var openIcon:Sprite;
		private var closeIcon:Sprite;
		private var nameText:TextField;
		
		public function TreeItem()
		{
			super();
			icon = Style.getBitmap(GameConfig.T1_VIEWUI,"icon_open");
			icon.x = 5;
			icon.y = 8;
			addChild(icon);
			
			nameText = ComponentUtil.createTextField("", 50, 5, null, 120, 22, this);
			mouseChildren = false;
		}
		
		//保存，为了节省查找的消耗
		private var link_text:String;
		override public function set data(value:Object):void {
			super.data = value;
			var treeNode:TreeNode = value as TreeNode;
			if (treeNode.nodeType == TreeNode.BRANCH_NODE) {
				if (treeNode.isOpen()) {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_close");
				} else {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_open");
				}
				nameText.x = 23;
				link_text = treeNode.data.name;
				nameText.htmlText = name;
			} else if (treeNode.nodeType == TreeNode.LEAF_NODE) {
				icon.bitmapData = null;
				nameText.x = 33;
				link_text = (value.data as XML).@name;
				nameText.htmlText = name;
			}
		}
		
		//是否被select
		private var isSelected:Boolean;
		public function set selected(value:Boolean):void
		{
			isSelected = value;
			if(isSelected == true){
				nameText.htmlText = "<font color='#FFFF00'>"+link_text+"</font>";
			}else {
				nameText.htmlText = link_text;
			}
		}
		
		public function get selected():Boolean
		{
			return isSelected;
		}
	}
}