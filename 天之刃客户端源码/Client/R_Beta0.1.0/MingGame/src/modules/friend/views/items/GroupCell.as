package modules.friend.views.items
{
	import com.common.effect.FlickerEffect;
	import com.globals.GameConfig;
	import com.ming.ui.containers.treeList.ICellRenderer;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	import modules.friend.views.vo.GroupVO;
	
	public class GroupCell extends UIComponent implements ICellRenderer
	{
		private var groupIcon:Image;
		private var nameText:TextField;
		public function GroupCell()
		{
			groupIcon = new Image();
			groupIcon.source = GameConfig.ROOT_URL + "com/assets/friend/group.png";
			groupIcon.width = 20;
			groupIcon.height = 20;
			groupIcon.x = 5;
			groupIcon.y = 2;
			addChild(groupIcon);
	
			nameText = ComponentUtil.createTextField("",40,2,null,140,22,this);
			mouseChildren = false;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			var treeNode:TreeNode = value as TreeNode;
			var groupVO:GroupVO = treeNode.data as GroupVO;
			if(treeNode.nodeType == TreeNode.BRANCH_NODE){
				nameText.text = groupVO.name;
				updateFlick(nameText);
				if(!data.flick){
					nameText.visible = true;
				}
			}
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
	}
}