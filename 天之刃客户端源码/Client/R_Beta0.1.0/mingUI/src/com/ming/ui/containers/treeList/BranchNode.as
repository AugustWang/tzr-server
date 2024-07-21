package com.ming.ui.containers.treeList
{
	dynamic public class BranchNode extends TreeNode
	{
		protected var _nodeState:String;
		protected var _children:Array;
		
		public function BranchNode(_dataProvider:TreeDataProvider){
			super(_dataProvider);
			_nodeType = TreeNode.BRANCH_NODE;
			_nodeState = TreeNode.CLOSE;
			_children = [];
		}
		/**
		 * 展开所有节点
		 */		
		public function openAllChildren() : void{
			openNode();
			for each(var node:TreeNode in _children){
				if(node is BranchNode){
					node.openAllChildren();
				}
			}
		}
		
		override public function drawNode() : void{
			var totalCount:int;
			var index:int;
			if (_dataProvider.getItemIndex(this) == -1 && isVisible()){
				var currentIndex:int = _parentNode.children.indexOf(this);
				while (index < currentIndex){
					totalCount = totalCount + _parentNode.children[index].getVisibleSize();
					index++;
				}
				if(_parentNode is RootNode){
					if (_dataProvider.length > 0){
						_dataProvider.addItemAt(this, totalCount);
					}
					else{
						_dataProvider.addItem(this);
					}
				}
				else{
					var targetIndex:int = _dataProvider.getItemIndex(_parentNode);
					_dataProvider.addItemAt(this, targetIndex + index + 1);
				}
				if (isOpen()){
					for each (var node:TreeNode in _children){
						node.drawNode();
					}
				}
			}
		}
		
		public function sortChildren():void{
			if (isOpen() && isVisible()){
				for(var i:int=0;i<children.length;i++){
					var node:TreeNode = children[i] as TreeNode;
					removeChild(node);
					addChildNodeAt(node,i);
				}
			}	
		}
		
		public function closeAllChildren() : void{
			closeNode();
			for each(var node:TreeNode in _children){
				if(node is BranchNode){
					node.closeAllChildren();
				}
			}
		}
		
		public function addChildNodeAt(node:TreeNode, index:int) : void{
			_children.splice(index,0,node);
			node.parentNode = this;
			node.nodeLevel = this.nodeLevel + 1;
			if (isOpen() && isVisible()){
				var dataIndex:int = getDataProviderIndex(index);
				_dataProvider.addItemAt(node,dataIndex);
				node.drawNode();
			}
		}
		
		override public function hideNode() : void{
			if (_dataProvider.getItemIndex(this) != -1 && !isVisible()){
				_dataProvider.removeItem(this);
				for each (var node:TreeNode in _children){
					node.hideNode();
				}
			}
		}
		
		public function openNode() : void{
			_nodeState = TreeNode.OPEN;
			for each (var node:TreeNode in _children){
				node.drawNode();
			}
			_dataProvider.invalidateItem(this);
		}
		
		public function get nodeState() : String{
			return _nodeState;
		}
		
		public function isOpen() : Boolean{
			return _nodeState == TreeNode.OPEN;
		}
		
		public function addChildNode(node:TreeNode) : void{
			addChildNodeAt(node, _children.length);
		}
		
		public function checkForValue(put:String, value:String) : TreeNode{
			var node:TreeNode;
			var targetNode:TreeNode;
			if (this[put] == value){
				return this;
			}
			for each (node in _children){
				targetNode = node.checkForValue(put, value);
				if (targetNode != null){
					return targetNode;
				}
			}
			return null;
		}
		
		public function removeChild(node:TreeNode) : TreeNode{
			var index:int = _children.indexOf(node);
			if (index >= 0){
				node.hideNode();
				_children.splice(index, 1);
				if (isOpen() && isVisible()){
					_dataProvider.removeItem(node);
				}
				return node;
			}
			return null;
		}
		
		public function closeNode() : void{
			_nodeState = TreeNode.CLOSE;
			for each (var node:TreeNode in _children){
				node.hideNode();
			}
			_dataProvider.invalidateItem(this);
		}
				
		public function getVisibleSize() : int{
			var count:int;
			if (!this.isVisible()){
				return 0;
			}
			if (!this.isOpen()){
				return 1;
			}
			for each (var node:TreeNode in _children){	
				if (node is LeafNode || !node.isOpen()){
					count = count + 1;
					continue;
				}
				if (node is BranchNode && node.isOpen()){
					count = count + node.getVisibleSize();
				}
			}
			return count + 1;
		}
		
		public function getDataProviderIndex(childIndex:int):int{
			var index:int;
			var totalCount:int;
			var currentIndex:int = _dataProvider.getItemIndex(this);
			currentIndex = Math.max(currentIndex,0);
			while (index < childIndex){
				totalCount = totalCount + children[index].getVisibleSize();
				index++;
			}
			return totalCount + currentIndex + 1;
		}
		
		public function get children() : Array{
			return _children;
		}
	}
}