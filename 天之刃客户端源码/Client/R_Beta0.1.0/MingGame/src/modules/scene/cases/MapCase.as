package modules.scene.cases {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameParameters;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.WorldManager;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneKit.LoadingSetter;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneManager.RoadManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.Collection;
	import com.scene.sceneUnit.DropThing;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyPet;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.ServerNPC;
	import com.scene.sceneUnit.Trap;
	import com.scene.sceneUnit.Waiter;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.map.Map;
	import com.scene.sceneUtils.ConvertMath;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitSearcher;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.heroFB.HeroFBModule;
	import modules.mypackage.ItemConstant;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.other.EnterScenePreparer;
	
	import proto.common.p_goods;
	import proto.common.p_map_collect;
	import proto.common.p_map_dropthing;
	import proto.common.p_map_monster;
	import proto.common.p_map_pet;
	import proto.common.p_map_role;
	import proto.common.p_map_server_npc;
	import proto.common.p_map_stall;
	import proto.common.p_map_trap;
	import proto.common.p_map_ybc;
	import proto.common.p_pos;
	import proto.common.p_role;
	import proto.common.p_skin;
	import proto.common.p_walk_path;
	import proto.line.m_map_change_map_toc;
	import proto.line.m_map_change_map_tos;
	import proto.line.m_map_change_pos_toc;
	import proto.line.m_map_dropthing_enter_toc;
	import proto.line.m_map_dropthing_pick_toc;
	import proto.line.m_map_dropthing_pick_tos;
	import proto.line.m_map_dropthing_quit_toc;
	import proto.line.m_map_enter_toc;
	import proto.line.m_map_enter_tos;
	import proto.line.m_map_quit_toc;
	import proto.line.m_map_role_killed_toc;
	import proto.line.m_map_slice_enter_toc;
	import proto.line.m_map_transfer_toc;
	import proto.line.m_map_transfer_tos;
	import proto.line.m_map_update_actor_mapinfo_toc;
	import proto.line.m_system_pk_not_agree_tos;


	public class MapCase extends BaseModule {
		private static var _instance:MapCase;
		private var _isOnEnter:Boolean
		private var _tarMap:int;
		public var isFirstEnterMap:Boolean=true;

		public function MapCase():void {
		}

		public static function getInstance():MapCase {
			if (_instance == null) {
				_instance=new MapCase;
			}
			return _instance;
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}

		public function toChangeMap(mapid:int, tox:int, toy:int):void {
			var vo:m_map_change_map_tos=new m_map_change_map_tos;
			vo.mapid=mapid;
			vo.tx=tox;
			vo.ty=toy;
			sendSocketMessage(vo);
			trace("chang_map:" + getTimer());
		}

		//开始换地图,先load 地图mcm文件，再load背景模糊图
		public function onChangMap(vo:m_map_change_map_toc):void {
			trace("chang_map_toc:" + getTimer());
			if (vo.succ) {
				SceneDataManager.isGaming=false;
				GlobalObjectManager.getInstance().bornPoint=new Pt(vo.tx, 0, vo.ty);
				_tarMap=vo.mapid;
				EnterScenePreparer.loadMapData(_tarMap);
				if (SceneModule.isAutoHit == true) {
					SceneModule.getInstance().toAutoHitMonster();
				}
			} else {
				view.hero.resetUnderControl(true);
				BroadcastSelf.logger(vo.reason);
			}
		}

		public var enterMapPath:String=""

		public function toEnter(mapid:int):void {
			var vo:m_map_enter_tos=new m_map_enter_tos;
			vo.map_id=mapid;
			sendSocketMessage(vo);
		}

		/**
		 * 玩家进入
		 * @param vo
		 *
		 */
		public function onEnter(vo:m_map_enter_toc):void {
			trace("map_enter:" + getTimer());
			if (SceneDataManager.isGaming == false) {
				return; //地图没切换完毕，忽略此消息
			}
			var role:Role;
			var effect:Effect;
			_isOnEnter=true;
			if (vo && vo.succ) {
				if (vo.return_self) { //自己进
					view.clear();
					view.reset(enterMapPath);
					LoadingSetter.mapLoading(false);
					view.map.startLoadBlur(enterMapPath);
				}
				if (vo.return_self == true && vo.pos) { //先把镜头移动过去，并加载地图切片
					var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.pos.tx, 0, vo.pos.pos.ty));
					view.centerCamera(p.x, p.y);
					view.map.frontLoadMap();
				}
				//逐步初始化，一个一个来
				for (var i:int=0; i < vo.roles.length; i++) {
					roleEnter(vo.roles[i] as p_map_role);
				}
				for (i=0; i < vo.monsters.length; i++) {
					monsterEnter(vo.monsters[i] as p_map_monster);
				}
				for (i=0; i < vo.ybcs.length; i++) {
					ybcEnter(vo.ybcs[i] as p_map_ybc);
				}
				for (i=0; i < vo.dropthings.length; i++) {
					dropThingEnter(vo.dropthings[i] as p_map_dropthing);
				}
				for (i=0; i < vo.stalls.length; i++) {
					stallEnter(vo.stalls[i] as p_map_stall);
				}
				for (i=0; i < vo.grafts.length; i++) {
					collectEnter(vo.grafts[i] as p_map_collect);
				}
				for (i=0; i < vo.server_npcs.length; i++) {
					serverNPCEnter(vo.server_npcs[i] as p_map_server_npc);
				}
				for (i=0; i < vo.pets.length; i++) {
					onPetEnter(vo.pets[i] as p_map_pet);
				}
				for (i=0; i < vo.trap_list.length; i++) {
					onTrapEnter(vo.trap_list[i] as p_map_trap);
				}
				if (vo.return_self) { //自己进
					NPCTeamManager.resetMap(SceneDataManager.mapData, view.midLayer); //重置NPC
					//					this.view.createYBCArrow();
					if (view.hero == null) {
						var myRole:MyRole=UnitPool.getMyRole(); //new MyRole;
						myRole.reset(vo.role_map_info);
						//修改BUFF的错误调换加载顺序,先添加监听
						view.addUnit(myRole, vo.pos.pos.tx, vo.pos.pos.ty);
						view.visible=true;
						switch (vo.role_map_info.state) {
							case RoleActState.DEAD:
								myRole.die();
								break;
							case RoleActState.TRAINING:
								DealCase.getInstance().trainingStart();
								break;
						}

						///////////////////出生后检查是否有跨地图路径没走完/////////////////////
						var arr:Array=RoadManager.macroPath;
						if (arr && arr.length > 0) {
							var nowPath:MacroPathVo=arr.shift();
							if (nowPath.mapid == SceneDataManager.mapData.map_id && nowPath.pt.key != "0|0|0") {
								if (arr.length == 0) {
									myRole.runToPoint(nowPath.pt, RoadManager.cut, RoadManager.action);
								} else {
									myRole.runToPoint(nowPath.pt);
								}
							}
						}else{
							dispatch(ModuleCommand.CLEAR_MAP_PATH);
						}
						enterMapTip(vo.pos.map_id); //进入哪个地图的提示
						MoveCase.getInstance().follow_id=-1;
						SceneDataManager.lockEnemyKey="";
					}
					if (isFirstEnterMap == true) { //发送第一次进入地图的VO
						dispatch(ModuleCommand.ENTER_GAME);
					}
					dispatch(ModuleCommand.CHANGE_MAP, SceneDataManager.mapData.map_id); //告诉别的模块我切地图了
					if (vo.return_self) {
						this.dispatch(ModuleCommand.CHANGE_MAP_ROLE_READY);
						view.map.addActiveItem();
					}
					doSceneColor(vo.pos.map_id);
					doPKTip();
				} else {
					//BroadcastSelf.logger("有单位进入地图");这句只是为了调试
				}
			} else {
//				throw(new Error("进入地图出错，新刷新" + vo.reason));
				BroadcastSelf.logger("进入地图出错，原因：" + vo.reason);
			}
		}

		private function enterMapTip(mapid:int):void {
			var city:CityVo=WorldManager.getCityVo(mapid);
			if (city) {
				var str:String=HtmlUtil.font(city.name, "#00CBCE", 14);
				dispatch(ModuleCommand.BROADCAST, str);
				var warning:String="你已进入" + city.name;
				var isProtectMap:Boolean=SceneDataManager.isProtectMap;
				if (isProtectMap == false && GlobalObjectManager.getInstance().user.attr.level < 20) {
					warning+="，新手不受保护，请注意安全";
				}
				BroadcastSelf.getInstance().appendMsg(warning);
			}
		}

		private function doPKTip():void {
			if (GameParameters.getInstance().pkTip == "true" && SceneDataManager.isTaiPingCun == false && isFirstEnterMap == true && SceneDataManager.mapData.map_id != 10700) {
				Alert.show("根据游戏设计，本地图为非安全区，会受到玩家的攻击，若对此感到不适或无法接受，可传送到安全区—太平村！是否继续留在本地图？", "声明", null, toTaiPing, "同意", "不同意");
			}
			isFirstEnterMap=false;
		}

		private function toTaiPing():void {
			var vo:m_system_pk_not_agree_tos=new m_system_pk_not_agree_tos;
			sendSocketMessage(vo);
		}

		private function doSceneColor(mapid:int):void { //专门处理地宫亮度
			if (mapid == 11106 || mapid == 12106 || mapid == 13106) {
				var mat:Array=[1, 0, 0, 0, -60, 0, 1, 0, 0, -60, 0, 0, 1, 0, -60, 0, 0, 0, 1, 0];

				var f:ColorMatrixFilter=new ColorMatrixFilter(mat);
				view.filters=[f];
			} else {
				view.filters=null;
			}
		}

		public function onSliceEnter(vo:m_map_slice_enter_toc):void {
			if (SceneDataManager.isGaming == false) {
				return;
			}
			/////////////////下面是退出的单位///////////////////////////
			for (var i:int=0; i < vo.del_roles.length; i++) { //排除自己
				if (vo.del_roles[i] != GlobalObjectManager.getInstance().user.base.role_id) {
					view.removeUnit(vo.del_roles[i]);
				}
			}
			for (i=0; i < vo.del_monsters.length; i++) {
				view.removeUnit(vo.del_monsters[i], SceneUnitType.MONSTER_TYPE);
			}
			for (i=0; i < vo.del_ybcs.length; i++) {
				view.removeUnit(vo.del_ybcs[i], SceneUnitType.YBC_TYPE);
			}
			for (i=0; i < vo.del_dropthings.length; i++) {
				view.removeUnit(vo.del_dropthings[i], SceneUnitType.DROP_THING_TYPE);
			}
			for (i=0; i < vo.del_stalls.length; i++) {
				view.removeUnit(vo.del_stalls[i], SceneUnitType.WAITER_TPYE);
			}
			for (i=0; i < vo.del_grafts.length; i++) {
				view.removeUnit(vo.del_grafts[i], SceneUnitType.COLLECT_TYPE);
			}
			for (i=0; i < vo.del_server_npcs.length; i++) {
				view.removeUnit(vo.del_server_npcs[i], SceneUnitType.SERVER_NPC_TYPE);
			}
			for (i=0; i < vo.del_pets.length; i++) {
				view.removeUnit(vo.del_pets[i], SceneUnitType.PET_TYPE);
			}
			for (i=0; i < vo.del_trap_list.length; i++) {
				view.removeUnit(vo.del_trap_list[i], SceneUnitType.TRAP_TYPE);
			}
			/////////////////下面是进入的单位///////////////////////////
			for (i=0; i < vo.roles.length; i++) {
				roleEnter(vo.roles[i] as p_map_role);
			}
			for (i=0; i < vo.monsters.length; i++) {
				monsterEnter(vo.monsters[i] as p_map_monster);
			}
			for (i=0; i < vo.ybcs.length; i++) {
				ybcEnter(vo.ybcs[i] as p_map_ybc);
			}
			for (i=0; i < vo.dropthings.length; i++) {
				dropThingEnter(vo.dropthings[i] as p_map_dropthing);
			}
			for (i=0; i < vo.stalls.length; i++) {
				stallEnter(vo.stalls[i] as p_map_stall);
			}
			for (i=0; i < vo.grafts.length; i++) {
				collectEnter(vo.grafts[i] as p_map_collect);
			}
			for (i=0; i < vo.server_npcs.length; i++) {
				serverNPCEnter(vo.server_npcs[i] as p_map_server_npc);
			}
			for (i=0; i < vo.pets.length; i++) {
				onPetEnter(vo.pets[i] as p_map_pet);
			}
			for (i=0; i < vo.trap_list.length; i++) {
				onTrapEnter(vo.trap_list[i] as p_map_trap);
			}
		}

		/**
		 * 每个玩家单独处理
		 * @param j
		 *
		 */
		private function roleEnter(j:p_map_role):void {
			if (j.role_id == GlobalObjectManager.getInstance().user.base.role_id) {
				return; //有时候包含自己，是后台的bug
			}
			var role:Role=SceneUnitManager.getUnit(j.role_id) as Role;
			if (role == null) {
				role=UnitPool.getRole();
				role.reset(j);
				view.addUnit(role, j.pos.tx, j.pos.ty, j.pos.dir);
			} else {
				if (role.parent == null) {
					view.midLayer.addChild(role);
				}
				role.reset(j);
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(j.pos.tx, 0, j.pos.ty));
				role.x=p.x;
				role.y=p.y;
				role.pvo=j;
				role.hideAvatar=SceneModule.isHideRole;
			}
			switch (j.state) {
				case RoleActState.DEAD:
					role.die();
					return;
				case RoleActState.ZAZEN:
					role.sitDown(true);
					return;
				case RoleActState.NORMAL:
					role.normal();
					break;
				case RoleActState.TRAINING:
					role.doTraining(true);
					return;
				case RoleActState.ON_HOOK:
					role.doHook(true);
					return;
				default:
					break;
			}
			var lastpath:p_walk_path=j.last_walk_path;
			if (lastpath != null && lastpath.path.length > 0) {
				lastpath.path=ConvertMath.walkPath_pt(lastpath.path); //转成PT
				lastpath.path=ConvertMath.revertPath(lastpath.path); //恢复路径
				var endPt:Pt=lastpath.path[lastpath.path.length - 1];
				var rolePt:Pt=TileUitls.getIndex(new Point(role.x, role.y));
				if (endPt.key != rolePt.key) {
					for (var i:int=0; i < lastpath.path.length; i++) {
						if (j.pos.tx == lastpath.path[0].x && j.pos.ty == lastpath.path[0].z) {
							break;
						} else { //去掉已经走过的半截路
							lastpath.path.shift();
						}
					}
					var pix:Point=TileUitls.getIsoIndexMidVertex(new Pt(j.pos.tx, 0, j.pos.ty));
					role.x=pix.x;
					role.y=pix.y;
					role.run(lastpath.path);
				}
			}
		}

		private function monsterEnter(i:p_map_monster):void {
			var qIndex:int=MonsterCase.prepareQuit.indexOf(i.monsterid)
			if (qIndex != -1) { //把此怪从删除列表里面删除
				MonsterCase.prepareQuit.splice(qIndex, 1);
			}
			var monster:Monster=SceneUnitManager.getUnit(i.monsterid, SceneUnitType.MONSTER_TYPE) as Monster;
			if (monster == null) {
				monster=UnitPool.getMonster();
				monster.reset(i);
				view.addUnit(monster, i.pos.tx, i.pos.ty, i.pos.dir);
			} else {
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(i.pos.tx, 0, i.pos.ty));
				monster.x=p.x;
				monster.y=p.y;
				monster.pvo=i;
			}
		}

		private function ybcEnter(i:p_map_ybc):void {
			var ybc:YBC=SceneUnitManager.getUnit(i.ybc_id, SceneUnitType.YBC_TYPE) as YBC;
			if (ybc == null) {
				ybc=UnitPool.getYBC();
				ybc.reset(i);
				view.addUnit(ybc, i.pos.tx, i.pos.ty, i.pos.dir);
			} else {
				if (ybc.parent == null) {
					view.midLayer.addChild(ybc);
				}
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(i.pos.tx, 0, i.pos.ty));
				ybc.x=p.x;
				ybc.y=p.y;
				ybc.pvo=i;
			}
		}

		private function collectEnter(vo:p_map_collect):void {
			var collect:Collection=SceneUnitManager.getUnit(vo.id, SceneUnitType.COLLECT_TYPE) as Collection;
			if (collect == null) {
				collect=new Collection();
				collect.reset(vo);
				view.addUnit(collect, vo.pos.tx, vo.pos.ty);
			} else {
				if (collect.parent == null) {
					view.midLayer.addChild(collect);
				}
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.tx, 0, vo.pos.ty));
				collect.x=p.x;
				collect.y=p.y;
				collect.reset(vo);
			}
		}

		public function onTrapEnter(vo:p_map_trap):void {
			var trap:Trap=SceneUnitManager.getUnit(vo.trap_id, SceneUnitType.TRAP_TYPE) as Trap;
			if (trap == null) {
				trap=new Trap();
				trap.reset(vo);
				view.addUnit(trap, vo.pos.tx, vo.pos.ty);
			} else {
				if (trap.parent == null) {
					view.midLayer.addChild(trap);
				}
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.tx, 0, vo.pos.ty));
				trap.x=p.x;
				trap.y=p.y;
				trap.reset(vo);
			}
		}

		private function dropThingEnter(i:p_map_dropthing):void {
			var item:DropThing=SceneUnitManager.getUnit(i.id, SceneUnitType.DROP_THING_TYPE) as DropThing;
			if (item == null) {
				item=UnitPool.getDropThing();
				item.reset(i);
				view.addUnit(item, i.pos.tx, i.pos.ty);
			} else {
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(i.pos.tx, 0, i.pos.ty));
				item.x=p.x;
				item.y=p.y;
				if (item.parent == null) {
					view.midLayer.addChild(item);
				}
			}
		}

		/**
		 * 摆摊点
		 * @param vo
		 *
		 */
		private function stallEnter(p:p_map_stall):void { //玩家亲自摆
			if (p.mode == 0) {
				var role:Role=SceneUnitManager.getUnit(p.role_id) as Role;
				if (role != null) {
					role.doStall(true, p.stall_name);
					if (role is MyRole) {
						MyRole(role).resetUnderControl(false);
					}
				}
			} else if (p.mode == 1) {
				var waiter:Waiter=SceneUnitManager.getUnit(p.role_id, SceneUnitType.WAITER_TPYE) as Waiter;
				if (waiter == null) {
					waiter=UnitPool.getWaiter();
					waiter.reset(p);
					view.addUnit(waiter, p.pos.tx, p.pos.ty);
				} else {
					var pp:Point=TileUitls.getIsoIndexMidVertex(new Pt(p.pos.tx, 0, p.pos.ty));
					waiter.x=pp.x;
					waiter.y=pp.y;
					if (waiter.parent == null) {
						view.midLayer.addChild(waiter);
					}
				}
			}
		}

		private function serverNPCEnter(vo:p_map_server_npc):void {
			var item:ServerNPC=SceneUnitManager.getUnit(vo.npc_id, SceneUnitType.SERVER_NPC_TYPE) as ServerNPC;
			if (item == null) {
				item=new ServerNPC;
				item.reset(vo);
				view.addUnit(item, vo.pos.tx, vo.pos.ty, vo.pos.dir);
			} else {
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.tx, 0, vo.pos.ty));
				item.x=p.x;
				item.y=p.y;
				if (item.parent == null) {
					view.midLayer.addChild(item);
				}
			}
		}

		private function onPetEnter(vo:p_map_pet):void {
			var qIndex:int=PetCase.prepareQuit.indexOf(vo.pet_id)
			if (qIndex != -1) { //把此怪从删除列表里面删除
				PetCase.prepareQuit.splice(qIndex, 1);
			}
			var master:MutualAvatar=SceneUnitManager.getUnit(vo.role_id) as MutualAvatar;
			var p:Point;
			if (master != null) {
				var pos:Pt=master.index;
				var petPos:Pt=ScenePtMath.getPetPt(pos, master.dir, 2);
				if (vo.role_id == GlobalObjectManager.getInstance().user.base.role_id) {
					var mypet:MyPet=SceneUnitManager.getUnit(vo.pet_id, SceneUnitType.PET_TYPE) as MyPet;
					if (mypet == null) {
						mypet=new MyPet;
						mypet.reset(vo);
						view.addUnit(mypet, petPos.x, petPos.z, master.dir);
					} else {
						p=TileUitls.getIsoIndexMidVertex(new Pt(petPos.x, 0, petPos.z));
						mypet.reset(vo);
						mypet.x=p.x;
						mypet.y=p.y;
						if (mypet.parent == null) {
							view.midLayer.addChild(mypet);
						}
					}
					dispatch(ModuleCommand.BATTLE_PET_CHANGE, vo);
				} else {
					var pet:Pet=SceneUnitManager.getUnit(vo.pet_id, SceneUnitType.PET_TYPE) as Pet;
					if (pet == null) {
						pet=UnitPool.getPet();
						pet.reset(vo);
						view.addUnit(pet, petPos.x, petPos.z, master.dir);
					} else {
						p=TileUitls.getIsoIndexMidVertex(new Pt(petPos.x, 0, petPos.z));
						pet.reset(vo);
						pet.x=p.x;
						pet.y=p.y;
						if (pet.parent == null) {
							view.midLayer.addChild(pet);
						}
					}
				}
			}
		}

		/**
		 * 玩家退出
		 * @param vo
		 *
		 */
		public function onOtherQuit(vo:m_map_quit_toc):void {
			if (vo.roleid != GlobalObjectManager.getInstance().user.base.role_id) {
				view.removeUnit(vo.roleid);
			}
		}

		/**
		 * 掉落物品
		 * @param vo
		 *
		 */
		public function onItemEnter(vo:m_map_dropthing_enter_toc):void {
			for each (var p:p_map_dropthing in vo.dropthing) {
				dropThingEnter(p);
			}
		}


		/**
		 * 物品消失
		 * @param vo
		 *
		 */
		public function onItemquit(vo:m_map_dropthing_quit_toc):void {
			for each (var i:int in vo.dropthingid) {
				view.removeUnit(i, SceneUnitType.DROP_THING_TYPE);
			}
		}

		public function gotoPickDropThing(tar:DropThing):void {
			var dis:int=ScenePtMath.checkDistance(SceneUnitManager.getSelf().index, tar.index);
			if (dis <= 10) { //10格就可以捡
				toItemPick(tar.id)
			} else {
				var handler:HandlerAction=new HandlerAction(toItemPick, [tar.id]);
				SceneUnitManager.getSelf().runToPoint(tar.index, 1, handler)
			}
		}

		private function toItemPick(tarID:int):void {
			var s:m_map_dropthing_pick_tos=new m_map_dropthing_pick_tos;
			s.dropthingid=tarID;
			sendSocketMessage(s);
		}

		/**
		 * 物品被捡
		 * @param vo
		 *
		 */
		public function onItemPick(vo:m_map_dropthing_pick_toc):void { //一定是自己捡的，return_self不用判断
			SceneModule.isPickBack=true;
			if (vo && vo.succ) {
				if (vo.money > 0) {
					if(vo.money_type == 1){//绑定
						GlobalObjectManager.getInstance().user.attr.silver_bind=vo.money;
						this.dispatch(ModuleCommand.BROADCAST_SELF, "你获得了绑定银子:" + MoneyTransformUtil.silverToOtherString(vo.add_money));
					}else{
						GlobalObjectManager.getInstance().user.attr.silver=vo.money;
						this.dispatch(ModuleCommand.BROADCAST_SELF, "你获得了银子:" + MoneyTransformUtil.silverToOtherString(vo.add_money));
					}
					this.dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
				} else {
					this.dispatch(ModuleCommand.PICK_UP_GOODS, vo.goods);
					var htmlGoodsName:String=getGoodsName(vo.goods);
					this.dispatch(ModuleCommand.BROADCAST_SELF, "你获得了" + vo.num + "件:" + htmlGoodsName);
				}
				GameScene.getInstance().removeUnit(vo.dropthingid, SceneUnitType.DROP_THING_TYPE);
			} else {
				SceneUnitSearcher.pickFailed=vo.dropthingid;
				var good:DropThing=SceneUnitManager.getUnit(vo.dropthingid, SceneUnitType.DROP_THING_TYPE) as DropThing;
				if (good != null) {
					good.pickFail();
					this.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font("物品拾取失败," + vo.reason, "#ff0000"));
				}
			}
		}

		private function getGoodsName(goods:p_goods):String {
			var color:String=ItemConstant.COLOR_VALUES[goods.current_colour];
			return HtmlUtil.font("【" + goods.name + "】", color);
		}

		/**
		 * 更新地图单位属性(自己更新不通过这个，没发给自己)
		 * @param vo
		 *
		 */
		public function upDateUnit(vo:m_map_update_actor_mapinfo_toc):void {
			var unit:IMutualUnit=SceneUnitManager.getUnit(vo.actor_id, vo.actor_type);
			if (unit != null) {
				if (unit is Role && vo.role_info != null) {
					if (vo.role_info.role_name == "" || vo.role_info.role_name == "undefined") {
						view.removeUnit(vo.actor_id, vo.actor_type);
						return;
					}
					Role(unit).pvo=vo.role_info;
				} else if (unit is MyRole) {
					MyRole(unit).pvo=vo.role_info;
					makePRole(vo.role_info);
					this.dispatch(ModuleCommand.ROLE_UPDATE_SEX);
				} else if (unit is Monster) {
					if (vo.monster_info != null) {
						Monster(unit).pvo=vo.monster_info;
					} else {
						//后台数据错误
					}
				} else if (unit is YBC) {
					if (vo.ybc_info != null) {
						YBC(unit).pvo=vo.ybc_info;
					} else {
						//后台数据错误
					}
				}
			}
		}

		/**
		 * 城内瞬移
		 * @param vo
		 *
		 */
		public function onChangePos(vo:m_map_change_pos_toc):void {
			var hero:MyRole=GameScene.getInstance().hero;
			if (hero != null) {
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.tx, 0, vo.ty));
				hero.x=p.x;
				hero.y=p.y;
				if (hero.pvo.state == RoleActState.TRAINING) {
					hero.sitDown(true);
				} else {
					hero.normal();
				}
				hero.skip();
				GameScene.getInstance().centerCamera(hero.x, hero.y);
				Map.centerHero=Map.heroMoving=true;
				if (vo.change_type == 1) { //1是普通2是冲锋
					if (SceneModule.isAutoHit == true) {
						SceneModule.getInstance().toAutoHitMonster();
					}
				}

				if (HeroFBModule.isOpenHeroFBPanel) {
					HeroFBModule.getInstance().closeHeroFBPanel();
				}
			}
		}



		public function onBrotherKilled(vo:m_map_role_killed_toc):void {
			//国人被杀了
			this.dispatch(ModuleCommand.MAP_BROTHER_KILLED, vo);
		}

		public function onGotoBrotherKilledPlace(arr:Array):void {
			var isFly:Boolean=arr[1] == 1 ? true : false;
			var runVO:MacroPathVo=arr[0] as MacroPathVo;
			if (isFly == true) {
				var vo:m_map_transfer_tos=new m_map_transfer_tos;
				vo.mapid=runVO.mapid;
				vo.tx=runVO.pt.x;
				vo.ty=runVO.pt.z;
				sendSocketMessage(vo);
			} else {
				var run:RunVo=new RunVo();
				run.mapid=runVO.mapid;
				run.pt=runVO.pt;
				this.dispatch(ModuleCommand.ROLE_MOVE_TO, run);
			}
		}

		/**
		 * 传送发送请求发送方法
		 * @param mapId
		 * @param pt
		 * @param changeType  跳转类型：0－普通、1－快速任务
		 *
		 */
		public function onTransferTos(mapId:int, pt:Pt, changeType:int=0):void {
			var vo:m_map_transfer_tos=new m_map_transfer_tos;
			vo.mapid=mapId;
			vo.tx=pt.x;
			vo.ty=pt.z;
			vo.change_type=changeType;
			sendSocketMessage(vo);
		}

		private function onTransfer(vo:m_map_transfer_toc):void {
			RoadManager.clear();
			if (vo.succ == false) {
				BroadcastSelf.getInstance().appendMsg(HtmlUtil.font(vo.reason, "#ff0000"));
			}
			if (SceneModule.isAutoHit == true) {
				SceneModule.getInstance().toAutoHitMonster();
			}
		}

		private function toJumpPos(vo:m_map_transfer_tos):void {
			sendSocketMessage(vo);
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.MAP_ENTER, onEnter); //人物进地图
			addSocketListener(SocketCommand.MAP_SLICE_ENTER, onSliceEnter); //跨Slice
			addSocketListener(SocketCommand.MAP_QUIT, onOtherQuit); //别人离开地图
			addSocketListener(SocketCommand.MAP_DROPTHING_ENTER, onItemEnter); //掉落物进入
			addSocketListener(SocketCommand.MAP_DROPTHING_QUIT, onItemquit); //掉落物退出
			addSocketListener(SocketCommand.MAP_DROPTHING_PICK, onItemPick); //掉落物被捡
			addSocketListener(SocketCommand.MAP_UPDATE_ACTOR_MAPINFO, upDateUnit); //更新场景单位数据
			addSocketListener(SocketCommand.MAP_CHANGE_MAP, onChangMap); //请求进地图返回
			addSocketListener(SocketCommand.MAP_CHANGE_POS, onChangePos); //同地图改变位置（瞬移）
			addSocketListener(SocketCommand.MAP_ROLE_KILLED, onBrotherKilled); //国人被杀
			addSocketListener(SocketCommand.MAP_TRANSFER, onTransfer);
			////////////////////////
			addMessageListener(ModuleCommand.GOTO_BROTHER_KILLED, onGotoBrotherKilledPlace);
			addMessageListener(ModuleCommand.REQUEST_JUMP_POS, toJumpPos);
		}

		private function makePRole(vo:p_map_role):void {

			var p:p_role=GlobalObjectManager.getInstance().user;

			p.base.role_id=vo.role_id;
			p.base.role_name=vo.role_name;
			p.base.faction_id=vo.faction_id;
			//			p.base.sex = vo.   // vo 里没有 sex .
			p.base.cur_title=vo.cur_title;
			p.base.family_id=vo.family_id;
			p.base.family_name=vo.family_name;
			p.pos.pos=vo.pos;
			p.fight.hp=vo.hp;
			p.base.max_hp=vo.max_hp;
			p.fight.mp=vo.mp;
			p.base.max_mp=vo.max_mp;
			p.attr.skin=vo.skin;
			p.base.move_speed=vo.move_speed;
			p.base.team_id=vo.team_id;
			p.attr.level=vo.level;
			p.base.pk_points=vo.pk_point;
			p.base.status=vo.state;
			p.base.if_gray_name=vo.gray_name;
			p.base.buffs=vo.state_buffs;
			p.attr.show_cloth=vo.show_cloth;
		}
		private var clothes:Array=[30105105, 30105106, 30205101, 30205106, 30305106]; //衣服

		private function makeTestRoles():void {
			var i:int=60;
			var j:int=51;
			for (i=180; i < 200; i+=1) {
				for (j=140; j < 160; j+=2) {
					var vo:p_map_role=new p_map_role;
					vo.role_id=i * j;
					vo.role_name=(i * j) + "号";
					vo.faction_id=1;
					vo.pos=new p_pos;
					vo.pos.tx=i;
					vo.pos.ty=j;
					vo.pos.dir=int(Math.random() * 8);
					vo.skin=new p_skin;
					vo.skin.skinid=1;
					vo.skin.clothes=clothes[int(Math.random() * 5)];
					vo.skin.weapon=int("100" + int(Math.random() * 4 + 1) + "0" + int(Math.random() * 4 + 3));
					roleEnter(vo);
				}
			}
		}
	}
}