package modules.scene.cases {
	import com.common.FlashObjectManager;
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.scene.GameScene;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;

	import flash.display.DisplayObject;
	import flash.geom.Point;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.robKingWar.view.RobKingBar;

	import proto.line.m_warofking_break_toc;
	import proto.line.m_warofking_end_toc;
	import proto.line.m_warofking_hold_toc;
	import proto.line.m_warofking_holding_toc;

	public class RobKingSceneCase extends BaseModule {
		private static var instance:RobKingSceneCase;

		public static function getInstance():RobKingSceneCase {
			if (instance == null) {
				instance=new RobKingSceneCase();
			}
			return instance;
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}
		private static var _isRobing:Boolean;

		public static function set isRobing(value:Boolean):void {
			_isRobing=value;
		}

		public static function get isRobing():Boolean {
			return _isRobing;
		}

		private function get bar():RobKingBar {
			return RobKingBar.instance;
		}




		private function onRobKingHold(vo:m_warofking_hold_toc):void {
			if (vo.return_self == true) {
				vo.role_id == GlobalObjectManager.getInstance().user.base.role_id;
			}
			var role:IRole=SceneUnitManager.getUnit(vo.role_id) as IRole;
			if (role) {
				FlashObjectManager.setFlash(role as DisplayObject);
				bar.x=0;
				bar.y=-180;
				if (bar.parent == null) {
					role.addChild(bar);
				}
			}
			bar.reset();
		}

		private function onHolding(vo:m_warofking_holding_toc):void {
			var role:IRole=SceneUnitManager.getUnit(vo.role_id) as IRole;
			if (role != null) {
				FlashObjectManager.setFlash(role as DisplayObject);
				bar.x=0;
				bar.y=-180;
				if (bar.parent == null) {
					role.addChild(bar);
				}
			}
			bar.update(vo.time / vo.total_time);
		}

		private function onBreak(vo:m_warofking_break_toc):void {
			if (bar.parent != null) {
				bar.parent.removeChild(bar);
			}
			var role:IRole=SceneUnitManager.getUnit(vo.role_id) as IRole;
			if (role != null) {
				FlashObjectManager.colseFlash(role as DisplayObject);
			}
		}

		private function onEnd(vo:m_warofking_end_toc):void {
			var role:IRole=SceneUnitManager.getUnit(vo.role_id) as IRole;
			if (role != null) {
				FlashObjectManager.colseFlash(role as DisplayObject);
			}
			if (bar.parent != null) { 
				bar.parent.removeChild(bar);
			}
			if (vo.family_id == GlobalObjectManager.getInstance().user.base.family_id) {
				this.dispatch(ModuleCommand.BROADCAST, "你的门派获胜了！");
			} else {
				this.dispatch(ModuleCommand.BROADCAST, "王座争霸战结束！");
			}
			isRobing=false;
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ROB_KING_HOLD_SEAT, onRobKingHold);
			addMessageListener(ModuleCommand.ROB_KING_HOLDING, onHolding);
			addMessageListener(ModuleCommand.ROB_KING_BREAK, onBreak);
			addMessageListener(ModuleCommand.ROB_KING_END, onEnd);
		}
	}
}