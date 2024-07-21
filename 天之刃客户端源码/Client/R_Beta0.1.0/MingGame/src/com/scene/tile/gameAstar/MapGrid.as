package com.scene.tile.gameAstar {
	import com.scene.sceneData.BinaryMath;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneUnit.map.Map;
	import com.utils.ObjectUtils;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class MapGrid {
		private var _startNode:Node;
		private var _endNode:Node;
		private var _numCols:int;
		private var _numRows:int;

		private var type:int;

		protected var xCost:Number = 2; //横向
		protected var yCost:Number = 1; //纵像
		protected var _straightCost:Number=Math.sqrt(1.25);//斜向
//		protected var _diagCost:Number=Math.SQRT2;
		private var _nodes:Array;

		public function MapGrid(vo:MapDataVo) {
			var t:int=getTimer();
			_nodes=ObjectUtils.copy(vo.tiles) as Array;
//			_nodes=new Array(vo.tiles.length);
//			var arr:Array;
//			var cell:int;
//			for (var x:int=0; x < vo.tiles.length; x++) {
//				arr=vo.tiles[x];
//				_nodes[x]=new Array(arr.length);
//				for (var z:int=0; z < arr.length; z++) {
//					cell=vo.tiles[x][z];
//					if (BinaryMath.isExist(cell) == true) {
//						var node:Node=new Node(x, z);
//						//						_nodes[x + "|0|" + z]=node;
//						_nodes[x][z]=node;
//					} else {
//						_nodes[x][z]=0;
//					}
//				}
//			}
			trace("A星节点遍历时间：", getTimer() - t);
//			calculateLinks();
//			trace("A星节点准备时间：", getTimer() - t);
		}


		public function calculateLinks():void {
			var arr:Array;
			for (var x:int=0; x < _nodes.length; x++) {
				arr=_nodes[x];
				for (var z:int=0; z < arr.length; z++) {
					if (_nodes[x][z] is Node) {
						initNodeLink(_nodes[x][z]);
					}
				}
			}
		}

		/**
		 * 为每个节点初始化周围可以走的节点
		 * @param	node
		 */
		public function initNodeLink(node:Node):void {
			if (node.initLink)
				return;
			var startX:int=node.x - 1;
			var endX:int=node.x + 1;
			var startY:int=node.y - 1;
			var endY:int=node.y + 1;
			node.links=[];
			for (var i:int=startX; i <= endX; i++) {
				for (var j:int=startY; j <= endY; j++) {
					//找出周围的八个格子
					var test:Node=getNode(i, j);
					if (test == null || test == node) { //中心格子或没有格子的跳过
						continue;
					}
					var cost:Number=_straightCost;//斜边四个格子
					if((node.x - test.x == 1 && node.y - test.y == 1) || (node.x - test.x == -1 && node.y - test.y == -1)){
						cost = yCost;
					}else if((node.x - test.x == -1 && node.y - test.y == 1) || (node.x - test.x == 1 && node.y - test.y == -1)){
						cost = xCost;
					}
					node.links.push(new Link(test, cost));
				}
			}
			node.initLink=true;
		}

		public function getNode(x:int, z:int):Node {
			if (x >= 0 && x < _nodes.length) {
				if (z >= 0 && z < _nodes[x].length) {
					var obj:*=_nodes[x][z];
					if (obj is Node) {
						return obj as Node;
					} else if (BinaryMath.isExist(int(obj)) == true) {
						var node:Node=new Node(x, z);
						_nodes[x][z]=node;
						return _nodes[x][z];
					} else {
						return null;
					}
				}
			}
			return null;
		}

//		public function getNodeByKey(key:String):Node {
//			var node:Node = _nodes[key];
//			if(node == null){
//				var cell:Cell=mapDataVo.hash[key];
//				if(cell != null){
//					node = new Node(cell.x, cell.z);
//					_nodes[key]=node;
//				}else{
//					return null;
//				}
//			}
//			return node;
//		}

		public function setNodeWalkAble(tx:int, ty:int, walk:Boolean):void {
			var node:Node=getNode(tx, ty);
			if (node) {
				node.walkable=walk;
			}
		}

		public function getNodeWalkAble(x:int, z:int):Boolean {
			var node:Node=getNode(x, z);
			if (node) {
				return node.walkable;
			}
			return false;
		}

		public function setEndNode(x:int, y:int):void {
			_endNode=getNode(x, y);
		}

		public function setStartNode(x:int, y:int):void {
			_startNode=getNode(x, y);
		}


		public function get endNode():Node {
			return _endNode;
		}

		public function get numCols():int {
			return _numCols;
		}

		public function get numRows():int {
			return _numRows;
		}

		public function get startNode():Node {
			return _startNode;
		}

	}
}