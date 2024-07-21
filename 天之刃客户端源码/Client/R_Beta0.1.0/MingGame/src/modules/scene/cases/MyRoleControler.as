package modules.scene.cases {
	//	import com.common.cursor.CursorManager;
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.cursor.cursors.MagicHandCursor;
	import com.managers.Dispatch;
	import com.scene.GameScene;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Collection;
	import com.scene.sceneUnit.DropThing;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.MapStuff;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUnit.Needfire;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.ServerNPC;
	import com.scene.sceneUnit.Waiter;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneCheckers;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.utils.HtmlUtil;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.collect.CollectModule;
	import modules.mission.MissionDataManager;
	import modules.mypackage.PackageModule;
	import modules.needfire.NeedfieModule;
	import modules.npc.NPCModule;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.other.HangMachineTip;
	import modules.skill.SkillModule;
	import modules.training.TrainConstant;

	import proto.common.p_map_bonfire;
	import proto.line.m_role2_getroleattr_tos;

	public class MyRoleControler extends BaseModule {
		private static var _instance:MyRoleControler;

		public function MyRoleControler() {
		}

		public static function getInstance():MyRoleControler {
			if (_instance == null) {
				_instance=new MyRoleControler;
			}
			return _instance;
		}

		private function get hero():MyRole {
			return GameScene.getInstance().hero;
		}

		public function onClickUnit(tar:IMutualUnit):void {
			var isDead:Boolean=GlobalObjectManager.getInstance().isDead;
			if (isDead == true || tar == null) {
				return;
			}
			switch (tar.sceneType) {
				case SceneUnitType.MONSTER_TYPE:
					doMonsterClick(tar as Monster);
					break;
				case SceneUnitType.ROLE_TYPE:
					if (tar is MyRole) {
						doMyRoleClick(tar as MyRole);
					} else {
						doRoleClick(tar as Role);
					}
					break;
				case SceneUnitType.PET_TYPE:
					doPetClick(tar as Pet);
					break;
				case SceneUnitType.WAITER_TPYE:
					this.dispatch(ModuleCommand.SELETED_STALL, Waiter(tar).pvo.role_id);
					break;
				case SceneUnitType.DROP_THING_TYPE:
					MapCase.getInstance().gotoPickDropThing(tar as DropThing);
					break;
				case SceneUnitType.YBC_TYPE:
					doYBCClick(tar as YBC);
					break;
				case SceneUnitType.NPC_TYPE:
					doNPCClick(tar as NPC)
					break;
				case SceneUnitType.COLLECT_TYPE:
					doCollectClick(tar as Collection);
					break;
				case SceneUnitType.SERVER_NPC_TYPE:
					doServerNPCClick(tar as ServerNPC);
					break;
				case SceneUnitType.MAP_STUFF_TYPE:
					doMapStuff(tar as MapStuff);
					break;
				case SceneUnitType.NEEDFIRE_TYPE:
					doNeedFire(tar as Needfire);
			}
		}

		public function runToPoint(tarPt:Pt, cut:int=0, handler:HandlerAction=null):void {
			var myRole:MyRole=SceneUnitManager.getSelf();
			if (myRole) {
				myRole.runToPoint(tarPt, cut, handler);
			}
		}

		public function runToHit(tar:MutualAvatar):void {
			SkillModule.getInstance().skillToTarget(tar); //选择技能后就去打
		}

		private function doMonsterClick(tar:Monster):void {
			var svo:SeletedRoleVo=new SeletedRoleVo;
			svo.setupMonster(tar.pvo);
			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
			SkillModule.getInstance().skillToTarget(tar); //选择技能后就去打
			SceneDataManager.lockEnemyKey=tar.unitKey; //作为锁定目标
			//HangMachineTip.showHangMachineTip(); //显示自动打怪提示
		}

		private function doPetClick(pet:Pet):void {
			var svo:SeletedRoleVo=new SeletedRoleVo;
			svo.setupPet(pet.pvo);
			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
			var isEmeny:Boolean=SceneCheckers.checkIsEnemy(pet);
			if (isEmeny == true) {
				SkillModule.getInstance().skillToTarget(pet); //选择技能后就去打
			}
		}

		private function doYBCClick(ybc:YBC):void {
			var svo:SeletedRoleVo=new SeletedRoleVo;
			svo.setupYBC(ybc.pvo);
			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
			var targetKey:String='';
			if (CursorManager.getInstance().currentCursor == CursorName.SELECT_TARGET) {
				SkillModule.getInstance().skillToTarget(ybc); //选择技能后就去打
				return;
			}
			var isEmeny:Boolean=SceneCheckers.checkIsEnemy(ybc);
			if (isEmeny == true) {
				SkillModule.getInstance().skillToTarget(ybc); //选择技能后就去打
			}
		}

		private function doMyRoleClick(myRole:MyRole):void {
			if (CursorManager.getInstance().currentCursor == CursorName.MAGIC_HAND) {
				var magicCursor:MagicHandCursor=CursorManager.getInstance().getCursor(CursorName.MAGIC_HAND) as MagicHandCursor;
				PackageModule.getInstance().useItem(magicCursor.data.oid, 1, myRole.id);
				return;
			}
			if (CursorManager.getInstance().currentCursor == CursorName.SELECT_TARGET) {
				SkillModule.getInstance().skillToTarget(myRole); //选择技能后就去打
				return;
			}
			GameScene.getInstance().onClickMap();
		}

		private function doRoleClick(role:Role):void {
			if (SceneModule.isLookInfo == true) { //查看详细
				var lookvo:m_role2_getroleattr_tos=new m_role2_getroleattr_tos;
				lookvo.role_id=role.id;
				sendSocketMessage(lookvo);
				return;
			}
			if (SceneModule.isFollowFoot == true) { //跟随
				MoveCase.getInstance().follow_id=role.id;
				MoveCase.getInstance().runToMaster();
				return;
			}
			if (role.curState == RoleActState.STALL) { //摆摊时
				this.dispatch(ModuleCommand.SELETED_STALL, role.id);
				return;
			}
			if (CursorManager.getInstance().currentCursor == CursorName.MAGIC_HAND) {
				var magicCursor:MagicHandCursor=CursorManager.getInstance().getCursor(CursorName.MAGIC_HAND) as MagicHandCursor;
				PackageModule.getInstance().useItem(magicCursor.data.oid, 1, role.id);
				return;
			}
			if (CursorManager.getInstance().currentCursor == CursorName.SELECT_TARGET) {
				SkillModule.getInstance().skillToTarget(role); //选择技能后就去打
				return;
			}

			if (RoleStateDateManager.seletedUnit != null && RoleStateDateManager.seletedUnit.key == role.unitKey) {
				SkillModule.getInstance().skillToTarget(role); //选择技能后就去打
			}
			var svo:SeletedRoleVo=new SeletedRoleVo;
			svo.setupRole(role.pvo);
			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
			//显示头像

		}

		private function doNPCClick(tar:NPC):void {
			//忽略显示NPC头像
//			var svo:SeletedRoleVo=new SeletedRoleVo;
//			svo.setupNPC(tar.pvo);
//			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
			var isDomestic:Boolean=SceneDataManager.isInHomeCountry;
			if (isDomestic == true || SceneDataManager.isInNeutrality == true) {
				var pt:Pt=tar.index;
				if (ScenePtMath.checkDistance(SceneUnitManager.getSelf().index, pt) <= 4) {
					sendToTask(tar.id);
				} else {
					var tarpt:Pt=ScenePtMath.getNearPt(pt, 4, false);
					var handler:HandlerAction=new HandlerAction(sendToTask, [tar.id]);
					runToPoint(pt, 2, handler);
				}
			} else if (!NPCModule.getInstance().hasMission(tar.id)) {
				this.dispatch(ModuleCommand.BROADCAST, HtmlUtil.font("NPC不为敌国玩家服务", "#ff0000"));
			} else {
				sendToTask(tar.id);
			}
		}

		private function sendToTask(npcID:int):void {
			var npc:NPC=NPCTeamManager.getNPC(npcID);
			var dir:int=ScenePtMath.getDretion(hero.index, npc.index);

			// 离线挂机状态下，不执行改变方向
			if (hero.pvo.state == RoleActState.NORMAL) {
				hero.turnDir(dir);
			}
			this.dispatch(ModuleCommand.OPEN_NPC_PANNEL, npcID);
		}

		private function doCollectClick(collect:Collection):void {
			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: false, vo: null});
			if (CollectModule.getInstance().isCollectIng) {
				if (collect.id == CollectModule.getInstance().getSelectCollect()) {
					return;
				}
				CollectModule.getInstance().collectStop();
			}
			var dis:int=ScenePtMath.checkDistance(collect.index, SceneDataManager.getMyPostion().pt);
			if (dis <= 1) {
				CollectModule.getInstance().getGraftsInfoSend(collect.id);
			} else {
				//这里目的是为了解决恶心的采集寻路失败的问题
				LoopManager.setTimeout(delayCollect, 20, [collect]);
//				var collectAction:HandlerAction=new HandlerAction(doCollect, [collect.id, collect.index]);
//				runToPoint(collect.index, 1, collectAction);
			}
		}

		private function delayCollect(collect:Collection):void {
			var collectAction:HandlerAction=new HandlerAction(doCollect, [collect.id, collect.index]);
			runToPoint(collect.index, 1, collectAction);

		}

		private function doCollect(collect_id:int, pt:Pt):void {

			var dis:int=ScenePtMath.checkDistance(pt, SceneDataManager.getMyPostion().pt);
			if (dis <= 1) {
				CollectModule.getInstance().getGraftsInfoSend(collect_id);
			}
		}

		private function doServerNPCClick(tar:ServerNPC):void {
			if (tar.isDialogNPC()) {
				var dis:int=ScenePtMath.checkDistance(tar.index, SceneDataManager.getMyPostion().pt);
				if (dis <= 3) {
					ServerNPCCase.getInstance().toOpenPanel(tar.id, tar.pvo.type_id);
				} else {
					var tarpt:Pt=ScenePtMath.getFrontPt(tar.index, 2);
					var openPanel:HandlerAction=new HandlerAction(ServerNPCCase.getInstance().toOpenPanel, [tar.id, tar.pvo.type_id]);
					runToPoint(tarpt, 0, openPanel);
				}
			} else {
				var svo:SeletedRoleVo=new SeletedRoleVo;
				svo.setupServerNPC(tar.pvo);
				this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
				SkillModule.getInstance().skillToTarget(tar); //选择技能后就去打
				SceneDataManager.lockEnemyKey=tar.unitKey;
			}
		}

		private function doMapStuff(tar:MapStuff):void {
			switch (tar.type) {
				case "tiangonglu":
					Dispatch.dispatch(ModuleCommand.OPEN_STOVE_WINDOW);
					break;
				case "throne":
					var vo:RunVo=new RunVo;
					vo.pt=tar.index;
					vo.action=new HandlerAction(function holdThrone():void {
							Dispatch.dispatch(ModuleCommand.ROB_KING_ONCLICK_THRONE);
						});
					this.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
					break;
				case "dragon":
					break;
			}
		}

		private function doNeedFire(tar:Needfire):void {
			NeedfieModule.getInstance().openNPCPanel(tar.vo);
		}
	}
}