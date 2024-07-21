package com.scene.tile.gameAstar {
	import com.scene.sceneData.MapDataVo;

	public class WorldMapGrid extends MapGrid {

		public function WorldMapGrid(vo:MapDataVo) {
			super(vo);
		}

		override public function initNodeLink(node:Node):void {
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
					var cost:Number=_straightCost;
					if (node.x == test.x || node.y == test.y) { //正边四个格子
						node.links.push(new Link(test, cost));
					}
				}
			}
		}
	}
}