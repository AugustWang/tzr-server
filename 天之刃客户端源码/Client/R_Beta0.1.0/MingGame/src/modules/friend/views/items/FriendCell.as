package modules.friend.views.items
{
	import com.common.FilterCommon;
	import com.common.GameConstant;
	import com.common.effect.FlickerEffect;
	import com.globals.GameConfig;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.ICellRenderer;
	import com.ming.ui.containers.treeList.LeafNode;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	
	import modules.friend.FriendsConstants;
	
	import proto.line.p_friend_info;
	
	public class FriendCell extends UIComponent implements ICellRenderer
	{
		private var icon:Bitmap;
		private var head:Image;
		private var nameText:TextField;
		public function FriendCell()
		{
			icon = Style.getBitmap(GameConfig.T1_VIEWUI,"icon_open");
			icon.x = 5;
			icon.y = 4;
			addChild(icon);

			head = new Image();
			head.width = 20;
			head.height = 20;
			head.x = 15;
			head.y = 2;
			addChild(head);
			
			nameText = ComponentUtil.createTextField("",50,2,null,140,22,this);
			nameText.filters = FilterCommon.FONT_BLACK_FILTERS;
			mouseChildren = false;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			var treeNode:TreeNode = value as TreeNode;
			var friendVO:p_friend_info = treeNode.data as p_friend_info;
			if(treeNode.nodeType == TreeNode.BRANCH_NODE){
				if (treeNode.isOpen()) {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_close");
				} else {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_open");
				}
				nameText.x = 25;
				nameText.text = treeNode.data+calculateOnline();
				if(BranchNode(treeNode).isOpen()){
					treeNode.flick = false;	
				}else{
					var b:BranchNode = treeNode as BranchNode;
					for each(var node:TreeNode in b.children){
						if(node.flick){
							b.flick = true;
							break;
						}
					}
				}
				updateFlick(nameText);
				if(treeNode.flick == false){
					nameText.visible = true;
				}
				head.visible = false;
			   	showToolTip = false;
			}else if(treeNode.nodeType == TreeNode.LEAF_NODE){
				icon.bitmapData = null;
				head.visible = true;
				head.source = GameConstant.getHeadImage(friendVO.head);
				nameText.x = 50;
				var html:String = friendVO.rolename;
				if(friendVO.relative && friendVO.relative.length > 0){
					if(friendVO.relative.length > 1){
						friendVO.relative.sort();
					}
					html += HtmlUtil.font("("+FriendsConstants.RELATIVES_NAMES[friendVO.relative[friendVO.relative.length-1]]+")","#ffff00");
				}
				nameText.htmlText = html;
				updateFlick(head);
				if(friendVO.sign && friendVO.sign != ""){
					setToolTip(friendVO.sign);
				}
			}
			setOnline();
		}
		
		private var _selected:Boolean;
		public function set selected(value:Boolean):void{
			_selected = value;
		}
		
		public function get selected():Boolean
		{
			return false;
		}
	
		private var flickEffect:FlickerEffect;
		private function updateFlick(target:DisplayObject):void{
			if(data.flick){
				if(flickEffect == null){
					flickEffect = new FlickerEffect();
				}
				flickEffect.start(target);
			}else if(flickEffect){
				flickEffect.stop();
			}
		}
		
		private function setOnline():void{
			var treeNode:TreeNode = data as TreeNode;
			if(treeNode.nodeType == TreeNode.LEAF_NODE){
				if(treeNode.data.is_online == false){
					filters = [ new ColorMatrixFilter([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0])];
				}else{
					filters = [];
				}
			}else{
				filters = [];
			}
		}
		
		private function calculateOnline():String{
			var branch:BranchNode = data as BranchNode;
			if(branch){
				var onlineCount:int = 0;
				for each(var node:LeafNode in branch.children){
					if(node.data.is_online){
						onlineCount++;
					}
				}
				return " ["+onlineCount+"/"+branch.children.length+"]";
			}
			return "";
		}
	}
}