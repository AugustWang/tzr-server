package modules.help.itemrender
{
	import com.globals.GameConfig;
	import com.ming.ui.containers.treeList.ICellRenderer;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class HelpItem extends UIComponent implements ICellRenderer
	{
		private var icon:Bitmap;
		private var nameText:TextField;
		
		public function HelpItem()
		{
			super();
			icon = Style.getBitmap(GameConfig.T1_VIEWUI,"icon_open");
			icon.x = 5;
			icon.y = 4;
			addChild(icon);
			
			nameText = ComponentUtil.createTextField("", 50, 2, null, 160, 22, this);
			mouseChildren = false;
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			var treeNode:TreeNode = value as TreeNode;
			if (treeNode.nodeType == TreeNode.BRANCH_NODE) {
				if (treeNode.isOpen()) {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_close");
				} else {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_open");
				}
				nameText.x = 15;
				link_text = treeNode.data.toString();
				nameText.htmlText = name;
			} else if (treeNode.nodeType == TreeNode.LEAF_NODE) {
				icon.bitmapData = null;
				nameText.x = 25;
				link_text = (value.data as XML).@question;
				nameText.htmlText = name;
			}
		}
		//保存，为了节省查找的消耗
		private var link_text:String;
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