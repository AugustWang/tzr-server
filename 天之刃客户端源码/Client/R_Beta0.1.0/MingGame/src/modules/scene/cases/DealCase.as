package modules.scene.cases {
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.scene.GameScene;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneKit.Training_bar;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.Waiter;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitType;
	
	import flash.geom.Point;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	
	import proto.common.p_map_stall;
	import proto.common.p_pos;
	import proto.line.m_exchange_request_tos;

	public class DealCase extends BaseModule {
		private static var _instance:DealCase;
		private var _trainBar:Training_bar;

		public function DealCase():void {
		}

		public static function getInstance():DealCase {
			if (_instance == null) {
				_instance=new DealCase;
			}
			return _instance;
		}
		
		private function onStageResize(value:Object):void
		{
			if (_trainBar && hero) {
				var p:Point = hero.localToGlobal(new Point());
				trainBar.x = p.x;
				trainBar.y = p.y;
			}
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}

		public function doDeal(role_id:int):void {
			var role:Role=SceneUnitManager.getUnit(role_id) as Role;
			if (role == null) {
				this.dispatch(ModuleCommand.BROADCAST, "交易人不在附近");
			} else {
				if (role.isDead == true) {
					this.dispatch(ModuleCommand.BROADCAST, "对方处于死亡状态，不可交易。");
					return;
				}
				if (ScenePtMath.checkDistance(hero.index, role.index) <= 3) {
					toDeal(role_id);
				} else {
					var ah:HandlerAction=new HandlerAction(toDeal, [role_id]);
					hero.runToPoint(role.index, 2, ah);
				}
			}
		}

		private function toDeal(role_id:int):void {
			var vo:m_exchange_request_tos=new m_exchange_request_tos();
			vo.target_roleid=role_id;
			sendSocketMessage(vo);
		}

		private function get trainBar():Training_bar {
			if (_trainBar == null) {
				_trainBar=new Training_bar;
			}
			return _trainBar;
		}

		private function get hero():MyRole {
			return GameScene.getInstance().hero;
		}

		public function trainingStart():void {
			if (hero != null) {
				hero.doTraining(true);
				trainBar.update(0);
				var p:Point=hero.localToGlobal(new Point());
				trainBar.x=p.x;
				trainBar.y=p.y;
				LayerManager.uiLayer.addChild(trainBar);
			}
		}

		public function trainingUpdate(percent:Number):void {
			if (_trainBar != null) {
				_trainBar.update(percent);
			}
		}

		public function trainingEnd():void {
			if (hero != null) {
				hero.doTraining(false);
			}
			if (_trainBar != null && _trainBar.parent != null) {
				_trainBar.parent.removeChild(_trainBar);
			}
		}

		/**
		 * 走到摆摊点面前，然后弹出摊位信息
		 * @param m
		 *
		 */
		public function onWalkTo(obj:Object):void {
			var roleID:int=obj.roleID;
			var handler:HandlerAction=obj.handler;
			var role:Role=SceneUnitManager.getUnit(roleID) as Role;
			if (role) {
				hero.runToPoint(role.index, 2, handler);
			}
		}

		/**
		 * 打开窗口成功后，主角不能移动
		 * @param m
		 *
		 */

		public function onOpenPanel(handler:HandlerAction):void {
			if (hero != null && hero.isStanding()) {
				handler.execute();
				hero.resetUnderControl(false);
			} else {
				this.dispatch(ModuleCommand.BROADCAST, "请站立在一个空闲位置");
			}
		}

		/**
		 * 自己或别人摆摊
		 * 包括真人摆和小二摆
		 */
		public function onStart(p:p_map_stall):void {
			if (p.mode == 0) {
				var role:IRole=SceneUnitManager.getUnit(p.role_id) as IRole;
				if (role != null) {
					role.doStall(true, p.stall_name);
				}
			} else if (p.mode == 1) {
				if (GlobalObjectManager.getInstance().user.base.role_id == p.role_id) {
					p.pos=new p_pos;
					p.pos.tx=hero.index.x;
					p.pos.ty=hero.index.z;
					hero.resetUnderControl(true);
				}
				var waiter:Waiter=SceneUnitManager.getUnit(p.role_id, SceneUnitType.WAITER_TPYE) as Waiter;
				if (waiter == null) {
					waiter=UnitPool.getWaiter();
					waiter.reset(p);
					view.addUnit(waiter, p.pos.tx, p.pos.ty);
				} else {
					waiter.x=hero.x;
					waiter.y=hero.y;
					if (waiter.parent == null) {
						view.midLayer.addChild(waiter);
					}
				}
			}
		}

		/**
		 * 收摊
		 * 自己或别人
		 */
		public function onEnd(p:p_map_stall):void {
			var waiter:IMutualUnit = SceneUnitManager.getUnit(p.role_id, SceneUnitType.WAITER_TPYE);
			if(waiter != null){
				view.removeUnit(p.role_id, SceneUnitType.WAITER_TPYE);
			}else{
				var role:IRole=SceneUnitManager.getUnit(p.role_id) as IRole;
				if(role != null && GlobalObjectManager.getInstance().user.base.status != RoleActState.ON_HOOK){
					role.doStall(false);
				}
				if(role != null && role is MyRole
					&& GlobalObjectManager.getInstance().user.base.status != RoleActState.ON_HOOK){
					(role as MyRole).resetUnderControl(true);
				}
			}
		}

		/**
		 *  是否锁住主角
		 * @param b
		 *
		 */
		public function doLockWalk(b:Boolean):void {
			if (hero != null) {
				hero.resetUnderControl(!b);
			}
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ACTION_RUN_TO_DEAL, doDeal);
			addMessageListener(ModuleCommand.TRAINING_START, trainingStart);
			addMessageListener(ModuleCommand.TRAINING_PROGRESS, trainingUpdate);
			addMessageListener(ModuleCommand.TRAINING_END, trainingEnd);
			addMessageListener(ModuleCommand.DEAL_STALL_WALK_TO, onWalkTo);
			addMessageListener(ModuleCommand.OPEN_STALL, onOpenPanel);
			addMessageListener(ModuleCommand.DEAL_STALL_START, onStart);
			addMessageListener(ModuleCommand.DEAL_STALL_END, onEnd);
			addMessageListener(ModuleCommand.LOCK_WALK, doLockWalk);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
		}

	}
}