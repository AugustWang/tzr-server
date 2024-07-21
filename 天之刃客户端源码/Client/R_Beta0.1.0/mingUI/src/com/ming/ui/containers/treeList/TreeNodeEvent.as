package com.ming.ui.containers.treeList
{
	import flash.events.Event;
	
	public class TreeNodeEvent extends Event
	{
		public static const ADD:String = "add";
		public static const REMOVE:String = "remove";
		public var node:TreeNode;
		public function TreeNodeEvent(type:String,node:TreeNode)
		{
			super(type);
			this.node = node;
		}
	}
}