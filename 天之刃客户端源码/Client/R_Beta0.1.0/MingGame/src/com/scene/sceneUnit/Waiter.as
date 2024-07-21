package com.scene.sceneUnit {
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.MutualThing;
	import com.scene.sceneUtils.SceneUnitType;

	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;

	import proto.common.p_map_stall;

	public class Waiter extends MutualThing {
		private var _pvo:p_map_stall;
		private var board:StallBoard;

		public function Waiter() {
			super();
			sceneType=SceneUnitType.WAITER_TPYE;
		}

		public function reset(vo:p_map_stall):void {
			id=vo.role_id;
			_pvo=vo;
			if (_thing == null) {
				init(GameConfig.NPCS_PATH + "waiter.swf");
			}
			if (board == null) {
				board=new StallBoard(vo.stall_name);
				board.y=-10;
				addChild(board);
			} else {
				board.reset(vo.stall_name);
			}
			SceneDataManager.setNodeWalk(vo.pos.tx, vo.pos.ty, false);
		}

		public function get pvo():p_map_stall {
			return _pvo;
		}

		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().setCursor(CursorName.HAND);
			}
		}

		override public function mouseOut():void {
			super.mouseOut();
			CursorManager.getInstance().clearAllCursor();
		}

		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}

		override public function remove():void {
			super.remove();
			UnitPool.disposeWaiter(this);
			SceneDataManager.setNodeWalk(pvo.pos.tx, pvo.pos.ty, true);
		}
	}
}