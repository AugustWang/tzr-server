package com.scene.tile.gameAstar {
	import com.scene.tile.Pt;

	public class Node {
		public var x:int;
		public var y:int;
		public var pt:Pt;
		public var f:Number; //f=g+h
		public var g:Number; //从起点到当前格子的消耗
		public var h:Number; //当前格到终点格子的消耗
		public var walkable:Boolean=true;
		public var parent:Node;
		//public var costMultiplier:Number = 1.0;
		public var version:int=1;
		public var links:Array;
		public var initLink:Boolean = false;
		//public var index:int;
		public function Node(x:int, y:int) {
			this.x=x;
			this.y=y;
			pt=new Pt(x, 0, y);
		}
	}
}