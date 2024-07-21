package modules.scene.cases {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.progressBar.CommonProgressBar;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneKit.ReliveView;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.Animal;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.effect.Shake;
	import com.scene.sceneUtils.RoleActState;
	import com.utils.PathUtil;

	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.navigation.NavigationModule;
	import modules.npc.NPCDataManager;
	import modules.pet.PetDataManager;
	import modules.playerGuide.GuideConstant;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.RoleStateModule;
	import modules.scene.SceneModule;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	import modules.skillTree.SkillTreeModule;

	import proto.common.p_map_role;
	import proto.common.p_role;
	import proto.common.p_title;
	import proto.line.m_role2_attr_change_toc;
	import proto.line.m_role2_attr_reload_toc;
	import proto.line.m_role2_dead_other_toc;
	import proto.line.m_role2_dead_toc;
	import proto.line.m_role2_event_toc;
	import proto.line.m_role2_gray_name_toc;
	import proto.line.m_role2_levelup_other_toc;
	import proto.line.m_role2_levelup_toc;
	import proto.line.m_role2_on_hook_begin_toc;
	import proto.line.m_role2_on_hook_end_toc;
	import proto.line.m_role2_on_hook_end_tos;
	import proto.line.m_role2_on_hook_status_toc;
	import proto.line.m_role2_on_hook_status_tos;
	import proto.line.m_role2_relive_toc;
	import proto.line.m_role2_relive_tos;
	import proto.line.m_role2_remove_skin_buff_toc;
	import proto.line.m_role2_show_cloth_toc;
	import proto.line.m_role2_show_equip_ring_toc;
	import proto.line.m_role2_system_buff_toc;
	import proto.line.m_role2_zazen_toc;
	import proto.line.m_title_change_cur_title_toc;

	public class Role2Case extends BaseModule {
		private static var _instance:Role2Case;
		private var _view:GameScene;
		private var alertKey:String;

		private var reliveView:ReliveView;

		private var onHookBar:CommonProgressBar;

		public function Role2Case():void {
			_view=GameScene.getInstance();
		}

		public static function getInstance():Role2Case {
			if (_instance == null) {
				_instance=new Role2Case;
			}
			return _instance;
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}

		private function get hero():MyRole {
			return GameScene.getInstance().hero;
		}

		/**
		 * 我死了，告诉角色状态模块，弹出复活框
		 * @param vo
		 *
		 */
		public function onDead(vo:m_role2_dead_toc):void {
			GlobalObjectManager.getInstance().user.base.status=RoleActState.DEAD;
			var hero:MyRole=GameScene.getInstance().hero;
			if (hero != null) {
				hero.die();
			}
			if (SceneModule.isAutoHit == true) {
				SceneModule.getInstance().toAutoHitMonster();
			}
			//dead_type,0是普通死亡，1是在个人副本死亡
			switch (vo.dead_type) {
				case 0:
					LoopManager.setTimeout(showReliveView, 600, [vo]);
					break;
				case 1:
					this.dispatch(ModuleCommand.HERO_FB_ROLE_DEAD);
					break;
				case 2: //同归于尽
					Shake.shakeScene(10, 0.6);
					LoopManager.setTimeout(toRelive, 3000, [3]);
					break;
			}
			////////////清空快捷栏里面的宠物群攻技能
			var items:Array=NavigationModule.getInstance().getItems();
			for (var i:int=0; i < items.length; i++) {
				if (items[i].type == 1) { //type==1表示那个栏里面放的是技能
					var sk:SkillVO=SkillDataManager.getSkill(items[i].id);
					if (sk.category == PetDataManager.petTroopIn || sk.category == PetDataManager.petTroopOut) {
						NavigationModule.getInstance().clearItemAt(i);
					}
				}
			}
		}

		private function showReliveView(vo:m_role2_dead_toc):void {
			if (reliveView == null) {
				reliveView=new ReliveView;
				reliveView.setup(toRelive, vo.relive_silver);
			} else {
				reliveView.cost=vo.relive_silver;
			}
			LayerManager.alertLayer.addChild(reliveView);
			WindowManager.getInstance().centerWindow(reliveView);
			reliveView.startTime();
			BroadcastSelf.getInstance().appendMsg("你被[" + vo.killer + "]击败");
			this.dispatch(ModuleCommand.ROLE_DEAD_ALIVE, false);
		}

		private function toRelive(type:int):void {
			var vo:m_role2_relive_tos=new m_role2_relive_tos;
			vo.type=type;
			sendSocketMessage(vo);
		}


		/**
		 * 别人死了
		 * @param vo
		 *
		 */
		public function onDeadOther(vo:m_role2_dead_other_toc):void {
			var role:Role=SceneUnitManager.getUnit(vo.roleid) as Role;
			if (role != null) {
				role.die();
				if (role.parent != null) {
					role.parent.removeChild(role);
					_view.midLayer.addChild(role);
				}
			}
		}

		/**
		 * 玩家属性改变
		 * @param vo
		 *
		 */
		public function onAttrReload(vo:m_role2_attr_reload_toc):void {
			var user:p_role=GlobalObjectManager.getInstance().user;
			user.attr=vo.role_attr;
			if (hero != null) {
				hero.attrChange(vo.role_attr);
			}
		}

		/**
		 * 自己或别人复活
		 * @param vo
		 *
		 */
		public function onRelive(vo:m_role2_relive_toc):void {
			if (vo && vo.succ) {
				var scene:GameScene=GameScene.getInstance();
				var effect:Effect=Effect.getEffect();

				///////////自己复活了//////////////
				if (vo.return_self == true) {
					GlobalObjectManager.getInstance().user.base=vo.role_base;
					GlobalObjectManager.getInstance().user.fight=vo.role_fight;
					GlobalObjectManager.getInstance().user.pos=vo.role_pos;
					this.dispatch(ModuleCommand.ROLE_DEAD_ALIVE, true);
					if (vo.map_changed == true) {
						//后台会发change_map_toc过来
					} else {
						GameScene.getInstance().removeUnit(vo.role_base.role_id);
						var myRole:MyRole=UnitPool.getMyRole();//new MyRole;
						myRole.reset(vo.map_role);
						scene.addUnit(myRole, vo.role_pos.pos.tx, vo.role_pos.pos.ty);
						scene.centerCamera(myRole.x, myRole.y);
						effect.show(GameConfig.EFFECT_SCENE + "intoEffect.swf", myRole.x, myRole.y, scene.lowEffLayer);
						this.dispatch(ModuleCommand.I_AM_RELIVE);
							//						RobKingSceneCase.doRobKingColor(myRole, myRoleVo);
					}
					if (reliveView != null) {
						reliveView.remove();
						if (reliveView.succReLiveCost != null) {
							this.dispatch(ModuleCommand.BROADCAST_SELF, "成功原地复活，扣除银子" + reliveView.succReLiveCost);
							reliveView.succReLiveCost=null;
						}
					}
				} else { /////////////别人复活了，所以的图上的人不一定是通过map_enter进来的/////////////
					if (vo.map_role.role_id == GlobalObjectManager.getInstance().user.base.role_id) {
						return; //广播的时候return_self是等于false的，但是自己也会收到
					}
					scene.removeUnit(vo.map_role.role_id);
					var role:Role=UnitPool.getRole();
					role.reset(vo.map_role);
					scene.addUnit(role, vo.map_role.pos.tx, vo.map_role.pos.ty, vo.map_role.pos.dir);
				}
			}
		}

		/**
		 * 升级
		 * @param vo
		 *
		 */
		public function onLevelup(vo:m_role2_levelup_toc):void {
			if (vo.level == 10 || vo.level == 20 || vo.level == 30) {
				if (SkillTreeModule.getInstance().skillPanel) {
					SkillTreeModule.getInstance().skillPanel.createNav();
				}
			}
			this.dispatch(GuideConstant.LEVEL_UP);
			var eImage:Effect=new Effect();
			eImage.show(GameConfig.OTHER_PATH + 'shengji_guang.swf', 0, 0, _view.hero, 5, 0, false, 10000);
			var eText:Effect=new Effect();
			var p:Point=GameScene.getInstance().midLayer.localToGlobal(new Point(_view.hero.x, _view.hero.y));
			eText.show(GameConfig.OTHER_PATH + 'shengji_wenzi.swf', p.x - 4, p.y - 160, LayerManager.alertLayer.parent, 6, 0, false, 10000);
//			var elizi:Effect=new Effect();
//			elizi.show(GameConfig.OTHER_PATH + 'shengji_lizi.swf', p.x - 4, p.y - 150, LayerManager.main, 5, 20, false, 10000);
//			//通知角色模块
		}

		/**
		 * 别人升级
		 * @param vo
		 *
		 */
		public function onLevelupOther(vo:m_role2_levelup_other_toc):void {
			var role:MutualAvatar=SceneUnitManager.getUnit(vo.roleid) as MutualAvatar;
			if (role != null) {
				var eImage:Effect=new Effect();
				eImage.show(GameConfig.OTHER_PATH + 'shengji_guang.swf', 0, 0, role, 4);
				var eText:Effect=new Effect();
				eText.show(GameConfig.OTHER_PATH + 'shengji_wenzi.swf', 0, -160, role, 4, 10);
//				var elizi:Effect=new Effect();
//				elizi.show(GameConfig.OTHER_PATH + 'shengji_lizi.swf', 0, -150, role, 4, 10);
			}
		}

		/**
		 * 打坐
		 * @param vo
		 *
		 */
		public function onZazen(vo:m_role2_zazen_toc):void {
			if (vo.succ) {
				if (vo.return_self == true) {
					vo.roleid=GlobalObjectManager.getInstance().user.base.role_id;
					GlobalObjectManager.getInstance().user.base.status=vo.status == true ? RoleActState.ZAZEN : RoleActState.NORMAL;
				}
				var role:Animal=SceneUnitManager.getUnit(vo.roleid) as Animal;
				if (role != null) {
					role.sitDown(vo.status);
					if (vo.status == false) {
						if (role.curState == RoleActState.ZAZEN) {
							role.curState=RoleActState.NORMAL;
						}
					} else if (vo.status == true) {
						if (role.curState == RoleActState.NORMAL) {
							role.curState=RoleActState.ZAZEN;
						}
					}
				}
			} else {
				this.dispatch(ModuleCommand.BROADCAST, vo.reason);
			}
		}

		/**
		 * 在线挂机：开始
		 * @param vo
		 *
		 */
		public function onRoleOnHookBegin(vo:m_role2_on_hook_begin_toc):void {
			if (vo.succ) {
				if (vo.return_self) {
					if (hero) {
						GlobalObjectManager.getInstance().user.base.status=RoleActState.ON_HOOK;
						hero.curState=RoleActState.ON_HOOK;
						hero.doHook(true);
						//怎么显示坐下和光环
						this.dispatch(ModuleCommand.BROADCAST_SELF, "<font color='#FF0000'>进入挂机状态，按D可结束，每15秒获得1次经验</font>");
						if (this.onHookBar == null) {
							this.onHookBar=new CommonProgressBar("打坐挂机中 ", 2);
							this.onHookBar.initView();
							this.onHookBar.addEventListener(MouseEvent.CLICK, onHookMouseClick);
						}
						LayerManager.uiLayer.addChild(this.onHookBar);
						this.onHookBar.update(7200);
						var p:Point=new Point(SceneUnitManager.getSelf().x, SceneUnitManager.getSelf().y);
						p=GameScene.getInstance().midLayer.localToGlobal(p);
						this.onHookBar.x=p.x - 83;
						this.onHookBar.y=p.y - 184;

					}
				} else {
					//其它人接收到的通知某个玩家开始在线挂机状态
					var role:Role=SceneUnitManager.getUnit(vo.role_id) as Role;
					if (role != null) {
						role.doHook(true);
					}
				}
			} else {
				this.dispatch(ModuleCommand.TIPS, vo.reason);
			}
		}

		/**
		 * 点击在线挂机进度条处理
		 * @param event
		 *
		 */
		private function onHookMouseClick(event:MouseEvent):void {
			var vo:m_role2_on_hook_status_tos=new m_role2_on_hook_status_tos;
			sendSocketMessage(vo);
		}

		/**
		 * 在线挂机：结束
		 * @param vo
		 *
		 */
		public function onRoleOnHookEnd(vo:m_role2_on_hook_end_toc):void {
			if (vo.succ) {
				if (vo.return_self) {
					GlobalObjectManager.getInstance().user.base.status=RoleActState.NORMAL;
					if (hero) {
						hero.doHook(false);
						if (vo.sum_exp >= 0) {
							this.dispatch(ModuleCommand.BROADCAST, "本次在线挂机共获得经验 " + vo.sum_exp);
						} else {
							this.dispatch(ModuleCommand.BROADCAST, "你取消在线挂机");
						}
						if (this.onHookBar && this.onHookBar.parent) {
							this.onHookBar.parent.removeChild(this.onHookBar);
						}
					}
					if (isGotoTraining) {
						isGotoTraining=false;
						var npcId:int=10000136 + GlobalObjectManager.getInstance().user.base.faction_id * 1000000 + 100000;
						if (NPCDataManager.getInstance().getNpcInfo(npcId) != null) {
							PathUtil.findNpcAndOpen(npcId);
						}
					}
						//取消坐下和光环
				} else {
					//其它人接收到的通知某个玩家取消在线挂机状态
					var role:Role=SceneUnitManager.getUnit(vo.role_id) as Role;
					if (role != null) {
						role.doHook(false);
					}
				}
			} else {
				this.dispatch(ModuleCommand.BROADCAST, vo.reason);
			}
		}

		/**
		 * 在线挂机：获取玩家在线挂机状态
		 * @param vo
		 *
		 */
		private var cancelOnHookAlertKey:String=null;

		public function onRoleOnHookStatus(vo:m_role2_on_hook_status_toc):void {
			isGotoTraining=false;
			if (vo.succ && !Alert.isPopUp(cancelOnHookAlertKey)) {
				var cancelStr:String="本次挂机活动经验 " + vo.sun_exp + "，要结束挂机吗？\n（前往<a href=\"event:gotoTraining\"><u><font color='#3BE450'>京城-张三丰</font></u></a>处可进行离线挂机）";
				cancelOnHookAlertKey=Alert.show(cancelStr, "在线挂机", cancelOnHook, null, "确定", "取消", null, true, false, null, gotoOnHook);
			} else {
				this.dispatch(ModuleCommand.BROADCAST, vo.reason);
			}
		}
		/**
		 * 在线打坐取消时,可以点击NPC连接寻路
		 */
		private var isGotoTraining:Boolean;

		private function gotoOnHook(evt:TextEvent):void {
			if (Alert.isPopUp(this.cancelOnHookAlertKey)) {
				Alert.removeAlert(this.cancelOnHookAlertKey);
			}
			isGotoTraining=true;
			cancelOnHook();
		}

		/**
		 * 取消在线挂机
		 */
		private function cancelOnHook():void {
			var vo:m_role2_on_hook_end_tos=new m_role2_on_hook_end_tos;
			sendSocketMessage(vo);
		}


		public function onAttrChange(vo:m_role2_attr_change_toc):void {
			//			var tar:Role=_view.getUnit(vo.) as Monster;
			//			var pvo:p_map_monster=tar.pvo;
			//			pvo.hp=vo.value;
			//			updateSeleteRole(pvo, true);
		}

		public function onChangePKTip(vo:m_role2_event_toc):void {
			if (vo.succ) {
				if (vo.event_id == 1) {
					GlobalObjectManager.getInstance().user.ext.ever_leave_xsc=true;
				}
			} else {
				Alert.show(vo.reason);
			}
		}

		/**
		 * 是否变灰名
		 * @param vo
		 *
		 */
		public function onGrayName(vo:m_role2_gray_name_toc):void {
			var role:IRole=SceneUnitManager.getUnit(vo.roleid) as IRole;
			if (role != null) {
				role.pvo.gray_name=vo.if_gray_name;
				role.doNameJob();
			}
			if (vo.roleid == GlobalObjectManager.getInstance().user.base.role_id) {
				GlobalObjectManager.getInstance().user.base.if_gray_name=vo.if_gray_name;
			}
		}

		public function onShowCloth(vo:m_role2_show_cloth_toc):void {
			if (vo.succ == true) {
				GlobalObjectManager.getInstance().user.attr.show_cloth=vo.show_cloth;
				if (GameScene.getInstance().hero != null) {
					var str:String=_view.hero.pvo.show_cloth ? "显示" : "隐藏";
					this.dispatch(ModuleCommand.BROADCAST_SELF, str + "服装配置保存成功");
				}
			} else {
				this.dispatch(ModuleCommand.BROADCAST, vo.reason);
			}
		}

		public function onShowEquipRing(vo:m_role2_show_equip_ring_toc):void {
			if (vo.succ == true) {
				GlobalObjectManager.getInstance().user.attr.show_equip_ring=vo.show_equip_ring;
				if (hero != null) {
					var str:String=hero.pvo.show_equip_ring ? "隐藏" : "显示";
					this.dispatch(ModuleCommand.BROADCAST_SELF, str + "装备特效配置保存成功");
				}
			} else {
				this.dispatch(ModuleCommand.BROADCAST, vo.reason);
			}
		}

		public function onCurrentTitle(vo:m_title_change_cur_title_toc):void {
			if (vo.succ) {
				var arr:Array=RoleStateDateManager.myTitles;
				if (hero) {
					for each (var p:p_title in arr) {
						if (p.id == vo.id) {
							GlobalObjectManager.getInstance().user.base.cur_title=p.name;
							hero.pvo.cur_title=p.name;
							hero.doNameJob();
							break;
						}
					}
				}
			}
		}

		public function onChangeAttr(vo:m_role2_attr_change_toc):void {
		}

		/**
		 * 移除变身道具
		 */
		public function onRemoveSkinBuff(vo:m_role2_remove_skin_buff_toc):void {
			if (vo.succ) {
				//成功
			} else {
				this.dispatch(ModuleCommand.TIPS, vo.reason);
			}
		}

		/**
		 * 系统BUFF
		 */
		public function onSystemBuff(vo:m_role2_system_buff_toc):void {
			GlobalObjectManager.getInstance().system_buff=vo.sys_buff;
			RoleStateModule.getInstance().mediator.updateMine();
		}

		private function trainingStart():void {

		}

		private function trainingUpdate(percent:Number):void {

		}

		private function trainingEnd():void {

		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.TRAINING_START, trainingStart);
			addMessageListener(ModuleCommand.TRAINING_PROGRESS, trainingUpdate);
			addMessageListener(ModuleCommand.TRAINING_END, trainingEnd);

			/////////////////
			addSocketListener(SocketCommand.ROLE2_DEAD, onDead); //主角死亡
			addSocketListener(SocketCommand.ROLE2_DEAD_OTHER, onDeadOther); //其他玩家死亡
			addSocketListener(SocketCommand.ROLE2_RELIVE, onRelive); //复活
			addSocketListener(SocketCommand.ROLE2_LEVELUP, onLevelup); //自己升级
			addSocketListener(SocketCommand.ROLE2_LEVELUP_OTHER, onLevelupOther); //别人升级
			addSocketListener(SocketCommand.ROLE2_ZAZEN, onZazen); //打坐
			addSocketListener(SocketCommand.ROLE2_ATTR_RELOAD, onAttrReload); //自己数据改变
			addSocketListener(SocketCommand.ROLE2_GRAY_NAME, onGrayName); //灰名
			addSocketListener(SocketCommand.ROLE2_SHOW_CLOTH, onShowCloth); //显示服装
			addSocketListener(SocketCommand.ROLE2_SHOW_EQUIP_RING, onShowEquipRing); //
			addSocketListener(SocketCommand.ROLE2_REMOVE_SKIN_BUFF, onRemoveSkinBuff); //
			addSocketListener(SocketCommand.ROLE2_SYSTEM_BUFF, onSystemBuff); //
			addSocketListener(SocketCommand.ROLE2_EVENT, onChangePKTip); //PK模式改变
			addSocketListener(SocketCommand.ROLE2_ON_HOOK_BEGIN, onRoleOnHookBegin); //
			addSocketListener(SocketCommand.ROLE2_ON_HOOK_END, onRoleOnHookEnd); //
			addSocketListener(SocketCommand.ROLE2_ON_HOOK_STATUS, onRoleOnHookStatus); //
			addSocketListener(SocketCommand.TITLE_CHANGE_CUR_TITLE, onCurrentTitle); //更新称号
			
			this.addMessageListener(ModuleCommand.STAGE_RESIZE,onStageResize);
		}
		private function onStageResize(obj:Object):void{
			//场景高宽变化处理
			if(this.onHookBar != null){
				var p:Point=new Point(SceneUnitManager.getSelf().x, SceneUnitManager.getSelf().y);
				p=GameScene.getInstance().midLayer.localToGlobal(p);
				this.onHookBar.x=p.x - 83;
				this.onHookBar.y=p.y - 184;
			}
		}
	}
}