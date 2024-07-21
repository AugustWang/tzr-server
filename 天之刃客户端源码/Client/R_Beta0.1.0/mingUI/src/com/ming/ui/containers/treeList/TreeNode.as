package com.ming.ui.containers.treeList{
	import com.ming.collections.IIterator;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * 树节点基类定义 
	 */	
	dynamic public class TreeNode{
		/**
		 * 节点类型 
		 */		
		public static const ROOT_NODE:String = "rootNode";
		public static const BRANCH_NODE:String = "branchNode";
		public static const LEAF_NODE:String = "leafNode";
		
		/**
		 * 节点当前状态 
		 */		
		public static const CLOSE:String = "close";
		public static const OPEN:String = "open";
		/**
		 * 所在层级 
		 */		
		protected var _nodeLevel:int;
		/**
		 * 数据提供器 
		 */		
		protected var _dataProvider:TreeDataProvider;
		/**
		 * 父节点 
		 */		
		protected var _parentNode:BranchNode;
		/**
		 * 节点类型 
		 */		
		protected var _nodeType:String;
		
		public function TreeNode(_dataProvider:TreeDataProvider){
			this._dataProvider = _dataProvider;
		}
		
		public function get nodeLevel() : int{
			return _nodeLevel;
		}
		
		public function get nodeType() : String{
			return _nodeType;
		}
		
		public function set nodeLevel(value:int) : void{
			if (value == _parentNode.nodeLevel + 1){
				_nodeLevel = value;
			}
		}
		
		public function drawNode() : void{

		}
		
		public function get parentNode() : BranchNode{
			return _parentNode;
		}
		/**
		 * 判断当前数据是否已经处在显示列表中
		 */		
		public function isVisible() : Boolean{
			var parent:BranchNode = _parentNode as BranchNode;
			while (parent && !(parent is RootNode)){
				if (!parent.isOpen()){
					return false;
				}
				parent = parent.parentNode;
			}
			return true;
		}
		/**
		 * 删除自己 
		 */		
		public function removeNode() : TreeNode{
			parentNode.removeChild(this);
			return this;
		}
		/**
		 * 设置父节点 
		 */		
		public function set parentNode(node:BranchNode) : void{
			if (node.children.indexOf(this) >= 0){
				_parentNode = node;
			}
		}
		
		public function hideNode() : void{
			
		}
	}
}