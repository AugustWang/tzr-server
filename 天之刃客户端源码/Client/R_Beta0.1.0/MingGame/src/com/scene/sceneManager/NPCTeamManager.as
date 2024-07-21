package com.scene.sceneManager {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.scene.GameScene;
	import com.scene.sceneData.EnterPoint;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.NPCVo;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	import com.scene.sceneUtils.Slice;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.roleStateG.RoleStateDateManager;
	import modules.scene.SceneDataManager;

	public class NPCTeamManager {
		private static var screenRectangle:Rectangle=new Rectangle(0, 0, 1002, 545);
		private static var NPCElement:Dictionary; //放MapElementVo
		private static var mapNPCS:Dictionary; //放真正的NPC
		private static var sliceNPCS:Dictionary; //按SLICE放NPC
		private static var NPCcontainer:Sprite;
		private static var mapID:int;

		public static function resetMap(mapVO:MapDataVo, container:Sprite):void {
			mapID=mapVO.map_id;
			mapNPCS=new Dictionary;
			NPCcontainer=container;
			NPCElement=new Dictionary();
			sliceNPCS=new Dictionary;
			for (var i:int=0; i < mapVO.elements.length; i++) {
				var e:MapElementVo=mapVO.elements[i];
				if (e.itemType == EnterPoint.NPC) {
					NPCElement[e.id]=e;
					var pt:Pt=new Pt(e.tx, 0, e.ty);
					var vo:NPCVo=new NPCVo;
					vo.setUP(pt, e.id);
					var npc:NPC=new NPC(vo);
					var p:Point=TileUitls.getIsoIndexMidVertex(vo.pt);
					npc.x=p.x;
					npc.y=p.y;
//					NPCcontainer.addChild(npc);
					mapNPCS[vo.id]=npc;
					var sliceKey:String=checkSliceKey(p);
					if (sliceNPCS[sliceKey] == null) {
						sliceNPCS[sliceKey]=[];
					}
					sliceNPCS[sliceKey].push(npc);
				}
			}
		}

		public static function getNPC(npcid:int):NPC {
			return mapNPCS[npcid + ""];
		}

		public static function getAllNPC():Dictionary {
			return mapNPCS;
		}

		/**
		 * 用于管理npc在屏幕内外是否显示
		 *
		 */
		private static var viewRect:Rectangle = new Rectangle();
		public static function npcCheckOut(sx:int, sy:int):void {
			viewRect.x = sx+SceneDataManager.mapData.offsetX-GlobalObjectManager.GAME_WIDTH/2;
			viewRect.y = sy+SceneDataManager.mapData.offsetY-GlobalObjectManager.GAME_HEIGHT/2;
			viewRect.width = GlobalObjectManager.GAME_WIDTH;
			viewRect.height = GlobalObjectManager.GAME_HEIGHT;
			var startX:int = int(viewRect.x/Slice.width);
			var endX:int = Math.ceil(viewRect.right/Slice.width);
			var startY:int = int(viewRect.y/Slice.height);
			var endY:int = Math.ceil(viewRect.bottom/Slice.height);
			var visibleNPCS:Array=[]; //放九宫格内的NPC
			for (var i:int=startX; i <= endX; i++) {
				for (var j:int=startY; j <= endY; j++) {
					var key:String=i + "_" + j;
					var arr:Array=sliceNPCS[key];
					if (arr != null) {
						visibleNPCS=visibleNPCS.concat(arr);
					}
				}
			}
			for (var s:String in mapNPCS) {
				var npc:NPC=mapNPCS[s];
				var has:int=visibleNPCS.indexOf(npc);
				if (has == -1) {
					npc.seeable=false;
					if (RoleStateDateManager.seletedUnit && npc.unitKey == RoleStateDateManager.seletedUnit.key) {
						Dispatch.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: false});
					}
					if (npc.parent != null) {
						npc.parent.removeChild(npc);
					}
				} else {
					npc.seeable=true;
					npc.startUp(); //加载NPC形象
					if (npc.parent == null) {
						NPCcontainer.addChild(npc);
					}
				}
			}
		}

		/**
		 * 更新NPC身上任务标记
		 */
		public static function updateNPCSign(npcID:*):void {
			if (mapNPCS[npcID]) {
				(mapNPCS[npcID] as NPC).needUpdateMissionSign=true;
			}
		}

		/**
		 * 直接移除NPC身上标记
		 */
		public static function removeNPCSign(npcID:*):void {
			if (mapNPCS[npcID]) {
				(mapNPCS[npcID] as NPC).removeSign();
			}
		}

		private static function checkSliceKey(p:Point):String {
			var sx:int=int((p.x + Slice.offsetx) / Slice.width);
			var sy:int=int((p.y + Slice.offsety) / Slice.height);
			return sx + "_" + sy;
		}

	}
}