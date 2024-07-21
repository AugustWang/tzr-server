package com.ming.ui.containers.treeList
{
	/**
	 * 根节点继承自叶节点 
	 */	
	dynamic public class RootNode extends BranchNode
	{
		public function RootNode(dataProvider:TreeDataProvider){
			super(dataProvider);
			_nodeLevel = -1;
			_nodeType = TreeNode.ROOT_NODE;
			_nodeState = TreeNode.OPEN;
		}
		
		override public function addChildNodeAt(node:TreeNode, index:int) : void{
			_children[index] = node;
			node.parentNode = this;
			node.nodeLevel = this.nodeLevel + 1;
			node.drawNode();
		}
		
		override public function hideNode() : void{

		}
		
		override public function set nodeLevel(level:int) : void{
			
		}
		
		override public function drawNode() : void{
			for each (var node:TreeNode in _children){
				node.drawNode();
			}
		}
	}
}