package modules.scene {
	import com.common.GlobalObjectManager;
	import com.common.InputKey;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.managers.LayerManager;
	import com.scene.GameScene;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Collection;
	import com.scene.sceneUnit.DropThing;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitSearcher;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.HtmlUtil;
	import com.utils.KeyUtil;
	
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.mypackage.PackageModule;
	import modules.pet.PetDataManager;
	import modules.playerGuide.PlayerGuideModule;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.cases.FightCase;
	import modules.scene.cases.MapCase;
	import modules.scene.cases.MyRoleControler;
	import modules.scene.cases.SettingCase;
	import modules.scene.other.EnterScenePreparer;
	import modules.skill.SkillModule;
	import modules.system.SystemConfig;
	
	import proto.line.m_role2_on_hook_begin_tos;
	import proto.line.m_role2_on_hook_end_tos;
	import proto.line.m_role2_on_hook_status_tos;
	import proto.line.m_role2_zazen_tos;

	public class SceneModule extends BaseModule {
		private static var instance:SceneModule;
		public static var isHideRole:Boolean;
		public static var isLookInfo:Boolean;
		public static var isFollowFoot:Boolean; //
		public static var isAutoHit:Boolean; //是否自动打怪

		private var zazenAbled:Boolean=true; //是否可以打坐
		private var autoHitLoopKey:String;
		private var startHugPt:Pt;
		private var hugBacking:Boolean;
		private static var startHitTime:int;
		public static var fightBackTime:int;
		public static var isAttackBack:Boolean=true; //攻击请求是否已经返回
		public static var isPickBack:Boolean=true; //捡东西是否已经返回
		public static var attackTimes:int=0;
		public static var pickTimes:int=0;
		public var view:GameScene;
		private var inited:Boolean;

		public function SceneModule() {
			init();
			super();
		}

		public static function getInstance():SceneModule {
			if (instance == null) {
				instance=new SceneModule();
			}
			return instance;
		}



		public function init():void {
			if (inited == false) {
				view=GameScene.getInstance();
				autoHitLoopKey=OnlyIDCreater.createID();
				KeyUtil.getInstance().addKeyHandler(toAutoHitMonster, [InputKey.Z]);
				KeyUtil.getInstance().addKeyHandler(toHitSeleted, [InputKey.A]);
				KeyUtil.getInstance().addKeyHandler(toSitDown, [InputKey.D]);
				KeyUtil.getInstance().addKeyHandler(hideRoles, [InputKey.P]);
				KeyUtil.getInstance().addKeyHandler(toLookInfo, [InputKey.J]);
				KeyUtil.getInstance().addKeyHandler(toFollow, [InputKey.G]);
				KeyUtil.getInstance().addKeyHandler(toPickNearItem, [InputKey.SPACE]);
				KeyUtil.getInstance().addKeyHandler(toSeleteTarget, [InputKey.TILDE]); //~
				inited=true;
			}
		}

		private function onStartUpScene():void {
			trace("startScene:"+getTimer());
			init();
			LayerManager.sceneLayer.addChild(view);
			EnterScenePreparer.init();
			if (MapCase.getInstance().isFirstEnterMap) {
				EnterScenePreparer.loadMapData(GlobalObjectManager.getInstance().user.pos.map_id);
			}
		}

		public function toLookInfo():void {
			isLookInfo=!isLookInfo;
			isFollowFoot=false;
		}

		private function toPickNearItem():void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				return;
			}
			var hero:MyRole=GameScene.getInstance().hero;
			if (hero != null) {
				var tar:DropThing=SceneUnitSearcher.searchNearItem(hero.index);
				if (tar) {
					MyRoleControler.getInstance().onClickUnit(tar);
				}
			}
		}

		public function toFollow():void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				return;
			}
			isFollowFoot=!isFollowFoot;
			isLookInfo=false;
		}

		private function toSeleteTarget():void {
			var a:MutualAvatar=SceneUnitSearcher.SearchEmeny();
			if (a != null) {
				var svo:SeletedRoleVo=new SeletedRoleVo;
				svo.setup(a);
				this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
			} else {
				this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: false, vo: null});
			}
			PetDataManager.attackAble=false;
		}

		private function hideRoles():void {
			isHideRole=!isHideRole;
			var roles:Dictionary=SceneUnitManager.roleHash;
			var pets:Dictionary=SceneUnitManager.petHash;
			var role:Role;
			var pet:Pet;
			for (var s:String in roles) {
				role=roles[s] as Role;
				if (role) {
					role.hideAvatar=isHideRole;
				}
			}
			for (var ss:String in pets) {
				pet=pets[ss] as Pet;
				if (pet) {
					pet.hideAvatar=isHideRole;
				}
			}
			var msg:String=isHideRole ? "您隐藏了周围的所有角色（按P切换）" : "您取消隐藏周围的所有角色（按P切换）";
			this.dispatch(ModuleCommand.BROADCAST_SELF, msg);
		}

		private function toHitSeleted():void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				return;
			}
			var vo:SeletedRoleVo=RoleStateDateManager.seletedUnit;
			if (vo != null) {
				var tar:MutualAvatar=SceneUnitManager.getUnitByKey(vo.key) as MutualAvatar;
				if (tar != null) {
					SkillModule.getInstance().skillToTarget(tar); //选择技能后就去打
				}
			}
		}
		private var onHookAlertKey:String=null;

		private function toSitDown():void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				return;
			}
			var hero:MyRole=GameScene.getInstance().hero;
			if (hero != null) {
				var state:int=GlobalObjectManager.getInstance().user.base.status;
				if (zazenAbled == true) {
					if (state == RoleActState.NORMAL && hero.isStanding() == true) {
						if (SceneDataManager.isInStallArea) {
							if (!Alert.isPopUp(onHookAlertKey)) {
								onHookAlertKey=Alert.show("挂机打坐可获得经验！", "在线挂机", doRoleOnHook, doRoleZaZen, "挂机打坐", "普通打坐", [true], true, true);
							}
						} else {
							doRoleZaZen(true);
						}
					} else if (state == RoleActState.ON_HOOK) {
						doRoleOnHook(false);
					} else if (state == RoleActState.ZAZEN) {
						doRoleZaZen(false);
					}
				}
			}
		}

		public function doRoleOnHook(isHook:Boolean):void {
			if (isHook) {
				var beginVo:m_role2_on_hook_begin_tos=new m_role2_on_hook_begin_tos;
				sendSocketMessage(beginVo);
			} else {
				var statusVo:m_role2_on_hook_status_tos=new m_role2_on_hook_status_tos;
				sendSocketMessage(statusVo);
			}
		}

		public function doRoleZaZen(isZazen:Boolean):void {
			zazenAbled=false;
			var zazen:Boolean=(GlobalObjectManager.getInstance().user.base.status == RoleActState.ZAZEN);
			var vo:m_role2_zazen_tos=new m_role2_zazen_tos;
			vo.status=!zazen;
			sendSocketMessage(vo);
			LoopManager.setTimeout(function setZazenAbled():void {
					zazenAbled=true;
				}, 500);
		}

		public function toTakeCollectByType(collectType:int):void {
			var index:Pt=SceneUnitManager.getSelf().index;
			var target:Collection=SceneUnitSearcher.searchCollectionByType(index, collectType);
			MyRoleControler.getInstance().onClickUnit(target);
		}

		public function toHitMonsterByType(monsterType:int):void {
			//startAutoHitByPlayGuide();
			var index:Pt=SceneUnitManager.getSelf().index;
			var target:Monster=SceneUnitSearcher.searchMonsterByType(index, monsterType);
			MyRoleControler.getInstance().onClickUnit(target);
		}

		/**
		 * 停止新手引导的自动打怪
		 */
		public function stopAutoHitByPlayGuide():void {
			if (isAutoHit == true) {
				toAutoHitMonster();
			}
		}

		/**
		 * 开始新手引导的自动打怪
		 */
		public function startAutoHitByPlayGuide():void {
			if (isAutoHit == false) { //启动怪物寻路后的自动打怪
				var roleLevel:int=GlobalObjectManager.getInstance().user.attr.level;
				if (roleLevel <= 10) {
					toAutoHitMonster();
				}
			}
		}

		public function toAutoHitMonster():void {
			isAutoHit=!isAutoHit;
			SystemConfig.open=isAutoHit;
			if (isAutoHit == true) {
				if (GlobalObjectManager.getInstance().isDead == true) {
					return;
				}
				PlayerGuideModule.getInstance().closeAutoHitTip();
				SettingCase.getInstance().reshowGuaJi(true);
				var hero:MyRole=GameScene.getInstance().hero;
				if (hero) {
					startHugPt=hero.index;
				}
				LoopManager.addToTimer(this, checkAutoHit);
				fightBackTime=getTimer();
				checkAutoHit();
			} else {
				SettingCase.getInstance().reshowGuaJi(false);
				SceneDataManager.lockEnemyKey="";
				LoopManager.removeFromTimer(this);
			}
		}

		private function checkAutoHit(e:TimerEvent=null):void {
			var nowTime:int=getTimer();
			if (isAttackBack == true && nowTime - fightBackTime >= 1360) { //到CD时间了
				startHitTime=getTimer();
				var hero:MyRole=GameScene.getInstance().hero;
				if (hero != null) {
					if (hugBacking == false) {
						if (startHugPt == null) {
							startHugPt=hero.index;
						}
						var dis:int=ScenePtMath.checkDistance(startHugPt, hero.index);
						var hasTarget:Boolean=RoleStateDateManager.seletedUnit == null ? false : true; //是否有目标
						var isSubMap:Boolean=SceneDataManager.isSubMap();
						var isSafeHandMap:Boolean=SceneDataManager.isInSafeMap();
						if (dis > 30 && startHugPt != null && isSafeHandMap == false && isSubMap == false) {
							var back:HandlerAction=new HandlerAction(resetHugBacking);
							hero.runToPoint(startHugPt, 0, back);
							this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: false}); //清除选中状态
							hugBacking=true;
							return;
						}
					}
					if (isAutoHit == true) { //是否自动打，并且玩家准备好
						if (RoleStateDateManager.isMount == true) {
							PackageModule.getInstance().mountDown(); //如果有坐骑则先下马
							//BroadcastSelf.logger("挂机打怪状态自动下马");
							return;
						}
						if (hero.isStanding() == true) {
							var targetKey:String;
							var tar:MutualAvatar=SceneUnitManager.getUnitByKey(SceneDataManager.lockEnemyKey) as MutualAvatar;
							var svo:SeletedRoleVo;
							if (tar == null) { //如果没有锁定目标，优先捡东西，再寻怪
								//装备，药，石头，其他
								var drop:DropThing=SceneUnitSearcher.seachDropThing(hero.index);
								if (drop != null) { //有东西可以捡就捡
									if (isPickBack == true) {
										MyRoleControler.getInstance().onClickUnit(drop);
									} else {
										pickTimes++;
										isPickBack=true;
										pickTimes=0;
									}
								} else { //没东西可以捡就找敌人
									tar=SceneUnitSearcher.searchHugEnemy(hero.index);
									if (tar != null) {
										SceneDataManager.lockEnemyKey=tar.unitKey;
										svo=new SeletedRoleVo;
										svo.setup(tar);
										this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
										SkillModule.getInstance().skillToTarget(tar);
//										isAttackBack=false;搬到MyRole的DoAttack里面，因为此时并非发起攻击的时刻，而是可能还需走一段路
									}
								}
							} else { //有锁定的敌人
								targetKey=SceneDataManager.lockEnemyKey;
								SkillModule.getInstance().skillToTarget(tar);
//								isAttackBack=false;搬到MyRole的DoAttack里面
							}
						} else if (hero.curState == RoleActState.ZAZEN) {
							if (zazenAbled == true) {
								doRoleZaZen(false);
							}
						}
					}
				}
				this.dispatch(ModuleCommand.MP_HP_CHANGED); //用于背包的自动喝血和蓝功能
				if (SystemConfig.autoPetSkill == true) { //自动宠物群攻
					PetDataManager.useTroopHit=true;
				}
				return;
			}
			if (nowTime - startHitTime > 2000 && isAttackBack == false) {
				isAttackBack=true;
				fightBackTime=nowTime;
			}

		}

		private function resetHugBacking():void {
			this.hugBacking=false;
		}

		private function startAutoHit():void {
			if (isAutoHit == false) {
				toAutoHitMonster();
			}
		}

		private function onStageResize(value:Object):void {
			var hero:MyRole=GameScene.getInstance().hero;
			if (hero) {
				GameScene.getInstance().heroXED=hero.x + 1;
				GameScene.getInstance().centerCamera(hero.x, hero.y);
			}
		}

		override protected function initListeners():void {
			/////////来自其他模块的消息/////////////////
			addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY, EnterScenePreparer.prepareRobKingMap);
			addMessageListener(ModuleCommand.START_UP_SCENE, onStartUpScene);
			addMessageListener(ModuleCommand.START_FLIGHT, startAutoHit);
			addMessageListener(ModuleCommand.SIT_DOWN, toSitDown);
			addMessageListener(ModuleCommand.AUTO_HIT_MONSTER, toAutoHitMonster);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
			addMessageListener(ModuleCommand.HIDE_ROLES,hideRoles);
		}

	}
}