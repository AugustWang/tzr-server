package com.scene.tile.gameAstar {
	import com.scene.tile.Pt;

	import flash.utils.getTimer;

	public class MCAstar {
		private var _open:BinaryHeap;
		private var _grid:MapGrid;
		private var _endNode:Node;
		private var _startNode:Node;
		private var _path:Array;
		public var heuristic:Function;
		private var _straightCost:Number=1.0;
		private var _diagCost:Number=Math.SQRT2;
		private var nowversion:int=1;

		public function MCAstar(grid:MapGrid) {
			this._grid=grid;
			heuristic=euclidian;
		}

		private function justMin(x:Object, y:Object):Boolean {
			return x.f < y.f;
		}

		public function findPath(start:Pt, end:Pt):Array {
			var t:int=getTimer();
			_startNode=_grid.getNode(start.x, start.z);
			_endNode=checkNode(end, 20);
			if (_startNode == null || _endNode == null) {
				return null;
			}
			nowversion++;
			//_open = [];
			_open=new BinaryHeap(justMin);
			_startNode.g=0;
			var find:Boolean=search();
			//trace("新寻路时间:" + (getTimer() - t));
			if (find) {
				return this.path;
			}
			return null;
		}

		public function search():Boolean {
			var node:Node=_startNode;
			_grid.initNodeLink(_startNode);
			node.version=nowversion;
			while (node != _endNode) {
				var len:int=node.links.length;
				for (var i:int=0; i < len; i++) {
					var test:Node=node.links[i].node;
					if (test.walkable == false && test != _endNode && (Math.abs(test.x - _startNode.x) < 4 && Math.abs(test.y - _startNode.y) < 4)) {
						continue;
					}
					_grid.initNodeLink(test);
					var cost:Number=node.links[i].cost;
					var g:Number=node.g + cost;
					var h:Number=heuristic(test);
					var f:Number=g + h;
					if (test.version == nowversion) { //test被访问过
						if (test.f > f) {
							test.f=f;
							test.g=g;
							test.h=h;
							test.parent=node;
						}
					} else { //test第一次被访问
						test.f=f;
						test.g=g;
						test.h=h;
						test.parent=node;
						_open.ins(test);
						test.version=nowversion;
					}

				}
				if (_open.a.length == 1) {
					return false;
				}
				node=_open.pop() as Node;
			}
			buildPath();
			return true;
		}

		private function buildPath():void {
			_path=[];
			var node:Node=_endNode;
			_path.push(node.pt);
			while (node != _startNode) {
				node=node.parent;
				_path.unshift(node.pt);
			}
		}

		public function get path():Array {
			return _path;
		}

		//如果这个点不可走，找出最近的
		private function checkNode(endPt:Pt, cycle:int):Node {
			var node:Node=_grid.getNode(endPt.x,endPt.z);
			if (node) {
				return node;
			} else {
				for (var i:int=1; i <= cycle; i++) {
					var outLine:Array=getOutLine(endPt, i);
					if (outLine.length > 0) {
						return outLine[0];
					}
				}
			}
			return null;
		}

		private function getOutLine(pt:Pt, cycle:int=1):Array {
			var arr:Array=[];
			for (var i:int=pt.x - cycle; i <= pt.x + cycle; i++) {
				for (var j:int=pt.z - cycle; j <= pt.z + cycle; j++) {
					var test:Node=_grid.getNode(i, j);
					if (test) {
						var dx:int=Math.abs(test.x - pt.x);
						var dy:int=Math.abs(test.y - pt.z);
						if (dx == cycle || dy == cycle) {
							arr.push(test);
						}
					}
				}
			}
			return arr;
		}

		public function manhattan(node:Node):Number {
			return Math.max(Math.abs(node.x - _endNode.x) + Math.abs(node.y - _endNode.y));
			//return Math.abs(node.x - _endNode.x) + Math.abs(node.y - _endNode.y);
		}

		public function manhattan2(node:Node):Number {
			var dx:Number=Math.abs(node.x - _endNode.x);
			var dy:Number=Math.abs(node.y - _endNode.y);
			return dx + dy + Math.abs(dx - dy) / 1000;
		}

		public function euclidian(node:Node):Number {
			var dx:Number=node.x - _endNode.x;
			var dy:Number=node.y - _endNode.y;
			return Math.sqrt(dx * dx + dy * dy);
		}

		private var TwoOneTwoZero:Number=2 * Math.cos(Math.PI / 3);

		public function chineseCheckersEuclidian2(node:Node):Number {
			var y:int=node.y / TwoOneTwoZero;
			var x:int=node.x + node.y / 2;
			var dx:Number=x - _endNode.x - _endNode.y / 2;
			var dy:Number=y - _endNode.y / TwoOneTwoZero;
			return sqrt(dx * dx + dy * dy);
		}

		private function sqrt(x:Number):Number {
			return Math.sqrt(x);
		}

		public function euclidian2(node:Node):Number {
			var dx:Number=node.x - _endNode.x;
			var dy:Number=node.y - _endNode.y;
			return dx * dx + dy * dy;
		}

		public function diagonal(node:Node):Number {
			var dx:Number=Math.abs(node.x - _endNode.x);
			var dy:Number=Math.abs(node.y - _endNode.y);
			var diag:Number=Math.min(dx, dy);
			var straight:Number=dx + dy;
			return _diagCost * diag + _straightCost * (straight - 2 * diag);
		}
	}
}