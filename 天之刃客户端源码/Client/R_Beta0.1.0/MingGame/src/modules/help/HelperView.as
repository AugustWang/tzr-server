package modules.help
{
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.LeafNode;
	import com.ming.ui.containers.treeList.Tree;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import modules.help.itemrender.HelpItem;
	
	public class HelperView extends UIComponent
	{
		private var _tree:Tree;
		//tree格式数据源
		private var _friendsDataProvider:TreeDataProvider;
		//xml格式的数据源
		private var _xml:XML;
		//info面板
		private var _helpInfo:InfoView;
		
		public function HelperView()
		{
			super();
			initUI();
		}
		
		private function initUI():void
		{
			var bgBorder:UIComponent = new UIComponent();
//			Style.setBorderSkin(bgBorder);
			Style.setNewBorderBgSkin(bgBorder);
			bgBorder.x = 3;
			bgBorder.y = 3;
			bgBorder.width = 525;
			bgBorder.height = 315;
			bgBorder.mouseChildren = false;
			bgBorder.mouseEnabled = false
			addChild(bgBorder);
			
//			var left:Sprite = Style.getBlackSprite(200, 320, 3);
			var left:Sprite=new Sprite();
			// TODO Auto Generated method stub
			_tree = new Tree();
			_tree.x=3;
			_tree.y = 5;
			_tree.width = 200;
			_tree.height = 310;
			_tree.cellRenderer = HelpItem;
			_tree.verticalScrollPolicy = ScrollPolicy.ON;
			_tree.addEventListener(ItemEvent.ITEM_CHANGE, onItemChanged);
			addChild(_tree);
			
//			var right:Sprite = Style.getBlackSprite(320, 320, 3);
			var right:Sprite=new Sprite();
			right.x = _tree.x + _tree.width + 1;
			bgBorder.addChild(left);
			bgBorder.addChild(right);
			
			_helpInfo = new InfoView();
			_helpInfo.verticalScrollPolicy = ScrollPolicy.AUTO;
			_helpInfo.x = _tree.x + _tree.width + 5;
			_helpInfo.y = _tree.y;
			addChild(_helpInfo);
		}
		
		//上一个被点击的render
		private var lastRender:HelpItem = null;
		protected function onItemChanged(event:ItemEvent):void
		{
			// TODO Auto-generated method stub
			var node:TreeNode = event.selectItem as TreeNode;
			if (node.nodeType == TreeNode.LEAF_NODE) {
				_helpInfo.dataXML = node.data;
			}
		}
		
		/**
		 * 数据类型转换
		 * @param xml
		 * 
		 */		
		public function setData(xml:XML):void{
			_xml = xml;
			var category_length:int = _xml.category.length();
			_friendsDataProvider = new TreeDataProvider(); 
			for(var i:int=0;i<category_length;i++){
				var title:String = _xml.category[i].@title;
				var parent:BranchNode = createBranchNode(_friendsDataProvider,title);
				_friendsDataProvider.addItem(parent);
				//插入子对象
				var subject_length:int = _xml.category[i].subject.length();
				for(var j:int=0;j<subject_length;j++){
					var data:XML = _xml.category[i].subject[j];
					var child:LeafNode = createLeafNode(_friendsDataProvider,data,parent);
				}
			}
			_tree.dataProvider = _friendsDataProvider;
		}
		
		/**
		 * 创建支节点
		 */		
		private function createBranchNode(_dataProvider:TreeDataProvider,data:Object=null,parent:BranchNode=null):BranchNode{
			var branchNode:BranchNode = new BranchNode(_dataProvider);
			if(parent){
				parent.addChildNode(branchNode);
			}
			branchNode.data = data;
			return branchNode;
		}
		/**
		 * 创建叶节点
		 */	
		private function createLeafNode(_dataProvider:TreeDataProvider,data:XML=null,parent:BranchNode=null):LeafNode{
			var leafNode:LeafNode = new LeafNode(_dataProvider);
			if(parent){
				//				if(data.is_online){
				//					parent.addChildNodeAt(leafNode,0);
				//				}else{
				parent.addChildNode(leafNode);
				//				}
				parent.data = parent.data;
				invalidateItem(parent);
			}
			leafNode.data = data;
			return leafNode;
		}
		
		/**
		 *更新
		 */		
		private function invalidateItem(node:TreeNode):void{
			if(node){
				_friendsDataProvider.invalidateItem(node);
			}
		}
	}
}
