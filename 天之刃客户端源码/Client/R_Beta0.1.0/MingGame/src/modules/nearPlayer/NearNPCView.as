package modules.nearPlayer {
	import com.common.FilterCommon;
	import com.components.DataGrid;
	import com.events.ParamEvent;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.Button;
	import com.scene.sceneData.NPCVo;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUtils.ScenePtMath;
	import com.utils.ComponentUtil;
	import com.utils.ObjectUtils;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.scene.SceneDataManager;

	public class NearNPCView extends Sprite {
		public static const CLICK_NPC:String="CLICK_NPC";
		private var grid:DataGrid;

		public function NearNPCView() {
			super();
			init();
		}

		public function init():void {
			grid=new DataGrid;
			grid.width=320;
			grid.height=292;
			grid.x=6;
			grid.y=4;
			grid.addColumn("NPC名字", 150);
			grid.addColumn("官职", 168);
			grid.itemRenderer=NearNPCItem;
			grid.pageCount=12;
			grid.itemHeight=24;
			grid.list.itemDoubleClickEnabled=true;
			grid.list.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK, onItemDoubleClick);
			addChild(grid);
			var txt:TextField = ComponentUtil.createTextField("*选中NPC名字，点击前往。", 5, 312, null, 200, 22, this);
			txt.textColor = 0x00ff00;
			txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			var goButton:Button=ComponentUtil.createButton("前往", 240, 312, 65, 25, this);
			goButton.addEventListener(MouseEvent.CLICK, onClick);
		}

		public function refreshHandler():void {
			var npc_arr:Array=[];
			var dic:Dictionary=NPCTeamManager.getAllNPC();
			for (var s:String in dic) {
				var npc:NPC=dic[s];
				var npcvo:NPCVo=ObjectUtils.copy(npc.pvo) as NPCVo;
				npc_arr.push(npcvo);
			}
			grid.list.dataProvider=npc_arr;
		}

		private function onItemDoubleClick(e:ItemEvent):void {
			var vo:NPCVo=grid.list.selectedItem as NPCVo;
			if (vo != null) {
				if (ScenePtMath.checkDistance(SceneDataManager.getMyPostion().pt, vo.pt) <= 8) { //在距离之内
					Dispatch.dispatch(ModuleCommand.OPEN_NPC_PANNEL, vo.id);
				} else {
					var run:RunVo=new RunVo;
					run.mapid=SceneDataManager.mapData.map_id;
					run.pt=ScenePtMath.getFrontPt(vo.pt, 2);
					var evt:ParamEvent=new ParamEvent(CLICK_NPC, run, true);
					this.dispatchEvent(evt);
				}
			}
		}

		private function onClick(e:MouseEvent):void {
			var vo:NPCVo=grid.list.selectedItem as NPCVo;
			if (vo != null && vo.pt) {
				if (ScenePtMath.checkDistance(SceneDataManager.getMyPostion().pt, vo.pt) <= 8) { //在距离之内
					Dispatch.dispatch(ModuleCommand.OPEN_NPC_PANNEL, vo.id);
				} else {
					var run:RunVo=new RunVo;
					run.mapid=SceneDataManager.mapData.map_id;
					run.pt=ScenePtMath.getFrontPt(vo.pt, 2);
					var evt:ParamEvent=new ParamEvent(CLICK_NPC, run, true);
					this.dispatchEvent(evt);
				}
			}
		}
	}
}