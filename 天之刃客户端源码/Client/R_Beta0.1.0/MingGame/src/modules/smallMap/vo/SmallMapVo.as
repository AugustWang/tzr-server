package modules.smallMap.vo {
	import com.globals.GameConfig;
	import com.scene.WorldManager;
	import com.scene.sceneData.EnterPoint;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.MapTransferVo;
	import com.scene.sceneUtils.SceneUnitType;
	import flash.geom.Point;
	import modules.scene.SceneDataManager;

	public class SmallMapVo {
		public var name:String;
		public var bg_url:String;
		public var offsetX:int;
		public var offsetY:int;
		public var width:int;
		public var height:int;
		public var turnPoints:Array=[];
		public var nps:Array=[];
		public var map_id:int
		public var map_url:String

		public function SmallMapVo() {
		}

		public function setup(vo:MapDataVo):void {
			nps.length=0;
			turnPoints.length=0;
			map_id=vo.map_id;
			name=vo.name;
//			bg_url=vo.url + "/view.jpg";
			map_url=GameConfig.ROOT_URL + 'com/maps/map/' + vo.map_id + '.jpg';
			offsetX=vo.offsetX;
			offsetY=vo.offsetY;
			width=vo.width;
			height=vo.height;
			for (var i:int=0; i < vo.elements.length; i++) {
				var es:MapElementVo=vo.elements[i] as MapElementVo;
				if (es.itemType == EnterPoint.NPC) {
					var npc:SmallMapNpcVo=new SmallMapNpcVo();
					npc.setup(es.tx, es.ty, es.id);
					nps.push(npc);
				}
			}
			var arr:Array=SceneDataManager.visualTurns;
			for (var j:int=0; j < arr.length; j++) {
				var tp:MapTransferVo=arr[j] as MapTransferVo;
				var tar_map_name:String=WorldManager.getMapName(tp.tar_Map);
				var t:SmallMapTurnPoint=new SmallMapTurnPoint;
				t.setup(tp.tx, tp.ty, tp.tar_Map, tar_map_name);
				turnPoints.push(t);
			}

		}
	}
}