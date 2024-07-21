package com.ming.ui.containers.treeList
{
	dynamic public class LeafNode extends TreeNode
	{
		public function LeafNode(dataProvider:TreeDataProvider){
			super(dataProvider);
			_nodeType = TreeNode.LEAF_NODE;
		}
		
		public function checkForValue(_tong:String, value:String) : TreeNode{
			if (this[_tong] == value){
				return this;
			}
			return null;
		}
		
		override public function hideNode() : void{
			if (_dataProvider.getItemIndex(this) != -1 && !isVisible()){
				_dataProvider.removeItem(this);
			}
		}
		
		override public function drawNode() : void{
			var currentIndex:int;
			var totalCount:int;
			var i:int;
			var parentIndex:int;
			if (_dataProvider.getItemIndex(this) == -1 && isVisible()){
				currentIndex = _parentNode.children.indexOf(this);
				while (i < currentIndex){
					totalCount = totalCount + _parentNode.children[i].getVisibleSize();
					i++;
				}
				if (_parentNode is RootNode){
					if (_dataProvider.length > 0){
						_dataProvider.addItemAt(this, totalCount);
					}
					else{
						_dataProvider.addItem(this);
					}
				}
				else{
					parentIndex = _dataProvider.getItemIndex(_parentNode);
					_dataProvider.addItemAt(this, parentIndex + totalCount + 1);
				}
			}
		}
	
		public function getVisibleSize() : int{
			return 1;
		}
	}
}